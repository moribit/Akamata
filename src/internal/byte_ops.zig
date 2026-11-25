//! Internal HTTP/MIME field-value validation. All loads are slice bounded.
const std = @import("std");

pub fn containsFieldControl(bytes: []const u8) bool {
    // Avoid vector-loop setup (and a stack frame on some backends) for the
    // empty/single-byte fields common in framing headers.
    if (bytes.len == 0) return false;
    if (bytes.len == 1) {
        const ch = bytes[0];
        return (ch < 32 and ch != '\t') or ch == 127;
    }
    var i: usize = 0;
    if (comptime std.simd.suggestVectorLength(u8) != null) {
        const V = @Vector(16, u8);
        while (bytes.len - i >= 16) : (i += 16) {
            const v: V = bytes[i..][0..16].*;
            const forbidden = ((v < @as(V, @splat(32))) & (v != @as(V, @splat('\t')))) | (v == @as(V, @splat(127)));
            if (@reduce(.Or, forbidden)) return true;
        }
    }
    return scalar(bytes[i..]);
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
