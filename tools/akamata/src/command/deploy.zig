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
    var environment: ?[]const u8 = null;
    var manifest: ?[]const u8 = null;
    var preflight = false;
    for (args) |raw| {
        const a = std.mem.sliceTo(raw, 0);
        if (std.mem.eql(u8, a, "--workers")) target_workers = true else if (std.mem.eql(u8, a, "--containers")) target_containers = true else if (std.mem.eql(u8, a, "--preflight")) preflight = true else if (std.mem.startsWith(u8, a, "--environment=")) environment = a[14..] else if (std.mem.startsWith(u8, a, "--manifest=")) manifest = a[11..] else if (std.mem.startsWith(u8, a, "--config=")) config_path = a[9..] else if (std.mem.startsWith(u8, a, "--migrate=")) migrate_path = a[10..];
    }
    if (!target_workers and !target_containers) target_workers = true;

    if (target_workers) {
        const cfg = try deployConfigPath(config_path);
        try @import("../cloudflare/config.zig").validateEnvironment(environment);
        if (environment != null and migrate_path != null) return error.EnvironmentMigrationUnsupported;
        const source = @import("../project/files.zig").readFileAlloc(alloc, "src/main.zig", 2 * 1024 * 1024) catch null;
        defer if (source) |bytes| alloc.free(bytes);
        const has_contract = if (source) |bytes| std.mem.indexOf(u8, bytes, "akamata-capabilities") != null else false;
        if (preflight or has_contract or manifest != null or environment != null) {
            var inspection: std.ArrayList([:0]const u8) = .empty;
            defer {
                for (inspection.items) |arg| alloc.free(arg);
                inspection.deinit(alloc);
            }
            for ([_][]const u8{ "--target=workers", "--strict" }) |arg| try inspection.append(alloc, try alloc.dupeSentinel(u8, arg, 0));
            try inspection.append(alloc, try std.fmt.allocPrintSentinel(alloc, "--config={s}", .{cfg}, 0));
            if (environment) |env| try inspection.append(alloc, try std.fmt.allocPrintSentinel(alloc, "--environment={s}", .{env}, 0));
            if (manifest) |path| try inspection.append(alloc, try std.fmt.allocPrintSentinel(alloc, "--manifest={s}", .{path}, 0));
            try @import("inspect.zig").cmdCapabilities(alloc, inspection.items);
        }
        // Deployment never implicitly provisions a declared capability.
        // Resource creation is a separate, explicitly invoked platform action.
        if (environment == null) if (try readD1FromConfig(alloc, cfg)) |database| {
            defer alloc.free(database.binding);
            defer alloc.free(database.name);
            defer alloc.free(database.id);
            if (std.mem.eql(u8, database.id, @import("../cloudflare/config.zig").PLACEHOLDER_UUID)) return error.ResourceNotProvisioned;
        };
        // 2. Apply the migration SQL to the remote D1, if requested.
        if (migrate_path) |sql| {
            const db_name = (try readD1FromConfig(alloc, cfg)) orelse {
                std.debug.print("--migrate given but {s} has no [[d1_databases]] entry — nothing to migrate against.\n", .{cfg});
                return error.UsageError;
            };
            defer alloc.free(db_name.name);
            defer alloc.free(db_name.id);
            defer alloc.free(db_name.binding);
            std.debug.print("==> akamata: applying {s} to remote D1 \"{s}\"\n", .{ sql, db_name.name });
            try cloudflare.executeD1(alloc, .{ .database = db_name.name, .location = .remote, .config = cfg, .file = sql });
        }
        // 3. Build wasm + deploy.
        const opt = optimizeFlag(args, workers_default_optimize);
        std.debug.print("==> akamata: building wasm ({s})\n", .{opt});
        const opt_flag = try std.fmt.allocPrint(alloc, "-Doptimize={s}", .{opt});
        defer alloc.free(opt_flag);
        try runChild(alloc, &.{ "zig", "build", "-Dbackend=workers", opt_flag }, null);
        try cloudflare.deployEnvironment(alloc, cfg, environment);
    }
    if (target_containers) {
        if (environment != null) return error.ContainerEnvironmentUnsupported;
        if (preflight or manifest != null) {
            const manifest_arg = if (manifest) |path| try std.fmt.allocPrintSentinel(alloc, "--manifest={s}", .{path}, 0) else null;
            defer if (manifest_arg) |arg| alloc.free(arg);
            const base = [_][:0]const u8{ "--target=containers", "--strict" };
            if (manifest_arg) |arg| {
                try @import("inspect.zig").cmdCapabilities(alloc, &.{ base[0], base[1], arg });
            } else try @import("inspect.zig").cmdCapabilities(alloc, &base);
        }
        try runChild(alloc, &.{ "zig", "build", "-Dtarget=x86_64-linux-musl", "-Doptimize=ReleaseFast" }, null);
        try runChild(alloc, &.{ "docker", "build", "-f", "deploy/Dockerfile", "-t", "akamata-app", "." }, null);
    }
}
