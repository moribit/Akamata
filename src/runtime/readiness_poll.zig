// Zig 0.17 std.Io.Threaded has no per-stream read deadline. Readiness
// bounds reads without SO_RCVTIMEO (EAGAIN is an errnoBug in netReadPosix).
const std = @import("std");
pub const Readiness = struct {
    pub fn init(_: c_int) !Readiness {
        return .{};
    }
    pub fn deinit(_: *Readiness) void {}
    pub fn wait(_: *Readiness, fd: c_int, timeout_ms: u32) !bool {
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
