//! Private opt-in diagnostics. Normal application roots compile every hook out.
const std = @import("std");
const root = @import("root");
const clock = @import("../observability/clock.zig");
pub const enabled = @hasDecl(root, "db_diagnostics") and root.db_diagnostics;
pub const Stage = enum { pool_acquire, sqlite_prepare, stmt_wrapper_alloc, bind, step, row_decode, row_copy, stmt_finalize, pool_release, json_serialize };
pub const Counts = struct {
    ns: [10]u64 = @splat(0),
    calls: [10]u64 = @splat(0),
    allocations: u64 = 0,
    frees: u64 = 0,
    bytes: u64 = 0,
    live: usize = 0,
    peak: usize = 0,
};
pub threadlocal var counts: Counts = .{};
pub inline fn begin() u64 {
    return if (enabled) clock.monotonicNs() else 0;
}
pub inline fn end(stage: Stage, start: u64) void {
    if (enabled) {
        counts.ns[@backingInt(stage)] += clock.elapsedNs(start);
        counts.calls[@backingInt(stage)] += 1;
    }
}
// Only used by the diagnostic executable, never installed as a provider default.
var allocator_token: u8 = 0;
pub fn allocator() std.mem.Allocator {
    return .{ .ptr = &allocator_token, .vtable = &.{ .alloc = alloc, .resize = resize, .remap = remap, .free = free } };
}
fn alloc(_: *anyopaque, len: usize, alignment: std.mem.Alignment, ret: usize) ?[*]u8 {
    const memory = std.heap.smp_allocator.rawAlloc(len, alignment, ret) orelse return null;
    counts.allocations += 1;
    counts.bytes += len;
    counts.live += len;
    counts.peak = @max(counts.peak, counts.live);
    return memory;
}
fn resize(_: *anyopaque, _: []u8, _: std.mem.Alignment, _: usize, _: usize) bool {
    return false;
}
fn remap(_: *anyopaque, _: []u8, _: std.mem.Alignment, _: usize, _: usize) ?[*]u8 {
    return null;
}
fn free(_: *anyopaque, memory: []u8, alignment: std.mem.Alignment, ret: usize) void {
    std.heap.smp_allocator.rawFree(memory, alignment, ret);
    counts.frees += 1;
    counts.live -= memory.len;
}
