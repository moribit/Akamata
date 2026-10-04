const std = @import("std");
const STABLE_HASH = @import("../release.zig").STABLE_HASH;
const readFileAlloc = @import("files.zig").readFileAlloc;

/// Read `.name = .<ident>,` from build.zig.zon. Zig requires the package name
/// to be an enum literal, so we read the bareword after `.name = .`.
pub fn readZonName(alloc: std.mem.Allocator) !?[]const u8 {
    const content = readFileAlloc(alloc, "build.zig.zon", 1 * 1024 * 1024) catch return null;
    defer alloc.free(content);
    const key = ".name";
    const ki = std.mem.indexOf(u8, content, key) orelse return null;
    var i = ki + key.len;
    // skip spaces, '=', spaces, then the leading '.' of the enum literal
    while (i < content.len and (content[i] == ' ' or content[i] == '\t' or content[i] == '=')) i += 1;
    if (i >= content.len or content[i] != '.') return null;
    i += 1;
    const start = i;
    while (i < content.len and (std.ascii.isAlphanumeric(content[i]) or content[i] == '_')) i += 1;
    if (i == start) return null;
    return try alloc.dupe(u8, content[start..i]);
}

pub fn quotedFieldRange(content: []const u8, start: usize, field: []const u8) ?struct { usize, usize } {
    const rel = std.mem.indexOf(u8, content[start..], field) orelse return null;
    const field_pos = start + rel;
    const quote = std.mem.indexOfScalarPos(u8, content, field_pos + field.len, '"') orelse return null;
    const end = std.mem.indexOfScalarPos(u8, content, quote + 1, '"') orelse return null;
    return .{ quote + 1, end };
}

pub fn replaceRange(alloc: std.mem.Allocator, content: []const u8, start: usize, end: usize, replacement: []const u8) ![]u8 {
    var out: std.ArrayList(u8) = .empty;
    try out.appendSlice(alloc, content[0..start]);
    try out.appendSlice(alloc, replacement);
    try out.appendSlice(alloc, content[end..]);
    return out.toOwnedSlice(alloc);
}

pub fn dependencyVersion(content: []const u8) ?[]const u8 {
    const dep = std.mem.indexOf(u8, content, ".akamata = .{") orelse return null;
    const marker = "/archive/refs/tags/";
    const rel = std.mem.indexOf(u8, content[dep..], marker) orelse return null;
    const start = dep + rel + marker.len;
    const end_rel = std.mem.indexOf(u8, content[start..], ".tar.gz") orelse return null;
    return content[start .. start + end_rel];
}

pub fn updateDependencyContent(alloc: std.mem.Allocator, content: []const u8, version: []const u8, hash: []const u8) ![]u8 {
    const dep = std.mem.indexOf(u8, content, ".akamata = .{") orelse return error.AkamataDependencyNotFound;
    const url = try std.fmt.allocPrint(alloc, "https://github.com/moribit/Akamata/archive/refs/tags/{s}.tar.gz", .{version});
    defer alloc.free(url);
    const url_range = quotedFieldRange(content, dep, ".url") orelse return error.AkamataDependencyNotFound;
    const with_url = try replaceRange(alloc, content, url_range[0], url_range[1], url);
    defer alloc.free(with_url);
    const hash_range = quotedFieldRange(with_url, dep, ".hash") orelse return error.AkamataDependencyNotFound;
    return replaceRange(alloc, with_url, hash_range[0], hash_range[1], hash);
}

test "update detects and rewrites only the tagged Akamata dependency" {
    const input =
        \\.{
        \\  .dependencies = .{
        \\    .other = .{ .url = "https://example.test/keep", .hash = "keep" },
        \\    .akamata = .{
        \\      .url = "https://github.com/appleuser634/Akamata/archive/refs/tags/v0.1.0.tar.gz",
        \\      .hash = "akamata-old",
        \\    },
        \\  },
        \\}
    ;
    try std.testing.expectEqualStrings("v0.1.0", dependencyVersion(input).?);
    const updated = try updateDependencyContent(std.testing.allocator, input, "v0.1.2", STABLE_HASH);
    defer std.testing.allocator.free(updated);
    try std.testing.expectEqualStrings("v0.1.2", dependencyVersion(updated).?);
    try std.testing.expect(std.mem.indexOf(u8, updated, "https://example.test/keep") != null);
    try std.testing.expect(std.mem.indexOf(u8, updated, STABLE_HASH) != null);
}
