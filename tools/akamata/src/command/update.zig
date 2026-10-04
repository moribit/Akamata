const std = @import("std");
const STABLE_HASH = @import("../release.zig").STABLE_HASH;
const STABLE_VERSION = @import("../release.zig").STABLE_VERSION;
const SyncOptions = @import("../project/managed_files.zig").SyncOptions;
const captureCmdAllowFail = @import("../process.zig").captureCmdAllowFail;
const defaultConfigPath = @import("../cloudflare/config.zig").defaultConfigPath;
const dependencyVersion = @import("../project/manifest.zig").dependencyVersion;
const printManagedDiff = @import("../project/managed_files.zig").printManagedDiff;
const readFileAlloc = @import("../project/files.zig").readFileAlloc;
const runChild = @import("../process.zig").runChild;
const syncManaged = @import("../project/managed_files.zig").syncManaged;
const updateDependencyContent = @import("../project/manifest.zig").updateDependencyContent;
const writeFileBytes = @import("../project/files.zig").writeFileBytes;

pub fn resolveReleaseHash(alloc: std.mem.Allocator, version: []const u8) ![]u8 {
    if (std.mem.eql(u8, version, STABLE_VERSION)) return try alloc.dupe(u8, STABLE_HASH);
    const url = try std.fmt.allocPrint(alloc, "https://github.com/moribit/Akamata/archive/refs/tags/{s}.tar.gz", .{version});
    const result = try captureCmdAllowFail(alloc, &.{ "zig", "fetch", url });
    if (result.rc != 0) {
        std.debug.print("update: zig fetch failed for {s}:\n{s}\n", .{ version, result.stdout });
        return error.ReleaseNotFound;
    }
    const output = std.mem.trim(u8, result.stdout, " \t\r\n");
    const line_start = if (std.mem.lastIndexOfScalar(u8, output, '\n')) |i| i + 1 else 0;
    const hash = output[line_start..];
    if (!std.mem.startsWith(u8, hash, "akamata-")) return error.InvalidReleaseHash;
    return try alloc.dupe(u8, hash);
}

pub fn cmdUpdate(parent_alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    var arena_state: std.heap.ArenaAllocator = .init(parent_alloc);
    defer arena_state.deinit();
    const alloc = arena_state.allocator();
    var target: []const u8 = STABLE_VERSION;
    var with_sync = false;
    var sync_opts: SyncOptions = .{};
    for (args) |raw| {
        const a = std.mem.sliceTo(raw, 0);
        if (std.mem.startsWith(u8, a, "--to=")) target = a["--to=".len..] else if (std.mem.eql(u8, a, "--sync")) with_sync = true else if (std.mem.eql(u8, a, "--force")) sync_opts.force = true else if (std.mem.eql(u8, a, "--dry-run")) sync_opts.dry_run = true else if (std.mem.startsWith(u8, a, "--config=")) sync_opts.config_path = a["--config=".len..] else {
            std.debug.print("update: unknown option {s}\n", .{a});
            return error.UsageError;
        }
    }
    if (target.len < 2 or target[0] != 'v') {
        std.debug.print("update: --to must use vMAJOR.MINOR.PATCH (for example v0.1.2).\n", .{});
        return error.UsageError;
    }
    const old = try readFileAlloc(alloc, "build.zig.zon", 4 * 1024 * 1024);
    const current = dependencyVersion(old) orelse {
        std.debug.print("update: build.zig.zon has no tagged .akamata dependency.\n", .{});
        return error.AkamataDependencyNotFound;
    };
    const hash = try resolveReleaseHash(alloc, target);
    const updated = try updateDependencyContent(alloc, old, target, hash);
    std.debug.print("update: Akamata {s} -> {s}\n", .{ current, target });
    if (with_sync and !std.mem.eql(u8, target, STABLE_VERSION)) {
        std.debug.print("update: this CLI only bundles managed templates for {s}; install the {s} CLI before using --sync.\n", .{ STABLE_VERSION, target });
        return error.TemplateVersionMismatch;
    }
    sync_opts.assumed_version = target;
    if (with_sync and sync_opts.dry_run) try syncManaged(alloc, sync_opts);
    if (std.mem.eql(u8, old, updated)) {
        std.debug.print("unchanged  build.zig.zon\n", .{});
    } else if (sync_opts.dry_run) {
        printManagedDiff("build.zig.zon", old, updated);
        std.debug.print("  would update build.zig.zon\n", .{});
    } else {
        try writeFileBytes("build.zig.zon", updated);
        std.debug.print("updated    build.zig.zon\n", .{});
    }
    if (sync_opts.dry_run) {
        std.debug.print("update: dry-run complete; builds skipped.\n", .{});
        return;
    }
    if (with_sync) syncManaged(alloc, sync_opts) catch |err| {
        try writeFileBytes("build.zig.zon", old);
        std.debug.print("update: sync failed; restored build.zig.zon.\n", .{});
        return err;
    };
    std.debug.print("==> akamata update: validating Native build\n", .{});
    runChild(alloc, &.{ "zig", "build" }, null) catch |err| {
        try writeFileBytes("build.zig.zon", old);
        std.debug.print("update: Native build failed; restored build.zig.zon.\n", .{});
        return err;
    };
    if (defaultConfigPath() != null) {
        std.debug.print("==> akamata update: validating Workers build\n", .{});
        runChild(alloc, &.{ "zig", "build", "-Dbackend=workers", "-Doptimize=ReleaseSmall" }, null) catch |err| {
            try writeFileBytes("build.zig.zon", old);
            std.debug.print("update: Workers build failed; restored build.zig.zon.\n", .{});
            return err;
        };
        if (!with_sync) std.debug.print("update: dependency updated; run `akamata sync` to review and update Workers managed files.\n", .{});
    }
    std.debug.print("update: complete at {s}.\n", .{target});
}
