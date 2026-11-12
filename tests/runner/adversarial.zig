//! Native HTTP adversarial smoke. JS remains only at actual JS/WASM boundaries.
const std = @import("std");
const s = @import("support.zig");
const w = @import("wire.zig");
const names = [_][]const u8{ "giantContentLengthLie", "hugeBodyButTinyCL", "chunkedZeroSize", "chunkedBadHex", "chunkedNoTerminator", "slowloris", "smugglingCLTE", "smugglingDuplicateCL", "illegalMethod", "illegalRequestLine", "controlCharInUrl", "nulByteInHeader", "pipelinedBurst", "resetMidWrite", "normalGetMixedIn" };
const variants = names.len;
const State = struct {
    h: s.H,
    port: u16,
    deadline: i96,
    sent: std.atomic.Value(usize) = .init(0),
    refused: std.atomic.Value(usize) = .init(0),
    socket_errors: std.atomic.Value(usize) = .init(0),
    counts: [variants]std.atomic.Value(usize) = @splat(.init(0)),
    fn attempt(state: *State, variant: usize) void {
        _ = state.counts[variant].fetchAdd(1, .monotonic);
        _ = state.sent.fetchAdd(1, .monotonic);
        var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
        defer arena.deinit();
        var h = state.h;
        h.a = arena.allocator();
        exchange(h, state.port, variant) catch |err| {
            if (err == error.ConnectionRefused) _ = state.refused.fetchAdd(1, .monotonic) else _ = state.socket_errors.fetchAdd(1, .monotonic);
        };
    }
    fn worker(state: *State, index: usize) void {
        var n = index;
        while (state.h.now() < state.deadline) : (n += 4) state.attempt(n % variants);
    }
};
fn exchange(h: s.H, port: u16, variant: usize) !void {
    var c = try w.Client.connect(h, port);
    defer c.close();
    c.timeout_ms = if (variant == 1) 1200 else if (variant == 12) 1500 else 800;
    const payload: []const u8 = switch (variant) {
        0 => "POST /echo HTTP/1.1\r\nHost: localhost\r\nContent-Length: 10737418240\r\n\r\n{}",
        1 => blk: {
            const body = try h.a.alloc(u8, 1024 * 1024);
            @memset(body, 'X');
            break :blk try h.fmt("POST /echo HTTP/1.1\r\nHost: localhost\r\nContent-Length: 4\r\n\r\n{s}", .{body});
        },
        2 => "POST /echo HTTP/1.1\r\nHost: localhost\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\n",
        3 => "POST /echo HTTP/1.1\r\nHost: localhost\r\nTransfer-Encoding: chunked\r\n\r\nzz\r\nhello\r\n0\r\n\r\n",
        4 => "POST /echo HTTP/1.1\r\nHost: localhost\r\nTransfer-Encoding: chunked\r\n\r\n5\r\nhello",
        5 => "GET / HTTP/1.1\r\nHost: localhost\r\nUser-Agent: ",
        6 => "POST /echo HTTP/1.1\r\nHost: localhost\r\nContent-Length: 4\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\nfoo",
        7 => "POST /echo HTTP/1.1\r\nHost: localhost\r\nContent-Length: 4\r\nContent-Length: 8\r\n\r\nabcd1234",
        8 => "🦀ATCH / HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n",
        9 => "GET   /   HTTP/9.99\r\nHost: localhost\r\nConnection: close\r\n\r\n",
        10 => "GET /\x01\x02\x03 HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n",
        11 => "GET / HTTP/1.1\r\nHost: localhost\r\nX-Bad: a\x00b\r\nConnection: close\r\n\r\n",
        12 => blk: {
            var out: std.Io.Writer.Allocating = .init(h.a);
            for (0..5) |_| try out.writer.writeAll("GET / HTTP/1.1\r\nHost: localhost\r\n\r\n");
            try out.writer.writeAll("GET / HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n");
            break :blk try out.toOwnedSlice();
        },
        13 => "GET /hello HTTP/1.1\r\nHost: ",
        14 => "GET / HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n",
        else => unreachable,
    };
    if (variant == 5) {
        for (payload) |byte| {
            try c.send(&.{byte});
            h.sleep(50);
        }
        return;
    }
    try c.send(payload);
    if (variant == 13) return c.reset();
    const raw = try c.collect();
    if (variant == 14) try s.check(std.mem.startsWith(u8, raw, "HTTP/1.1 "), "normal traffic mixed into adversarial load");
}
pub fn run(h: s.H, binary_path: []const u8) !void {
    const binary = try h.absolute(binary_path);
    // The benchmark fixture deliberately owns fixed port 8080. Never probe or
    // terminate an unrelated application already listening there.
    if (w.Client.connect(h, 8080)) |existing| {
        var c = existing;
        c.close();
        return error.FixturePortAlreadyInUse;
    } else |err| {
        if (err != error.ConnectionRefused) return err;
    }
    var server = try w.Server.start(h, &.{binary}, null, h.env, 8080);
    defer server.deinit();
    errdefer {
        const log = h.read(server.log_path) catch "fixture log unavailable";
        std.debug.print("adversarial fixture: {s}\n", .{log});
        h.write(".zig-cache/adversarial-http-server.log", log) catch {};
    }
    var ready = false;
    for (0..100) |_| {
        if (try server.poll()) return error.FixtureStartup;
        if (std.mem.indexOf(u8, try h.read(server.log_path), "akamata listening on http://") == null) {
            h.sleep(20);
            continue;
        }
        const c = server.connect() catch {
            h.sleep(20);
            continue;
        };
        try c.send(try w.request(h, "/hello", true, ""));
        try s.check((try c.response()).status == 200, "adversarial fixture health");
        c.close();
        ready = true;
        break;
    }
    try s.check(ready, "adversarial fixture startup deadline");
    var state: State = .{ .h = h, .port = 8080, .deadline = 0 };
    // Deterministic prefix guarantees coverage; the old random five-second
    // smoke could omit variants. Then mix four workers for the original 5s.
    for (0..variants) |variant| state.attempt(variant);
    state.deadline = h.now() + 5 * std.time.ns_per_s;
    var threads: std.ArrayList(std.Thread) = .empty;
    try threads.ensureTotalCapacity(h.a, 4);
    defer for (threads.items) |thread| thread.join();
    for (0..4) |index| threads.appendAssumeCapacity(try std.Thread.spawn(.{}, State.worker, .{ &state, index }));
    for (threads.items) |thread| thread.join();
    threads.clearRetainingCapacity();
    const final = try server.connect();
    try final.send(try w.request(h, "/hello", true, ""));
    try s.check((try final.response()).status == 200, "server remains healthy after all adversarial variants");
    var counts: std.json.ObjectMap = .empty;
    for (&state.counts, names) |*counter, name| {
        const count = counter.load(.acquire);
        try s.check(count > 0, "every adversarial variant exercised");
        try counts.put(h.a, name, .{ .integer = @intCast(count) });
    }
    const report = try h.encode(.{ .sent = state.sent.load(.acquire), .refused = state.refused.load(.acquire), .socket_errors = state.socket_errors.load(.acquire), .variants = std.json.Value{ .object = counts }, .policy = "all variants once, then four-worker cyclic mix for five seconds; liveness gate, not throughput" });
    try h.write(".zig-cache/adversarial-http.json", report);
    std.debug.print("adversarial HTTP: all 15 variants + 4-worker mixed load passed; {s}\n", .{report});
    try server.finish();
    try h.write(".zig-cache/adversarial-http-server.log", try h.read(server.log_path));
}
