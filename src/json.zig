const reflection = @import("reflection.zig");
const std = @import("std");

pub const ParseError = error{ Invalid, OutOfMemory };

/// Lenient JSON parse — unknown fields are dropped, duplicate fields keep the
/// last value. Suitable for user-supplied request bodies where forward/back-
/// ward compatibility matters more than catching typos.
pub fn parseLeaky(comptime T: type, arena: std.mem.Allocator, bytes: []const u8) !T {
    return std.json.parseFromSliceLeaky(T, arena, bytes, .{
        .ignore_unknown_fields = true,
        .duplicate_field_behavior = .use_last,
    });
}

/// Strict JSON parse — rejects unknown fields and duplicate fields. Use for
/// security-relevant inputs (JWT claims, RBAC payloads) where ignoring an
/// extra field could silently mask a mass-assignment attempt.
pub fn parseLeakyStrict(comptime T: type, arena: std.mem.Allocator, bytes: []const u8) !T {
    return std.json.parseFromSliceLeaky(T, arena, bytes, .{
        .ignore_unknown_fields = false,
        .duplicate_field_behavior = .@"error",
    });
}

pub fn stringify(value: anytype, writer: *std.Io.Writer) !void {
    // Comptime-specialised fast path. For supported shapes (struct, slice,
    // int, float, bool, optional, enum, null) we generate straight-line
    // emission code per call site, no reflection at runtime. Anything else
    // (unions other than optional, fn ptrs, etc.) falls back to the std
    // serialiser via `appendValue`.
    try appendValue(@TypeOf(value), value, writer);
}

/// Recursive comptime emitter. Handles the type shapes the framework uses
/// for handler responses; falls back to `std.json.Stringify.value` for the
/// long tail.
pub fn appendValue(comptime T: type, value: T, w: *std.Io.Writer) !void {
    if (T == []const u8 or T == []u8) {
        return appendStringLiteral(value, w);
    }
    const info = @typeInfo(T);
    switch (info) {
        .void => try w.writeAll("null"),
        .null => try w.writeAll("null"),
        .bool => try w.writeAll(if (value) "true" else "false"),
        .int, .comptime_int => {
            // Let Writer size its integer formatting buffer for the actual
            // Zig type, including u128/i128, rather than assuming 64-bit values.
            try w.print("{d}", .{value});
        },
        .float, .comptime_float => {
            // Decimal output of a finite f64 can exceed 32 characters. Preserve
            // the existing decimal representation without a fixed-size trap.
            try w.print("{d}", .{value});
        },
        .optional => {
            if (value) |v| try appendValue(@TypeOf(v), v, w) else try w.writeAll("null");
        },
        .@"enum" => {
            // Enums become their tag name as a JSON string. Models that
            // need a different mapping should use `__schema.enums` on the
            // model side; that translation is handled before reaching here.
            try w.writeByte('"');
            try escapeAscii(@tagName(value), w);
            try w.writeByte('"');
        },
        .pointer => |p| {
            if (p.size == .slice) {
                if (p.child == u8) return appendStringLiteral(value, w);
                try w.writeByte('[');
                for (value, 0..) |item, i| {
                    if (i > 0) try w.writeByte(',');
                    try appendValue(@TypeOf(item), item, w);
                }
                try w.writeByte(']');
                return;
            }
            if (p.size == .one) {
                return appendValue(p.child, value.*, w);
            }
            // Unsupported pointer shape — defer to std.
            return std.json.Stringify.value(value, .{}, w);
        },
        .array => |a| {
            if (a.child == u8) return appendStringLiteral(&value, w);
            try w.writeByte('[');
            inline for (value, 0..) |item, i| {
                if (i > 0) try w.writeByte(',');
                try appendValue(@TypeOf(item), item, w);
            }
            try w.writeByte(']');
        },
        .@"struct" => |s| {
            // Preserve ordinary Zig custom wire representations (for example
            // BoundedString), rather than exposing their storage fields.
            if (comptime @hasDecl(T, "jsonStringify")) return std.json.Stringify.value(value, .{}, w);
            try w.writeByte('{');
            comptime var first = true;
            inline for (reflection.fields(s)) |f| {
                if (!first) try w.writeByte(',');
                first = false;
                try w.writeByte('"');
                try escapeAscii(f.name, w);
                try w.writeAll("\":");
                try appendValue(f.type, @field(value, f.name), w);
            }
            try w.writeByte('}');
        },
        else => return std.json.Stringify.value(value, .{}, w),
    }
}

/// Emit `"…"` with JSON escaping. We hand-roll the common cases (no per-byte
/// branch into std) since this dominates handler hot paths.
fn appendStringLiteral(s: []const u8, w: *std.Io.Writer) !void {
    try w.writeByte('"');
    try escapeJsonString(s, w);
    try w.writeByte('"');
}

fn escapeJsonString(s: []const u8, w: *std.Io.Writer) !void {
    var start: usize = 0;
    var i: usize = 0;
    while (i < s.len) : (i += 1) {
        const c = s[i];
        // Fast path: ASCII printable that needs no escape.
        if (c >= 0x20 and c != '"' and c != '\\') continue;

        if (i > start) try w.writeAll(s[start..i]);
        switch (c) {
            '"' => try w.writeAll("\\\""),
            '\\' => try w.writeAll("\\\\"),
            '\n' => try w.writeAll("\\n"),
            '\r' => try w.writeAll("\\r"),
            '\t' => try w.writeAll("\\t"),
            8 => try w.writeAll("\\b"),
            12 => try w.writeAll("\\f"),
            else => {
                // Other control chars → \u00XX
                var buf: [6]u8 = undefined;
                const out = std.fmt.bufPrint(&buf, "\\u{x:0>4}", .{c}) catch unreachable;
                try w.writeAll(out);
            },
        }
        start = i + 1;
    }
    if (start < s.len) try w.writeAll(s[start..]);
}

/// Ascii-only escape for field names (no Unicode in our generated keys).
fn escapeAscii(s: []const u8, w: *std.Io.Writer) !void {
    return escapeJsonString(s, w);
}

pub fn allocStringify(arena: std.mem.Allocator, value: anytype) ![]u8 {
    var aw: std.Io.Writer.Allocating = .init(arena);
    defer aw.deinit();
    try std.json.Stringify.value(value, .{}, &aw.writer);
    const list = aw.toArrayList();
    return list.items;
}

test "fast JSON preserves custom bounded wire representation" {
    const BoundedString = @import("contract/bounded.zig").BoundedString;
    const value = .{ .text = try BoundedString(64).init("hello") };
    var output: std.Io.Writer.Allocating = .init(std.testing.allocator);
    defer output.deinit();
    try stringify(value, &output.writer);
    try std.testing.expectEqualStrings("{\"text\":\"hello\"}", output.written());
}

test "JSON numeric output supports wide integers and finite float extremes" {
    inline for (.{ @as(u128, std.math.maxInt(u128)), @as(i128, std.math.minInt(i128)), @as(f64, 1e308), @as(f64, 1e-308) }) |value| {
        var output: std.Io.Writer.Allocating = .init(std.testing.allocator);
        defer output.deinit();
        try stringify(value, &output.writer);
        const decoded = try std.json.parseFromSlice(@TypeOf(value), std.testing.allocator, output.written(), .{});
        defer decoded.deinit();
        try std.testing.expectEqual(value, decoded.value);
    }
}
