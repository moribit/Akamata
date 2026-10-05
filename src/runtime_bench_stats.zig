//! Opt-in benchmark instrumentation; excludes libc/SQLite malloc and stacks.
const std = @import("std");
const Alignment = std.mem.Alignment;
pub const Stats = struct {
    backing: std.mem.Allocator,
    calls: std.atomic.Value(u64) = .init(0),
    requested: std.atomic.Value(u64) = .init(0),
    live: std.atomic.Value(u64) = .init(0),
    peak: std.atomic.Value(u64) = .init(0),
    pub fn allocator(self: *Stats) std.mem.Allocator {
        return .{ .ptr = self, .vtable = &.{ .alloc = alloc, .resize = resize, .remap = remap, .free = free } };
    }
    fn grow(self: *Stats, bytes: usize) void {
        _ = self.requested.fetchAdd(bytes, .monotonic);
        const total = self.live.fetchAdd(bytes, .monotonic) + bytes;
        _ = self.peak.fetchMax(total, .monotonic);
    }
    fn adjust(self: *Stats, old: usize, new: usize) void {
        if (new >= old) self.grow(new - old) else _ = self.live.fetchSub(old - new, .monotonic);
    }
    fn alloc(ptr: *anyopaque, len: usize, alignment: Alignment, ret: usize) ?[*]u8 {
        const self: *Stats = @ptrCast(@alignCast(ptr));
        const result = self.backing.rawAlloc(len, alignment, ret) orelse return null;
        _ = self.calls.fetchAdd(1, .monotonic);
        self.grow(len);
        return result;
    }
    fn resize(ptr: *anyopaque, memory: []u8, alignment: Alignment, len: usize, ret: usize) bool {
        const self: *Stats = @ptrCast(@alignCast(ptr));
        if (!self.backing.rawResize(memory, alignment, len, ret)) return false;
        self.adjust(memory.len, len);
        return true;
    }
    fn remap(ptr: *anyopaque, memory: []u8, alignment: Alignment, len: usize, ret: usize) ?[*]u8 {
        const self: *Stats = @ptrCast(@alignCast(ptr));
        const result = self.backing.rawRemap(memory, alignment, len, ret) orelse return null;
        self.adjust(memory.len, len);
        return result;
    }
    fn free(ptr: *anyopaque, memory: []u8, alignment: Alignment, ret: usize) void {
        const self: *Stats = @ptrCast(@alignCast(ptr));
        self.backing.rawFree(memory, alignment, ret);
        _ = self.live.fetchSub(memory.len, .monotonic);
    }
    pub fn report(self: *Stats) void {
        std.debug.print("BENCH_STATS {{\"calls\":{d},\"requested\":{d},\"live\":{d},\"peak\":{d}}}\n", .{
            self.calls.load(.monotonic), self.requested.load(.monotonic), self.live.load(.monotonic), self.peak.load(.monotonic),
        });
    }
};
