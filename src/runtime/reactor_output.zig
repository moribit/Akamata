//! A single bounded producer slot. Only the event loop sends socket bytes.
const std = @import("std");
const sync = @import("../sync.zig");
const cost = @import("cost.zig");
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
        allocator: std.mem.Allocator,
        // Finite offer borrows stable connection/session storage until drain.
        // Only the legacy protocol-error Writer requires an owned copy slot.
        bytes: []const u8 = &.{},
        owned: ?*[16 * 1024]u8 = null,
        len: usize = 0,
        offset: usize = 0,
        failed: bool = false,
        timeout_ms: u32 = 0,
        pub fn init(owner: *Owner, token: u64, node: *@import("drain.zig").Node, buffer: []u8, allocator: std.mem.Allocator) Self {
            return .{ .owner = owner, .token = token, .node = node, .allocator = allocator, .mutex = .init(), .changed = .init(), .interface = .{ .buffer = buffer, .vtable = &.{ .drain = drain } } };
        }
        pub fn deinit(self: *Self) void {
            if (self.owned) |storage| self.allocator.destroy(storage);
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
        /// Event-loop-owned finite quantum. No condition wait or producer task
        /// is retained behind backpressure; caller retries after output drains.
        pub fn offer(self: *Self, data: []const u8) !void {
            self.mutex.lock();
            defer self.mutex.unlock();
            if (self.failed) return error.ConnectionWriteFailed;
            if (self.len != 0) return error.OutputPending;
            if (data.len > 16 * 1024) return error.InvalidOutputQuantum;
            if (data.len == 0) return;
            if (self.node.write_deadline_ns.load(.acquire) == 0)
                self.node.write_deadline_ns.store(clock.monotonicNs() +| @as(u64, self.timeout_ms) * std.time.ns_per_ms, .release);
            self.bytes = data;
            self.len = data.len;
            self.offset = 0;
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
                if (self.owned == null) self.owned = self.allocator.create([16 * 1024]u8) catch {
                    self.mutex.unlock();
                    return error.WriteFailed;
                };
                const storage = self.owned.?;
                const n = @min(data.len - offset, storage.len);
                cost.add(.copy_bytes, n);
                @memcpy(storage[0..n], data[offset..][0..n]);
                self.bytes = storage[0..n];
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
            const deadline = self.node.write_deadline_ns.load(.acquire);
            if (deadline != 0 and clock.monotonicNs() >= deadline) return error.ConnectionWriteFailed;
            const send_cost = cost.begin();
            cost.add(.send_call, 1);
            const n = std.c.send(fd, self.bytes[self.offset..self.len].ptr, self.len - self.offset, std.c.MSG.DONTWAIT | std.c.MSG.NOSIGNAL);
            send_cost.end(.send);
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

test "pending output preserves partial send, EAGAIN and disconnect" {
    const Owner = struct {
        pub fn notify(_: *@This(), _: u64) void {}
    };
    var owner: Owner = .{};
    var sockets: [2]c_int = undefined;
    try std.testing.expectEqual(@as(c_int, 0), std.c.socketpair(std.c.AF.UNIX, std.c.SOCK.STREAM, 0, &sockets));
    var peer_open = true;
    defer if (peer_open) {
        _ = std.c.close(sockets[1]);
    };
    try @import("reactor_selector.zig").nonblocking(sockets[0]);
    try @import("reactor_selector.zig").nonblocking(sockets[1]);
    const size: c_int = 1024;
    try std.testing.expectEqual(@as(c_int, 0), std.c.setsockopt(sockets[0], std.c.SOL.SOCKET, std.c.SO.SNDBUF, &size, @sizeOf(c_int)));
    var registry: @import("drain.zig").Registry = .{ .mutex = .init() };
    defer registry.mutex.deinit();
    var node: @import("drain.zig").Node = undefined;
    registry.attach(&node, sockets[0]);
    defer node.detach();
    var buffer: [4096]u8 = undefined;
    var output = Output(Owner).init(&owner, 2, &node, &buffer, std.testing.allocator);
    defer output.deinit();
    output.timeout_ms = 1000;
    var bytes: [16 * 1024]u8 = undefined;
    for (&bytes, 0..) |*byte, i| byte.* = @intCast(i % 251);
    try output.offer(&bytes);
    try std.testing.expect(output.owned == null);
    try output.pump(sockets[0]);
    try std.testing.expect(output.offset > 0 and output.offset < bytes.len);
    const progress = output.offset;
    try output.pump(sockets[0]);
    try std.testing.expectEqual(progress, output.offset);
    var received: [16 * 1024]u8 = undefined;
    var len: usize = 0;
    while (len < received.len) {
        const n = std.c.recv(sockets[1], received[len..].ptr, received.len - len, std.c.MSG.DONTWAIT);
        if (n > 0) len += @intCast(n) else try std.testing.expect(std.posix.errno(n) == .AGAIN);
        try output.pump(sockets[0]);
    }
    try std.testing.expectEqualSlices(u8, &bytes, &received);
    try std.testing.expect(!output.status().pending);
    try output.interface.writeAll(&bytes);
    node.write_deadline_ns.store(1, .release);
    try std.testing.expectError(error.ConnectionWriteFailed, output.pump(sockets[0]));
    try std.testing.expectEqual(@as(usize, 0), output.offset);
    node.write_deadline_ns.store(clock.monotonicNs() + std.time.ns_per_s, .release);
    _ = std.c.close(sockets[1]);
    peer_open = false;
    try std.testing.expectError(error.ConnectionWriteFailed, output.pump(sockets[0]));
    output.abort();
    try std.testing.expectError(error.WriteFailed, output.interface.writeAll(&bytes));
}

fn failingOwnedOutput(allocator: std.mem.Allocator) !void {
    const Owner = struct {
        pub fn notify(_: *@This(), _: u64) void {}
    };
    var owner: Owner = .{};
    var registry: @import("drain.zig").Registry = .{ .mutex = .init() };
    defer registry.mutex.deinit();
    var node: @import("drain.zig").Node = undefined;
    registry.attach(&node, -1);
    defer node.detach();
    var buffer: [4096]u8 = undefined;
    var output = Output(Owner).init(&owner, 2, &node, &buffer, allocator);
    defer output.deinit();
    const borrowed = "finite data";
    try output.offer(borrowed);
    try std.testing.expectEqual(borrowed.ptr, output.bytes.ptr);
    try std.testing.expect(output.owned == null);
    output.abort();
    // Reinitialize for the protocol-error copy path. Test every allocation
    // failure independently of borrowed storage and preserve cleanup ownership.
    output.failed = false;
    var bytes: [8192]u8 = undefined;
    @memset(&bytes, 'a');
    output.interface.writeAll(&bytes) catch return error.OutOfMemory;
    try output.interface.flush();
    try std.testing.expect(output.owned != null);
    try std.testing.expectEqualSlices(u8, &bytes, output.bytes);
}
test "finite output borrows storage and owned fallback handles allocation failure" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, failingOwnedOutput, .{});
}
