// Private socket Contract fixture; deliberately not exported by akamata.zig.
const std = @import("std");
const am = @import("akamata.zig");
const State = struct {};
const Ctx = am.Context(State);

test {
    _ = @import("runtime/io_group_experiment.zig");
    _ = @import("runtime/deadline_heap.zig");
    _ = @import("runtime/reactor_notifications.zig");
    _ = @import("runtime/reactor.zig");
}

pub fn main(init: std.process.Init) !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var arena: std.heap.ArenaAllocator = .init(alloc);
    defer arena.deinit();
    const args = try init.minimal.args.toSlice(arena.allocator());
    if (args.len != 4) return error.InvalidArguments;
    const adapter = args[1];
    const profile = args[3];
    var app = am.App(State).init(alloc, .{});
    defer app.deinit();
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
    var opts: am.ServeOptions = .{
        .address = "127.0.0.1",
        .port = try std.fmt.parseInt(u16, args[2], 10),
        .accept_thread_count = 2,
        .parse_limits = .{ .max_request_bytes = 256, .max_headers = 8, .max_body_bytes = 64 },
        .header_read_timeout_ms = 250,
        .body_read_timeout_ms = 400,
        .total_request_timeout_ms = 500,
        .keep_alive_idle_timeout_ms = 180,
        .max_requests_per_connection = 3,
        .max_connections = 8,
    };
    if (std.mem.eql(u8, profile, "total")) {
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
    const w = try c.startStream(.{ .content_type = "text/plain" });
    try w.writeAll("one");
    try w.flush();
    try w.writeAll("two");
    try w.flush();
}
fn streamError(c: *Ctx) !void {
    const w = try c.startStream(.{});
    try w.writeAll("partial");
    try w.flush();
    return error.ExpectedStreamFailure;
}
fn fixed(c: *Ctx) !void {
    const w = try c.startStream(.{ .content_length = 5 });
    try w.writeAll("hello");
    try w.flush();
}
fn fixedShort(c: *Ctx) !void {
    const w = try c.startStream(.{ .content_length = 5 });
    try w.writeAll("he");
    try w.flush();
}
fn upgrade(c: *Ctx) !void {
    var conn = try am.ws.upgrade(Ctx, c, .{ .read_timeout_ms = 500 });
    defer conn.deinit();
    try conn.sendText("upgraded");
}
fn upgradeEcho(c: *Ctx) !void {
    var conn = try am.ws.upgrade(Ctx, c, .{ .read_timeout_ms = 500 });
    defer conn.deinit();
    const message = try conn.readMessage(c.arena);
    try conn.sendText(message.payload);
}
fn upgradeWait(c: *Ctx) !void {
    var conn = try am.ws.upgrade(Ctx, c, .{ .read_timeout_ms = 5000 });
    defer conn.deinit();
    _ = conn.readMessage(c.arena) catch return;
}
fn upgradeLarge(c: *Ctx) !void {
    var conn = try am.ws.upgrade(Ctx, c, .{});
    defer conn.deinit();
    const bytes: [16384]u8 = @splat('x');
    for (0..4096) |_| try conn.sendBinary(&bytes);
}
fn slow(c: *Ctx) !void {
    const io: *std.Io = @ptrCast(@alignCast(c.io_ptr.?));
    const w = try c.startStream(.{ .content_length = 9 });
    try std.Io.sleep(io.*, .fromMilliseconds(300), .awake);
    try w.writeAll("completed");
    try w.flush();
}
fn pausedStream(c: *Ctx) !void {
    const io: *std.Io = @ptrCast(@alignCast(c.io_ptr.?));
    const w = try c.startStream(.{ .content_length = 9 });
    try std.Io.sleep(io.*, .fromMilliseconds(1000), .awake);
    try w.writeAll("completed");
    try w.flush();
}
fn large(c: *Ctx) !void {
    const w = try c.startStream(.{ .content_length = 16 * 1024 * 1024 });
    const bytes: [16384]u8 = @splat('x');
    for (0..1024) |_| try w.writeAll(&bytes);
    try w.flush();
}
