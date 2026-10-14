//! Private Workers benchmark application. No resource provisioning or migration.
const std = @import("std");
const ak = @import("akamata");
pub const std_options: std.Options = .{ .logFn = struct {
    fn log(comptime _: std.log.Level, comptime _: @TypeOf(.enum_literal), comptime _: []const u8, _: anytype) void {}
}.log };
const State = struct { db: ak.db.Db };
const Message = struct { message: []const u8 };
const Route = struct { user: u64, post: u64 };
const Item = struct { id: i64, name: []const u8, weight: f64 };
fn plaintext() []const u8 {
    return "Hello, World!";
}
fn json() Message {
    return .{ .message = "Hello, World!" };
}
fn routing(user: ak.Path(u64, "user"), post: ak.Path(u64, "post")) Route {
    return .{ .user = user.value, .post = post.value };
}
fn echo(c: *ak.Context(State)) anyerror!void {
    try c.header("content-type", "application/octet-stream");
    try c.body(c.req.body());
}
fn database(c: *ak.Context(State)) anyerror!Item {
    var stmt = try c.state().db.prepare("SELECT id, name, weight FROM items WHERE id = ?");
    defer stmt.deinit();
    try stmt.bindAll(.{@as(i64, 1)});
    if (try stmt.step() != .row) return error.MissingFixtureRow;
    const item = try stmt.readRow(Item);
    return .{ .id = item.id, .name = try c.arena.dupe(u8, item.name), .weight = item.weight };
}
const Application = ak.App(.{ .State = State, .routes = .{
    ak.get("/plaintext", plaintext),                                                                            ak.get("/json", json),
    ak.get("/users/:user/posts/:post", routing),                                                                ak.endpoint(.{ .method = .POST, .path = "/echo", .handler = echo, .fallback = .internal_server_error }),
    ak.endpoint(.{ .method = .GET, .path = "/db/1", .handler = database, .fallback = .internal_server_error }),
} });
var application: Application = undefined;
var initialized = false;
fn initialize() !void {
    if (initialized) return;
    const gpa = std.heap.wasm_allocator;
    const db = try ak.db.open(gpa, "d1:DB");
    errdefer db.close();
    application = try Application.initWithState(gpa, .{ .db = db });
    errdefer application.deinit();
    try application.serve(.{ .parse_limits = .{ .max_body_bytes = 1024 * 1024 } });
    initialized = true;
}
export fn akamata_init() void {
    // Unregistered dispatch fails closed through the existing Workers ABI.
    initialize() catch return;
}
// Test host explicitly tears down the isolate-owned graph after its probes.
// The deployment host does not call this while requests are in flight.
export fn benchmark_deinit() void {
    if (!initialized) return;
    const db = application.core.state_value.db;
    application.deinit();
    db.close();
    initialized = false;
}
