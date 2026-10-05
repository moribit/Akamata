//! Private multiplexed evaluation. Shared Session and dispatch own HTTP semantics.
const std = @import("std");
const app_mod = @import("../app.zig");
const http = @import("../http/connection.zig");
const sessions = @import("../http/session.zig");
const readiness = @import("reactor_selector.zig");
const sync = @import("../sync.zig");
const clock = @import("../observability/clock.zig");
const drain = @import("drain.zig");
const net = std.Io.net;

pub fn evaluate(comptime State: type, app: *app_mod.App(State), opts: app_mod.ServeOptions) !void {
    if (@sizeOf(usize) != 8) return error.UnsupportedPlatform;
    if (opts.max_connections == 0 or opts.max_connections > std.math.maxInt(u32) - 2) return error.InvalidConnectionLimit;
    app.trust_proxy_headers = opts.trust_proxy_headers;
    app.trusted_proxy_fn = opts.trusted_proxy_fn;
    try app.prepare();
    var io_impl: std.Io.Threaded = .init(app.gpa, .{});
    defer io_impl.deinit();
    const io = io_impl.io();
    var address = try net.IpAddress.parseIp4(opts.address orelse "0.0.0.0", opts.port);
    var listener = try address.listen(io, .{ .reuse_address = true });
    defer {
        app.listener_fd.store(-1, .seq_cst);
        listener.deinit(io);
    }
    try readiness.nonblocking(listener.socket.handle);
    app.listener_fd.store(listener.socket.handle, .seq_cst);
    var signals = @import("threaded.zig").installSignalHandlers(State, app);
    defer signals.deinit();
    var ctx = try Context(State).init(app, io, &opts, listener.socket.handle);
    defer ctx.deinit();
    try ctx.startWorkers();
    std.log.info("experimental multiplexed reactor listening on port {d}", .{opts.port});
    try ctx.run();
}

