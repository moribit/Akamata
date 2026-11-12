//! OS resource samples for owned fixture PIDs; never used by production code.
const std = @import("std");
const builtin = @import("builtin");
const s = @import("support.zig");
pub const Sample = struct { rss_kib: u64, cpu_seconds: f64, cpu_percent: f64, threads: usize, fds: usize };
pub fn sample(h: s.H, pid: std.process.Child.Id) !Sample {
    const id = try h.fmt("{d}", .{pid});
    const output = try h.run(&.{ "ps", "-o", "rss=,time=,pcpu=", "-p", id }, null, h.env);
    var fields = std.mem.tokenizeAny(u8, output, " \t\r\n");
    const rss = try std.fmt.parseInt(u64, fields.next() orelse return error.MissingRss, 10);
    const time = fields.next() orelse return error.MissingCpuTime;
    var parts = std.mem.splitScalar(u8, time, ':');
    var seconds: f64 = 0;
    while (parts.next()) |part| seconds = seconds * 60 + try std.fmt.parseFloat(f64, part);
    const cpu = try std.fmt.parseFloat(f64, fields.next() orelse return error.MissingCpu);
    if (builtin.os.tag == .linux) return .{ .rss_kib = rss, .cpu_seconds = seconds, .cpu_percent = cpu, .threads = try entries(h, try h.fmt("/proc/{s}/task", .{id})), .fds = try entries(h, try h.fmt("/proc/{s}/fd", .{id})) };
    const listing = try h.run(&.{ "lsof", "-nP", "-a", "-p", id, "-Ff" }, null, h.env);
    var lines = std.mem.tokenizeScalar(u8, listing, '\n');
    var fds: usize = 0;
    while (lines.next()) |line| {
        if (line.len > 1 and line[0] == 'f') {
            _ = std.fmt.parseInt(u64, line[1..], 10) catch continue;
            fds += 1;
        }
    }
    var threads: usize = 0;
    lines = std.mem.tokenizeScalar(u8, try h.run(&.{ "ps", "-M", "-p", id }, null, h.env), '\n');
    while (lines.next() != null) threads += 1;
    return .{ .rss_kib = rss, .cpu_seconds = seconds, .cpu_percent = cpu, .threads = threads -| 1, .fds = fds };
}
fn entries(h: s.H, path: []const u8) !usize {
    var dir = try std.Io.Dir.cwd().openDir(h.io, path, .{ .iterate = true });
    defer dir.close(h.io);
    var iterator = dir.iterate();
    var count: usize = 0;
    while (try iterator.next(h.io) != null) count += 1;
    return count;
}
pub fn raiseFdCeiling(ceiling: u64) !void {
    var limit = try std.posix.getrlimit(.NOFILE);
    limit.cur = @max(limit.cur, @min(limit.max, ceiling));
    try std.posix.setrlimit(.NOFILE, limit);
}
pub fn execLimited(h: s.H, args: []const []const u8) !void {
    if (args.len < 2) return error.InvalidLimitedExec;
    const limit = try std.fmt.parseInt(u64, args[0], 10);
    if (limit < 16 or limit > 16384) return error.InvalidFdLimit;
    try std.posix.setrlimit(.NOFILE, .{ .cur = limit, .max = limit });
    return std.process.replace(h.io, .{ .argv = args[1..], .environ_map = h.env });
}
