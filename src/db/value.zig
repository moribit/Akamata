const std = @import("std");

pub const Value = union(enum) {
    null_value: void,
    int: i64,
    float: f64,
    text: []const u8,
    blob: []const u8,

    /// Byte buffers are borrowed. Inline conversion keeps array storage in
    /// the caller instead of returning a slice into a copied parameter.
    pub inline fn fromAny(v: anytype) Value {
        return Converter(@TypeOf(v)).convert(v);
    }

    fn Converter(comptime T: type) type {
        return struct {
            inline fn convert(v: T) Value {
                const info = @typeInfo(T);
                return switch (info) {
                    .null => .{ .null_value = {} },
                    .int, .comptime_int => .{ .int = @intCast(v) },
                    .float, .comptime_float => .{ .float = @floatCast(v) },
                    .bool => .{ .int = if (v) 1 else 0 },
                    .optional => if (v) |inner| Converter(info.optional.child).convert(inner) else .{ .null_value = {} },
                    .pointer => |p| switch (p.size) {
                        .slice => if (p.child == u8) .{ .text = v } else @compileError("Value.fromAny: only []u8 and []const u8 slices are supported"),
                        .one => if (@typeInfo(p.child) == .array and @typeInfo(p.child).array.child == u8)
                            .{ .text = v.*[0..] }
                        else
                            Converter(p.child).convert(v.*),
                        else => @compileError("Value.fromAny: unsupported pointer size"),
                    },
                    .array => if (info.array.child == u8) .{ .text = v[0..] } else @compileError("Value.fromAny: only [N]u8 arrays are supported"),
                    .@"enum" => .{ .int = @backingInt(v) },
                    else => @compileError("Value.fromAny: unsupported type " ++ @typeName(T)),
                };
            }
        };
    }
};

test "byte array forms preserve the complete D1 and SQLite bind length" {
    var fixed: [64]u8 = @as([64]u8, @splat('a'));
    const fixed_value = Value.fromAny(fixed);
    try std.testing.expectEqual(@as(usize, 64), fixed_value.text.len);
    const pointer_value = Value.fromAny(&fixed);
    try std.testing.expectEqual(@as(usize, 64), pointer_value.text.len);
    const mutable_slice: []u8 = fixed[0..31];
    try std.testing.expectEqual(@as(usize, 31), Value.fromAny(mutable_slice).text.len);
    const const_slice: []const u8 = fixed[0..32];
    try std.testing.expectEqual(@as(usize, 32), Value.fromAny(const_slice).text.len);
}
