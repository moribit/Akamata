const std = @import("std");

pub const CapturedCmd = struct { rc: c_int, stdout: []u8 };

/// Run a command and return both its exit code and combined stdout/stderr.
/// Does NOT error on non-zero exit — caller inspects `rc` and decides.
pub fn captureCmdAllowFail(alloc: std.mem.Allocator, argv: []const []const u8) !CapturedCmd {
    var cmd: std.ArrayList(u8) = .empty;
    defer cmd.deinit(alloc);
    for (argv, 0..) |a, i| {
        if (i > 0) try cmd.append(alloc, ' ');
        try cmd.append(alloc, '\'');
        for (a) |ch| {
            if (ch == '\'') try cmd.appendSlice(alloc, "'\\''") else try cmd.append(alloc, ch);
        }
        try cmd.append(alloc, '\'');
    }
    try cmd.appendSlice(alloc, " 2>&1");
    try cmd.append(alloc, 0);

    const FILE = opaque {};
    const Lib = struct {
        extern "c" fn popen(c: [*:0]const u8, m: [*:0]const u8) ?*FILE;
        extern "c" fn pclose(s: *FILE) c_int;
        extern "c" fn fread(p: [*]u8, sz: usize, n: usize, s: *FILE) usize;
    };
    const cmd_z: [*:0]const u8 = @ptrCast(cmd.items.ptr);
    const f = Lib.popen(cmd_z, "r") orelse return error.PopenFailed;
    var out: std.ArrayList(u8) = .empty;
    var buf: [4096]u8 = undefined;
    while (true) {
        const n = Lib.fread(&buf, 1, buf.len, f);
        if (n == 0) break;
        try out.appendSlice(alloc, buf[0..n]);
    }
    const rc = Lib.pclose(f);
    return .{ .rc = rc, .stdout = try out.toOwnedSlice(alloc) };
}

/// Run a command and return its captured stdout. Errors out if the command
/// exits non-zero. Mirrors `runChild` but with popen() to read output.
pub fn captureCmd(alloc: std.mem.Allocator, argv: []const []const u8) ![]u8 {
    var cmd: std.ArrayList(u8) = .empty;
    defer cmd.deinit(alloc);
    for (argv, 0..) |a, i| {
        if (i > 0) try cmd.append(alloc, ' ');
        try cmd.append(alloc, '\'');
        for (a) |ch| {
            if (ch == '\'') try cmd.appendSlice(alloc, "'\\''") else try cmd.append(alloc, ch);
        }
        try cmd.append(alloc, '\'');
    }
    // Combine stderr into stdout so we don't miss the UUID if wrangler ever
    // writes its success line there.
    try cmd.appendSlice(alloc, " 2>&1");
    try cmd.append(alloc, 0);

    const FILE = opaque {};
    const Lib = struct {
        extern "c" fn popen(c: [*:0]const u8, m: [*:0]const u8) ?*FILE;
        extern "c" fn pclose(s: *FILE) c_int;
        extern "c" fn fread(p: [*]u8, sz: usize, n: usize, s: *FILE) usize;
    };
    const cmd_z: [*:0]const u8 = @ptrCast(cmd.items.ptr);
    const f = Lib.popen(cmd_z, "r") orelse return error.PopenFailed;
    var out: std.ArrayList(u8) = .empty;
    var buf: [4096]u8 = undefined;
    while (true) {
        const n = Lib.fread(&buf, 1, buf.len, f);
        if (n == 0) break;
        try out.appendSlice(alloc, buf[0..n]);
    }
    const rc = Lib.pclose(f);
    if (rc != 0) {
        std.debug.print("captureCmd: command failed (rc={d}):\n{s}\n", .{ rc, out.items });
        out.deinit(alloc);
        return error.ChildFailed;
    }
    return out.toOwnedSlice(alloc);
}

pub extern "c" fn system(cmd: [*:0]const u8) c_int;

pub extern "c" fn chdir(p: [*:0]const u8) c_int;

pub fn runChild(alloc: std.mem.Allocator, argv: []const []const u8, cwd: ?[]const u8) !void {
    // Build a shell command line. Each argv element is single-quoted with any
    // embedded single quote escaped as `'\''`. Sufficient for the trusted
    // commands we issue (zig, wrangler, docker).
    var buf: std.ArrayList(u8) = .empty;
    defer buf.deinit(alloc);
    for (argv, 0..) |a, i| {
        if (i > 0) try buf.append(alloc, ' ');
        try buf.append(alloc, '\'');
        for (a) |ch| {
            if (ch == '\'') {
                try buf.appendSlice(alloc, "'\\''");
            } else {
                try buf.append(alloc, ch);
            }
        }
        try buf.append(alloc, '\'');
    }

    if (cwd) |c| {
        const cwd_z = try alloc.dupeSentinel(u8, c, 0);
        defer alloc.free(cwd_z);
        if (chdir(cwd_z.ptr) != 0) return error.ChildFailed;
    }

    try buf.append(alloc, 0);
    const cmd: [*:0]const u8 = @ptrCast(buf.items.ptr);
    const rc = system(cmd);
    if (rc != 0) {
        std.debug.print("child exited with status {d}\n", .{rc});
        return error.ChildFailed;
    }
}
