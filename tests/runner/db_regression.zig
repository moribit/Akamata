//! Serial DB regression orchestration; distinct from benchmark measurement.
const std = @import("std");
const s = @import("support.zig");
pub fn run(h: s.H, args: []const []const u8) !void {
    if (args.len > 1) return error.ExpectedOutputDirectory;
    const directory = if (args.len == 1) args[0] else ".zig-cache/db-validation";
    const zig = h.env.get("ZIG") orelse "zig";
    const commands = [_][]const []const u8{
        &.{ zig, "build", "test", "db-pool-test", "-j2", "--summary", "all" },
        &.{ zig, "build", "test", "db-pool-test", "documentation-test", "-Doptimize=ReleaseSafe", "-j2", "--summary", "all" },
        &.{ zig, "build", "test", "-Doptimize=ReleaseFast", "-j2", "--summary", "all" },
        &.{ zig, "build", "portable-application-test", "documentation-test", "-Dbackend=workers", "-Doptimize=ReleaseSafe", "-j2", "--summary", "all" },
        &.{ zig, "build", "transport-contract-test", "-Doptimize=ReleaseSafe", "-j2", "--summary", "all" },
        &.{ zig, "build", "db-pool-test", "-Druntime-tsan=true", "-Doptimize=ReleaseSafe", "-j2", "--summary", "all" },
    };
    const sha = std.mem.trim(u8, try h.run(&.{ "git", "rev-parse", "HEAD" }, null, null), "\r\n");
    const Row = struct { command: []const []const u8, exit: ?u8, seconds: f64, log: []const u8 };
    var rows: std.ArrayList(Row) = .empty;
    for (commands, 0..) |command, i| {
        const log = try h.fmt("{s}/validation-{d}.log", .{ directory, i });
        const start = h.now();
        const result = try h.commandFor(command, null, null, 1200);
        try h.write(log, try h.fmt("{s}\n{s}", .{ result.stdout, result.stderr }));
        try rows.append(h.a, .{ .command = command, .exit = if (result.term == .exited) result.term.exited else null, .seconds = @as(f64, @floatFromInt(h.now() - start)) / std.time.ns_per_s, .log = log });
        try h.write(try h.fmt("{s}/validation.json", .{directory}), try h.encode(.{ .source_sha = sha, .runs = rows.items }));
        if (!s.success(result.term)) {
            std.debug.print("DB regression failed; see {s}\n", .{log});
            return error.DbRegressionFailed;
        }
    }
}
