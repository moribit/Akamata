//! Fixed-capacity output, absolute response/frame budget, no EAGAIN spin.
const std = @import("std");
const cost = @import("cost.zig");
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
            if (elapsed >= self.timeout_ms) {
                cost.add(.write_timeout, 1);
                return error.WriteFailed;
            }
            const send_cost = cost.begin();
            cost.add(.send_call, 1);
            const n = std.c.send(self.fd, bytes[offset..].ptr, bytes.len - offset, std.c.MSG.DONTWAIT | std.c.MSG.NOSIGNAL);
            send_cost.end(.send);
            if (n > 0) {
                offset += @intCast(n);
                continue;
            }
            if (n == 0) return error.WriteFailed;
            switch (std.posix.errno(n)) {
                .INTR => continue,
                .AGAIN => {
                    cost.add(.write_again, 1);
                    var p = [1]std.c.pollfd{.{ .fd = self.fd, .events = std.c.POLL.OUT, .revents = 0 }};
                    const remaining = self.timeout_ms - elapsed;
                    const wait_cost = cost.begin();
                    cost.add(.poll_call, 1);
                    const ready = std.c.poll(&p, 1, @intCast(@min(remaining, 100)));
                    wait_cost.end(.write_wait);
                    if (ready < 0 and std.posix.errno(ready) != .INTR) return error.WriteFailed;
                },
                else => |err| {
                    if (comptime cost.enabled) switch (err) {
                        .CONNRESET => cost.add(.write_reset, 1),
                        .PIPE => cost.add(.write_pipe, 1),
                        else => cost.add(.write_other_failure, 1),
                    };
                    return error.WriteFailed;
                },
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

test "buffered prefix and large body preserve partial writes under backpressure" {
    var sockets: [2]c_int = undefined;
    try std.testing.expectEqual(@as(c_int, 0), std.c.socketpair(std.c.AF.UNIX, std.c.SOCK.STREAM, 0, &sockets));
    defer for (sockets) |fd| {
        _ = std.c.close(fd);
    };
    const capacity: c_int = 1024;
    try std.testing.expectEqual(@as(c_int, 0), std.c.setsockopt(sockets[0], std.c.SOL.SOCKET, std.c.SO.SNDBUF, &capacity, @sizeOf(c_int)));
    const Peer = struct {
        fd: c_int,
        count: usize = 0,
        valid: bool = true,
        fn run(self: *@This()) void {
            var buffer: [1024]u8 = undefined;
            while (true) {
                const n = std.c.recv(self.fd, &buffer, buffer.len, 0);
                if (n < 0) {
                    if (std.posix.errno(n) == .INTR) continue;
                    self.valid = false;
                    return;
                }
                if (n == 0) return;
                for (buffer[0..@intCast(n)]) |byte| {
                    const expected: u8 = if (self.count < 4) "HEAD"[self.count] else 'x';
                    if (byte != expected) self.valid = false;
                    self.count += 1;
                }
                std.Io.sleep(std.testing.io, .fromMilliseconds(1), .awake) catch {};
            }
        }
    };
    var peer: Peer = .{ .fd = sockets[1] };
    const thread = try std.Thread.spawn(.{}, Peer.run, .{&peer});
    var joined = false;
    defer if (!joined) {
        _ = std.c.shutdown(sockets[0], std.c.SHUT.RDWR);
        thread.join();
    };
    var buffer: [32]u8 = undefined;
    var writer = Writer.init(sockets[0], std.testing.io, &buffer, 2000);
    try writer.interface.writeAll("HEAD");
    const body: [65536]u8 = @splat('x');
    try writer.interface.writeAll(&body);
    try writer.interface.flush();
    _ = std.c.shutdown(sockets[0], std.c.SHUT.WR);
    thread.join();
    joined = true;
    try std.testing.expect(peer.valid);
    try std.testing.expectEqual(@as(usize, 4 + body.len), peer.count);
}
