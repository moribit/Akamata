//! Private experiments. Not imported by the application library.
const std = @import("std");

pub const Scan = enum { scalar, vector };
pub const Predicate = enum { json, field, form };

fn special(comptime kind: Predicate, c: u8) bool {
    return switch (kind) {
        .json => c < 32 or c == '"' or c == '\\',
        .field => (c < 32 and c != '\t') or c == 127,
        .form => c == '%' or c == '+',
    };
}

pub noinline fn find(comptime kind: Predicate, comptime mode: Scan, bytes: []const u8) usize {
    var i: usize = 0;
    if (mode == .vector) {
        const V = @Vector(16, u8);
        while (bytes.len - i >= 16) : (i += 16) {
            const v: V = bytes[i..][0..16].*;
            const matches = switch (kind) {
                .json => (v < @as(V, @splat(32))) | (v == @as(V, @splat('"'))) | (v == @as(V, @splat('\\'))),
                .field => ((v < @as(V, @splat(32))) & (v != @as(V, @splat('\t')))) | (v == @as(V, @splat(127))),
                .form => (v == @as(V, @splat('%'))) | (v == @as(V, @splat('+'))),
            };
            if (@reduce(.Or, matches)) return i + std.simd.firstTrue(matches).?;
        }
    }
    for (bytes[i..], i..) |c, j| if (special(kind, c)) return j;
    return bytes.len;
}

pub const Mask = enum { byte, word32, word64, unrolled, vector16, vector32 };

pub noinline fn maskCopy(comptime mode: Mask, comptime fused: bool, dst: []u8, src: []const u8, key: [4]u8, offset: usize) void {
    std.debug.assert(dst.len == src.len);
    if (!fused) @memcpy(dst, src);
    const input = if (fused) src else dst;
    var i: usize = 0;
    const width = comptime switch (mode) {
        .byte => 1,
        .word32, .unrolled => 4,
        .word64 => 8,
        .vector16 => 16,
        .vector32 => 32,
    };
    if (width > 1) {
        var repeated: [width]u8 = undefined;
        for (&repeated, 0..) |*c, j| c.* = key[(offset +% j) & 3];
        while (src.len - i >= width) : (i += width) {
            switch (mode) {
                .word32, .word64 => {
                    const T = if (width == 4) u32 else u64;
                    const value: T = @bitCast(input[i..][0..width].*);
                    dst[i..][0..width].* = @bitCast(value ^ @as(T, @bitCast(repeated)));
                },
                .unrolled => inline for (0..4) |j| {
                    dst[i + j] = input[i + j] ^ repeated[j];
                },
                .vector16, .vector32 => {
                    const V = @Vector(width, u8);
                    dst[i..][0..width].* = @as(V, input[i..][0..width].*) ^ @as(V, repeated);
                },
                .byte => unreachable,
            }
        }
    }
    while (i < src.len) : (i += 1) dst[i] = input[i] ^ key[(offset +% i) & 3];
}

pub noinline fn escape(comptime mode: Scan, s: []const u8, w: *std.Io.Writer) !void {
    var start: usize = 0;
    var i: usize = 0;
    while (i < s.len) {
        i += find(.json, mode, s[i..]);
        if (i == s.len) break;
        if (i > start) try w.writeAll(s[start..i]);
        switch (s[i]) {
            '"' => try w.writeAll("\\\""),
            '\\' => try w.writeAll("\\\\"),
            '\n' => try w.writeAll("\\n"),
            '\r' => try w.writeAll("\\r"),
            '\t' => try w.writeAll("\\t"),
            8 => try w.writeAll("\\b"),
            12 => try w.writeAll("\\f"),
            else => {
                var buf: [6]u8 = undefined;
                const out = std.fmt.bufPrint(&buf, "\\u{x:0>4}", .{s[i]}) catch unreachable;
                try w.writeAll(out);
            },
        }
        i += 1;
        start = i;
    }
    if (start < s.len) try w.writeAll(s[start..]);
}

pub const Form = enum { byte, bulk_scalar, bulk_vector };
pub noinline fn decode(comptime mode: Form, allocator: std.mem.Allocator, s: []const u8) ![]u8 {
    var buf = try std.ArrayList(u8).initCapacity(allocator, s.len);
    // Match production allocation/error behavior (caller supplies an arena).
    var i: usize = 0;
    while (i < s.len) : (i += 1) {
        if (mode != .byte) {
            const end = i + find(.form, if (mode == .bulk_vector) .vector else .scalar, s[i..]);
            try buf.appendSlice(allocator, s[i..end]);
            i = end;
            if (i == s.len) break;
        }
        const c = s[i];
        if (c == '+') {
            try buf.append(allocator, ' ');
        } else if (c == '%') {
            if (s.len - i < 3) return error.InvalidEscape;
            const hi = hex(s[i + 1]) orelse return error.InvalidEscape;
            const lo = hex(s[i + 2]) orelse return error.InvalidEscape;
            try buf.append(allocator, (hi << 4) | lo);
            i += 2;
        } else {
            try buf.append(allocator, c);
        }
    }
    return buf.toOwnedSlice(allocator);
}

fn hex(c: u8) ?u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'a'...'f' => 10 + (c - 'a'),
        'A'...'F' => 10 + (c - 'A'),
        else => null,
    };
}

