//! Native-only test support. Every process/socket has a bounded owner.
const std = @import("std");
pub const H = struct {
    a: std.mem.Allocator,
    io: std.Io,
    env: *std.process.Environ.Map,
    self: []const u8,
    pub fn fmt(h: H, comptime format: []const u8, args: anytype) ![]u8 {
        return std.fmt.allocPrint(h.a, format, args);
    }
    pub fn read(h: H, path: []const u8) ![]u8 {
        return std.Io.Dir.cwd().readFileAlloc(h.io, path, h.a, .limited(64 * 1024 * 1024));
    }
    pub fn write(h: H, path: []const u8, data: []const u8) !void {
        if (std.fs.path.dirname(path)) |parent| try std.Io.Dir.cwd().createDirPath(h.io, parent);
        try std.Io.Dir.cwd().writeFile(h.io, .{ .sub_path = path, .data = data });
    }
    pub fn json(h: H, data: []const u8) !std.json.Value {
        return (try std.json.parseFromSlice(std.json.Value, h.a, data, .{ .allocate = .alloc_always })).value;
    }
    pub fn encode(h: H, data: anytype) ![]const u8 {
        return std.json.Stringify.valueAlloc(h.a, data, .{});
    }
    pub fn now(h: H) i96 {
        return std.Io.Clock.awake.now(h.io).toNanoseconds();
    }
    pub fn sleep(h: H, ms: u64) void {
        std.Io.sleep(h.io, .fromMilliseconds(@intCast(ms)), .awake) catch {};
    }
    pub fn command(h: H, argv: []const []const u8, cwd: ?[]const u8, env: ?*const std.process.Environ.Map) !std.process.RunResult {
        return h.commandFor(argv, cwd, env, 600);
    }
    pub fn commandFor(h: H, argv: []const []const u8, cwd: ?[]const u8, env: ?*const std.process.Environ.Map, seconds: u32) !std.process.RunResult {
        const start = h.now();
        const cpu_start = childCpu();
        const result = std.process.run(h.a, h.io, .{
            .argv = argv,
            .cwd = if (cwd) |p| .{ .path = p } else .inherit,
            .environ_map = env,
            .stdout_limit = .limited(32 * 1024 * 1024),
            .stderr_limit = .limited(32 * 1024 * 1024),
            .timeout = .{ .duration = .{ .clock = .awake, .raw = .fromSeconds(seconds) } },
        }) catch |err| {
            try h.trace(argv, start, cpu_start, null);
            return err;
        };
        try h.trace(argv, start, cpu_start, if (result.term == .exited) result.term.exited else null);
        return result;
    }
    pub fn append(h: H, path: []const u8, data: []const u8) !void {
        if (std.fs.path.dirname(path)) |parent| try std.Io.Dir.cwd().createDirPath(h.io, parent);
        const file = try std.Io.Dir.cwd().createFile(h.io, path, .{ .truncate = false });
        defer file.close(h.io);
        const flags = std.c.fcntl(file.handle, std.c.F.GETFL);
        const append_flag: c_int = @bitCast(std.c.O{ .APPEND = true });
        if (flags < 0 or std.c.fcntl(file.handle, std.c.F.SETFL, flags | append_flag) < 0) return error.Append;
        try file.writeStreamingAll(h.io, data);
    }
    fn trace(h: H, argv: []const []const u8, start: i96, cpu_start: ?f64, code: ?u8) !void {
        const directory = h.env.get("AKAMATA_CI_TIMING_DIR") orelse return;
        const suite = h.env.get("AKAMATA_TEST_SUITE") orelse "commands";
        const elapsed: f64 = @as(f64, @floatFromInt(h.now() - start)) / std.time.ns_per_s;
        const cpu_end = childCpu();
        const cpu: ?f64 = if (cpu_start != null and cpu_end != null) cpu_end.? - cpu_start.? else null;
        const row = try h.encode(.{ .command = argv, .seconds = elapsed, .child_cpu_seconds = cpu, .returncode = code });
        try h.append(try h.fmt("{s}/{s}.jsonl", .{ directory, suite }), try h.fmt("{s}\n", .{row}));
    }
    pub fn run(h: H, argv: []const []const u8, cwd: ?[]const u8, env: ?*const std.process.Environ.Map) ![]const u8 {
        const result = try h.command(argv, cwd, env);
        if (!success(result.term)) {
            std.debug.print("command failed: {s}\n{s}\n{s}\n", .{ argv[0], result.stdout, result.stderr });
            return error.CommandFailed;
        }
        return result.stdout;
    }
    pub fn absolute(h: H, path: []const u8) ![]const u8 {
        return std.Io.Dir.cwd().realPathFileAlloc(h.io, path, h.a);
    }
    pub fn temp(h: H) !Temp {
        const base = h.env.get("TMPDIR") orelse "/tmp";
        const path = try h.fmt("{s}/akamata-zig-tests-{d}-{d}", .{ base, std.c.getpid(), h.now() });
        try std.Io.Dir.cwd().createDir(h.io, path, .default_dir);
        return .{ .h = h, .path = path };
    }
    pub fn exists(h: H, path: []const u8) bool {
        std.Io.Dir.cwd().access(h.io, path, .{}) catch return false;
        return true;
    }
};
fn childCpu() ?f64 {
    var usage: std.c.rusage = undefined;
    if (std.c.getrusage(std.c.rusage.CHILDREN, &usage) != 0) return null;
    return @as(f64, @floatFromInt(usage.utime.sec + usage.stime.sec)) + @as(f64, @floatFromInt(usage.utime.usec + usage.stime.usec)) / 1_000_000;
}
pub const Temp = struct {
    h: H,
    path: []const u8,
    pub fn deinit(t: Temp) void {
        std.Io.Dir.cwd().deleteTree(t.h.io, t.path) catch |err| std.debug.print("cleanup {s}: {s}\n", .{ t.path, @errorName(err) });
    }
    pub fn file(t: Temp, name: []const u8) ![]const u8 {
        return t.h.fmt("{s}/{s}", .{ t.path, name });
    }
};
pub fn success(term: std.process.Child.Term) bool {
    return switch (term) {
        .exited => |n| n == 0,
        else => false,
    };
}
pub fn check(ok: bool, message: []const u8) !void {
    if (!ok) {
        std.debug.print("contract assertion: {s}\n", .{message});
        return error.ContractAssertion;
    }
}
pub fn eq(actual: []const u8, expected: []const u8) !void {
    if (!std.mem.eql(u8, actual, expected)) {
        std.debug.print("expected {s}, got {s}\n", .{ expected, actual });
        return error.ContractAssertion;
    }
}
pub fn contains(actual: []const u8, expected: []const u8) !void {
    try check(std.mem.indexOf(u8, actual, expected) != null, expected);
}
pub fn replace(h: H, text: []const u8, old: []const u8, new: []const u8) ![]const u8 {
    try contains(text, old);
    var out: std.Io.Writer.Allocating = .init(h.a);
    var parts = std.mem.splitSequence(u8, text, old);
    try out.writer.writeAll(parts.first());
    while (parts.next()) |part| {
        try out.writer.writeAll(new);
        try out.writer.writeAll(part);
    }
    return out.toOwnedSlice();
}
pub fn field(v: std.json.Value, name: []const u8) !std.json.Value {
    if (v != .object) return error.ExpectedObject;
    return v.object.get(name) orelse error.MissingJsonField;
}
