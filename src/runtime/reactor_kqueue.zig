// Experimental kernel readiness adapter, without HTTP implementation.
// evaluate uses the proven thread-per-connection lifecycle. It does not
// certify a multiplexed reactor: the production entry remains fail-closed.
const std = @import("std");
const builtin = @import("builtin");
const app_mod = @import("../app.zig");
pub fn serve(comptime State: type, _: *app_mod.App(State), _: app_mod.ServeOptions) !void {
    return error.ExperimentalRuntimeDisabled;
}
pub fn evaluate(comptime State: type, app: *app_mod.App(State), opts: app_mod.ServeOptions) !void {
    return @import("threaded.zig").serveWithReadiness(State, Readiness, app, opts);
}
pub const Readiness = struct {
    queue: c_int,
    pub fn init(fd: c_int) !Readiness {
        if (builtin.os.tag != .macos and builtin.os.tag != .freebsd) return error.UnsupportedPlatform;
        const queue = std.c.kqueue();
        if (queue < 0) return error.ReadinessInitFailed;
        errdefer _ = std.c.close(queue);
        var change: std.c.Kevent = .{
            .ident = @intCast(fd),
            .filter = std.c.EVFILT.READ,
            .flags = std.c.EV.ADD | std.c.EV.ENABLE,
            .fflags = 0,
            .data = 0,
            .udata = 0,
        };
        var empty: [0]std.c.Kevent = .{};
        if (std.c.kevent(queue, @ptrCast(&change), 1, &empty, 0, null) < 0) return error.ReadinessInitFailed;
        return .{ .queue = queue };
    }
    pub fn deinit(self: *Readiness) void {
        _ = std.c.close(self.queue);
    }
    pub fn wait(self: *Readiness, _: c_int, timeout_ms: u32) !bool {
        var event: [1]std.c.Kevent = undefined;
        const timeout: std.c.timespec = .{
            .sec = @intCast(timeout_ms / 1000),
            .nsec = @intCast((timeout_ms % 1000) * 1_000_000),
        };
        const n = std.c.kevent(self.queue, &.{}, 0, &event, 1, &timeout);
        if (n < 0) {
            if (std.posix.errno(n) == .INTR) return false;
            return error.ReadinessFailed;
        }
        if (n > 0 and event[0].flags & std.c.EV.ERROR != 0) return error.ReadinessFailed;
        return n > 0;
    }
};
