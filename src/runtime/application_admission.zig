//! Fixed-capacity FIFO for finite application work. Callers synchronize access.
//! The queue owns no task resources; admission transfers a borrow until completion.
const std = @import("std");

pub fn Queue(comptime Task: type) type {
    return struct {
        const Self = @This();
        entries: []Task,
        head: usize = 0,
        len: usize = 0,

        pub fn init(gpa: std.mem.Allocator, capacity: usize) !Self {
            if (capacity == 0) return error.InvalidApplicationTaskLimit;
            return .{ .entries = try gpa.alloc(Task, capacity) };
        }
        pub fn deinit(self: *Self, gpa: std.mem.Allocator) void {
            std.debug.assert(self.len == 0);
            gpa.free(self.entries);
        }
        /// No allocation, blocking or eviction. The caller retains ownership
        /// on rejection and must close/cancel that connection explicitly.
        pub fn push(self: *Self, task: Task) bool {
            if (self.len == self.entries.len) return false;
            self.entries[(self.head + self.len) % self.entries.len] = task;
            self.len += 1;
            return true;
        }
        pub fn pop(self: *Self) ?Task {
            if (self.len == 0) return null;
            const task = self.entries[self.head];
            self.head = (self.head + 1) % self.entries.len;
            self.len -= 1;
            return task;
        }
    };
}

test "application admission rejects overflow without losing accepted FIFO work" {
    var queue = try Queue(u64).init(std.testing.allocator, 3);
    defer queue.deinit(std.testing.allocator);
    try std.testing.expect(queue.push(10));
    try std.testing.expect(queue.push(20));
    try std.testing.expect(queue.push(30));
    try std.testing.expect(!queue.push(40));
    try std.testing.expectEqual(@as(u64, 10), queue.pop().?);
    try std.testing.expect(queue.push(50));
    for ([_]u64{ 20, 30, 50 }) |expected| try std.testing.expectEqual(expected, queue.pop().?);
    try std.testing.expect(queue.pop() == null);
}

test "zero application queue is rejected" {
    try std.testing.expectError(error.InvalidApplicationTaskLimit, Queue(u64).init(std.testing.allocator, 0));
}
