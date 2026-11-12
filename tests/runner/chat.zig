//! The real chat application: HTTP, masked frames, two peers and persistence.
const std = @import("std");
const s = @import("support.zig");
const w = @import("wire.zig");
fn http(server: *w.Server, method: []const u8, path: []const u8, body: []const u8, expected: u16) !std.json.Value {
    const h = server.h;
    const c = try server.connect();
    defer c.close();
    try c.send(try h.fmt("{s} {s} HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\nContent-Type: application/json\r\nContent-Length: {d}\r\n\r\n{s}", .{ method, path, body.len, body }));
    const response = try c.response();
    try s.check(response.status == expected, "chat HTTP status");
    if (std.mem.eql(u8, path, "/health")) return .null;
    return h.json(response.body);
}
fn connect(server: *w.Server, room: i64, user: []const u8) !*w.Client {
    const c = try server.connect();
    try c.send(try w.request(server.h, try server.h.fmt("/realtime/{d}?user={s}", .{ room, user }), false, w.upgrade));
    try s.check((try c.response()).status == 101, "chat upgrade status");
    return c;
}
fn send(c: *w.Client, text: []const u8) !void {
    const data = try c.h.encode(.{ .protocol_version = 1, .event_type = "send", .payload = .{ .text = text } });
    try c.send(try w.frame(c.h, 1, data, true));
}
fn receive(c: *w.Client) !std.json.Value {
    const head = try c.take(2);
    try s.check(head[0] == 0x81 and head[1] & 0x80 == 0, "unmasked text frame");
    var length: usize = head[1] & 0x7f;
    if (length == 126) length = std.mem.readInt(u16, (try c.take(2))[0..2], .big);
    try s.check(length < 8192, "bounded chat frame");
    return c.h.json(try c.take(length));
}
pub fn run(h: s.H, args: []const []const u8) !void {
    if (args.len != 1) return error.InvalidArguments;
    const binary = try h.absolute(args[0]);
    const temp = try h.temp();
    defer temp.deinit();
    const port = try w.freePort();
    try h.env.put("PORT", try h.fmt("{d}", .{port}));
    try h.env.put("DATABASE_URL", try h.fmt("file:{s}/chat.db", .{temp.path}));
    var server = try w.Server.start(h, &.{binary}, temp.path, h.env, port);
    defer server.deinit();
    const deadline = h.now() + 10 * std.time.ns_per_s;
    var ready = false;
    while (h.now() < deadline) {
        if (try server.poll()) return error.ChatExited;
        _ = http(&server, "GET", "/health", "", 200) catch {
            h.sleep(50);
            continue;
        };
        ready = true;
        break;
    }
    try s.check(ready, "chat startup deadline");
    const room = (try s.field(try http(&server, "POST", "/rooms", "{\"name\":\"wire\"}", 201), "id")).integer;
    const alice = try connect(&server, room, "alice");
    const bob = try connect(&server, room, "bob");
    try send(bob, "registered");
    try s.eq((try s.field(try s.field(try receive(bob), "payload"), "user")).string, "bob");
    try s.eq((try s.field(try s.field(try receive(alice), "payload"), "text")).string, "registered");
    try send(alice, "portable frame");
    for ([_]*w.Client{ alice, bob }) |c| {
        const event = try receive(c);
        try s.eq((try s.field(event, "event_type")).string, "message");
        try s.eq((try s.field(try s.field(event, "payload"), "text")).string, "portable frame");
    }
    const persisted = try http(&server, "GET", try h.fmt("/rooms/{d}/messages", .{room}), "", 200);
    try s.check((try s.field(persisted, "messages")).array.items.len == 2, "chat persists both messages");
    alice.close();
    bob.close();
    const start = h.now();
    server.signal(.TERM);
    try server.wait(10000);
    const seconds = @as(f64, @floatFromInt(h.now() - start)) / std.time.ns_per_s;
    try std.Io.File.stdout().writeStreamingAll(h.io, try h.encode(.{ .example = "chat", .evidence = "Native loopback HTTP + masked WebSocket frames", .clients = 2, .persisted_messages = 2, .shutdown_seconds = seconds }));
}
