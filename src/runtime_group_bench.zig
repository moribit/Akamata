// Isolated Io.Group benchmark. Same three handlers, SQLite data, allocator,
// and ServeOptions as examples/bench; not part of the installed public API.
// Minimal Akamata benchmark server. Three scenarios:
//   GET  /hello       — static text response (framework overhead only)
//   POST /echo        — JSON parse + JSON serialize
//   GET  /db/:id      — SQLite query

const std = @import("std");
const am = @import("akamata.zig");

const State = struct {
    db: am.db.Db,
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const base_alloc = gpa.allocator();
    const tracked = am.env.get(base_alloc, "BENCH_STATS");
    if (tracked) |value| base_alloc.free(value);
    var stats: @import("runtime_bench_stats.zig").Stats = .{ .backing = base_alloc };
    var task_stats: @import("runtime/io_group_experiment.zig").TaskStats = .{};
    defer if (tracked != null and !@import("bench_kind").reactor) task_stats.report();
    defer if (tracked != null) stats.report();
    const alloc = if (tracked != null) stats.allocator() else base_alloc;

    var db = try am.db.openSqlite(alloc, ":memory:");
    defer db.close();
    try db.execAll(
        \\CREATE TABLE items (id INTEGER PRIMARY KEY, name TEXT NOT NULL, weight REAL);
        \\INSERT INTO items(id, name, weight) VALUES (1,'alpha',1.5);
        \\INSERT INTO items(id, name, weight) VALUES (2,'beta',2.5);
        \\INSERT INTO items(id, name, weight) VALUES (3,'gamma',3.5);
    );

    var app = am.App(State).init(alloc, .{ .db = db });
    defer app.deinit();

    _ = try app.get("/hello", hello);
    _ = try app.post("/echo", echo);
    _ = try app.get("/db/:id", lookup);

    if (@import("bench_kind").reactor)
        try @import("runtime/reactor.zig").evaluate(State, &app, .{ .port = 8080, .worker_count = 8 })
    else
        try @import("runtime/io_group_experiment.zig").serveMeasured(State, &app, .{ .port = 8080, .accept_thread_count = 8 }, if (tracked != null) &task_stats else null);
}

fn hello(c: *am.Context(State)) !void {
    try c.text("Hello, Akamata!");
}

fn echo(c: *am.Context(State)) !void {
    const Body = struct { name: []const u8, n: u32 = 0 };
    const body = c.req.json(Body) catch {
        return c.json(.{ .error_kind = "bad_request" }, 400);
    };
    try c.json(.{ .name = body.name, .n = body.n, .echoed = true }, 200);
}

fn lookup(c: *am.Context(State)) !void {
    const id = c.req.paramAs(i64, "id") catch {
        return c.json(.{ .error_kind = "bad_id" }, 400);
    };
    var stmt = try c.db().prepare("SELECT id, name, weight FROM items WHERE id = ?");
    defer stmt.deinit();
    try stmt.bindAll(.{id});
    if ((try stmt.step()) != .row) return c.json(.{ .error_kind = "not_found" }, 404);
    const Row = struct { id: i64, name: []const u8, weight: f64 };
    const r = try stmt.readRow(Row);
    try c.json(.{
        .id = r.id,
        .name = try c.arena.dupe(u8, r.name),
        .weight = r.weight,
    }, 200);
}
