//! Shared HTTP dispatch/serialization. Runtime owns scheduling and sockets.
const std = @import("std");
const app_mod = @import("../app.zig");
const res_mod = @import("response.zig");
const session_mod = @import("session.zig");
pub const Outcome = enum { keep_alive, close, upgraded };

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
    response.keep_alive = request.keep_alive and session.request_count +| 1 < opts.max_requests_per_connection;
    if (request.header("upgrade") != null) {
        const tail = session.input.items[parsed.consumed..];
        const buffered = transport.bufferedInput();
        response.upgrade_input = if (buffered.len == 0) tail else try std.mem.concat(arena, u8, &.{ tail, buffered });
    }
    const writer = transport.writer();
    response.socket_writer = writer;
    app.dispatchWithPeer(arena, &request, &response, transport.streamPtr(), transport.ioPtr(), try transport.peerIp(arena)) catch |err| {
        if (response.streaming != null or response.fixed_streaming != null) {
            response.endStream() catch {};
            writer.flush() catch {};
            return .close;
        }
        return err;
    };
    if (response.is_upgrade) return .upgraded;
    if (response.streaming != null or response.fixed_streaming != null) {
        response.endStream() catch return .close;
        writer.flush() catch return .close;
        return .close;
    }
    if (app.shutdown_flag.load(.acquire) or session.request_count +| 1 >= opts.max_requests_per_connection) response.keep_alive = false;
    response.writeTo(writer) catch return .close;
    writer.flush() catch return .close;
    return if (response.keep_alive) .keep_alive else .close;
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
