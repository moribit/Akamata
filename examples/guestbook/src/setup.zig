//! Shared application graph; owners stay with the caller.
const std = @import("std");
const am = @import("akamata");
const State = @import("app.zig").App;
const models = @import("models.zig");
pub const Application = blk: {
    @setEvalBranchQuota(50_000);
    break :blk am.App(.{ .State = State, .routes = @import("contract.zig").routes, .configure = configure });
};
pub const default_native_url = "file:guestbook.db";
pub const default_workers_url = "d1:" ++ @import("contract.zig").For(.workers).resolve(.database).binding.?;
fn configure(app: *am.App(State)) !void {
    _ = try app.useAll(am.mw.recover(State));
    _ = try app.useAll(am.mw.logger(State));
}
pub fn migrateDevelopment(allocator: std.mem.Allocator, database: am.db.Db) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const plan = try am.model.migrate.diff(arena.allocator(), database, &models.all_models);
    try am.model.migrate.apply(arena.allocator(), database, plan);
}
pub fn buildState(allocator: std.mem.Allocator) !State {
    if (am.backend == .native) try am.env.loadDotEnv(allocator, ".env");
    const url = am.env.get(allocator, "DATABASE_URL") orelse try allocator.dupe(u8, if (am.backend == .native) default_native_url else default_workers_url);
    defer allocator.free(url);
    const database = try am.db.openForContract(allocator, State.application_contract, url);
    errdefer database.close();
    // Tutorial convenience only. Workers schema is applied before deployment.
    if (am.backend == .native) try migrateDevelopment(allocator, database);
    return .{ .db = database };
}
