//! Experimental HTTP/MIME field validation; not imported by the public library.
//! All loads are slice bounded. See docs/evidence/simd-optimization/results.md.
const std = @import("std");

pub fn containsFieldControl(bytes: []const u8) bool {
    // Avoid vector-loop setup (and a stack frame on some backends) for the
    // empty/single-byte fields common in framing headers.
    if (bytes.len == 0) return false;
    if (bytes.len == 1) {
        const ch = bytes[0];
        return (ch < 32 and ch != '\t') or ch == 127;
    }
    var rest = bytes;
    if (comptime std.simd.suggestVectorLength(u8) != null) {
        const V = @Vector(16, u8);
        while (rest.len >= 16) {
            const v: V = rest[0..16].*;
            const forbidden = ((v < @as(V, @splat(32))) & (v != @as(V, @splat('\t')))) | (v == @as(V, @splat(127)));
            if (@reduce(.Or, forbidden)) return true;
            rest = rest[16..];
        }
    }
    return scalar(rest);
}

fn scalar(bytes: []const u8) bool {
    for (bytes) |ch| if ((ch < 32 and ch != '\t') or ch == 127) return true;
    return false;
}

test "field control predicate matches scalar for every byte and alignment" {
    var storage: [161]u8 = undefined;
    for (0..32) |alignment| {
        for (0..130) |len| {
            const bytes = storage[alignment..][0..len];
            @memset(bytes, 'x');
            try std.testing.expectEqual(scalar(bytes), containsFieldControl(bytes));
            for (0..len) |pos| {
                for (0..256) |value| {
                    bytes[pos] = @intCast(value);
                    try std.testing.expectEqual(scalar(bytes), containsFieldControl(bytes));
                }
                bytes[pos] = 'x';
            }
        }
    }
}
