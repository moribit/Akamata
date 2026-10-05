// Private socket Contract fixture; deliberately not exported by akamata.zig.
const std = @import("std");
const am = @import("akamata.zig");
const Hub = am.ws.Hub(u64);
const tasks = @import("http/application_session.zig");
const State = struct {
    hub: *Hub,
    sessions: *SessionGroup,
    incremental: bool,
    db: am.db.Db,
    stats: ?*@import("runtime_bench_stats.zig").Stats = null,
    sessions_created: std.atomic.Value(u64) = .init(0),
    sessions_closed: std.atomic.Value(u64) = .init(0),
    mailbox_overflows: std.atomic.Value(u64) = .init(0),
    close_reasons: [5]std.atomic.Value(u64) = .{ .init(0), .init(0), .init(0), .init(0), .init(0) },
    fn recordClosed(self: *State, reason: tasks.CloseReason) void {
        _ = self.close_reasons[@backingInt(reason)].fetchAdd(1, .monotonic);
        _ = self.sessions_closed.fetchAdd(1, .monotonic);
    }
};
const Ctx = am.Context(State);

test {
    _ = @import("runtime/io_group_experiment.zig");
    _ = @import("runtime/deadline_heap.zig");
    _ = @import("runtime/reactor_notifications.zig");
    _ = @import("runtime/reactor.zig");
    _ = @import("runtime/application_admission.zig");
    _ = @import("runtime/reactor_output.zig");
    _ = @import("http/session.zig");
    _ = @import("ws/conn.zig");
    _ = @import("ws/message_state.zig");
    _ = @import("http/response_cursor.zig");
    _ = @import("http/application_session.zig");
}

