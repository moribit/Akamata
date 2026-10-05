//! Shared HTTP dispatch/serialization. Runtime owns scheduling and sockets.
const std = @import("std");
const app_mod = @import("../app.zig");
const res_mod = @import("response.zig");
const session_mod = @import("session.zig");
pub const Outcome = enum { keep_alive, close, upgraded, incremental, prepared };

pub fn run(comptime State: type, app: *app_mod.App(State), transport: anytype, opts: *const app_mod.ServeOptions) !void {
    var owns_stream = true;
    defer if (owns_stream) transport.close();
    var session = try session_mod.Session.init(app.gpa, opts);
    defer session.deinit();
    while (!app.shutdown_flag.load(.acquire)) switch (try session.next(opts)) {
        .input => |need| {
            var vec = [_][]u8{try session.writable(need.maximum)};
            const n = try transport.read(&vec, need.timeout_ms, need.shutdown_if_idle);
            session.received(n);
        },
        .issue => |issue| {
            transport.beginResponse(opts.write_timeout_ms);
            try writeProtocolError(session.arena.allocator(), transport, issue.code, issue.kind);
            return;
        },
        .request => |parsed| switch (try dispatchOne(State, app, &session, parsed, transport, opts)) {
            .close => return,
            .upgraded => {
                owns_stream = false;
                return;
            },
            .incremental, .prepared => unreachable,
            .keep_alive => {
                transport.endResponse();
                session.finish(parsed.consumed);
            },
        },
    };
}

pub fn dispatchOne(comptime State: type, app: *app_mod.App(State), session: *session_mod.Session, parsed: session_mod.Parsed, transport: anytype, opts: *const app_mod.ServeOptions) !Outcome {
    transport.beginResponse(opts.write_timeout_ms);
    const arena = session.arena.allocator();
    var request = parsed.request;
    var response: res_mod.Response = .init(arena);
    response.native_control = transport.controlPtr();
    response.native_write_timeout_ms = opts.write_timeout_ms;
    if (comptime @hasDecl(@TypeOf(transport.*), "deferSession")) response.synchronous_application_io = false;
    response.keep_alive = request.keep_alive and session.request_count +| 1 < opts.max_requests_per_connection;
    if (request.header("upgrade") != null) {
        const tail = session.input.items[parsed.consumed..];
        const buffered = transport.bufferedInput();
        response.upgrade_input = if (buffered.len == 0) tail else try std.mem.concat(arena, u8, &.{ tail, buffered });
    }
    const writer = transport.writer();
    response.socket_writer = writer;
    app.dispatchWithPeer(arena, &request, &response, transport.streamPtr(), transport.ioPtr(), try transport.peerIp(arena)) catch |err| {
        if (response.application_session) |definition| {
            _ = definition.callback(definition.state, .{ .closed = .application_error }, &.{}) catch {};
            response.application_session = null;
        }
        if (response.streaming != null or response.fixed_streaming != null) {
            response.endStream() catch {};
            writer.flush() catch {};
            return .close;
        }
        return err;
    };
    if (response.application_session) |definition| {
        if (response.application_session_error) {
            _ = definition.callback(definition.state, .{ .closed = .application_error }, &.{}) catch {};
            response.application_session = null;
        } else if (comptime @hasDecl(@TypeOf(transport.*), "deferSession")) {
            try transport.deferSession(&response, definition);
            return .incremental;
        } else {
            try runApplicationSession(transport, &response, definition, app.gpa, opts, &app.shutdown_flag);
            return .close;
        }
    }
    if (response.is_upgrade) return .upgraded;
    if (response.streaming != null or response.fixed_streaming != null) {
        response.endStream() catch return .close;
        writer.flush() catch return .close;
        return .close;
    }
    if (app.shutdown_flag.load(.acquire) or session.request_count +| 1 >= opts.max_requests_per_connection) response.keep_alive = false;
    if (comptime @hasDecl(@TypeOf(transport.*), "deferResponse")) {
        try transport.deferResponse(&response);
        return .prepared;
    }
    response.writeTo(writer) catch return .close;
    writer.flush() catch return .close;
    return if (response.keep_alive) .keep_alive else .close;
}

