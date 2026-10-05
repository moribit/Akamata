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
// std.c.epoll_event has the correct packed ABI on Linux x86_64.
pub const Readiness = struct {
    queue: c_int,
    pub fn init(fd: c_int) !Readiness {
        if (builtin.os.tag != .linux) return error.UnsupportedPlatform;
        const queue = std.c.epoll_create1(std.os.linux.EPOLL.CLOEXEC);
        if (queue < 0) return error.ReadinessInitFailed;
        errdefer _ = std.c.close(queue);
        var event: std.c.epoll_event = .{
            .events = std.os.linux.EPOLL.IN | std.os.linux.EPOLL.RDHUP,
            .data = .{ .fd = fd },
        };
        if (std.c.epoll_ctl(queue, std.os.linux.EPOLL.CTL_ADD, fd, &event) < 0) return error.ReadinessInitFailed;
        return .{ .queue = queue };
    }
    pub fn deinit(self: *Readiness) void {
        _ = std.c.close(self.queue);
    }
    pub fn wait(self: *Readiness, _: c_int, timeout_ms: u32) !bool {
        var event: [1]std.c.epoll_event = undefined;
        const n = std.c.epoll_wait(self.queue, &event, 1, @intCast(@min(timeout_ms, std.math.maxInt(c_int))));
        if (n < 0) {
            if (std.posix.errno(n) == .INTR) return false;
            return error.ReadinessFailed;
        }
        return n > 0;
    }
};