pub fn main(init: std.process.Init) !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);
    var stats: @import("runtime_bench_stats.zig").Stats = .{ .backing = gpa.allocator() };
    defer stats.report();
    const alloc = stats.allocator();
    var arena: std.heap.ArenaAllocator = .init(alloc);
    defer arena.deinit();
    const args = try init.minimal.args.toSlice(arena.allocator());
    if (args.len != 4) return error.InvalidArguments;
    const adapter = args[1];
    const use_incremental = std.mem.eql(u8, adapter, "kqueue") or std.mem.eql(u8, adapter, "epoll") or std.mem.startsWith(u8, args[3], "incremental-");
    const profile = if (std.mem.startsWith(u8, args[3], "incremental-")) args[3]["incremental-".len..] else args[3];
    var hub = Hub.init(alloc);
    defer hub.deinit();
    if (comptime @import("runtime/cost.zig").enabled) std.debug.print("APPLICATION_MEMORY {{\"upgrade_state_size\":{d},\"mailbox_bytes\":8192,\"group_size\":{d}}}\n", .{ @sizeOf(UpgradeState), @sizeOf(SessionGroup) });
    var group: SessionGroup = .{ .mutex = .init() };
    defer group.mutex.deinit();
    var db = try am.db.openSqlite(alloc, ":memory:");
    defer db.close();
    try db.execAll("CREATE TABLE items(id INTEGER PRIMARY KEY, name TEXT); INSERT INTO items VALUES(1, 'alpha');");
    var app = am.App(State).init(alloc, .{ .hub = &hub, .sessions = &group, .incremental = use_incremental, .db = db, .stats = &stats });
    defer app.deinit();
    defer {
        const created = app.state_value.sessions_created.load(.acquire);
        const closed = app.state_value.sessions_closed.load(.acquire);
        std.debug.print("SESSION_STATS {{\"created\":{d},\"closed\":{d},\"close_reasons\":[{d},{d},{d},{d},{d}]}}\n", .{ created, closed, app.state_value.close_reasons[0].load(.monotonic), app.state_value.close_reasons[1].load(.monotonic), app.state_value.close_reasons[2].load(.monotonic), app.state_value.close_reasons[3].load(.monotonic), app.state_value.close_reasons[4].load(.monotonic) });
        std.debug.assert(created == closed);
    }
    _ = try app.get("/hello", hello);
    _ = try app.post("/echo", echo);
    _ = try app.get("/ip", ip);
    _ = try app.get("/stream", stream);
    _ = try app.get("/stream-error", streamError);
    _ = try app.get("/fixed", fixed);
    _ = try app.get("/fixed-short", fixedShort);
    _ = try app.get("/upgrade", upgrade);
    _ = try app.get("/upgrade-echo", upgradeEcho);
    _ = try app.get("/slow", slow);
    _ = try app.get("/paused-stream", pausedStream);
    _ = try app.get("/large", large);
    _ = try app.get("/upgrade-wait", upgradeWait);
    _ = try app.get("/upgrade-large", upgradeLarge);
    _ = try app.get("/upgrade-room", upgradeRoom);
    _ = try app.get("/sync-stream", syncStream);
    _ = try app.get("/sync-upgrade", syncUpgrade);
    _ = try app.get("/application-hold", applicationHold);
    _ = try app.get("/db/:id", databaseLookup);
    _ = try app.get("/upgrade-live", upgradeLive);
    _ = try app.get("/upgrade-budget", upgradeBudget);
    _ = try app.get("/runtime-stats", runtimeStats);
    var opts: am.ServeOptions = .{
        .address = "127.0.0.1",
        .port = try std.fmt.parseInt(u16, args[2], 10),
        .accept_thread_count = 2,
        .worker_count = 4,
        .parse_limits = .{ .max_request_bytes = 256, .max_headers = 8, .max_body_bytes = 64 },
        .header_read_timeout_ms = 250,
        .body_read_timeout_ms = 400,
        .total_request_timeout_ms = 500,
        .keep_alive_idle_timeout_ms = 180,
        .max_requests_per_connection = 3,
        .max_connections = 8,
    };
    if (std.mem.eql(u8, profile, "certify")) {
        opts.max_connections = 16384;
        opts.max_pending_application_tasks = 16384;
        opts.worker_count = 4;
        opts.parse_limits.max_body_bytes = 1024 * 1024;
        opts.keep_alive_idle_timeout_ms = 60_000;
        opts.body_read_timeout_ms = 5000;
        opts.total_request_timeout_ms = 6000;
        opts.write_timeout_ms = 2000;
        opts.shutdown_drain_timeout_ms = 150;
        opts.max_requests_per_connection = 100_000;
    } else if (std.mem.eql(u8, profile, "stress")) {
        opts.max_connections = 512;
        opts.worker_count = 4;
        opts.max_requests_per_connection = 100;
        opts.parse_limits.max_body_bytes = 1024 * 1024;
        opts.keep_alive_idle_timeout_ms = 5000;
        opts.body_read_timeout_ms = 5000;
        opts.total_request_timeout_ms = 6000;
        opts.write_timeout_ms = 500;
        opts.shutdown_drain_timeout_ms = 150;
    } else if (std.mem.eql(u8, profile, "admission")) {
        opts.worker_count = 1;
        opts.max_pending_application_tasks = 1;
        opts.max_connections = 8;
        opts.header_read_timeout_ms = 5000;
        opts.total_request_timeout_ms = 10000;
        opts.keep_alive_idle_timeout_ms = 5000;
        opts.shutdown_drain_timeout_ms = 150;
    } else if (std.mem.eql(u8, profile, "total")) {
        opts.header_read_timeout_ms = 1500;
        opts.body_read_timeout_ms = 1500;
        opts.total_request_timeout_ms = 300;
    } else if (std.mem.eql(u8, profile, "shutdown")) {
        opts.header_read_timeout_ms = 5000;
        opts.body_read_timeout_ms = 5000;
        opts.total_request_timeout_ms = 10000;
        opts.keep_alive_idle_timeout_ms = 5000;
    } else if (std.mem.eql(u8, profile, "overload")) {
        opts.max_connections = 2;
        opts.header_read_timeout_ms = 2000;
        opts.total_request_timeout_ms = 3000;
        opts.keep_alive_idle_timeout_ms = 2000;
    } else if (std.mem.eql(u8, profile, "write")) {
        opts.write_timeout_ms = 250;
    } else if (std.mem.eql(u8, profile, "write-slot")) {
        opts.write_timeout_ms = 250;
        opts.max_connections = 1;
    } else if (std.mem.eql(u8, profile, "write-zero")) {
        opts.write_timeout_ms = 0;
    } else if (std.mem.eql(u8, profile, "drain")) {
        opts.write_timeout_ms = 5000;
        opts.shutdown_drain_timeout_ms = 150;
        opts.header_read_timeout_ms = 5000;
        opts.body_read_timeout_ms = 5000;
        opts.total_request_timeout_ms = 10000;
    } else if (std.mem.eql(u8, profile, "proxy")) {
        opts.trust_proxy_headers = true;
        opts.trusted_proxy_fn = trusted;
    } else if (std.mem.eql(u8, profile, "untrusted")) {
        opts.trust_proxy_headers = true;
        opts.trusted_proxy_fn = untrusted;
    }
    if (std.mem.eql(u8, adapter, "threaded")) return app.serve(opts);
    if (std.mem.eql(u8, adapter, "group")) return @import("runtime/io_group_experiment.zig").serve(State, &app, opts);
    if (std.mem.eql(u8, adapter, "disabled")) {
        opts.runtime = .reactor;
        if (app.serve(opts)) |_| return error.ReactorUnexpectedlyEnabled else |err| {
            if (err != error.ExperimentalRuntimeDisabled) return err;
        }
        // Direct module entrypoints also fail closed (no hidden unsafe server).
        inline for (.{ @import("runtime/reactor_kqueue.zig"), @import("runtime/reactor_epoll.zig") }) |runtime| {
            if (runtime.serve(State, &app, opts)) |_| return error.ReactorUnexpectedlyEnabled else |err| {
                if (err != error.ExperimentalRuntimeDisabled) return err;
            }
        }
        return;
    }
    if (std.mem.eql(u8, adapter, "kqueue")) {
        if (comptime @import("builtin").os.tag == .macos or @import("builtin").os.tag == .freebsd)
            return @import("runtime/reactor_kqueue.zig").evaluate(State, &app, opts);
        return error.UnsupportedPlatform;
    }
    if (std.mem.eql(u8, adapter, "epoll")) {
        if (comptime @import("builtin").os.tag == .linux)
            return @import("runtime/reactor_epoll.zig").evaluate(State, &app, opts);
        return error.UnsupportedPlatform;
    }
    return error.UnknownAdapter;
}