fn Context(comptime State: type) type {
    return struct {
        const Self = @This();
        const Output = @import("reactor_output.zig").Output(Self);
        const Phase = enum { reading, working, closing };
        const Connection = struct {
            owner: *Self,
            token: u64,
            slot: usize,
            stream: net.Stream,
            node: drain.Node,
            session: sessions.Session,
            output: Output,
            writer_buffer: [4096]u8 = undefined,
            interests: readiness.Interests = .{},
            phase: Phase = .reading,
            need: ?sessions.Need = null,
            job: sessions.Event = undefined,
            next_job: ?*Connection = null,
            busy: bool = false,
            done: std.atomic.Value(bool) = .init(false),
            outcome: http.Outcome = .close,
            consumed: usize = 0,
        };
        const Slot = struct { connection: ?*Connection = null, generation: u32 = 0 };
        const Transport = struct {
            connection: *Connection,
            pub fn beginResponse(t: *@This(), timeout: u32) void {
                t.connection.node.clearWriteDeadline();
                t.connection.node.synchronous_output.store(false, .release);
                t.connection.output.timeout_ms = timeout;
                t.connection.output.interface.end = 0;
            }
            pub fn endResponse(t: *@This()) void {
                t.connection.node.clearWriteDeadline();
            }
            pub fn writer(t: *@This()) *std.Io.Writer {
                return &t.connection.output.interface;
            }
            pub fn bufferedInput(_: *@This()) []const u8 {
                return "";
            }
            pub fn controlPtr(t: *@This()) *drain.Node {
                return &t.connection.node;
            }
            pub fn streamPtr(t: *@This()) *net.Stream {
                return &t.connection.stream;
            }
            pub fn ioPtr(t: *@This()) *std.Io {
                return &t.connection.owner.io;
            }
            pub fn peerIp(t: *@This(), arena: std.mem.Allocator) ![]const u8 {
                return @import("socket_transport.zig").formatPeerIp(arena, t.connection.stream.socket.address);
            }
        };
        app: *app_mod.App(State),
        io: std.Io,
        opts: *const app_mod.ServeOptions,
        listener: c_int,
        selector: readiness.Selector,
        listener_interests: readiness.Interests = .{},
        wake: [2]c_int,
        notifications: @import("reactor_notifications.zig").Queue,
        timers: @import("deadline_heap.zig").Heap,
        slots: []Slot,
        free_slots: []usize,
        free_len: usize,
        count: usize = 0,
        registry: drain.Registry,
        workers: std.ArrayList(std.Thread) = .empty,
        jobs_mutex: sync.Mutex,
        jobs_changed: sync.Condition,
        jobs_head: ?*Connection = null,
        jobs_tail: ?*Connection = null,
        stop_workers: bool = false,
        stopping: bool = false,
        forced: bool = false,
        drain_deadline: u64 = 0,
        accept_resume: u64 = 0,
        accept_backoff_ms: u32 = 0,
        fn init(app: *app_mod.App(State), io: std.Io, opts: *const app_mod.ServeOptions, listener: c_int) !Self {
            const gpa = app.gpa;
            var selector = try readiness.Selector.init();
            errdefer selector.deinit();
            var wake: [2]c_int = undefined;
            if (std.c.pipe(&wake) < 0) return error.WakeupInitFailed;
            errdefer {
                _ = std.c.close(wake[0]);
                _ = std.c.close(wake[1]);
            }
            try readiness.nonblocking(wake[0]);
            try readiness.nonblocking(wake[1]);
            var interests: readiness.Interests = .{};
            try selector.set(wake[0], 1, .{ .read = true }, &interests);
            const slots = try gpa.alloc(Slot, opts.max_connections);
            errdefer gpa.free(slots);
            @memset(slots, .{});
            const free = try gpa.alloc(usize, slots.len);
            errdefer gpa.free(free);
            for (free, 0..) |*slot, i| slot.* = i;
            var timers = try @import("deadline_heap.zig").Heap.init(gpa, slots.len);
            errdefer timers.deinit(gpa);
            var notifications = try @import("reactor_notifications.zig").Queue.init(gpa, slots.len);
            errdefer notifications.deinit(gpa);
            return .{ .app = app, .io = io, .opts = opts, .listener = listener, .selector = selector, .wake = wake, .notifications = notifications, .timers = timers, .slots = slots, .free_slots = free, .free_len = free.len, .registry = .{ .mutex = .init() }, .jobs_mutex = .init(), .jobs_changed = .init() };
        }
        fn deinit(self: *Self) void {
            self.registry.force();
            for (self.slots) |slot| if (slot.connection) |c| c.output.abort();
            self.jobs_mutex.lock();
            self.stop_workers = true;
            self.jobs_changed.broadcast();
            self.jobs_mutex.unlock();
            for (self.workers.items) |worker| worker.join();
            for (self.slots) |slot| if (slot.connection) |c| self.destroy(c);
            self.workers.deinit(self.app.gpa);
            self.jobs_changed.deinit();
            self.jobs_mutex.deinit();
            self.registry.mutex.deinit();
            self.notifications.deinit(self.app.gpa);
            self.timers.deinit(self.app.gpa);
            self.app.gpa.free(self.slots);
            self.app.gpa.free(self.free_slots);
            _ = std.c.close(self.wake[0]);
            _ = std.c.close(self.wake[1]);
            self.selector.deinit();
        }
        fn startWorkers(self: *Self) !void {
            const count = @max(1, self.opts.worker_count orelse (std.Thread.getCpuCount() catch 2));
            try self.workers.ensureTotalCapacity(self.app.gpa, count);
            for (0..count) |_| self.workers.appendAssumeCapacity(try std.Thread.spawn(.{}, workerMain, .{self}));
        }
        fn workerMain(self: *Self) void {
            while (true) {
                self.jobs_mutex.lock();
                while (self.jobs_head == null and !self.stop_workers) self.jobs_changed.wait(&self.jobs_mutex);
                const c = self.jobs_head orelse {
                    self.jobs_mutex.unlock();
                    return;
                };
                self.jobs_head = c.next_job;
                if (self.jobs_head == null) self.jobs_tail = null;
                self.jobs_mutex.unlock();
                var transport: Transport = .{ .connection = c };
                c.outcome = .close;
                if (!c.output.status().failed and !c.node.isClosed()) switch (c.job) {
                    .request => |parsed| c.outcome = http.dispatchOne(State, self.app, &c.session, parsed, &transport, self.opts) catch .close,
                    .issue => |issue| {
                        transport.beginResponse(self.opts.write_timeout_ms);
                        http.writeProtocolError(c.session.arena.allocator(), &transport, issue.code, issue.kind) catch {};
                    },
                    .input => unreachable,
                };
                // Publication relinquishes every borrowed connection pointer.
                const token = c.token;
                c.done.store(true, .release);
                self.notify(token);
            }
        }
        pub fn notify(self: *Self, token: u64) void {
            self.notifications.push(token);
            const byte = [_]u8{1};
            _ = std.c.write(self.wake[1], &byte, 1);
        }
        fn lookup(self: *Self, token: u64) ?*Connection {
            const low: u32 = @truncate(token);
            if (low < 2 or low - 2 >= self.slots.len) return null;
            const slot = &self.slots[low - 2];
            if (slot.generation != token >> 32) return null;
            return slot.connection;
        }
        fn interest(self: *Self, c: *Connection, next: readiness.Interests) !void {
            // Serialize descriptor checks with upgrade-owner close; an fd may
            // otherwise be recycled between isClosed and selector modification.
            self.registry.mutex.lock();
            defer self.registry.mutex.unlock();
            if (c.node.isClosed()) {
                c.interests = .{};
                return;
            }
            try self.selector.set(c.stream.socket.handle, c.token, next, &c.interests);
        }
        fn destroy(self: *Self, c: *Connection) void {
            self.timers.remove(c.slot);
            self.interest(c, .{}) catch {};
            c.node.detach();
            c.output.deinit();
            c.session.deinit();
            self.slots[c.slot].connection = null;
            self.free_slots[self.free_len] = c.slot;
            self.free_len += 1;
            self.count -= 1;
            self.app.gpa.destroy(c);
        }
        fn fail(self: *Self, c: *Connection) void {
            self.interest(c, .{}) catch {};
            self.timers.remove(c.slot);
            c.phase = .closing;
            c.output.abort();
            c.node.shutdown();
            if (!c.busy) self.destroy(c);
        }
        fn drive(self: *Self, c: *Connection) !void {
            if (self.stopping) {
                self.fail(c);
                return;
            }
            const event = try c.session.next(self.opts);
            switch (event) {
                .input => |need| {
                    c.need = need;
                    c.phase = .reading;
                    try self.interest(c, .{ .read = true });
                    self.timers.set(c.slot, need.deadline_ns);
                },
                else => {
                    try self.interest(c, .{});
                    c.job = event;
                    c.need = null;
                    c.phase = .working;
                    c.busy = true;
                    c.done.store(false, .release);
                    c.consumed = if (event == .request) event.request.consumed else 0;
                    self.timers.remove(c.slot);
                    self.jobs_mutex.lock();
                    c.next_job = null;
                    if (self.jobs_tail) |tail| tail.next_job = c else self.jobs_head = c;
                    self.jobs_tail = c;
                    self.jobs_changed.signal();
                    self.jobs_mutex.unlock();
                },
            }
        }
        fn refresh(self: *Self, c: *Connection) void {
            const status = c.output.status();
            if (c.busy and c.done.load(.acquire) and (!status.pending or status.failed)) {
                c.busy = false;
                if (c.phase != .closing and !status.failed and !c.node.isClosed() and c.outcome == .keep_alive and !self.stopping) {
                    c.node.clearWriteDeadline();
                    c.session.finish(c.consumed);
                    self.drive(c) catch self.fail(c);
                    return;
                }
                self.fail(c);
                return;
            }
            if (c.phase == .closing) return;
            if (status.failed or c.node.isClosed()) {
                self.fail(c);
                return;
            }
            self.interest(c, .{ .read = c.phase == .reading, .write = status.pending }) catch {
                self.fail(c);
                return;
            };
            const write = c.node.write_deadline_ns.load(.acquire);
            const read = if (c.need) |need| need.deadline_ns else 0;
            self.timers.set(c.slot, if (write == 0) read else if (read == 0) write else @min(read, write));
        }
        fn readReady(self: *Self, c: *Connection) void {
            const token = c.token;
            var total: usize = 0;
            while (c.phase == .reading and total < 64 * 1024) {
                const need = c.need orelse return;
                const buffer = c.session.writable(need.maximum) catch {
                    self.fail(c);
                    return;
                };
                const n = std.c.recv(c.stream.socket.handle, buffer.ptr, buffer.len, std.c.MSG.DONTWAIT);
                if (n < 0) switch (std.posix.errno(n)) {
                    .AGAIN, .INTR => return,
                    else => {
                        self.fail(c);
                        return;
                    },
                };
                if (n == 0) {
                    self.fail(c);
                    return;
                }
                c.session.received(@intCast(n));
                total += @intCast(n);
                self.drive(c) catch {
                    self.fail(c);
                    return;
                };
                if (self.lookup(token) == null) return;
            }
        }
        fn admit(self: *Self, stream: net.Stream) !void {
            errdefer stream.close(self.io);
            try readiness.nonblocking(stream.socket.handle);
            @import("threaded.zig").applyTcpNoDelay(stream) catch {};
            const c = try self.app.gpa.create(Connection);
            errdefer self.app.gpa.destroy(c);
            const slot_index = self.free_slots[self.free_len - 1];
            const slot = &self.slots[slot_index];
            slot.generation +%= 1;
            if (slot.generation == 0) slot.generation = 1;
            const token = (@as(u64, slot.generation) << 32) | @as(u64, slot_index + 2);
            c.* = .{ .owner = self, .token = token, .slot = slot_index, .stream = stream, .node = undefined, .session = try sessions.Session.init(self.app.gpa, self.opts), .output = undefined };
            c.output = Output.init(self, token, &c.node, &c.writer_buffer);
            self.registry.attach(&c.node, stream.socket.handle);
            self.free_len -= 1;
            slot.connection = c;
            self.count += 1;
            // Ownership is committed. A driver failure is cleaned internally.
            self.drive(c) catch self.fail(c);
        }
        fn acceptReady(self: *Self) void {
            for (0..64) |_| {
                if (self.app.shutdown_flag.load(.acquire)) return;
                const accepted = @import("threaded.zig").rawAccept(self.listener);
                if (accepted.fd < 0) {
                    switch (std.posix.errno(accepted.fd)) {
                        .AGAIN, .INTR, .CONNABORTED => return,
                        else => {},
                    }
                    self.accept_backoff_ms = @min(5000, @max(1, self.accept_backoff_ms *| 2));
                    self.accept_resume = clock.monotonicNs() +| @as(u64, self.accept_backoff_ms) * std.time.ns_per_ms;
                    self.selector.set(self.listener, 0, .{}, &self.listener_interests) catch {};
                    return;
                }
                self.accept_backoff_ms = 0;
                const stream: net.Stream = .{ .socket = .{ .handle = accepted.fd, .address = accepted.address } };
                if (self.count >= self.opts.max_connections) {
                    stream.close(self.io);
                    continue;
                }
                self.admit(stream) catch {};
            }
        }
        fn run(self: *Self) !void {
            try self.selector.set(self.listener, 0, .{ .read = true }, &self.listener_interests);
            var events: [128]readiness.Event = undefined;
            while (true) {
                const now = clock.monotonicNs();
                if (!self.stopping and self.app.shutdown_flag.load(.acquire)) {
                    self.stopping = true;
                    try self.selector.set(self.listener, 0, .{}, &self.listener_interests);
                    const started = self.app.shutdown_started_ns.load(.acquire);
                    self.drain_deadline = (if (started == 0) now else started) +| @as(u64, self.opts.shutdown_drain_timeout_ms) * std.time.ns_per_ms;
                    for (self.slots) |slot| if (slot.connection) |c| if (c.need) |need| {
                        if (need.shutdown_if_idle) self.fail(c);
                    };
                }
                if (self.stopping and !self.forced and now >= self.drain_deadline) {
                    self.forced = true;
                    self.registry.force();
                    for (self.slots) |slot| if (slot.connection) |c| self.fail(c);
                }
                while (self.notifications.pop()) |token| if (self.lookup(token)) |c| self.refresh(c);
                if (self.notifications.takeOverflow()) for (self.slots) |slot| {
                    if (slot.connection) |c| self.refresh(c);
                };
                while (self.timers.top()) |timer| {
                    if (timer.deadline > now) break;
                    self.timers.remove(timer.slot);
                    if (self.slots[timer.slot].connection) |c| {
                        const write = c.node.write_deadline_ns.load(.acquire);
                        if ((write != 0 and write <= now) or (c.need != null and c.need.?.deadline_ns <= now)) self.fail(c) else self.refresh(c);
                    }
                }
                if (self.stopping and self.count == 0) return;
                if (!self.stopping and self.accept_resume != 0 and now >= self.accept_resume) {
                    self.accept_resume = 0;
                    try self.selector.set(self.listener, 0, .{ .read = true }, &self.listener_interests);
                }
                var deadline = now +| 100 * std.time.ns_per_ms;
                if (self.timers.top()) |timer| deadline = @min(deadline, timer.deadline);
                if (self.stopping and !self.forced) deadline = @min(deadline, self.drain_deadline);
                if (self.accept_resume != 0) deadline = @min(deadline, self.accept_resume);
                const wait_ms: u32 = @intCast((deadline -| now + std.time.ns_per_ms - 1) / std.time.ns_per_ms);
                const count = try self.selector.wait(&events, wait_ms);
                for (events[0..count]) |event| {
                    if (event.token == 0) {
                        if (!self.stopping) self.acceptReady();
                        continue;
                    }
                    if (event.token == 1) {
                        var bytes: [256]u8 = undefined;
                        while (std.c.read(self.wake[0], &bytes, bytes.len) > 0) {}
                        continue;
                    }
                    const c = self.lookup(event.token) orelse continue;
                    if (event.write) {
                        self.registry.mutex.lock();
                        const sent = if (c.node.isClosed()) error.ConnectionWriteFailed else c.output.pump(c.stream.socket.handle);
                        self.registry.mutex.unlock();
                        sent catch {
                            self.fail(c);
                            continue;
                        };
                        self.refresh(c);
                    }
                    // refresh may free/reuse a slot; revalidate the generation.
                    const current = self.lookup(event.token) orelse continue;
                    if (event.read and current.phase == .reading) self.readReady(current) else if (event.failed) self.fail(current);
                }
            }
        }
    };
}

fn allocationFailureSetup(gpa: std.mem.Allocator) !void {
    const State = struct {};
    var app = app_mod.App(State).init(gpa, .{});
    defer app.deinit();
    const opts: app_mod.ServeOptions = .{ .max_connections = 8 };
    var ctx = try Context(State).init(&app, std.testing.io, &opts, -1);
    defer ctx.deinit();
}
test "reactor setup rolls back every allocation failure" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, allocationFailureSetup, .{});
}
