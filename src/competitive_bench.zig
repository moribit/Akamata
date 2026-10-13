//! Private comparison fixture; never changes App.serve runtime selection.
const std = @import("std");
const ak = @import("akamata.zig");
const State = struct { pool: *ak.db.Pool };
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
    var lease = try c.state().pool.acquire();
    defer lease.deinit();
    var stmt = try lease.db.prepare("SELECT id, name, weight FROM items WHERE id = ?");
    defer stmt.deinit();
    try stmt.bindAll(.{@as(i64, 1)});
    if (try stmt.step() != .row) return error.MissingFixtureRow;
    const item = try stmt.readRow(Item);
    return .{ .id = item.id, .name = try c.arena.dupe(u8, item.name), .weight = item.weight };
}
const Application = ak.App(.{ .State = State, .routes = .{
    ak.get("/plaintext", plaintext),             ak.get("/json", json),                                                                                      ak.endpoint(.{ .method = .POST, .path = "/echo", .handler = echo, .fallback = .internal_server_error }),
    ak.get("/users/:user/posts/:post", routing), ak.endpoint(.{ .method = .GET, .path = "/db/1", .handler = database, .fallback = .internal_server_error }),
} });
pub fn main() !void {
    // Release allocator is explicitly different from the v0.2.1 DebugAllocator
    // diagnostic fixture; compare only the identical new fixture before/after.
    const base = std.heap.smp_allocator;
    var stats: @import("runtime_bench_stats.zig").Stats = .{ .backing = base };
    const enabled = ak.env.get(base, "BENCH_STATS");
    if (enabled) |v| base.free(v);
    const gpa = if (enabled != null) stats.allocator() else base;
    defer if (enabled != null) stats.report();
    var handles: [8]ak.db.Db = undefined;
    var count: usize = 0;
    errdefer for (handles[0..count]) |db| db.close();
    for (&handles) |*db| {
        db.* = try ak.db.openSqlite(gpa, ":memory:");
        count += 1;
        try db.execAll("PRAGMA journal_mode=MEMORY; PRAGMA synchronous=OFF; PRAGMA temp_store=MEMORY; CREATE TABLE items(id INTEGER PRIMARY KEY, name TEXT NOT NULL, weight REAL); INSERT INTO items VALUES(1,'alpha',1.5),(2,'beta',2.5),(3,'gamma',3.5);");
    }
    var pool = try ak.db.Pool.init(gpa, &handles);
    count = 0; // ownership transferred only on success
    defer pool.deinit();
    var app = try Application.initWithState(gpa, .{ .pool = &pool });
    defer app.deinit();
    const opts: ak.ServeOptions = .{
        .address = "127.0.0.1",
        .port = 8088,
        .accept_thread_count = 8,
        .max_connections = 4096,
        .max_requests_per_connection = std.math.maxInt(u32),
        .keep_alive_idle_timeout_ms = 60_000,
        .parse_limits = .{ .max_body_bytes = 1024 * 1024 },
    };
    const runtime = ak.env.get(gpa, "COMPETITIVE_RUNTIME");
    defer if (runtime) |v| gpa.free(v);
    if (runtime != null and std.mem.eql(u8, runtime.?, "reactor")) {
        try @import("runtime/reactor.zig").evaluate(State, &app.core, opts);
    } else try app.serve(opts);
}