fn hello(c: *Ctx) !void {
    try c.text("hello");
}
fn echo(c: *Ctx) !void {
    try c.text(c.req.text());
}
fn ip(c: *Ctx) !void {
    try c.text(c.req.ip() orelse "missing");
}
fn trusted(peer: ?[]const u8) bool {
    return peer != null and std.mem.eql(u8, peer.?, "127.0.0.1");
}
fn untrusted(_: ?[]const u8) bool {
    return false;
}
fn stream(c: *Ctx) !void {
    if (c.state().incremental) return newStream(c, .stream);
    const w = try c.startStream(.{ .content_type = "text/plain" });
    try w.writeAll("one");
    try w.flush();
    try w.writeAll("two");
    try w.flush();
}
fn streamError(c: *Ctx) !void {
    if (c.state().incremental) return newStream(c, .stream_error);
    const w = try c.startStream(.{});
    try w.writeAll("partial");
    try w.flush();
    return error.ExpectedStreamFailure;
}
fn fixed(c: *Ctx) !void {
    if (c.state().incremental) return newStream(c, .fixed);
    const w = try c.startStream(.{ .content_length = 5 });
    try w.writeAll("hello");
    try w.flush();
}
fn fixedShort(c: *Ctx) !void {
    if (c.state().incremental) return newStream(c, .fixed_short);
    const w = try c.startStream(.{ .content_length = 5 });
    try w.writeAll("he");
    try w.flush();
}
fn upgrade(c: *Ctx) !void {
    if (c.state().incremental) return newUpgrade(c, .one);
    var conn = try am.ws.upgrade(Ctx, c, .{ .read_timeout_ms = 500 });
    defer conn.deinit();
    try conn.sendText("upgraded");
}
fn upgradeEcho(c: *Ctx) !void {
    if (c.state().incremental) return newUpgrade(c, .echo);
    var conn = try am.ws.upgrade(Ctx, c, .{ .read_timeout_ms = 500 });
    defer conn.deinit();
    const message = try conn.readMessage(c.arena);
    try conn.sendText(message.payload);
}
fn upgradeWait(c: *Ctx) !void {
    if (c.state().incremental) return newUpgrade(c, .wait);
    var conn = try am.ws.upgrade(Ctx, c, .{ .read_timeout_ms = 5000 });
    defer conn.deinit();
    _ = conn.readMessage(c.arena) catch return;
}
fn upgradeRoom(c: *Ctx) !void {
    if (c.state().incremental) return newUpgrade(c, .room);
    var conn = try am.ws.upgrade(Ctx, c, .{ .read_timeout_ms = 5000 });
    defer conn.deinit();
    try c.state().hub.attach(1, &conn);
    defer c.state().hub.detach(1, &conn);
    try conn.sendText("ready");
    while (true) {
        const message = conn.readMessage(c.arena) catch return;
        try c.state().hub.broadcast(1, message.payload);
    }
}
fn upgradeLarge(c: *Ctx) !void {
    if (c.state().incremental) return newUpgrade(c, .large);
    var conn = try am.ws.upgrade(Ctx, c, .{});
    defer conn.deinit();
    const bytes: [16384]u8 = @splat('x');
    for (0..4096) |_| try conn.sendBinary(&bytes);
}
fn slow(c: *Ctx) !void {
    if (c.state().incremental) return newStream(c, .slow);
    const io: *std.Io = @ptrCast(@alignCast(c.io_ptr.?));
    const w = try c.startStream(.{ .content_length = 9 });
    try std.Io.sleep(io.*, .fromMilliseconds(300), .awake);
    try w.writeAll("completed");
    try w.flush();
}
fn pausedStream(c: *Ctx) !void {
    if (c.state().incremental) return newStream(c, .paused);
    const io: *std.Io = @ptrCast(@alignCast(c.io_ptr.?));
    const w = try c.startStream(.{ .content_length = 9 });
    try std.Io.sleep(io.*, .fromMilliseconds(1000), .awake);
    try w.writeAll("completed");
    try w.flush();
}
fn large(c: *Ctx) !void {
    if (c.state().incremental) return newStream(c, .large);
    const w = try c.startStream(.{ .content_length = 16 * 1024 * 1024 });
    const bytes: [16384]u8 = @splat('x');
    for (0..1024) |_| try w.writeAll(&bytes);
    try w.flush();
}

