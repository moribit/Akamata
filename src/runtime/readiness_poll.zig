// Zig 0.17 std.Io.Threaded has no per-stream read deadline. Readiness
// bounds reads without SO_RCVTIMEO (EAGAIN is an errnoBug in netReadPosix).
const std = @import("std");
pub const Readiness = struct {
    pub fn init(_: c_int) !Readiness {
        return .{};
    }
    pub fn deinit(_: *Readiness) void {}
    pub fn waitIdle(_: *Readiness, fd: c_int, wake_fd: c_int, timeout_ms: u32) !bool {
        const measured = @import("cost.zig").begin();
        defer measured.end(.selector_wait);
        @import("cost.zig").add(.poll_call, 1);
        var fds = [_]std.posix.pollfd{
            .{ .fd = fd, .events = std.posix.POLL.IN, .revents = 0 },
            .{ .fd = wake_fd, .events = std.posix.POLL.IN, .revents = 0 },
        };
        const n = std.c.poll(&fds, fds.len, @intCast(@min(timeout_ms, std.math.maxInt(c_int))));
        if (n < 0) {
            if (std.posix.errno(n) == .INTR) return false;
            return error.ReadinessFailed;
        }
        // The wake byte remains unread: every idle connection observes the
        // same shutdown, including threads which enter poll after notification.
        return n > 0 and fds[1].revents == 0 and fds[0].revents != 0;
    }
    pub fn wait(_: *Readiness, fd: c_int, timeout_ms: u32) !bool {
        const measured = @import("cost.zig").begin();
        defer measured.end(.selector_wait);
        @import("cost.zig").add(.poll_call, 1);
        var fds = [_]std.posix.pollfd{.{ .fd = fd, .events = std.posix.POLL.IN, .revents = 0 }};
        // posix.poll retries EINTR with the original timeout; use one libc
        // call so the transport recomputes its absolute deadline after EINTR.
        const n = std.c.poll(&fds, 1, @intCast(@min(timeout_ms, std.math.maxInt(c_int))));
        if (n < 0) {
            if (std.posix.errno(n) == .INTR) return false;
            return error.ReadinessFailed;
        }
        // EOF/HUP must reach the reader too; never spin on a closed peer.
        return n > 0;
    }
};

pub const ShutdownWake = struct {
    descriptors: [2]c_int,
    pub fn init() !ShutdownWake {
        var result: ShutdownWake = undefined;
        if (std.c.pipe(&result.descriptors) < 0) return error.WakeupInitFailed;
        errdefer result.deinit();
        for (result.descriptors) |fd| {
            const flags = std.c.fcntl(fd, std.c.F.GETFL);
            const nonblock: c_int = @bitCast(std.c.O{ .NONBLOCK = true });
            if (flags < 0 or std.c.fcntl(fd, std.c.F.SETFL, flags | nonblock) < 0 or
                std.c.fcntl(fd, std.c.F.SETFD, @as(c_int, std.c.FD_CLOEXEC)) < 0)
                return error.SocketConfigurationFailed;
        }
        return result;
    }
    pub fn notify(self: *ShutdownWake) void {
        const byte = [_]u8{1};
        // One notification after admission has stopped. Retry EINTR; the
        // nonblocking pipe is never read and cannot fill from this one byte.
        while (std.c.write(self.descriptors[1], &byte, 1) < 0) {
            if (std.posix.errno(-1) != .INTR) break;
        }
    }
    pub fn deinit(self: *ShutdownWake) void {
        for (self.descriptors) |fd| _ = std.c.close(fd);
    }
};

test "idle shutdown notification remains visible to successive waiters" {
    var wake = try ShutdownWake.init();
    defer wake.deinit();
    var sockets: [2]c_int = undefined;
    try std.testing.expectEqual(@as(c_int, 0), std.c.socketpair(std.c.AF.UNIX, std.c.SOCK.STREAM, 0, &sockets));
    defer for (sockets) |fd| {
        _ = std.c.close(fd);
    };
    var readiness: Readiness = .{};
    wake.notify();
    for (0..3) |_| try std.testing.expect(!try readiness.waitIdle(sockets[0], wake.descriptors[0], 1000));
    const byte = [_]u8{1};
    try std.testing.expectEqual(@as(isize, 1), std.c.write(sockets[1], &byte, 1));
    // Shutdown wins if both descriptors are ready; no new idle request starts.
    try std.testing.expect(!try readiness.waitIdle(sockets[0], wake.descriptors[0], 1000));
}
