const std = @import("std");
const STABLE_VERSION = @import("../release.zig").STABLE_VERSION;
const VERSION = @import("../release.zig").VERSION;
const appendPrint = @import("../format.zig").appendPrint;
const defaultConfigPath = @import("../cloudflare/config.zig").defaultConfigPath;
const deleteFile = @import("files.zig").deleteFile;
const dependencyVersion = @import("manifest.zig").dependencyVersion;
const detectWorkerCapabilities = @import("../cloudflare/config.zig").detectWorkerCapabilities;
const dirName = @import("files.zig").dirName;
const makeDirRecursive = @import("files.zig").makeDirRecursive;
const printCapabilities = @import("../cloudflare/config.zig").printCapabilities;
const readFileAlloc = @import("files.zig").readFileAlloc;
const readWranglerName = @import("../cloudflare/config.zig").readWranglerName;
const renderWorkerIndex = @import("worker_glue.zig").renderWorkerIndex;
const tmpl_internal_routes = @import("templates.zig").tmpl_internal_routes;
const tmpl_realtime_object = @import("templates.zig").tmpl_realtime_object;
const tmpl_wasm_dispatch = @import("templates.zig").tmpl_wasm_dispatch;

// Both `init` and `sync` pass this full bridge template through the same
// capability-aware renderer below.
const tmpl_worker_index = @import("templates.zig").tmpl_worker_index;
const writeFileBytes = @import("files.zig").writeFileBytes;

pub const MANAGED_MANIFEST = ".akamata/managed-files.json";

// ---- project update / managed-file sync ----
pub const ManagedFile = struct {
    path: []const u8,
    content: []const u8,
};

pub const SyncOptions = struct {
    config_path: ?[]const u8 = null,
    force: bool = false,
    dry_run: bool = false,
    assumed_version: ?[]const u8 = null,
};

pub const LEGACY_V010_WORKER_TEMPLATE_SHA256 = "9518deaaa60e8b843921648ce42224759794e9e9364e138e99db3c1897d50c19";

pub const KNOWN_LEGACY_WORKER_SHA256 = [_][]const u8{
    LEGACY_V010_WORKER_TEMPLATE_SHA256,
    "f424b881c384520c63d41a37fc0f8b0369c7da643bcd7f899600ea81c0942a2f", // v0.1.0 repository glue
    "1ffdffed7f4e0c7972b3c730fcff6c10939a79198060dd231faa50a0d5d4e423", // v0.1.1 scaffold
    "dc5c464a61bc89324ec64cdf142b68574fd9d46c88967078b6df3bfa86aceb17", // v0.1.1 full-capability glue
    "d1714c0ac56ec68ac4d42e0ca37f441b17c731f765590ff8fc6e830553d4a32d", // v0.1.2 scaffold before capability sync
};

pub fn sha256Hex(bytes: []const u8) [64]u8 {
    var digest: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(bytes, &digest, .{});
    return std.fmt.bytesToHex(digest, .lower);
}

pub fn writeInitialManagedManifest(alloc: std.mem.Allocator, root: []const u8, paths: []const []const u8) !void {
    const manifest_dir = try std.fmt.allocPrint(alloc, "{s}/.akamata", .{root});
    defer alloc.free(manifest_dir);
    try makeDirRecursive(manifest_dir);
    var out: std.ArrayList(u8) = .empty;
    defer out.deinit(alloc);
    try appendPrint(&out, alloc, "{{\n  \"schema\": 1,\n  \"framework_version\": \"{s}\",\n  \"files\": {{\n", .{VERSION});
    for (paths, 0..) |rel, i| {
        const full = try std.fmt.allocPrint(alloc, "{s}/{s}", .{ root, rel });
        defer alloc.free(full);
        const bytes = try readFileAlloc(alloc, full, 4 * 1024 * 1024);
        defer alloc.free(bytes);
        const hash = sha256Hex(bytes);
        try appendPrint(&out, alloc, "    \"{s}\": \"{s}\"{s}\n", .{ rel, hash, if (i + 1 == paths.len) "" else "," });
    }
    try out.appendSlice(alloc, "  }\n}\n");
    const path = try std.fmt.allocPrint(alloc, "{s}/{s}", .{ root, MANAGED_MANIFEST });
    defer alloc.free(path);
    try writeFileBytes(path, out.items);
}

pub fn manifestHash(alloc: std.mem.Allocator, path: []const u8) !?[]u8 {
    const bytes = readFileAlloc(alloc, MANAGED_MANIFEST, 1024 * 1024) catch return null;
    defer alloc.free(bytes);
    var parsed = std.json.parseFromSlice(std.json.Value, alloc, bytes, .{}) catch return null;
    defer parsed.deinit();
    if (parsed.value != .object) return null;
    const files = parsed.value.object.get("files") orelse return null;
    if (files != .object) return null;
    const value = files.object.get(path) orelse return null;
    if (value != .string or value.string.len != 64) return null;
    return try alloc.dupe(u8, value.string);
}