fn syncStream(c: *Ctx) !void {
    const writer = try c.startStream(.{});
    try writer.writeAll("synchronous");
}
fn syncUpgrade(c: *Ctx) !void {
    var conn = try am.ws.upgrade(Ctx, c, .{});
    defer conn.deinit();
}
fn applicationHold(c: *Ctx) !void {
    std.debug.print("APPLICATION_WORK_ENTERED\n", .{});
    const io: *std.Io = @ptrCast(@alignCast(c.io_ptr.?));
    try std.Io.sleep(io.*, .fromMilliseconds(700), .awake);
    try c.text("completed");
}
fn databaseLookup(c: *Ctx) !void {
    var stmt = try c.db().prepare("SELECT id, name FROM items WHERE id = ?");
    defer stmt.deinit();
    try stmt.bindAll(.{try c.req.paramAs(i64, "id")});
    if (try stmt.step() != .row) return c.json(.{ .error_kind = "not_found" }, 404);
    const row = try stmt.readRow(struct { id: i64, name: []const u8 });
    try c.json(.{ .id = row.id, .name = try c.arena.dupe(u8, row.name) }, 200);
}
fn runtimeStats(c: *Ctx) !void {
    const stats = c.state().stats.?;
    try c.json(.{ .live = stats.live.load(.monotonic), .peak = stats.peak.load(.monotonic), .calls = stats.calls.load(.monotonic), .created = c.state().sessions_created.load(.acquire), .closed = c.state().sessions_closed.load(.acquire), .mailbox_overflows = c.state().mailbox_overflows.load(.monotonic), .close_reasons = [5]u64{ c.state().close_reasons[0].load(.monotonic), c.state().close_reasons[1].load(.monotonic), c.state().close_reasons[2].load(.monotonic), c.state().close_reasons[3].load(.monotonic), c.state().close_reasons[4].load(.monotonic) } }, 200);
}
fn upgradeLive(c: *Ctx) !void {
    // Same application callback/session on both transports for certification.
    try newUpgradeWithTimeout(c, .room, 60_000);
}
fn upgradeBudget(c: *Ctx) !void {
    try newUpgradeWithTimeout(c, .room, 400);
}

