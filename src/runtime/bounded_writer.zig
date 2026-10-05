//! Fixed-capacity output, absolute response/frame budget, no EAGAIN spin.
const std = @import("std");
const clock = @import("../observability/clock.zig");
pub const Writer = struct {
    interface: std.Io.Writer,
    fd: c_int,
    io: std.Io,
    timeout_ms: u32,
    started: ?u64 = null,
    control: ?*@import("drain.zig").Node = null,
    pub fn init(fd: c_int, io: std.Io, buffer: []u8, timeout_ms: u32) Writer {
        return .{ .fd = fd, .io = io, .timeout_ms = timeout_ms, .interface = .{ .buffer = buffer, .vtable = &.{ .drain = drain } } };
    }
    fn send(self: *Writer, bytes: []const u8) std.Io.Writer.Error!void {
        if (bytes.len == 0) return;
        if (self.started == null or (self.control != null and self.control.?.write_deadline_ns.load(.acquire) == 0)) {
            self.started = clock.monotonicNs();
            if (self.control) |node| node.write_deadline_ns.store(self.started.? +| @as(u64, self.timeout_ms) * std.time.ns_per_ms, .release);
        }
        var offset: usize = 0;
        while (offset < bytes.len) {
            self.io.checkCancel() catch return error.WriteFailed;
            const elapsed = clock.elapsedNs(self.started.?) / std.time.ns_per_ms;
            if (elapsed >= self.timeout_ms) return error.WriteFailed;
            const n = std.c.send(self.fd, bytes[offset..].ptr, bytes.len - offset, std.c.MSG.DONTWAIT | std.c.MSG.NOSIGNAL);
            if (n > 0) {
                offset += @intCast(n);
                continue;
            }
            if (n == 0) return error.WriteFailed;
            switch (std.posix.errno(n)) {
                .INTR => continue,
                .AGAIN => {
                    var p = [1]std.c.pollfd{.{ .fd = self.fd, .events = std.c.POLL.OUT, .revents = 0 }};
                    const remaining = self.timeout_ms - elapsed;
                    const ready = std.c.poll(&p, 1, @intCast(@min(remaining, 100)));
                    if (ready < 0 and std.posix.errno(ready) != .INTR) return error.WriteFailed;
                },
                else => return error.WriteFailed,
            }
        }
    }
    fn drain(w: *std.Io.Writer, data: []const []const u8, splat: usize) std.Io.Writer.Error!usize {
        const self: *Writer = @alignCast(@fieldParentPtr("interface", w));
        try self.send(w.buffered());
        w.end = 0;
        for (data[0 .. data.len - 1]) |bytes| try self.send(bytes);
        for (0..splat) |_| try self.send(data[data.len - 1]);
        return std.Io.Writer.countSplat(data, splat);
    }
};
