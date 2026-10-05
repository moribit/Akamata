//! A single bounded producer slot. Only the event loop sends socket bytes.
const std = @import("std");
const sync = @import("../sync.zig");
const clock = @import("../observability/clock.zig");
pub fn Output(comptime Owner: type) type {
    return struct {
        const Self = @This();
        owner: *Owner,
        token: u64,
        node: *@import("drain.zig").Node,
        mutex: sync.Mutex,
        changed: sync.Condition,
        interface: std.Io.Writer,
        bytes: [16 * 1024]u8 = undefined,
        len: usize = 0,
        offset: usize = 0,
        failed: bool = false,
        timeout_ms: u32 = 0,
        pub fn init(owner: *Owner, token: u64, node: *@import("drain.zig").Node, buffer: []u8) Self {
            return .{ .owner = owner, .token = token, .node = node, .mutex = .init(), .changed = .init(), .interface = .{ .buffer = buffer, .vtable = &.{ .drain = drain } } };
        }
        pub fn deinit(self: *Self) void {
            self.changed.deinit();
            self.mutex.deinit();
        }
        pub fn abort(self: *Self) void {
            self.mutex.lock();
            defer self.mutex.unlock();
            self.failed = true;
            self.len = 0;
            self.offset = 0;
            self.changed.broadcast();
        }
        pub fn status(self: *Self) struct { pending: bool, failed: bool } {
            self.mutex.lock();
            defer self.mutex.unlock();
            return .{ .pending = self.len != 0, .failed = self.failed };
        }
        fn waitEmpty(self: *Self) std.Io.Writer.Error!void {
            while (self.len != 0 and !self.failed) self.changed.wait(&self.mutex);
            if (self.failed) return error.WriteFailed;
        }
        fn enqueue(self: *Self, data: []const u8) std.Io.Writer.Error!void {
            var offset: usize = 0;
            while (offset < data.len) {
                self.mutex.lock();
                self.waitEmpty() catch |err| {
                    self.mutex.unlock();
                    return err;
                };
                if (self.node.write_deadline_ns.load(.acquire) == 0)
                    self.node.write_deadline_ns.store(clock.monotonicNs() +| @as(u64, self.timeout_ms) * std.time.ns_per_ms, .release);
                const n = @min(data.len - offset, self.bytes.len);
                @memcpy(self.bytes[0..n], data[offset..][0..n]);
                self.len = n;
                self.offset = 0;
                self.mutex.unlock();
                self.owner.notify(self.token);
                offset += n;
            }
        }
        fn drain(w: *std.Io.Writer, data: []const []const u8, splat: usize) std.Io.Writer.Error!usize {
            const self: *Self = @alignCast(@fieldParentPtr("interface", w));
            try self.enqueue(w.buffered());
            w.end = 0;
            for (data[0 .. data.len - 1]) |bytes| try self.enqueue(bytes);
            for (0..splat) |_| try self.enqueue(data[data.len - 1]);
            if (self.node.synchronous_output.load(.acquire)) {
                self.mutex.lock();
                defer self.mutex.unlock();
                try self.waitEmpty();
            }
            return std.Io.Writer.countSplat(data, splat);
        }
        pub fn pump(self: *Self, fd: c_int) !void {
            self.mutex.lock();
            defer self.mutex.unlock();
            if (self.failed) return error.ConnectionWriteFailed;
            if (self.len == 0) return;
            const n = std.c.send(fd, self.bytes[self.offset..self.len].ptr, self.len - self.offset, std.c.MSG.DONTWAIT | std.c.MSG.NOSIGNAL);
            if (n < 0) switch (std.posix.errno(n)) {
                .AGAIN, .INTR => return,
                else => return error.ConnectionWriteFailed,
            } else if (n == 0) return error.ConnectionWriteFailed;
            self.offset += @intCast(n);
            if (self.offset == self.len) {
                self.len = 0;
                self.offset = 0;
                self.changed.broadcast();
            }
        }
    };
}
