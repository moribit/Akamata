//! Shared application graph. Successful providers remain entrypoint-owned.
const am = @import("akamata");
const State = @import("app.zig").App;
pub const Application = am.App(.{ .State = State, .routes = @import("contract.zig").routes, .configure = configure });
fn configure(app: *am.App(State)) !void {
    _ = try app.useAll(am.mw.recover(State));
}
pub fn migrateDevelopment(db: am.db.Db) !void {
    try db.execAll(@embedFile("schema.sql"));
}
