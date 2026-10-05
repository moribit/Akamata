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
const cost = @import("cost.zig");
const tasks = @import("../http/application_session.zig");

pub fn evaluate(comptime State: type, app: *app_mod.App(State), opts: app_mod.ServeOptions) !void {
    defer cost.report();
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
        const Phase = enum { reading, working, application, closing };
        const Job = union(enum) { http: sessions.Event, step: tasks.Event, dispose: tasks.CloseReason };
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
            job: Job = undefined,
            execution: ?*tasks.Session = null,
            response_cursor: ?@import("../http/response_cursor.zig").Cursor = null,
            response_keep_alive: bool = false,
            // Event-loop-owned snapshot: a producer worker may mutate Session,
            // but an in-progress input budget remains independently cancellable.
            application_read_deadline_ns: u64 = 0,
            task_failed: bool = false,
            close_reason: tasks.CloseReason = .disconnected,
            busy: bool = false,
            done: std.atomic.Value(bool) = .init(false),
            outcome: http.Outcome = .close,
            consumed: usize = 0,
            measured: if (cost.enabled) struct { queued: u64 = 0, completed: u64 = 0 } else struct {} = .{},
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
            pub fn deferSession(t: *@This(), response: anytype, definition: tasks.Definition) !void {
                const c = t.connection;
                errdefer _ = definition.callback(definition.state, .{ .closed = .application_error }, &.{}) catch {};
                // A long-lived ~16 KiB session in the request arena forces a
                // geometrically grown chunk retained for every idle upgrade.
                // Separate exact-size ownership preserves application state in
                // the arena while avoiding that measured unused arena capacity.
                const execution = try c.owner.app.gpa.create(tasks.Session);
                errdefer c.owner.app.gpa.destroy(execution);
                execution.* = try tasks.Session.init(c.owner.app.gpa, definition, response.upgrade_input);
                errdefer execution.deinit();
                try http.prepareApplicationSession(execution, response);
                execution.resumer = .{ .pending = &execution.external_wake, .context = c.owner, .token = c.token, .notify = struct {
                    fn notify(ptr: *anyopaque, token: u64) void {
                        const owner: *Self = @ptrCast(@alignCast(ptr));
                        owner.notify(token);
                    }
                }.notify };
                c.execution = execution;
                if (comptime cost.enabled) {
                    if (!c.owner.memory_reported.swap(true, .monotonic)) {
                        std.debug.print("RUNTIME_MEMORY {{\"connection_size\":{d},\"http_session_size\":{d},\"output_size\":{d},\"writer_buffer\":{d},\"http_input_capacity\":{d},\"arena_capacity\":{d},\"application_session_size\":{d},\"slot_size\":{d},\"fixed_queue_capacity\":{d}}}\n", .{ @sizeOf(Connection), @sizeOf(sessions.Session), @sizeOf(Output), c.writer_buffer.len, c.session.input.capacity, c.session.arena.queryCapacity(), @sizeOf(tasks.Session), @sizeOf(Slot), c.owner.slots.len });
                    }
                }
            }
            pub fn deferResponse(t: *@This(), response: anytype) !void {
                t.connection.response_cursor = try @import("../http/response_cursor.zig").Cursor.init(response);
                t.connection.response_keep_alive = response.keep_alive;
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
        jobs: @import("application_admission.zig").Queue(*Connection),
        // Cancellation owns at most one entry per live connection and cannot
        // be rejected by an already-full ordinary application admission queue.
        cleanup_jobs: @import("application_admission.zig").Queue(*Connection),
        stop_workers: bool = false,
        stopping: bool = false,
        forced: bool = false,
        drain_deadline: u64 = 0,
        accept_resume: u64 = 0,
        accept_backoff_ms: u32 = 0,
        memory_reported: std.atomic.Value(bool) = .init(false),
        fn init(app: *app_mod.App(State), io: std.Io, opts: *const app_mod.ServeOptions, listener: c_int) !Self {
            const gpa = app.gpa;
            const task_limit = opts.max_pending_application_tasks orelse opts.max_connections;
            if (task_limit == 0 or task_limit > opts.max_connections) return error.InvalidApplicationTaskLimit;
            var jobs = try @import("application_admission.zig").Queue(*Connection).init(gpa, task_limit);
            errdefer jobs.deinit(gpa);
            var cleanup_jobs = try @import("application_admission.zig").Queue(*Connection).init(gpa, opts.max_connections);
            errdefer cleanup_jobs.deinit(gpa);
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
            return .{ .app = app, .io = io, .opts = opts, .listener = listener, .selector = selector, .wake = wake, .notifications = notifications, .timers = timers, .slots = slots, .free_slots = free, .free_len = free.len, .registry = .{ .mutex = .init() }, .jobs = jobs, .cleanup_jobs = cleanup_jobs, .jobs_mutex = .init(), .jobs_changed = .init() };
        }
        fn deinit(self: *Self) void {
            self.registry.force();
            for (self.slots) |slot| if (slot.connection) |c| c.output.abort();
            self.jobs_mutex.lock();
            self.stop_workers = true;
            self.jobs_changed.broadcast();
            self.jobs_mutex.unlock();
            for (self.workers.items) |worker| worker.join();
            // Setup/unit evaluation may not have started any workers. Abort
            // above revokes their I/O; queued borrows are now unowned.
            while (self.jobs.pop()) |_| {}
            while (self.cleanup_jobs.pop()) |_| {}
            self.jobs.deinit(self.app.gpa);
            self.cleanup_jobs.deinit(self.app.gpa);
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
                const lock_cost = cost.begin();
                self.jobs_mutex.lock();
                lock_cost.end(.worker_lock);
                while (self.jobs.len == 0 and self.cleanup_jobs.len == 0 and !self.stop_workers) {
                    const wait_cost = cost.begin();
                    self.jobs_changed.wait(&self.jobs_mutex);
                    wait_cost.end(.worker_wait);
                }
                const c = self.cleanup_jobs.pop() orelse self.jobs.pop() orelse {
                    self.jobs_mutex.unlock();
                    return;
                };
                self.jobs_mutex.unlock();
                if (comptime cost.enabled) cost.elapsed(.queue_wait, c.measured.queued);
                const work_cost = cost.begin();
                var transport: Transport = .{ .connection = c };
                if (c.job == .dispose) {
                    c.execution.?.dispose(c.job.dispose);
                } else if (c.job == .step) {
                    if (!c.output.status().failed and !c.node.isClosed()) c.execution.?.step(c.job.step, clock.monotonicNs()) catch {
                        c.task_failed = true;
                    };
                } else {
                    c.outcome = .close;
                    if (!c.output.status().failed and !c.node.isClosed()) switch (c.job.http) {
                        .request => |parsed| c.outcome = http.dispatchOne(State, self.app, &c.session, parsed, &transport, self.opts) catch .close,
                        .issue => |issue| {
                            transport.beginResponse(self.opts.write_timeout_ms);
                            http.writeProtocolError(c.session.arena.allocator(), &transport, issue.code, issue.kind) catch {};
                        },
                        .input => unreachable,
                    };
                }
                // Publication relinquishes every borrowed connection pointer.
                work_cost.end(.worker_work);
                const publish_cost = cost.begin();
                if (comptime cost.enabled) c.measured.completed = cost.now();
                const token = c.token;
                c.done.store(true, .release);
                self.notify(token);
                publish_cost.end(.completion_publish);
            }
        }
        pub fn notify(self: *Self, token: u64) void {
            cost.add(.notify, 1);
            if (!self.notifications.push(token)) return;
            cost.add(.wake_write, 1);
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
            if (c.execution) |execution| {
                // Fatal runtime teardown happens after worker join, outside an
                // active event loop. Ordinary lifecycle uses a cleanup task.
                execution.dispose(if (self.stopping) .shutdown else .disconnected);
                execution.deinit();
                self.app.gpa.destroy(execution);
            }
            c.session.deinit();
            self.slots[c.slot].connection = null;
            self.free_slots[self.free_len] = c.slot;
            self.free_len += 1;
            self.count -= 1;
            self.app.gpa.destroy(c);
        }
        fn fail(self: *Self, c: *Connection) void {
            const now = clock.monotonicNs();
            const deadline = applicationDeadline(c, 0);
            self.failReason(c, if (self.stopping) .shutdown else if (deadline != 0 and now >= deadline) .timeout else .disconnected);
        }
        fn failReason(self: *Self, c: *Connection, reason: tasks.CloseReason) void {
            if (c.phase != .closing) c.close_reason = reason;
            self.interest(c, .{}) catch {};
            self.timers.remove(c.slot);
            c.phase = .closing;
            c.output.abort();
            c.node.shutdown();
            // Completion may have been observed while the last output slot
            // was still pending. A later write failure must reclaim it even
            // when no further worker notification will arrive.
            if (c.busy and c.done.load(.acquire)) c.busy = false;
            if (!c.busy) {
                if (c.execution) |execution| if (!execution.disposed) {
                    c.job = .{ .dispose = c.close_reason };
                    c.busy = true;
                    c.done.store(false, .release);
                    self.jobs_mutex.lock();
                    if (comptime cost.enabled) c.measured.queued = cost.now();
                    std.debug.assert(self.cleanup_jobs.push(c));
                    self.jobs_changed.signal();
                    self.jobs_mutex.unlock();
                    return;
                };
                self.destroy(c);
            }
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
                    c.job = .{ .http = event };
                    c.need = null;
                    c.phase = .working;
                    c.busy = true;
                    c.done.store(false, .release);
                    c.consumed = if (event == .request) event.request.consumed else 0;
                    self.timers.remove(c.slot);
                    const enqueue_cost = cost.begin();
                    if (comptime cost.enabled) c.measured.queued = cost.now();
                    self.jobs_mutex.lock();
                    if (!self.jobs.push(c)) {
                        self.jobs_mutex.unlock();
                        // No worker owns the rejected borrow. fail() must not
                        // wait for a completion which can never be published.
                        c.busy = false;
                        self.fail(c);
                        return;
                    }
                    self.jobs_changed.signal();
                    self.jobs_mutex.unlock();
                    enqueue_cost.end(.enqueue);
                },
            }
        }
        fn refresh(self: *Self, c: *Connection) void {
            // Observe publication once. A worker can complete during refresh;
            // reloading done in a later branch could route a newly published
            // incremental session through the ordinary HTTP close path.
            const completed = c.busy and c.done.load(.acquire);
            if (comptime cost.enabled) {
                if (completed) cost.elapsed(.completion_wait, c.measured.completed);
            }
            const status = c.output.status();
            // A worker may publish a new session pointer. Never read it before
            // acquire-observing that job's completion (including overflow scan).
            if (completed and (c.execution != null or c.response_cursor != null)) c.busy = false;
            if (!c.busy and c.response_cursor != null) {
                if (c.phase == .closing or status.failed or c.node.isClosed()) {
                    self.fail(c);
                    return;
                }
                self.resumeResponse(c) catch self.fail(c);
                return;
            }
            if (!c.busy and c.execution != null) {
                if (c.phase == .closing or status.failed or c.node.isClosed() or c.task_failed) {
                    self.failReason(c, if (c.task_failed) .application_error else if (self.stopping) .shutdown else .disconnected);
                    return;
                }
                c.phase = .application;
                self.resumeApplication(c) catch self.fail(c);
                return;
            }
            if (completed and (!status.pending or status.failed)) {
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
                if (clock.monotonicNs() >= need.deadline_ns) {
                    self.fail(c);
                    return;
                }
                const buffer = c.session.writable(need.maximum) catch {
                    self.fail(c);
                    return;
                };
                const read_cost = cost.begin();
                cost.add(.recv_call, 1);
                const n = std.c.recv(c.stream.socket.handle, buffer.ptr, buffer.len, std.c.MSG.DONTWAIT);
                read_cost.end(.read);
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
        fn resumeResponse(self: *Self, c: *Connection) !void {
            // Profiling: ordinary small responses previously paid writable
            // ADD/DELETE and a selector round trip even with an empty socket
            // send buffer. Attempt bounded nonblocking progress immediately;
            // retain the exact pending offset/readiness/deadline on EAGAIN.
            for (0..4) |_| {
                if (c.output.status().pending) break;
                const n = c.response_cursor.?.fill(&c.writer_buffer);
                if (n != 0) {
                    try c.output.offer(c.writer_buffer[0..n]);
                    self.registry.mutex.lock();
                    const sent = if (c.node.isClosed()) error.ConnectionWriteFailed else c.output.pump(c.stream.socket.handle);
                    self.registry.mutex.unlock();
                    try sent;
                } else {
                    c.response_cursor = null;
                    if (c.response_keep_alive and !self.stopping) {
                        c.node.clearWriteDeadline();
                        c.session.finish(c.consumed);
                        try self.drive(c);
                    } else self.failReason(c, .completed);
                    return;
                }
            }
            const pending = c.output.status().pending;
            try self.interest(c, .{ .write = pending });
            self.timers.set(c.slot, c.node.write_deadline_ns.load(.acquire));
            // More cursor data after this turn's 16 KiB fairness quantum.
            if (!pending) self.notify(c.token);
        }
        fn scheduleStep(self: *Self, c: *Connection, event: tasks.Event) void {
            c.application_read_deadline_ns = c.execution.?.read_deadline_ns;
            c.job = .{ .step = event };
            c.task_failed = false;
            c.busy = true;
            c.done.store(false, .release);
            if (comptime cost.enabled) c.measured.queued = cost.now();
            self.jobs_mutex.lock();
            const admitted = self.jobs.push(c);
            if (admitted) self.jobs_changed.signal();
            self.jobs_mutex.unlock();
            if (!admitted) {
                c.busy = false;
                self.failReason(c, .application_error);
                return;
            }
            self.interest(c, .{}) catch {
                self.fail(c);
                return;
            };
            self.armApplication(c, 0);
        }
        fn applicationDeadline(c: *Connection, other: u64) u64 {
            var deadline = c.node.write_deadline_ns.load(.acquire);
            for ([_]u64{ c.application_read_deadline_ns, other }) |candidate| {
                if (candidate != 0) deadline = if (deadline == 0) candidate else @min(deadline, candidate);
            }
            return deadline;
        }
        fn armApplication(self: *Self, c: *Connection, other: u64) void {
            self.timers.set(c.slot, applicationDeadline(c, other));
        }
        fn resumeApplication(self: *Self, c: *Connection) !void {
            const execution = c.execution.?;
            c.application_read_deadline_ns = execution.read_deadline_ns;
            const ws = execution.definition.mode == .websocket;
            if (self.forced or (self.stopping and (ws or execution.next == .wait))) {
                self.failReason(c, .shutdown);
                return;
            }
            if (!c.output.status().pending and execution.wire_len != 0) {
                if (ws) c.node.clearWriteDeadline();
                try c.output.offer(execution.wire[0..execution.wire_len]);
                execution.wire_len = 0;
            }
            if (c.output.status().pending) {
                try self.interest(c, .{ .write = true });
                self.armApplication(c, 0);
                return;
            }
            if (ws) c.node.clearWriteDeadline();
            if (execution.next == .done) {
                self.failReason(c, execution.closing_reason);
                return;
            }
            if (!execution.started) {
                execution.started = true;
                self.scheduleStep(c, .{ .opened = execution.control() });
                return;
            }
            if (execution.external_wake.swap(false, .acq_rel)) {
                self.scheduleStep(c, .produce);
                return;
            }
            const now = clock.monotonicNs();
            switch (execution.next) {
                .produce => self.scheduleStep(c, .produce),
                .after_ms => {
                    if (now >= execution.wake_ns) {
                        self.scheduleStep(c, .produce);
                    } else {
                        try self.interest(c, .{});
                        self.armApplication(c, execution.wake_ns);
                    }
                },
                .input => {
                    if (execution.read_deadline_ns == 0) execution.read_deadline_ns = now +| @as(u64, execution.definition.mode.websocket.read_timeout_ms) * std.time.ns_per_ms;
                    if (now >= execution.read_deadline_ns) {
                        self.failReason(c, .timeout);
                        return;
                    }
                    const event = try execution.consumeInput();
                    c.application_read_deadline_ns = execution.read_deadline_ns;
                    if (event) |available| {
                        self.scheduleStep(c, available);
                    } else if (execution.wire_len != 0) {
                        try self.resumeApplication(c);
                    } else if (execution.protocol_yielded) {
                        self.notify(c.token);
                        try self.interest(c, .{});
                        self.armApplication(c, 0);
                    } else {
                        if (execution.read_deadline_ns == 0) execution.read_deadline_ns = now +| @as(u64, execution.definition.mode.websocket.read_timeout_ms) * std.time.ns_per_ms;
                        c.application_read_deadline_ns = execution.read_deadline_ns;
                        try self.interest(c, .{ .read = true });
                        self.armApplication(c, 0);
                    }
                },
                .wait => {
                    try self.interest(c, .{});
                    self.armApplication(c, 0);
                },
                .done => unreachable,
            }
        }
        fn readApplication(self: *Self, c: *Connection) void {
            const execution = c.execution.?;
            const buffer = execution.receiveBuffer() catch {
                self.fail(c);
                return;
            };
            if (clock.monotonicNs() >= execution.read_deadline_ns) {
                self.failReason(c, .timeout);
                return;
            }
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
            execution.received(@intCast(n));
            self.resumeApplication(c) catch self.fail(c);
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
            c.output = Output.init(self, token, &c.node, &c.writer_buffer, self.app.gpa);
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
                    std.log.warn("reactor accept failed: {t}", .{std.posix.errno(accepted.fd)});
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
            const measured = cost.begin();
            defer measured.end(.event_loop);
            try self.selector.set(self.listener, 0, .{ .read = true }, &self.listener_interests);
            var events: [128]readiness.Event = undefined;
            while (true) {
                cost.add(.loop, 1);
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
                // A hot session/producer cannot indefinitely extend this turn
                // by pushing notifications while the event loop drains them.
                for (0..128) |_| {
                    const token = self.notifications.pop() orelse break;
                    if (self.lookup(token)) |c| self.refresh(c);
                }
                if (self.notifications.takeOverflow()) for (self.slots) |slot| {
                    if (slot.connection) |c| self.refresh(c);
                };
                while (self.timers.top()) |timer| {
                    if (timer.deadline > now) break;
                    self.timers.remove(timer.slot);
                    if (self.slots[timer.slot].connection) |c| {
                        const write = c.node.write_deadline_ns.load(.acquire);
                        if ((write != 0 and write <= now) or (c.application_read_deadline_ns != 0 and c.application_read_deadline_ns <= now) or (c.need != null and c.need.?.deadline_ns <= now)) self.failReason(c, .timeout) else if (!c.busy and c.execution != null) self.resumeApplication(c) catch self.fail(c) else self.refresh(c);
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
                const wait_ms: u32 = if (self.notifications.pending()) 0 else @intCast((deadline -| now + std.time.ns_per_ms - 1) / std.time.ns_per_ms);
                const count = try self.selector.wait(&events, wait_ms);
                for (events[0..count]) |event| {
                    if (event.token == 0) {
                        if (!self.stopping) self.acceptReady();
                        continue;
                    }
                    if (event.token == 1) {
                        var bytes: [256]u8 = undefined;
                        while (true) {
                            cost.add(.wake_read, 1);
                            if (std.c.read(self.wake[0], &bytes, bytes.len) <= 0) break;
                        }
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
                    if (event.read and current.phase == .reading) self.readReady(current) else if (event.read and current.phase == .application and !current.busy) self.readApplication(current) else if (event.failed) self.fail(current);
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
fn allocationFailureSessionHandoff(gpa: std.mem.Allocator) !void {
    const State = struct {};
    const Callback = struct {
        closed: usize = 0,
        fn step(self: *@This(), event: tasks.Event, _: []u8) !tasks.Action {
            if (event == .closed) self.closed += 1;
            return .{ .next = .done };
        }
    };
    var callback: Callback = .{};
    {
        var app = app_mod.App(State).init(gpa, .{});
        defer app.deinit();
        const opts: app_mod.ServeOptions = .{ .max_connections = 1 };
        var ctx = try Context(State).init(&app, std.testing.io, &opts, -1);
        defer ctx.deinit();
        var sockets: [2]c_int = undefined;
        if (std.c.socketpair(std.c.AF.UNIX, std.c.SOCK.STREAM, 0, &sockets) != 0) return error.SocketPairFailed;
        defer _ = std.c.close(sockets[1]);
        try ctx.admit(.{ .socket = .{ .handle = sockets[0], .address = .{ .ip4 = .{ .bytes = .{ 127, 0, 0, 1 }, .port = 0 } } } });
        const c = ctx.slots[0].connection.?;
        var transport: Context(State).Transport = .{ .connection = c };
        var response = @import("../http/response.zig").Response.init(c.session.arena.allocator());
        try transport.deferSession(&response, tasks.Definition.init(Callback, &callback, Callback.step, .{ .stream = .{} }));
    }
    try std.testing.expectEqual(@as(usize, 1), callback.closed);
}
test "separate application session handoff rolls back every allocation failure" {
    const before = testFdCount();
    try std.testing.checkAllAllocationFailures(std.testing.allocator, allocationFailureSessionHandoff, .{});
    try std.testing.expectEqual(before, testFdCount());
}
test "reactor setup rolls back every allocation failure" {
    const before = testFdCount();
    try std.testing.checkAllAllocationFailures(std.testing.allocator, allocationFailureSetup, .{});
    try std.testing.expectEqual(before, testFdCount());
}
fn testFdCount() usize {
    var count: usize = 0;
    for (0..256) |fd| if (std.c.fcntl(@intCast(fd), std.c.F.GETFD) >= 0) {
        count += 1;
    };
    return count;
}
test "stale generation tokens never resolve a recycled slot" {
    const State = struct {};
    var app = app_mod.App(State).init(std.testing.allocator, .{});
    defer app.deinit();
    const opts: app_mod.ServeOptions = .{ .max_connections = 2 };
    var ctx = try Context(State).init(&app, std.testing.io, &opts, -1);
    defer ctx.deinit();
    var connection: Context(State).Connection = undefined;
    ctx.slots[0] = .{ .generation = 2, .connection = &connection };
    defer ctx.slots[0].connection = null;
    try std.testing.expect(ctx.lookup((@as(u64, 1) << 32) | 2) == null);
    try std.testing.expect(ctx.lookup((@as(u64, 2) << 32) | 2) == &connection);
    try std.testing.expect(ctx.lookup((@as(u64, 2) << 32) | 100) == null);
}

test "failed pending output after worker completion reclaims admission" {
    const State = struct {};
    var app = app_mod.App(State).init(std.testing.allocator, .{});
    defer app.deinit();
    const opts: app_mod.ServeOptions = .{ .max_connections = 1 };
    var ctx = try Context(State).init(&app, std.testing.io, &opts, -1);
    defer ctx.deinit();
    var sockets: [2]c_int = undefined;
    try std.testing.expectEqual(@as(c_int, 0), std.c.socketpair(std.c.AF.UNIX, std.c.SOCK.STREAM, 0, &sockets));
    defer {
        _ = std.c.close(sockets[1]);
    }
    try ctx.admit(.{ .socket = .{ .handle = sockets[0], .address = .{ .ip4 = .{ .bytes = .{ 127, 0, 0, 1 }, .port = 0 } } } });
    const connection = ctx.slots[0].connection.?;
    connection.busy = true;
    connection.phase = .working;
    connection.done.store(true, .release);
    connection.output.len = 1;
    ctx.fail(connection);
    try std.testing.expectEqual(@as(usize, 0), ctx.count);
    try std.testing.expect(ctx.slots[0].connection == null);
}

test "application queue overflow closes only the unowned connection" {
    const State = struct {};
    var app = app_mod.App(State).init(std.testing.allocator, .{});
    defer app.deinit();
    const opts: app_mod.ServeOptions = .{ .max_connections = 2, .max_pending_application_tasks = 1 };
    var ctx = try Context(State).init(&app, std.testing.io, &opts, -1);
    defer ctx.deinit();
    var peers: [2]c_int = undefined;
    for (&peers) |*peer| {
        var sockets: [2]c_int = undefined;
        try std.testing.expectEqual(@as(c_int, 0), std.c.socketpair(std.c.AF.UNIX, std.c.SOCK.STREAM, 0, &sockets));
        peer.* = sockets[1];
        try ctx.admit(.{ .socket = .{ .handle = sockets[0], .address = .{ .ip4 = .{ .bytes = .{ 127, 0, 0, 1 }, .port = 0 } } } });
    }
    defer for (peers) |peer| {
        _ = std.c.close(peer);
    };
    const first = ctx.slots[0].connection.?;
    const second = ctx.slots[1].connection.?;
    const second_token = second.token;
    const request = "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n";
    for ([_]*Context(State).Connection{ first, second }) |connection| {
        const writable = try connection.session.writable(request.len);
        @memcpy(writable[0..request.len], request);
        connection.session.received(request.len);
        try ctx.drive(connection);
    }
    try std.testing.expectEqual(@as(usize, 1), ctx.count);
    try std.testing.expectEqual(@as(usize, 1), ctx.jobs.len);
    try std.testing.expect(first.busy);
    try std.testing.expect(ctx.lookup(second_token) == null);
    try std.testing.expect(ctx.slots[0].connection == first);
    // deinit exercises aborted queued ownership without starting any workers.
}

test "invalid application limits are rejected before opening reactor resources" {
    const State = struct {};
    var app = app_mod.App(State).init(std.testing.allocator, .{});
    defer app.deinit();
    const before = testFdCount();
    for ([_]usize{ 0, 3 }) |limit| {
        const opts: app_mod.ServeOptions = .{ .max_connections = 2, .max_pending_application_tasks = limit };
        try std.testing.expectError(error.InvalidApplicationTaskLimit, Context(State).init(&app, std.testing.io, &opts, -1));
    }
    try std.testing.expectEqual(before, testFdCount());
}

test "session cancellation retains reserved admission when ordinary work is full" {
    const State = struct {};
    const SessionState = struct {
        closed: usize = 0,
        fn step(self: *@This(), event: tasks.Event, _: []u8) !tasks.Action {
            if (event == .closed) self.closed += 1;
            return .{ .next = .wait };
        }
    };
    var state: SessionState = .{};
    var app = app_mod.App(State).init(std.testing.allocator, .{});
    defer app.deinit();
    const opts: app_mod.ServeOptions = .{ .max_connections = 2, .max_pending_application_tasks = 1 };
    var ctx = try Context(State).init(&app, std.testing.io, &opts, -1);
    defer ctx.deinit();
    var peers: [2]c_int = undefined;
    for (&peers) |*peer| {
        var sockets: [2]c_int = undefined;
        try std.testing.expectEqual(@as(c_int, 0), std.c.socketpair(std.c.AF.UNIX, std.c.SOCK.STREAM, 0, &sockets));
        peer.* = sockets[1];
        try ctx.admit(.{ .socket = .{ .handle = sockets[0], .address = .{ .ip4 = .{ .bytes = .{ 127, 0, 0, 1 }, .port = 0 } } } });
    }
    defer for (peers) |peer| {
        _ = std.c.close(peer);
    };
    const ordinary = ctx.slots[0].connection.?;
    const request = "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n";
    const writable = try ordinary.session.writable(request.len);
    @memcpy(writable[0..request.len], request);
    ordinary.session.received(request.len);
    try ctx.drive(ordinary);
    const parked = ctx.slots[1].connection.?;
    const token = parked.token;
    parked.execution = try std.testing.allocator.create(tasks.Session);
    parked.execution.?.* = try tasks.Session.init(std.testing.allocator, tasks.Definition.init(SessionState, &state, SessionState.step, .{ .stream = .{} }), "");
    parked.phase = .application;
    ctx.failReason(parked, .shutdown);
    try std.testing.expectEqual(@as(usize, 1), ctx.jobs.len);
    try std.testing.expectEqual(@as(usize, 1), ctx.cleanup_jobs.len);
    const cleanup = ctx.cleanup_jobs.pop().?;
    try std.testing.expect(cleanup == parked);
    cleanup.execution.?.dispose(cleanup.job.dispose);
    cleanup.done.store(true, .release);
    ctx.refresh(cleanup);
    try std.testing.expect(ctx.lookup(token) == null);
    try std.testing.expectEqual(@as(usize, 1), state.closed);
    try std.testing.expectEqual(@as(usize, 1), ctx.count);
}

test "partial input deadline remains armed while a producer worker owns the session" {
    const State = struct {};
    const SessionState = struct {
        fn step(_: *@This(), _: tasks.Event, _: []u8) !tasks.Action {
            return .{ .next = .input };
        }
    };
    var state: SessionState = .{};
    var app = app_mod.App(State).init(std.testing.allocator, .{});
    defer app.deinit();
    const opts: app_mod.ServeOptions = .{ .max_connections = 1 };
    var ctx = try Context(State).init(&app, std.testing.io, &opts, -1);
    defer ctx.deinit();
    var sockets: [2]c_int = undefined;
    try std.testing.expectEqual(@as(c_int, 0), std.c.socketpair(std.c.AF.UNIX, std.c.SOCK.STREAM, 0, &sockets));
    defer {
        _ = std.c.close(sockets[1]);
    }
    try ctx.admit(.{ .socket = .{ .handle = sockets[0], .address = .{ .ip4 = .{ .bytes = .{ 127, 0, 0, 1 }, .port = 0 } } } });
    const c = ctx.slots[0].connection.?;
    c.execution = try std.testing.allocator.create(tasks.Session);
    c.execution.?.* = try tasks.Session.init(std.testing.allocator, tasks.Definition.init(SessionState, &state, SessionState.step, .{ .websocket = .{} }), "");
    c.execution.?.read_deadline_ns = 10;
    c.node.write_deadline_ns.store(100, .release);
    ctx.scheduleStep(c, .produce);
    try std.testing.expect(c.busy);
    try std.testing.expectEqual(@as(u64, 10), ctx.timers.top().?.deadline);
    // Event-loop timeout bookkeeping uses its own immutable admission snapshot
    // rather than reading worker-mutated session state before publication.
    c.execution.?.read_deadline_ns = 999;
    try std.testing.expectEqual(@as(u64, 10), Context(State).applicationDeadline(c, 50));
    ctx.failReason(c, .timeout);
    try std.testing.expect(c.phase == .closing and c.busy);
}