const StreamState = struct {
    const Kind = enum { stream, stream_error, fixed, fixed_short, slow, paused, large };
    kind: Kind,
    account: *State,
    count: usize = 0,
    fn step(self: *StreamState, event: tasks.Event, out: []u8) !tasks.Action {
        if (event == .closed) {
            self.account.recordClosed(event.closed);
            return .{ .next = .done };
        }
        if (event == .opened and (self.kind == .slow or self.kind == .paused))
            return .{ .next = .{ .after_ms = if (self.kind == .slow) 300 else 1000 } };
        const bytes: []const u8 = switch (self.kind) {
            .stream => if (self.count == 0) "one" else if (self.count == 1) "two" else return .{ .next = .done },
            .stream_error => if (self.count == 0) "partial" else return error.ExpectedStreamFailure,
            .fixed => if (self.count == 0) "hello" else return .{ .next = .done },
            .fixed_short => if (self.count == 0) "he" else return .{ .next = .done },
            .slow, .paused => if (self.count == 0) "completed" else return .{ .next = .done },
            .large => {
                if (self.count == 2048) return .{ .next = .done };
                self.count += 1;
                @memset(out, 'x');
                return .{ .output = .{ .len = out.len } };
            },
        };
        self.count += 1;
        @memcpy(out[0..bytes.len], bytes);
        return .{ .output = .{ .len = bytes.len } };
    }
};
fn newStream(c: *Ctx, kind: StreamState.Kind) !void {
    const state = try c.arena.create(StreamState);
    state.* = .{ .kind = kind, .account = c.state() };
    const length: ?u64 = switch (kind) {
        .fixed, .fixed_short => 5,
        .slow, .paused => 9,
        .large => 16 * 1024 * 1024,
        else => null,
    };
    try c.res.streamSession(tasks.Definition.init(StreamState, state, StreamState.step, .{ .stream = .{ .content_length = length, .content_type = "text/plain" } }));
    _ = c.state().sessions_created.fetchAdd(1, .monotonic);
}

