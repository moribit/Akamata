//! Private multiplexed evaluation; public selection remains fail-closed.
const builtin = @import("builtin");
const app_mod = @import("../app.zig");
pub fn serve(comptime State: type, _: *app_mod.App(State), _: app_mod.ServeOptions) !void {
    return error.ExperimentalRuntimeDisabled;
}
pub fn evaluate(comptime State: type, app: *app_mod.App(State), opts: app_mod.ServeOptions) !void {
    if (builtin.os.tag != .linux) return error.UnsupportedPlatform;
    return @import("reactor.zig").evaluate(State, app, opts);
}
