//! Bounded, deduplicated generation tokens; no borrowed connection pointers.
const std = @import("std");
const Mutex = @import("../sync.zig").Mutex;
pub const Queue = struct {
    mutex: Mutex,
    tokens: []u64,
    tags: []u64,
    head: usize = 0,
    len: usize = 0,
    overflow: bool = false,
    pub fn init(gpa: std.mem.Allocator, capacity: usize) !Queue {
        const tokens = try gpa.alloc(u64, capacity);
        errdefer gpa.free(tokens);
        const tags = try gpa.alloc(u64, capacity);
        @memset(tags, 0);
        return .{ .mutex = .init(), .tokens = tokens, .tags = tags };
    }
    pub fn deinit(self: *Queue, gpa: std.mem.Allocator) void {
        self.mutex.deinit();
        gpa.free(self.tokens);
        gpa.free(self.tags);
    }
    pub fn push(self: *Queue, token: u64) void {
        const slot: usize = @as(u32, @truncate(token)) - 2;
        self.mutex.lock();
        defer self.mutex.unlock();
        if (self.tags[slot] == token) return;
        self.tags[slot] = token;
        if (self.len == self.tokens.len) {
            self.overflow = true;
            return;
        }
        self.tokens[(self.head + self.len) % self.tokens.len] = token;
        self.len += 1;
    }
    pub fn pop(self: *Queue) ?u64 {
        self.mutex.lock();
        defer self.mutex.unlock();
        if (self.len == 0) return null;
        const token = self.tokens[self.head];
        self.head = (self.head + 1) % self.tokens.len;
        self.len -= 1;
        const slot: usize = @as(u32, @truncate(token)) - 2;
        if (self.tags[slot] == token) self.tags[slot] = 0;
        return token;
    }
    pub fn takeOverflow(self: *Queue) bool {
        self.mutex.lock();
        defer self.mutex.unlock();
        const value = self.overflow;
        self.overflow = false;
        if (value) @memset(self.tags, 0);
        return value;
    }
};

test "generation replacement and full notification queue remain bounded" {
    var queue = try Queue.init(std.testing.allocator, 2);
    defer queue.deinit(std.testing.allocator);
    queue.push((@as(u64, 1) << 32) | 2);
    queue.push((@as(u64, 1) << 32) | 3);
    queue.push((@as(u64, 2) << 32) | 2);
    try std.testing.expectEqual(@as(usize, 2), queue.len);
    try std.testing.expect(queue.takeOverflow());
    while (queue.pop() != null) {}
    queue.push((@as(u64, 2) << 32) | 2);
    try std.testing.expectEqual((@as(u64, 2) << 32) | 2, queue.pop().?);
}
