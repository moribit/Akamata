//! One application graph for production and in-process tests.
const std = @import("std");
const am = @import("akamata");
const State = @import("app.zig").App;
const models = @import("models.zig");
pub const Application = am.App(.{ .State = State, .routes = @import("contract.zig").routes, .configure = configure });
fn configure(app: *am.App(State)) !void {
    _ = try app.useAll(am.mw.recover(State));
    _ = try app.useAll(am.mw.requestId(State));
}
pub fn migrateDevelopment(allocator: std.mem.Allocator, db: am.db.Db) !void {
    var arena: std.heap.ArenaAllocator = .init(allocator);
    defer arena.deinit();
    const plan = try am.model.migrate.diff(arena.allocator(), db, &models.all_models);
    try am.model.migrate.apply(arena.allocator(), db, plan);
    try db.exec("CREATE TABLE IF NOT EXISTS task_deliveries (event_id TEXT PRIMARY KEY, task_id INTEGER NOT NULL, attempt INTEGER NOT NULL)");
}
