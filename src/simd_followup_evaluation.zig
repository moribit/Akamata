//! Exact production field predicate and an ArrayList-free scalar Form control.
const std = @import("std");
const bench = @import("simd_evaluation.zig");
const clock = @import("observability/clock.zig");
const field = @import("internal/byte_ops.zig");
const ops = @import("simd_candidates.zig");

noinline fn contains(comptime vector: bool, input: []const u8) bool {
    if (vector) return field.containsFieldControl(input);
    for (input) |ch| if (ch == '\r' or ch == '\n' or ch == 0 or (ch < 32 and ch != '\t') or ch == 127) return true;
    return false;
}

fn sample(comptime vector: bool, kind: []const u8, input: []const u8, round: usize) void {
    var sum: usize = 0;
    var count: usize = 0;
    const start = clock.monotonicNs();
    while (count == 0 or clock.elapsedNs(start) < 10_000_000) {
        for (0..1024) |_| {
            std.mem.doNotOptimizeAway(input);
            sum +%= @intFromBool(contains(vector, input));
        }
        count += 1024;
    }
    bench.report(kind, if (vector) "vector" else "scalar", input.len, round, count, clock.elapsedNs(start), sum);
}

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const rounds = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 11;
    const order = if (args.len > 2) try std.fmt.parseInt(usize, args[2], 10) else 0;
    var storage: [65537]u8 = undefined;
    for ([_]usize{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 15, 16, 17, 31, 32, 33, 63, 64, 65, 128, 256, 512, 1024, 4096, 16384, 65536 }) |size| {
        const input = storage[1..][0..size];
        inline for (.{ "field-production-clean", "field-production-first", "field-production-middle", "field-production-last" }, 0..) |kind, position| {
            @memset(input, 'x');
            if (size > 0 and position > 0) input[
                switch (position) {
                    1 => 0,
                    2 => size / 2,
                    else => size - 1,
                }
            ] = 127;
            for (0..rounds) |round| {
                if ((round + order) % 2 == 0) {
                    sample(false, kind, input, round);
                    sample(true, kind, input, round);
                } else {
                    sample(true, kind, input, round);
                    sample(false, kind, input, round);
                }
            }
        }
        inline for (.{ "form-clean", "form-sparse", "form-dense", "form-japanese" }, 0..) |kind, density| {
            @memset(input, 'x');
            for (input, 0..) |*c, i| {
                if (density == 1 and i % 97 == 0) c.* = '+';
                if (density == 2) c.* = '+';
                if (density == 3) c.* = "%E6%9D%B1%E4%BA%AC"[i % 18];
            }
            if (density == 3) @memset(input[input.len - input.len % 3 ..], 'x');
            for (0..rounds) |round| {
                inline for (0..4) |index| {
                    const modes = .{ ops.Form.byte, ops.Form.direct, ops.Form.bulk_scalar, ops.Form.bulk_vector };
                    if ((round + order) % 2 == 0) try bench.form(modes[index], kind, input, 128, round) else try bench.form(modes[3 - index], kind, input, 128, round);
                }
            }
        }
    }
}