pub fn writeManagedManifest(alloc: std.mem.Allocator, files: []const ManagedFile) !void {
    try makeDirRecursive(".akamata");
    var out: std.ArrayList(u8) = .empty;
    defer out.deinit(alloc);
    try appendPrint(&out, alloc, "{{\n  \"schema\": 1,\n  \"framework_version\": \"{s}\",\n  \"files\": {{\n", .{VERSION});
    for (files, 0..) |file, i| {
        const hash = sha256Hex(file.content);
        try appendPrint(&out, alloc, "    \"{s}\": \"{s}\"{s}\n", .{ file.path, hash, if (i + 1 == files.len) "" else "," });
    }
    try out.appendSlice(alloc, "  }\n}\n");
    try writeFileBytes(MANAGED_MANIFEST, out.items);
}

pub fn workerDir(alloc: std.mem.Allocator, cfg: []const u8) ![]u8 {
    const dir = dirName(cfg);
    return if (std.mem.eql(u8, dir, ".")) try alloc.dupe(u8, "worker") else try std.fmt.allocPrint(alloc, "{s}/worker", .{dir});
}

pub fn buildManagedFiles(alloc: std.mem.Allocator, cfg: []const u8, name: []const u8) ![]ManagedFile {
    const dir = try workerDir(alloc, cfg);
    const caps = try detectWorkerCapabilities(alloc, cfg);
    var files: std.ArrayList(ManagedFile) = .empty;
    try files.append(alloc, .{
        .path = try std.fmt.allocPrint(alloc, "{s}/index.mjs", .{dir}),
        .content = try renderWorkerIndex(alloc, name, caps),
    });
    try files.append(alloc, .{ .path = try std.fmt.allocPrint(alloc, "{s}/wasm_dispatch.mjs", .{dir}), .content = try alloc.dupe(u8, tmpl_wasm_dispatch) });
    if (caps.realtime) {
        try files.append(alloc, .{ .path = try std.fmt.allocPrint(alloc, "{s}/internal_routes.mjs", .{dir}), .content = try alloc.dupe(u8, tmpl_internal_routes) });
        try files.append(alloc, .{ .path = try std.fmt.allocPrint(alloc, "{s}/realtime_object.mjs", .{dir}), .content = try alloc.dupe(u8, tmpl_realtime_object) });
    }
    return files.toOwnedSlice(alloc);
}

pub fn printManagedDiff(path: []const u8, old: ?[]const u8, new: []const u8) void {
    std.debug.print("--- {s} (current)\n+++ {s} (framework {s})\n", .{ path, path, VERSION });
    if (old == null) {
        std.debug.print("+ add managed file ({d} bytes)\n", .{new.len});
        return;
    }
    const old_hash = sha256Hex(old.?);
    const new_hash = sha256Hex(new);
    std.debug.print("- sha256 {s}\n+ sha256 {s}\n", .{ old_hash, new_hash });
    var old_lines = std.mem.splitScalar(u8, old.?, '\n');
    var new_lines = std.mem.splitScalar(u8, new, '\n');
    var line: usize = 1;
    while (true) : (line += 1) {
        const a = old_lines.next();
        const b = new_lines.next();
        if (a == null and b == null) break;
        if (a == null or b == null or !std.mem.eql(u8, a.?, b.?)) {
            std.debug.print("@@ first difference at line {d} @@\n", .{line});
            if (a) |value| std.debug.print("- {s}\n", .{value});
            if (b) |value| std.debug.print("+ {s}\n", .{value});
            break;
        }
    }
}

pub fn isKnownLegacyWorkerIndex(alloc: std.mem.Allocator, bytes: []const u8) !bool {
    const prefix = "import wasm from \"../../zig-out/bin/";
    const suffix = "_worker.wasm\";";
    const start = std.mem.indexOf(u8, bytes, prefix) orelse return false;
    const name_start = start + prefix.len;
    const name_end_rel = std.mem.indexOf(u8, bytes[name_start..], suffix) orelse return false;
    const name_end = name_start + name_end_rel;
    var normalized: std.ArrayList(u8) = .empty;
    defer normalized.deinit(alloc);
    try normalized.appendSlice(alloc, bytes[0..name_start]);
    try normalized.appendSlice(alloc, "{{NAME}}");
    try normalized.appendSlice(alloc, bytes[name_end..]);
    const hash = sha256Hex(normalized.items);
    for (KNOWN_LEGACY_WORKER_SHA256) |known| if (std.mem.eql(u8, &hash, known)) return true;
    return false;
}

