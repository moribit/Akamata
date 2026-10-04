const std = @import("std");
const am = @import("akamata");

const State = struct { counter: std.atomic.Value(u32) = .init(0) };

fn helloHandler(ctx: *am.Context(State)) !void {
    _ = ctx.state().counter.fetchAdd(1, .seq_cst);
    try ctx.json(.{ .greeting = "hello" }, 200);
}

fn echoHandler(ctx: *am.Context(State)) !void {
    try ctx.res.header("content-type", "text/plain; charset=utf-8");
    try ctx.res.writeAll(ctx.req.text());
}

fn streamHandler(ctx: *am.Context(State)) !void {
    const w = try ctx.res.startStream(.{ .content_type = "text/plain; charset=utf-8" });
    try w.writeAll("chunk-one");
    try w.flush();
    try w.writeAll("chunk-two");
    try w.flush();
    try w.writeAll("chunk-three");
    try w.flush();
}

fn initApp(alloc: std.mem.Allocator) !am.App(State) {
    var app = am.App(State).init(alloc, .{});
    errdefer app.deinit();
    _ = try app.get("/hello", helloHandler);
    _ = try app.post("/echo", echoHandler);
    _ = try app.get("/stream", streamHandler);
    return app;
}

test "server roundtrips a GET request" {
    const alloc = std.testing.allocator;

    var io_impl: std.Io.Threaded = .init(alloc, .{});
    defer io_impl.deinit();
    const io = io_impl.io();

    var app = try initApp(alloc);
    defer app.deinit();

    // Bind ephemeral port for the test (use a well-known high port to keep this
    // hermetic on a developer box; if it's in use, the test will fail explicitly).
    const port: u16 = 18180;

    const opts: am.ServeOptions = .{
        .address = "127.0.0.1",
        .port = port,
        .accept_thread_count = 1,
    };

    const t = try std.Thread.spawn(.{}, runServer, .{ &app, opts });
    defer {
        app.requestShutdown();
        t.join();
    }

    std.Io.sleep(io, .fromMilliseconds(80), .awake) catch {};

    // Connect via std.Io.net.IpAddress.connect
    var connect_addr = std.Io.net.IpAddress.parseIp4("127.0.0.1", port) catch unreachable;
    var client_stream = try std.Io.net.IpAddress.connect(&connect_addr, io, .{ .mode = .stream });
    defer client_stream.close(io);

    var w_buf: [1024]u8 = undefined;
    var sw = client_stream.writer(io, &w_buf);
    const w = &sw.interface;
    try w.writeAll("GET /hello HTTP/1.1\r\nhost: localhost\r\nconnection: close\r\n\r\n");
    try w.flush();

    var r_buf: [4096]u8 = undefined;
    var sr = client_stream.reader(io, &r_buf);
    const r = &sr.interface;

    var collected: std.ArrayList(u8) = .empty;
    defer collected.deinit(alloc);
    var tmp: [4096]u8 = undefined;
    while (true) {
        const n = r.readSliceShort(&tmp) catch break;
        if (n == 0) break;
        try collected.appendSlice(alloc, tmp[0..n]);
    }
    const resp = collected.items;

    try std.testing.expect(std.mem.startsWith(u8, resp, "HTTP/1.1 200"));
    try std.testing.expect(std.mem.indexOf(u8, resp, "\"greeting\":\"hello\"") != null);
    try std.testing.expectEqual(@as(u32, 1), app.state().counter.load(.seq_cst));
}

fn runServer(app: *am.App(State), opts: am.ServeOptions) void {
    app.serve(opts) catch {};
}

test "server streams chunked response" {
    const alloc = std.testing.allocator;

    var io_impl: std.Io.Threaded = .init(alloc, .{});
    defer io_impl.deinit();
    const io = io_impl.io();

    var app = try initApp(alloc);
    defer app.deinit();
    const port: u16 = 18181;

    const opts: am.ServeOptions = .{
        .address = "127.0.0.1",
        .port = port,
        .accept_thread_count = 1,
    };

    const t = try std.Thread.spawn(.{}, runServer, .{ &app, opts });
    defer {
        app.requestShutdown();
        t.join();
    }

    std.Io.sleep(io, .fromMilliseconds(80), .awake) catch {};

    var connect_addr = std.Io.net.IpAddress.parseIp4("127.0.0.1", port) catch unreachable;
    var client_stream = try std.Io.net.IpAddress.connect(&connect_addr, io, .{ .mode = .stream });
    defer client_stream.close(io);

    var w_buf: [256]u8 = undefined;
    var sw = client_stream.writer(io, &w_buf);
    try sw.interface.writeAll("GET /stream HTTP/1.1\r\nhost: localhost\r\nconnection: close\r\n\r\n");
    try sw.interface.flush();

    var r_buf: [4096]u8 = undefined;
    var sr = client_stream.reader(io, &r_buf);
    var collected: std.ArrayList(u8) = .empty;
    defer collected.deinit(alloc);
    var tmp: [4096]u8 = undefined;
    while (true) {
        const n = sr.interface.readSliceShort(&tmp) catch break;
        if (n == 0) break;
        try collected.appendSlice(alloc, tmp[0..n]);
    }
    const resp = collected.items;

    try std.testing.expect(std.mem.startsWith(u8, resp, "HTTP/1.1 200"));
    try std.testing.expect(std.mem.indexOf(u8, resp, "transfer-encoding: chunked") != null);
    // 9-byte first chunk = "9\r\nchunk-one\r\n"
    try std.testing.expect(std.mem.indexOf(u8, resp, "9\r\nchunk-one\r\n") != null);
    // Terminator
    try std.testing.expect(std.mem.endsWith(u8, resp, "0\r\n\r\n"));
}