test "Form arbitrary input, invalid escapes and allocation failures" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();
    var storage: [257]u8 = undefined;
    var state: u64 = 0x113589;
    for (0..10000) |iteration| {
        _ = arena.reset(.retain_capacity);
        const input = storage[0 .. iteration % storage.len];
        for (input) |*c| {
            state = state *% 6364136223846793005 +% 1;
            c.* = @truncate(state >> 32);
        }
        const expected = decode(.byte, arena.allocator(), input);
        inline for (.{ Form.bulk_scalar, Form.bulk_vector }) |mode| {
            const actual = decode(mode, arena.allocator(), input);
            if (expected) |bytes| {
                try std.testing.expectEqualSlices(u8, bytes, try actual);
            } else |err| try std.testing.expectError(err, actual);
        }
    }
    inline for (.{ Form.byte, Form.bulk_scalar, Form.bulk_vector }) |mode| {
        var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
        try std.testing.expectError(error.OutOfMemory, decode(mode, failing.allocator(), "abc"));
        inline for (.{ "%", "%0", "%GG", "x%0x", "東京%" }) |bad| {
            try std.testing.expectError(error.InvalidEscape, decode(mode, arena.allocator(), bad));
        }
    }
}

test "scan differential: all bytes, lengths, positions and alignments" {
    var storage: [256 + 32]u8 = undefined;
    inline for (comptime std.meta.tags(Predicate)) |kind| {
        for (0..32) |alignment| {
            for (0..130) |len| {
                const bytes = storage[alignment..][0..len];
                @memset(bytes, 'x');
                try std.testing.expectEqual(find(kind, .scalar, bytes), find(kind, .vector, bytes));
                for (0..len) |pos| {
                    for (0..256) |c| {
                        bytes[pos] = @intCast(c);
                        try std.testing.expectEqual(find(kind, .scalar, bytes), find(kind, .vector, bytes));
                    }
                    bytes[pos] = 'x';
                }
            }
        }
    }
}

test "mask differential: all modes, offsets, tails and unaligned input" {
    var src: [289]u8 = undefined;
    for (&src, 0..) |*c, i| c.* = @truncate(i *% 71);
    const original = src;
    var expected: [257]u8 = undefined;
    var actual: [289]u8 = undefined;
    for (0..32) |alignment| {
        for (0..258) |len| {
            for (0..4) |offset| {
                const input = src[alignment..][0..len];
                maskCopy(.byte, false, expected[0..len], input, .{ 0, 255, 93, 128 }, offset);
                inline for (comptime std.meta.tags(Mask)) |mode| {
                    inline for (.{ false, true }) |fused| {
                        const output = actual[31 - alignment ..][0..len];
                        maskCopy(mode, fused, output, input, .{ 0, 255, 93, 128 }, offset);
                        try std.testing.expectEqualSlices(u8, expected[0..len], output);
                    }
                }
            }
        }
    }
    try std.testing.expectEqualSlices(u8, &original, &src);
}

test "JSON differential, arbitrary bytes and writer failure" {
    var input: [513]u8 = undefined;
    var a: [4096]u8 = undefined;
    var b: [4096]u8 = undefined;
    for (&input, 0..) |*c, i| c.* = @truncate(i);
    for (0..input.len + 1) |len| {
        var scalar = std.Io.Writer.fixed(&a);
        var vector = std.Io.Writer.fixed(&b);
        try escape(.scalar, input[0..len], &scalar);
        try escape(.vector, input[0..len], &vector);
        try std.testing.expectEqualSlices(u8, scalar.buffered(), vector.buffered());
        var original = std.Io.Writer.fixed(&a);
        try @import("json.zig").stringify(input[0..len], &original);
        try std.testing.expectEqualSlices(u8, original.buffered()[1 .. original.end - 1], vector.buffered());
        var short = std.Io.Writer.fixed(b[0..0]);
        if (len > 0) try std.testing.expectError(error.WriteFailed, escape(.vector, input[0..len], &short));
    }
}

test "guard pages reject accidental SIMD overread or overwrite" {
    const os = @import("builtin").os.tag;
    if (comptime os != .macos and os != .linux) return error.SkipZigTest;
    const page = std.heap.pageSize();
    const src = std.c.mmap(null, page * 2, .{ .READ = true, .WRITE = true }, .{ .TYPE = .PRIVATE, .ANONYMOUS = true }, -1, 0);
    if (src == std.c.MAP_FAILED) return error.Mmap;
    defer _ = std.c.munmap(@alignCast(src), page * 2);
    const dst = std.c.mmap(null, page * 2, .{ .READ = true, .WRITE = true }, .{ .TYPE = .PRIVATE, .ANONYMOUS = true }, -1, 0);
    if (dst == std.c.MAP_FAILED) return error.Mmap;
    defer _ = std.c.munmap(@alignCast(dst), page * 2);
    const source: [*]u8 = @ptrCast(src);
    const dest: [*]u8 = @ptrCast(dst);
    if (std.c.mprotect(@ptrCast(@alignCast(source + page)), page, .{}) != 0 or std.c.mprotect(@ptrCast(@alignCast(dest + page)), page, .{}) != 0) return error.Mprotect;
    for (0..258) |len| {
        const input = source[page - len .. page];
        const output = dest[page - len .. page];
        @memset(input, 'x');
        inline for (comptime std.meta.tags(Predicate)) |kind| try std.testing.expectEqual(len, find(kind, .vector, input));
        try std.testing.expect(!@import("internal/byte_ops.zig").containsFieldControl(input));
        inline for (comptime std.meta.tags(Mask)) |mode| {
            inline for (.{ false, true }) |fused| maskCopy(mode, fused, output, input, .{ 0, 1, 2, 3 }, 0);
        }
        var writer = std.Io.Writer.fixed(output);
        try escape(.vector, input, &writer);
        try std.testing.expectEqualSlices(u8, input, writer.buffered());
    }
}
