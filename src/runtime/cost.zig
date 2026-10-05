//! Compile-time opt-in attribution. Aggregates are inclusive across threads;
//! wall wait is not CPU, and timed regions may overlap. Never sum nested regions.
const std = @import("std");
pub const enabled = @import("build_options").runtime_cost and @import("build_options").backend == .native;
pub const Kind = enum {
    parse,
    dispatch,
    read,
    serialize,
    send,
    enqueue,
    worker_lock,
    worker_wait,
    worker_work,
    queue_wait,
    completion_publish,
    completion_wait,
    selector_wait,
    selector_update,
    selector_add,
    selector_modify,
    selector_delete,
    selector_same,
    writable_enable,
    writable_disable,
    notify,
    wake_write,
    wake_read,
    loop,
    request,
    recv_call,
    send_call,
    accept_call,
    copy_bytes,
    poll_call,
    readvec_call,
    mutex_lock,
    mutex_unlock,
    condition_wait,
    condition_signal,
    condition_broadcast,
};
const Value = struct {
    count: std.atomic.Value(u64) = .init(0),
    wall: std.atomic.Value(u64) = .init(0),
    cpu: std.atomic.Value(u64) = .init(0),
};
var values: [@typeInfo(Kind).@"enum".field_names.len]Value = @splat(.{});
pub fn add(kind: Kind, n: u64) void {
    if (comptime enabled) _ = values[@backingInt(kind)].count.fetchAdd(n, .monotonic);
}
pub fn now() u64 {
    if (comptime !enabled) return 0;
    return @import("../observability/clock.zig").monotonicNs();
}
fn cpuNow() u64 {
    if (comptime !enabled) return 0;
    var ts: std.c.timespec = undefined;
    if (std.c.clock_gettime(.THREAD_CPUTIME_ID, &ts) != 0) return 0;
    return @as(u64, @intCast(ts.sec)) * std.time.ns_per_s + @as(u64, @intCast(ts.nsec));
}
pub fn elapsed(kind: Kind, started: u64) void {
    if (comptime enabled) {
        add(kind, 1);
        _ = values[@backingInt(kind)].wall.fetchAdd(now() -| started, .monotonic);
    }
}
pub const Span = struct {
    wall: u64 = 0,
    cpu: u64 = 0,
    pub fn end(self: Span, kind: Kind) void {
        if (comptime enabled) {
            const wall = now() -| self.wall;
            const cpu = cpuNow() -| self.cpu;
            add(kind, 1);
            _ = values[@backingInt(kind)].wall.fetchAdd(wall, .monotonic);
            _ = values[@backingInt(kind)].cpu.fetchAdd(cpu, .monotonic);
        }
    }
};
pub fn begin() Span {
    if (comptime !enabled) return .{};
    return .{ .wall = now(), .cpu = cpuNow() };
}
pub fn report() void {
    if (comptime enabled) {
        std.debug.print("RUNTIME_COST {{", .{});
        inline for (@typeInfo(Kind).@"enum".field_names, 0..) |field, i| {
            std.debug.print("{s}\"{s}\":{{\"count\":{d},\"wall_ns\":{d},\"cpu_ns\":{d}}}", .{
                if (i == 0) "" else ",", field, values[i].count.load(.monotonic), values[i].wall.load(.monotonic), values[i].cpu.load(.monotonic),
            });
        }
        std.debug.print("}}\n", .{});
    }
}