test "slow header times out without starving subsequent connections" {
    const alloc = std.testing.allocator;
    var io_impl: std.Io.Threaded = .init(alloc, .{});
    defer io_impl.deinit();
    const io = io_impl.io();
    var app = try initApp(alloc);
    defer app.deinit();
    const port: u16 = 18182;
    const opts: am.ServeOptions = .{
        .address = "127.0.0.1",
        .port = port,
        .accept_thread_count = 1,
        .header_read_timeout_ms = 100,
        .keep_alive_idle_timeout_ms = 100,
    };
    const t = try std.Thread.spawn(.{}, runServer, .{ &app, opts });
    defer {
        app.requestShutdown();
        t.join();
    }
    std.Io.sleep(io, .fromMilliseconds(80), .awake) catch {};

    var connect_addr = std.Io.net.IpAddress.parseIp4("127.0.0.1", port) catch unreachable;
    var slow = try std.Io.net.IpAddress.connect(&connect_addr, io, .{ .mode = .stream });
    defer slow.close(io);
    var slow_w_buf: [128]u8 = undefined;
    var slow_w = slow.writer(io, &slow_w_buf);
    try slow_w.interface.writeAll("GET /hello HTTP/1.1\r\nHost:");
    try slow_w.interface.flush();
    std.Io.sleep(io, .fromMilliseconds(200), .awake) catch {};

    // A single accept worker remains available because connection handling is
    // detached and bounded; the valid request succeeds after the slow peer.
    var normal = try std.Io.net.IpAddress.connect(&connect_addr, io, .{ .mode = .stream });
    defer normal.close(io);
    var w_buf: [256]u8 = undefined;
    var w = normal.writer(io, &w_buf);
    try w.interface.writeAll("GET /hello HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n");
    try w.interface.flush();
    var r_buf: [1024]u8 = undefined;
    var reader = normal.reader(io, &r_buf);
    var out: [1024]u8 = undefined;
    const n = try reader.interface.readSliceShort(&out);
    try std.testing.expect(std.mem.startsWith(u8, out[0..n], "HTTP/1.1 200"));
}

const NewState = struct {};

fn newHello(c: *am.Context(NewState)) !void {
    try c.text("ok");
}

fn runNewServer(app: *am.App(NewState)) void {
    app.serve(.{ .address = "127.0.0.1", .port = 18183, .accept_thread_count = 1 }) catch {};
}

test "new App server maps malformed framing to HTTP 400" {
    const alloc = std.testing.allocator;
    var app = am.App(NewState).init(alloc, .{});
    defer app.deinit();
    _ = try app.get("/hello", newHello);
    const thread = try std.Thread.spawn(.{}, runNewServer, .{&app});
    defer {
        app.requestShutdown();
        thread.join();
    }

    var io_impl: std.Io.Threaded = .init(alloc, .{});
    defer io_impl.deinit();
    const io = io_impl.io();
    std.Io.sleep(io, .fromMilliseconds(80), .awake) catch {};
    var address = std.Io.net.IpAddress.parseIp4("127.0.0.1", 18183) catch unreachable;
    var stream = try std.Io.net.IpAddress.connect(&address, io, .{ .mode = .stream });
    defer stream.close(io);
    var wbuf: [512]u8 = undefined;
    var writer = stream.writer(io, &wbuf);
    try writer.interface.writeAll(
        "POST /hello HTTP/1.1\r\nHost: localhost\r\nContent-Length: 0\r\nContent-Length: 0\r\nConnection: close\r\n\r\n",
    );
    try writer.interface.flush();
    var rbuf: [1024]u8 = undefined;
    var reader = stream.reader(io, &rbuf);
    var out: [1024]u8 = undefined;
    const n = try reader.interface.readSliceShort(&out);
    try std.testing.expect(std.mem.startsWith(u8, out[0..n], "HTTP/1.1 400"));
}
