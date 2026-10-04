const std = @import("std");

pub fn appendPrint(list: *std.ArrayList(u8), alloc: std.mem.Allocator, comptime fmt: []const u8, args: anytype) !void {
    const rendered = try std.fmt.allocPrint(alloc, fmt, args);
    defer alloc.free(rendered);
    try list.appendSlice(alloc, rendered);
}