pub fn syncManaged(alloc: std.mem.Allocator, opts: SyncOptions) !void {
    const zon = try readFileAlloc(alloc, "build.zig.zon", 4 * 1024 * 1024);
    const project_version = opts.assumed_version orelse dependencyVersion(zon) orelse {
        std.debug.print("sync: build.zig.zon has no tagged .akamata dependency.\n", .{});
        return error.AkamataDependencyNotFound;
    };
    if (!std.mem.eql(u8, project_version, STABLE_VERSION)) {
        std.debug.print("sync: project uses {s}, but this CLI bundles {s} templates; run `akamata update --sync`.\n", .{ project_version, STABLE_VERSION });
        return error.TemplateVersionMismatch;
    }
    const cfg = opts.config_path orelse defaultConfigPath() orelse {
        std.debug.print("sync: no wrangler.toml found; pass --config=PATH.\n", .{});
        return error.UsageError;
    };
    const name = (try readWranglerName(alloc, cfg)) orelse {
        std.debug.print("sync: {s} has no top-level name.\n", .{cfg});
        return error.UsageError;
    };
    const files = try buildManagedFiles(alloc, cfg, name);
    const capabilities = try detectWorkerCapabilities(alloc, cfg);
    printCapabilities(capabilities);
    var conflicts: usize = 0;
    var changes: usize = 0;
    const changed = try alloc.alloc(bool, files.len);
    @memset(changed, false);
    const modified = try alloc.alloc(bool, files.len);
    @memset(modified, false);
    // Preflight all managed files before writing any of them, so one local
    // edit cannot leave a project partially synchronized.
    for (files, 0..) |file, i| {
        const existing = readFileAlloc(alloc, file.path, 4 * 1024 * 1024) catch null;
        if (existing) |current| {
            if (std.mem.eql(u8, current, file.content)) {
                std.debug.print("unchanged  {s}\n", .{file.path});
                continue;
            }
        }
        changed[i] = true;
        changes += 1;
        printManagedDiff(file.path, existing, file.content);
        var locally_modified = false;
        if (existing) |current| {
            if (try manifestHash(alloc, file.path)) |recorded| {
                const current_hash = sha256Hex(current);
                locally_modified = !std.mem.eql(u8, &current_hash, recorded);
            } else if (std.mem.endsWith(u8, file.path, "/index.mjs") and try isKnownLegacyWorkerIndex(alloc, current)) {
                std.debug.print("  recognized unmodified legacy Akamata template\n", .{});
            } else {
                locally_modified = true;
            }
        }
        modified[i] = locally_modified;
        if (locally_modified and !opts.force) {
            conflicts += 1;
            std.debug.print("  REFUSED: local changes detected (use --force to replace)\n", .{});
        } else {
            std.debug.print("  would update {s}\n", .{file.path});
        }
    }
    const managed_dir = try workerDir(alloc, cfg);
    const stale_paths = [_][]const u8{
        try std.fmt.allocPrint(alloc, "{s}/internal_routes.mjs", .{managed_dir}),
        try std.fmt.allocPrint(alloc, "{s}/realtime_object.mjs", .{managed_dir}),
    };
    var stale_delete = @as([stale_paths.len]bool, @splat(false));
    var stale_modified = @as([stale_paths.len]bool, @splat(false));
    if (!capabilities.realtime) for (stale_paths, 0..) |path, i| {
        const recorded = try manifestHash(alloc, path) orelse continue;
        const current = readFileAlloc(alloc, path, 4 * 1024 * 1024) catch continue;
        stale_delete[i] = true;
        changes += 1;
        const current_hash = sha256Hex(current);
        stale_modified[i] = !std.mem.eql(u8, &current_hash, recorded);
        std.debug.print("--- {s} (current)\n+++ /dev/null (capability disabled)\n  would delete {s}\n", .{ path, path });
        if (stale_modified[i] and !opts.force) {
            conflicts += 1;
            std.debug.print("  REFUSED: local changes detected (use --force to back up and remove)\n", .{});
        }
    };
    if (conflicts > 0) {
        std.debug.print("sync: refused {d} locally modified file(s); no manifest update written.\n", .{conflicts});
        return error.ManagedFileModified;
    }
    if (!opts.dry_run) {
        for (files, 0..) |file, i| {
            if (!changed[i]) continue;
            const existing = readFileAlloc(alloc, file.path, 4 * 1024 * 1024) catch null;
            try makeDirRecursive(dirName(file.path));
            if (modified[i] and opts.force and existing != null) {
                const backup = try std.fmt.allocPrint(alloc, "{s}.bak", .{file.path});
                try writeFileBytes(backup, existing.?);
                std.debug.print("backup     {s}\n", .{backup});
            }
            try writeFileBytes(file.path, file.content);
            std.debug.print("updated    {s}\n", .{file.path});
        }
        for (stale_paths, 0..) |path, i| {
            if (!stale_delete[i]) continue;
            if (stale_modified[i] and opts.force) {
                const current = try readFileAlloc(alloc, path, 4 * 1024 * 1024);
                const backup = try std.fmt.allocPrint(alloc, "{s}.bak", .{path});
                try writeFileBytes(backup, current);
                std.debug.print("backup     {s}\n", .{backup});
            }
            try deleteFile(path);
            std.debug.print("deleted    {s}\n", .{path});
        }
        try writeManagedManifest(alloc, files);
    }
    std.debug.print("sync: {d} change(s){s}; wrangler.toml and application source untouched.\n", .{ changes, if (opts.dry_run) " planned" else " applied" });
}

test "managed templates cover serialization and realtime glue" {
    try std.testing.expect(std.mem.indexOf(u8, tmpl_worker_index, "wasm_dispatch.mjs") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_wasm_dispatch, "await previous") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_internal_routes, "rejectPublicInternalRoute") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_realtime_object, "AkamataRealtimeRoom") != null);
}
