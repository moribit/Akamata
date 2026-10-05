//! Indexed min heap: at most one timer per admitted connection, no stale growth.
const std = @import("std");
pub const Entry = struct { slot: usize, deadline: u64 };
pub const Heap = struct {
    entries: []Entry,
    positions: []usize,
    len: usize = 0,
    const absent = std.math.maxInt(usize);
    pub fn init(allocator: std.mem.Allocator, capacity: usize) !Heap {
        const entries = try allocator.alloc(Entry, capacity);
        errdefer allocator.free(entries);
        const positions = try allocator.alloc(usize, capacity);
        @memset(positions, absent);
        return .{ .entries = entries, .positions = positions };
    }
    pub fn deinit(self: *Heap, allocator: std.mem.Allocator) void {
        allocator.free(self.entries);
        allocator.free(self.positions);
    }
    pub fn top(self: *Heap) ?Entry {
        return if (self.len == 0) null else self.entries[0];
    }
    fn swap(self: *Heap, a: usize, b: usize) void {
        std.mem.swap(Entry, &self.entries[a], &self.entries[b]);
        self.positions[self.entries[a].slot] = a;
        self.positions[self.entries[b].slot] = b;
    }
    fn up(self: *Heap, start: usize) void {
        var i = start;
        while (i > 0) {
            const parent = (i - 1) / 2;
            if (self.entries[parent].deadline <= self.entries[i].deadline) break;
            self.swap(i, parent);
            i = parent;
        }
    }
    fn down(self: *Heap, start: usize) void {
        var i = start;
        while (i * 2 + 1 < self.len) {
            var child = i * 2 + 1;
            if (child + 1 < self.len and self.entries[child + 1].deadline < self.entries[child].deadline) child += 1;
            if (self.entries[i].deadline <= self.entries[child].deadline) break;
            self.swap(i, child);
            i = child;
        }
    }
    pub fn remove(self: *Heap, slot: usize) void {
        const index = self.positions[slot];
        if (index == absent) return;
        self.positions[slot] = absent;
        self.len -= 1;
        if (index == self.len) return;
        self.entries[index] = self.entries[self.len];
        self.positions[self.entries[index].slot] = index;
        const moved = self.entries[index].slot;
        self.up(index);
        self.down(self.positions[moved]);
    }
    pub fn set(self: *Heap, slot: usize, deadline: u64) void {
        if (deadline == 0) {
            self.remove(slot);
            return;
        }
        if (self.positions[slot] == absent) {
            const i = self.len;
            self.len += 1;
            self.entries[i] = .{ .slot = slot, .deadline = deadline };
            self.positions[slot] = i;
            self.up(i);
        } else {
            const i = self.positions[slot];
            self.entries[i].deadline = deadline;
            self.up(i);
            self.down(self.positions[slot]);
        }
    }
};

test "indexed deadlines replace/remove without stale entries" {
    var heap = try Heap.init(std.testing.allocator, 8);
    defer heap.deinit(std.testing.allocator);
    heap.set(0, 100);
    heap.set(1, 20);
    heap.set(2, 30);
    heap.set(1, 200);
    try std.testing.expectEqual(@as(usize, 2), heap.top().?.slot);
    heap.remove(2);
    try std.testing.expectEqual(@as(usize, 0), heap.top().?.slot);
    for (0..10000) |n| heap.set(1, @intCast(n + 1));
    try std.testing.expectEqual(@as(usize, 2), heap.len);
    heap.set(0, 0);
    heap.set(1, 0);
    try std.testing.expect(heap.top() == null);
}

test "indexed timer updates match a reference under replacement churn" {
    var heap = try Heap.init(std.testing.allocator, 64);
    defer heap.deinit(std.testing.allocator);
    var model: [64]u64 = @splat(0);
    var random: u64 = 42;
    for (0..10000) |_| {
        random = random *% 6364136223846793005 +% 1;
        const slot: usize = @intCast(random % model.len);
        random = random *% 6364136223846793005 +% 1;
        const deadline = if (random % 5 == 0) 0 else random % 1000 + 1;
        model[slot] = deadline;
        heap.set(slot, deadline);
        var count: usize = 0;
        var minimum: u64 = std.math.maxInt(u64);
        for (model, 0..) |value, i| if (value != 0) {
            count += 1;
            minimum = @min(minimum, value);
            try std.testing.expectEqual(i, heap.entries[heap.positions[i]].slot);
        };
        try std.testing.expectEqual(count, heap.len);
        if (count == 0) try std.testing.expect(heap.top() == null) else try std.testing.expectEqual(minimum, heap.top().?.deadline);
    }
}