// One bounded mailbox per member. The membership lock joins every sender with
// closed/detach, so no borrowed state/resumer survives arena destruction.
const SessionGroup = struct {
    mutex: @import("sync.zig").Mutex,
    entries: [16384]?*UpgradeState = @splat(null),
    fn attach(self: *SessionGroup, state: *UpgradeState) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        for (&self.entries) |*entry| if (entry.* == null) {
            entry.* = state;
            state.attached = true;
            return;
        };
        return error.SessionGroupFull;
    }
    fn detach(self: *SessionGroup, state: *UpgradeState) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        for (&self.entries) |*entry| if (entry.* == state) {
            entry.* = null;
            state.attached = false;
            return;
        };
    }
    fn broadcast(self: *SessionGroup, bytes: []const u8) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        for (self.entries) |entry| if (entry) |state| {
            if (state.mailbox_len != 0 or bytes.len > state.mailbox.len) {
                if (!state.mailbox_failed) _ = state.account.mailbox_overflows.fetchAdd(1, .monotonic);
                state.mailbox_failed = true;
            } else {
                @memcpy(state.mailbox[0..bytes.len], bytes);
                state.mailbox_len = bytes.len;
            }
            state.resumer.?.wake();
        };
    }
};
const UpgradeState = struct {
    const Kind = enum { one, echo, wait, large, room };
    kind: Kind,
    group: *SessionGroup,
    account: *State,
    count: usize = 0,
    attached: bool = false,
    resumer: ?tasks.Resumer = null,
    mailbox: [8192]u8 = undefined,
    mailbox_len: usize = 0,
    mailbox_failed: bool = false,
    fn step(self: *UpgradeState, event: tasks.Event, out: []u8) !tasks.Action {
        if (event == .closed) {
            if (self.attached) self.group.detach(self);
            self.resumer = null;
            self.account.recordClosed(event.closed);
            return .{ .next = .done };
        }
        if (event == .opened) {
            self.resumer = event.opened;
            if (self.kind == .room) {
                try self.group.attach(self);
                @memcpy(out[0..5], "ready");
                return .{ .output = .{ .len = 5, .opcode = .text, .next = .input } };
            }
            if (self.kind == .one) {
                @memcpy(out[0..8], "upgraded");
                return .{ .output = .{ .len = 8, .opcode = .text, .next = .done } };
            }
            if (self.kind != .large) return .{ .next = .input };
        }
        if (event == .message) {
            if (self.kind == .room) {
                self.group.broadcast(event.message.payload);
                return .{ .next = .input };
            }
            if (self.kind == .wait) return .{ .next = .done };
            if (event.message.payload.len > out.len) return error.MessageTooLarge;
            @memcpy(out[0..event.message.payload.len], event.message.payload);
            return .{ .output = .{ .len = event.message.payload.len, .opcode = .text, .next = .done } };
        }
        if (self.kind == .room) {
            self.group.mutex.lock();
            defer self.group.mutex.unlock();
            if (self.mailbox_failed) return .{ .next = .done };
            if (self.mailbox_len == 0) return .{ .next = .input };
            const n = self.mailbox_len;
            @memcpy(out[0..n], self.mailbox[0..n]);
            self.mailbox_len = 0;
            return .{ .output = .{ .len = n, .opcode = .text, .next = .input } };
        }
        if (self.kind == .large) {
            if (self.count == 8192) return .{ .next = .done };
            self.count += 1;
            @memset(out, 'x');
            return .{ .output = .{ .len = out.len, .opcode = .binary } };
        }
        return .{ .next = .input };
    }
};
fn newUpgrade(c: *Ctx, kind: UpgradeState.Kind) !void {
    return newUpgradeWithTimeout(c, kind, if (kind == .wait or kind == .room) 5000 else 500);
}
fn newUpgradeWithTimeout(c: *Ctx, kind: UpgradeState.Kind, timeout: u32) !void {
    const state = try c.arena.create(UpgradeState);
    state.* = .{ .kind = kind, .group = c.state().sessions, .account = c.state() };
    try am.ws.upgradeSession(Ctx, c, .{ .read_timeout_ms = timeout }, tasks.Definition.init(UpgradeState, state, UpgradeState.step, .{ .websocket = .{} }));
    _ = c.state().sessions_created.fetchAdd(1, .monotonic);
}
