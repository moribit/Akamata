const std = @import("std");
const runChild = @import("../process.zig").runChild;

// ---- build ----

// Workers default optimize mode. ReleaseFast: the CPU-bound request paths
// (JSON, HTML inlining, validation) are noticeably faster than ReleaseSmall,
// and the wasm still gzips well under Cloudflare's bundle limit. Override per
// invocation with `--optimize=ReleaseSmall` (or `=ReleaseSafe`/`=Debug`).
pub const workers_default_optimize = "ReleaseFast";

/// Pull an explicit `--optimize=<Mode>` out of args, else return the default.
/// Recognises the Zig mode names; anything else is passed through verbatim so
/// `zig build` reports the error.
pub fn optimizeFlag(args: []const [:0]const u8, default_mode: []const u8) []const u8 {
    for (args) |raw| {
        const a = std.mem.sliceTo(raw, 0);
        if (std.mem.startsWith(u8, a, "--optimize=")) return a["--optimize=".len..];
    }
    return default_mode;
}

pub fn cmdBuild(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    var argv: std.ArrayList([]const u8) = .empty;
    defer argv.deinit(alloc);
    var optimize_arg: ?[]u8 = null;
    defer if (optimize_arg) |value| alloc.free(value);
    try argv.append(alloc, "zig");
    try argv.append(alloc, "build");
    for (args) |raw| {
        const a = std.mem.sliceTo(raw, 0);
        if (std.mem.eql(u8, a, "--workers")) {
            try argv.append(alloc, "-Dbackend=workers");
            optimize_arg = try std.fmt.allocPrint(alloc, "-Doptimize={s}", .{optimizeFlag(args, workers_default_optimize)});
            try argv.append(alloc, optimize_arg.?);
        } else if (std.mem.eql(u8, a, "--containers")) {
            try argv.append(alloc, "-Dtarget=x86_64-linux-musl");
            try argv.append(alloc, "-Doptimize=ReleaseFast");
        }
    }
    try runChild(alloc, argv.items, null);
}
