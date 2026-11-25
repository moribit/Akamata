//! Offline private candidate benchmark; timings are not server throughput.
const std = @import("std");
const ops = @import("simd_candidates.zig");
const clock = @import("observability/clock.zig");
const sizes = [_]usize{ 0, 1, 7, 8, 15, 16, 17, 31, 32, 33, 63, 64, 65, 128, 256, 512, 1024, 4096, 16384, 65536 };

fn report(kind: []const u8, mode: []const u8, size: usize, round: usize, n: usize, ns: u64, checksum: usize) void {
    std.debug.print("SIMD {{\"kind\":\"{s}\",\"mode\":\"{s}\",\"size\":{d},\"round\":{d},\"iterations\":{d},\"elapsed_ns\":{d},\"checksum\":{d}}}\n", .{ kind, mode, size, round, n, ns, checksum });
}

fn scan(comptime kind: ops.Predicate, comptime mode: ops.Scan, input: []const u8, n: usize, round: usize) void {
    var sum: usize = 0;
    const start = clock.monotonicNs();
    var total: usize = 0;
    while (total == 0 or clock.elapsedNs(start) < 10_000_000) : (total += n) {
        for (0..n) |_| {
            std.mem.doNotOptimizeAway(input);
            sum +%= ops.find(kind, mode, input);
        }
    }
    report(@tagName(kind), @tagName(mode), input.len, round, total, clock.elapsedNs(start), sum);
}

fn mask(comptime mode: ops.Mask, comptime fused: bool, input: []const u8, output: []u8, n: usize, round: usize) void {
    var sum: usize = 0;
    const start = clock.monotonicNs();
    var total: usize = 0;
    while (total == 0 or clock.elapsedNs(start) < 10_000_000) : (total += n) {
        for (0..n) |_| {
            std.mem.doNotOptimizeAway(input);
            ops.maskCopy(mode, fused, output, input, .{ 17, 99, 128, 255 }, 0);
            std.mem.doNotOptimizeAway(output);
            if (output.len > 0) sum +%= output[output.len - 1];
        }
    }
    report(if (fused) "mask-fused" else "mask-copy-then-xor", @tagName(mode), input.len, round, total, clock.elapsedNs(start), sum);
}

fn json(comptime mode: ops.Scan, kind: []const u8, input: []const u8, output: []u8, n: usize, round: usize) !void {
    var sum: usize = 0;
    const start = clock.monotonicNs();
    var total: usize = 0;
    while (total == 0 or clock.elapsedNs(start) < 10_000_000) : (total += n) {
        for (0..n) |_| {
            std.mem.doNotOptimizeAway(input);
            var writer = std.Io.Writer.fixed(output);
            if (mode == .scalar) {
                try @import("json.zig").stringify(input, &writer);
            } else {
                try writer.writeByte('"');
                try ops.escape(mode, input, &writer);
                try writer.writeByte('"');
            }
            std.mem.doNotOptimizeAway(writer.buffered());
            sum +%= writer.end;
        }
    }
    report(kind, @tagName(mode), input.len, round, total, clock.elapsedNs(start), sum);
}

fn form(comptime mode: ops.Form, kind: []const u8, input: []const u8, n: usize, round: usize) !void {
    var arena: std.heap.ArenaAllocator = .init(std.heap.smp_allocator);
    defer arena.deinit();
    // Reserve backing memory before measuring; allocation operations remain timed.
    _ = try ops.decode(mode, arena.allocator(), input);
    _ = arena.reset(.retain_capacity);
    var sum: usize = 0;
    const start = clock.monotonicNs();
    var total: usize = 0;
    while (total == 0 or clock.elapsedNs(start) < 10_000_000) : (total += n) {
        for (0..n) |_| {
            std.mem.doNotOptimizeAway(input);
            const decoded = try ops.decode(mode, arena.allocator(), input);
            std.mem.doNotOptimizeAway(decoded);
            sum +%= decoded.len;
            _ = arena.reset(.retain_capacity);
        }
    }
    report(kind, @tagName(mode), input.len, round, total, clock.elapsedNs(start), sum);
}

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const rounds = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 11;
    const order = if (args.len > 2) try std.fmt.parseInt(usize, args[2], 10) else 0;
    var storage: [65537]u8 = @splat('x');
    var output: [65536 * 6]u8 = undefined;
    for (sizes) |size| {
        // Unaligned input, full bounded loads only. Round zero is warmup.
        const input = storage[1..][0..size];
        const n = @max(128, @min(200_000, 2 * 1024 * 1024 / @max(size, 1)));
        for (0..rounds) |round| {
            inline for (comptime std.meta.tags(ops.Predicate)) |kind| {
                if ((round + order) % 2 == 0) {
                    scan(kind, .scalar, input, n, round);
                    scan(kind, .vector, input, n, round);
                } else {
                    scan(kind, .vector, input, n, round);
                    scan(kind, .scalar, input, n, round);
                }
            }
            // Reverse ordering between rounds to reduce order/thermal bias.
            inline for (0..6) |index| {
                const modes = comptime std.meta.tags(ops.Mask);
                inline for (.{ false, true }) |fused| {
                    if ((round + order) % 2 == 0) mask(modes[index], fused, input, output[0..size], n, round) else mask(modes[5 - index], fused, input, output[0..size], n, round);
                }
            }
        }
        inline for (.{ "json-clean", "json-sparse", "json-dense", "json-utf8", "json-invalid-utf8" }, 0..) |kind, density| {
            @memset(input, 'x');
            for (input, 0..) |*c, i| {
                if (density == 1 and i % 97 == 0) c.* = '\n';
                if (density == 2) c.* = "\"\\\n\t"[i % 4];
                if (density == 3) c.* = "東京🙂"[i % "東京🙂".len];
                if (density == 4) c.* = @truncate(i);
            }
            for (0..rounds) |round| {
                if ((round + order) % 2 == 0) {
                    try json(.scalar, kind, input, &output, n, round);
                    try json(.vector, kind, input, &output, n, round);
                } else {
                    try json(.vector, kind, input, &output, n, round);
                    try json(.scalar, kind, input, &output, n, round);
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
            // Percent encodings at the truncated tail must remain complete.
            if (density == 3) {
                var i = input.len - input.len % 3;
                while (i < input.len) : (i += 1) input[i] = 'x';
            }
            for (0..rounds) |round| {
                if ((round + order) % 2 == 0) {
                    try form(.byte, kind, input, n, round);
                    try form(.bulk_scalar, kind, input, n, round);
                    try form(.bulk_vector, kind, input, n, round);
                } else {
                    try form(.bulk_vector, kind, input, n, round);
                    try form(.bulk_scalar, kind, input, n, round);
                    try form(.byte, kind, input, n, round);
                }
            }
        }
        @memset(input, 'x');
    }
}