pub fn prepareApplicationSession(session: *@import("application_session.zig").Session, response: *res_mod.Response) !void {
    if (response.body.items.len != 0) return error.InvalidSessionResponse;
    var writer: std.Io.Writer = .fixed(&session.wire);
    switch (session.definition.mode) {
        .websocket => try response.writeTo(&writer),
        .stream => |stream| try response.writeStreamPrelude(&writer, .{ .content_length = stream.content_length, .content_type = stream.content_type }),
    }
    session.wire_len = writer.end;
    // HEAD commits headers only and never runs an application producer.
    if (response.suppress_body) session.next = .done;
}

fn runApplicationSession(transport: anytype, response: *res_mod.Response, definition: @import("application_session.zig").Definition, gpa: std.mem.Allocator, opts: *const app_mod.ServeOptions, shutdown: *std.atomic.Value(bool)) !void {
    const tasks = @import("application_session.zig");
    const clock = @import("../observability/clock.zig");
    var session = tasks.Session.init(gpa, definition, response.upgrade_input) catch |err| {
        _ = definition.callback(definition.state, .{ .closed = .application_error }, &.{}) catch {};
        return err;
    };
    defer session.deinit();
    var reason: tasks.CloseReason = .completed;
    defer session.dispose(if (reason == .completed) session.closing_reason else reason);
    errdefer reason = if (shutdown.load(.acquire)) .shutdown else .disconnected;
    try prepareApplicationSession(&session, response);
    if (definition.mode == .websocket) transport.consumeBufferedInput();
    while (true) {
        if (session.wire_len != 0) {
            if (definition.mode == .websocket) transport.beginResponse(opts.write_timeout_ms);
            const writer = transport.writer();
            try writer.writeAll(session.wire[0..session.wire_len]);
            try writer.flush();
            session.wire_len = 0;
            if (definition.mode == .websocket) transport.endResponse();
        }
        // Registry forced-drain shuts down the socket. A finite producer may
        // finish within grace; idle/read sessions stop immediately on shutdown.
        if (session.next == .done) return;
        if (!session.started) {
            session.started = true;
            try session.step(.{ .opened = session.control() }, clock.monotonicNs());
            continue;
        }
        if (session.external_wake.swap(false, .acq_rel)) {
            try session.step(.produce, clock.monotonicNs());
            continue;
        }
        if (session.next == .wait) {
            if (shutdown.load(.acquire)) {
                reason = .shutdown;
                return;
            }
            const io: *std.Io = @ptrCast(@alignCast(transport.ioPtr()));
            try std.Io.sleep(io.*, .fromMilliseconds(10), .awake);
            continue;
        }
        if (session.next == .after_ms) {
            const now = clock.monotonicNs();
            if (now < session.wake_ns) {
                const io: *std.Io = @ptrCast(@alignCast(transport.ioPtr()));
                try std.Io.sleep(io.*, .fromNanoseconds(@intCast(@min(session.wake_ns - now, 100 * std.time.ns_per_ms))), .awake);
                continue;
            }
        }
        if (session.next == .input) {
            if (session.read_deadline_ns == 0) session.read_deadline_ns = clock.monotonicNs() +| @as(u64, definition.mode.websocket.read_timeout_ms) * std.time.ns_per_ms;
            if (try session.consumeInput()) |event| {
                try session.step(event, clock.monotonicNs());
                continue;
            }
            if (session.wire_len != 0) continue;
            if (session.protocol_yielded) continue;
            const now = clock.monotonicNs();
            if (session.read_deadline_ns == 0) session.read_deadline_ns = now +| @as(u64, definition.mode.websocket.read_timeout_ms) * std.time.ns_per_ms;
            if (now >= session.read_deadline_ns) return error.Timeout;
            const remaining_ms: u32 = @intCast(@min(std.math.maxInt(u32), (session.read_deadline_ns - now + std.time.ns_per_ms - 1) / std.time.ns_per_ms));
            var vec = [_][]u8{try session.receiveBuffer()};
            const n = transport.read(&vec, @min(remaining_ms, 100), true) catch |err| {
                if (err == error.Timeout) continue;
                return err;
            };
            session.received(n);
            continue;
        }
        try session.step(.produce, clock.monotonicNs());
    }
}

pub fn writeProtocolError(arena: std.mem.Allocator, transport: anytype, code: u16, kind: []const u8) !void {
    var response: res_mod.Response = .init(arena);
    response.setStatus(code);
    response.keep_alive = false;
    try response.json(.{ .error_kind = kind });
    const writer = transport.writer();
    try response.writeTo(writer);
    try writer.flush();
}
