const std = @import("std");
const deployConfigPath = @import("../cloudflare/config.zig").deployConfigPath;
const cloudflare = @import("../cloudflare/operations.zig").default;
const optimizeFlag = @import("build.zig").optimizeFlag;
const readD1FromConfig = @import("../cloudflare/config.zig").readD1FromConfig;
const runChild = @import("../process.zig").runChild;

// ---- build ----

// Workers default optimize mode. ReleaseFast: the CPU-bound request paths
// (JSON, HTML inlining, validation) are noticeably faster than ReleaseSmall,
// and the wasm still gzips well under Cloudflare's bundle limit. Override per
// invocation with `--optimize=ReleaseSmall` (or `=ReleaseSafe`/`=Debug`).
const workers_default_optimize = @import("build.zig").workers_default_optimize;

pub fn cmdDeploy(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    var target_workers = false;
    var target_containers = false;
    var config_path: ?[]const u8 = null;
    var migrate_path: ?[]const u8 = null;
    for (args) |raw| {
        const a = std.mem.sliceTo(raw, 0);
        if (std.mem.eql(u8, a, "--workers")) target_workers = true else if (std.mem.eql(u8, a, "--containers")) target_containers = true else if (std.mem.startsWith(u8, a, "--config=")) config_path = a[9..] else if (std.mem.startsWith(u8, a, "--migrate=")) migrate_path = a[10..];
    }
    if (!target_workers and !target_containers) target_workers = true;

    if (target_workers) {
        const cfg = try deployConfigPath(config_path);
        // 1. Ensure the D1 referenced by the config exists, auto-creating if
        //    the database_id is still the placeholder UUID.
        try cloudflare.ensureD1(alloc, cfg);
        // 2. Apply the migration SQL to the remote D1, if requested.
        if (migrate_path) |sql| {
            const db_name = (try readD1FromConfig(alloc, cfg)) orelse {
                std.debug.print("--migrate given but {s} has no [[d1_databases]] entry — nothing to migrate against.\n", .{cfg});
                return error.UsageError;
            };
            std.debug.print("==> akamata: applying {s} to remote D1 \"{s}\"\n", .{ sql, db_name.name });
            try cloudflare.executeD1(alloc, .{ .database = db_name.name, .location = .remote, .config = cfg, .file = sql });
            alloc.free(db_name.name);
            alloc.free(db_name.id);
            alloc.free(db_name.binding);
        }
        // 3. Build wasm + deploy.
        const opt = optimizeFlag(args, workers_default_optimize);
        std.debug.print("==> akamata: building wasm ({s})\n", .{opt});
        const opt_flag = try std.fmt.allocPrint(alloc, "-Doptimize={s}", .{opt});
        defer alloc.free(opt_flag);
        try runChild(alloc, &.{ "zig", "build", "-Dbackend=workers", opt_flag }, null);
        try cloudflare.deploy(alloc, cfg);
    }
    if (target_containers) {
        try runChild(alloc, &.{ "zig", "build", "-Dtarget=x86_64-linux-musl", "-Doptimize=ReleaseFast" }, null);
        try runChild(alloc, &.{ "docker", "build", "-f", "deploy/Dockerfile", "-t", "akamata-app", "." }, null);
    }
}
