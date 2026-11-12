//! Prime the two immutable translate-c source packages. No build/test retry.
const std = @import("std");
const Dep = struct { url: []const u8, hash: []const u8 };
const Root = struct { dependencies: struct { translate_c: Dep } };
const Translator = struct { dependencies: struct { aro: Dep } };
const Saved = struct { dependencies: struct { ci_source: Dep } };
fn manifest(comptime T: type, init: std.process.Init, path: []const u8) !T {
    const a = init.arena.allocator();
    const text = try std.Io.Dir.cwd().readFileAlloc(init.io, path, a, .limited(1024 * 1024));
    var diagnostics: std.zon.parse.Diagnostics = undefined;
    return std.zon.parse.fromSlice(T, .{ .gpa = a, .arena = a, .source = try a.dupeSentinel(u8, text, 0), .diagnostics = &diagnostics, .ignore_unknown_fields = true });
}
fn fetch(init: std.process.Init, zig: []const u8, dep: Dep) !void {
    const a = init.arena.allocator();
    const local = try std.fmt.allocPrint(a, "zig-pkg/{s}", .{dep.hash});
    const exists = blk: {
        std.Io.Dir.cwd().access(init.io, local, .{}) catch |err| {
            if (err == error.FileNotFound) break :blk false;
            return err;
        };
        break :blk true;
    };
    const source = if (exists) local else dep.url;
    var random: [8]u8 = undefined;
    init.io.random(&random);
    const scratch = try std.fmt.allocPrint(a, ".zig-cache/dependency-fetch-{s}", .{std.fmt.bytesToHex(random, .lower)});
    try std.Io.Dir.cwd().createDirPath(init.io, scratch);
    defer std.Io.Dir.cwd().deleteTree(init.io, scratch) catch {};
    const scratch_absolute = try std.Io.Dir.cwd().realPathFileAlloc(init.io, scratch, a);
    const pkg_absolute = try std.Io.Dir.cwd().realPathFileAlloc(init.io, "zig-pkg", a);
    const manifest_path = try std.fs.path.join(a, &.{ scratch, "build.zig.zon" });
    const build_path = try std.fs.path.join(a, &.{ scratch, "build.zig" });
    // findBuildRoot anchors on build.zig, not build.zig.zon.
    try std.Io.Dir.cwd().writeFile(init.io, .{ .sub_path = build_path, .data = "" });
    const root_text = try std.Io.Dir.cwd().readFileAlloc(init.io, "build.zig.zon", a, .limited(1024 * 1024));
    try std.Io.Dir.cwd().writeFile(init.io, .{ .sub_path = manifest_path, .data = root_text });
    // A successful download is accepted only with the repository's exact pin.
    // Never retry a hash mismatch or a test/compile command.
    for (0..3) |attempt| {
        const result = std.process.run(a, init.io, .{
            // Zig 0.17 materializes --pkg-dir only with --save. Save into an
            // isolated manifest, never the repository's dependency declaration.
            .argv = if (exists) &.{ zig, "fetch", source } else &.{ zig, "fetch", "--save=ci_source", "--pkg-dir", pkg_absolute, source },
            .cwd = if (exists) .inherit else .{ .path = scratch_absolute },
            .stdout_limit = .limited(1024 * 1024),
            .stderr_limit = .limited(1024 * 1024),
            .timeout = .{ .duration = .{ .clock = .awake, .raw = .fromSeconds(120) } },
        }) catch |err| {
            std.debug.print("dependency fetch {s}, attempt {d}: {s}\n", .{ dep.hash, attempt + 1, @errorName(err) });
            if (attempt == 2) return err;
            try std.Io.sleep(init.io, .fromSeconds(@intCast(attempt + 1)), .awake);
            continue;
        };
        if (result.term == .exited and result.term.exited == 0) {
            const hash = if (exists) std.mem.trim(u8, result.stdout, "\r\n \t") else (try manifest(Saved, init, manifest_path)).dependencies.ci_source.hash;
            if (!std.mem.eql(u8, hash, dep.hash)) return error.DependencyHashMismatch;
            try std.Io.Dir.cwd().access(init.io, local, .{});
            std.debug.print("verified dependency {s}\n", .{dep.hash});
            return;
        }
        std.debug.print("dependency fetch {s}, attempt {d}: {s}\n", .{ dep.hash, attempt + 1, result.stderr });
        if (attempt == 2) return error.DependencyDownloadFailed;
        try std.Io.sleep(init.io, .fromSeconds(@intCast(attempt + 1)), .awake);
    }
}
pub fn main(init: std.process.Init) !void {
    const a = init.arena.allocator();
    const args = try init.minimal.args.toSlice(a);
    if (args.len != 2) return error.ExpectedZigExecutable;
    try std.Io.Dir.cwd().createDirPath(init.io, "zig-pkg");
    const root = try manifest(Root, init, "build.zig.zon");
    try fetch(init, args[1], root.dependencies.translate_c);
    const path = try std.fmt.allocPrint(a, "zig-pkg/{s}/build.zig.zon", .{root.dependencies.translate_c.hash});
    const translator = try manifest(Translator, init, path);
    try fetch(init, args[1], translator.dependencies.aro);
}
