//! Bounded repeated contract execution for sanitizer jobs.
const std = @import("std");
const builtin = @import("builtin");
const s = @import("support.zig");
const transport = @import("transport.zig");
pub fn run(h: s.H, args: []const []const u8) !void {
    if (args.len < 1) return error.MissingFixtureBinary;
    const binary = try h.absolute(args[0]);
    var adapter: ?[]const u8 = null;
    var output: ?[]const u8 = null;
    var selected: transport.Case = .upgrade_hub_snapshot_disconnect_ownership;
    var repeats: usize = 30;
    var i: usize = 1;
    while (i < args.len) : (i += 2) {
        if (i + 1 >= args.len) return error.MissingOptionValue;
        const key = args[i];
        const value = args[i + 1];
        if (std.mem.eql(u8, key, "--adapter")) {
            if (!std.mem.eql(u8, value, "threaded") and !std.mem.eql(u8, value, "kqueue") and !std.mem.eql(u8, value, "epoll") and !std.mem.eql(u8, value, "sharded")) return error.InvalidAdapter;
            adapter = value;
        } else if (std.mem.eql(u8, key, "--output")) {
            output = value;
        } else if (std.mem.eql(u8, key, "--repeats")) {
            repeats = try std.fmt.parseInt(usize, value, 10);
        } else if (std.mem.eql(u8, key, "--test")) {
            if (!std.mem.startsWith(u8, value, "test_")) return error.InvalidCase;
            selected = std.meta.stringToEnum(transport.Case, value[5..]) orelse return error.InvalidCase;
        } else return error.UnknownOption;
    }
    if (repeats < 1 or repeats > 100) return error.InvalidRepeatCount;
    const target = adapter orelse return error.MissingAdapter;
    const path = output orelse return error.MissingOutput;
    const digest = try h.sha256(binary);
    var runs: std.ArrayList(Row) = .empty;
    for (0..repeats) |index| {
        var diagnostic: transport.Diagnostic = .{};
        const failure: ?anyerror = blk: {
            transport.runCaseDiagnostic(h, binary, target, false, selected, &diagnostic) catch |err| break :blk err;
            break :blk null;
        };
        try runs.append(h.a, .{ .repeat = index + 1, .passed = failure == null, .failure = if (failure) |err| @errorName(err) else null, .diagnostic = diagnostic });
        try h.write(path, try h.encode(.{
            .platform = @tagName(builtin.os.tag),
            .binary_sha256 = digest[0..],
            .adapter = target,
            .@"test" = try h.fmt("test_{s}", .{@tagName(selected)}),
            .requested_repeats = repeats,
            .runs = runs.items,
        }));
        if (failure) |err| return err;
    }
}
const Row = struct { repeat: usize, passed: bool, failure: ?[]const u8, diagnostic: transport.Diagnostic };
