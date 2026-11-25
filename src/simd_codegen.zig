//! Private stable symbols for inspecting compiler output; not application API.
const ops = @import("simd_candidates.zig");
const std = @import("std");
export fn json_scalar(p: [*]const u8, n: usize) usize {
    return ops.find(.json, .scalar, p[0..n]);
}
export fn json_vector(p: [*]const u8, n: usize) usize {
    return ops.find(.json, .vector, p[0..n]);
}
export fn field_scalar(p: [*]const u8, n: usize) usize {
    return ops.find(.field, .scalar, p[0..n]);
}
export fn field_vector(p: [*]const u8, n: usize) usize {
    return ops.find(.field, .vector, p[0..n]);
}
export fn std_search(p: [*]const u8, n: usize) usize {
    return std.mem.indexOfScalar(u8, p[0..n], '\r') orelse n;
}
export fn mask_byte(dst: [*]u8, src: [*]const u8, n: usize) void {
    ops.maskCopy(.byte, true, dst[0..n], src[0..n], .{ 17, 99, 128, 255 }, 0);
}
export fn mask_word(dst: [*]u8, src: [*]const u8, n: usize) void {
    ops.maskCopy(.word64, true, dst[0..n], src[0..n], .{ 17, 99, 128, 255 }, 0);
}
export fn mask_vector(dst: [*]u8, src: [*]const u8, n: usize) void {
    ops.maskCopy(.vector16, true, dst[0..n], src[0..n], .{ 17, 99, 128, 255 }, 0);
}
