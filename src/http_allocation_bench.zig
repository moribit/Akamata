//! Offline diagnostic fixture; logical arena requests and backing heap are distinct.
const std = @import("std");
const am = @import("akamata");
const Stats = @import("runtime_bench_stats.zig").Stats;
const State = struct {};
fn empty(c: *am.Context(State)) !void {
    c.status(204);
}
fn pass(c: *am.Context(State), next: am.Next(State)) !void {
    try next.run(c);
}
fn dispatchProfile(backing: std.mem.Allocator, with_middleware: bool) !void {
    var app = am.App(State).init(std.heap.page_allocator, .{});
    defer app.deinit();
    _ = try app.get("/hello", empty);
    if (with_middleware) _ = try app.useAll(.{ .call = pass });
    try app.prepare();
    var stats: Stats = .{ .backing = backing };
    var request: am.Request = .{ .method = .GET, .raw_method = "GET", .path = "/hello", .query = "", .version = "HTTP/1.1", .headers = &.{}, .body = "", .keep_alive = false };
    var response = am.Response.init(stats.allocator());
    try app.dispatch(stats.allocator(), &request, &response, null, null);
    emit(if (with_middleware) "route_with_passthrough_middleware" else "route_and_empty_handler", &stats);
}
fn emit(name: []const u8, stats: *Stats) void {
    std.debug.print("ALLOCATION_PHASE {{\"phase\":\"{s}\",\"calls\":{d},\"requested\":{d}}}\n", .{ name, stats.calls.load(.monotonic), stats.requested.load(.monotonic) });
}
pub fn main() !void {
    var backing: Stats = .{ .backing = std.heap.page_allocator };
    var arena = std.heap.ArenaAllocator.init(backing.allocator());
    defer arena.deinit();
    var parse: Stats = .{ .backing = arena.allocator() };
    _ = try am.http.parser.parseRequest(parse.allocator(), "GET /hello HTTP/1.1\r\nHost: a\r\n\r\n", .{});
    emit("parse", &parse);
    try dispatchProfile(arena.allocator(), false);
    try dispatchProfile(arena.allocator(), true);
    var headers: Stats = .{ .backing = arena.allocator() };
    var response = am.Response.init(headers.allocator());
    try response.header("content-type", "text/plain");
    emit("header", &headers);
    var body: Stats = .{ .backing = arena.allocator() };
    response.arena = body.allocator();
    try response.writeAll("Hello, Akamata!");
    emit("static_body_copy", &body);
    var json: Stats = .{ .backing = arena.allocator() };
    var json_response = am.Response.init(json.allocator());
    try json_response.json(.{ .name = "x", .n = 42, .echoed = true });
    emit("json_header_and_body", &json);
    var output: [4096]u8 = undefined;
    var writer = std.Io.Writer.fixed(&output);
    const previous = backing.calls.load(.monotonic);
    try response.writeTo(&writer);
    std.debug.print("ALLOCATION_PHASE {{\"phase\":\"cursor_and_write\",\"heap_calls\":{d}}}\n", .{backing.calls.load(.monotonic) - previous});
    _ = arena.reset(.retain_capacity);
    const warmed = backing.calls.load(.monotonic);
    for (0..1000) |_| {
        var r = am.Response.init(arena.allocator());
        try r.json(.{ .name = "x", .n = 42, .echoed = true });
        _ = arena.reset(.retain_capacity);
    }
    std.debug.print("ALLOCATION_PHASE {{\"phase\":\"warm_json_1000\",\"heap_calls\":{d}}}\n", .{backing.calls.load(.monotonic) - warmed});
}
