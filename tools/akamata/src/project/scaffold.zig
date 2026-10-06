const std = @import("std");
const WorkerCapabilities = @import("../cloudflare/config.zig").WorkerCapabilities;
const makeDirRecursive = @import("files.zig").makeDirRecursive;
const renderWorkerIndex = @import("worker_glue.zig").renderWorkerIndex;
const scaffoldConfig = @import("../cloudflare/config.zig").scaffoldConfig;
const tmpl_build_zig = @import("templates.zig").tmpl_build_zig;
const tmpl_build_zon = @import("templates.zig").tmpl_build_zon;
const tmpl_dockerfile = @import("templates.zig").tmpl_dockerfile;
const tmpl_gitignore = @import("templates.zig").tmpl_gitignore;
const tmpl_internal_routes = @import("templates.zig").tmpl_internal_routes;
const tmpl_main = @import("templates.zig").tmpl_main;
const tmpl_readme = @import("templates.zig").tmpl_readme;
const tmpl_realtime_object = @import("templates.zig").tmpl_realtime_object;
const tmpl_wasm_dispatch = @import("templates.zig").tmpl_wasm_dispatch;
const tmpl_worker = @import("templates.zig").tmpl_worker;
const writeInitialManagedManifest = @import("managed_files.zig").writeInitialManagedManifest;

// ---- init ----
pub const InitOpts = struct {
    name: []const u8,
    target: enum { native, workers, containers, both } = .native,
    capabilities: WorkerCapabilities = .{},
    template: enum { minimal, notes } = .minimal,
};

pub fn validAppName(name: []const u8) bool {
    if (name.len == 0 or name.len > 128) return false;
    if (!(std.ascii.isAlphabetic(name[0]) or name[0] == '_')) return false;
    for (name) |c| {
        if (!(std.ascii.isAlphanumeric(c) or c == '-' or c == '_')) return false;
    }
    return true;
}

/// Zig package fingerprint: upper 32 bits = CRC32 of the package name,
/// lower 32 bits = a stable project identifier. The compiler rejects the all-zero / placeholder
/// patterns, so each generated project needs a unique value.
pub fn computeFingerprint(name: []const u8) u64 {
    // Zig 0.17 layout: upper 32 bits = CRC32 of the package name (so the
    // compiler can detect a renamed package), lower 32 bits = an `id` that
    // just needs to avoid the placeholder/all-ones patterns the compiler
    // rejects. Deriving `id` from the name keeps fingerprints stable across
    // re-runs of `akamata init` for the same project.
    const name_hash: u32 = std.hash.Crc32.hash(name);
    var id: u32 = name_hash *% 0x9E37_79B1 ^ 0xC0FF_EE13;
    if (id == 0 or id == 0xFFFF_FFFF) id = 0x1234_5678;
    return (@as(u64, name_hash) << 32) | @as(u64, id);
}

pub const Replacement = struct { key: []const u8, val: []const u8 };

pub fn renderFile(
    alloc: std.mem.Allocator,
    root: []const u8,
    rel: []const u8,
    content: []const u8,
    replacements: []const Replacement,
) !void {
    var rendered: []u8 = try alloc.dupe(u8, content);
    for (replacements) |rep| {
        const next = try std.mem.replaceOwned(u8, alloc, rendered, rep.key, rep.val);
        alloc.free(rendered);
        rendered = next;
    }
    defer alloc.free(rendered);

    const path = try std.fmt.allocPrint(alloc, "{s}/{s}", .{ root, rel });
    defer alloc.free(path);
    const path_z = try alloc.dupeSentinel(u8, path, 0);
    defer alloc.free(path_z);

    const FILE = opaque {};
    const Lib = struct {
        extern "c" fn fopen(p: [*:0]const u8, m: [*:0]const u8) ?*FILE;
        extern "c" fn fwrite(ptr: [*]const u8, size: usize, n: usize, s: *FILE) usize;
        extern "c" fn fclose(s: *FILE) c_int;
    };
    const f = Lib.fopen(path_z.ptr, "wb") orelse {
        std.debug.print("failed to create {s}\n", .{path});
        return error.WriteFailed;
    };
    defer _ = Lib.fclose(f);
    _ = Lib.fwrite(rendered.ptr, 1, rendered.len, f);
}

test "scaffold names are path-safe and support hyphens" {
    try std.testing.expect(validAppName("release-smoke"));
    try std.testing.expect(validAppName("app_2"));
    try std.testing.expect(!validAppName("../escape"));
    try std.testing.expect(!validAppName("bad/name"));
    try std.testing.expect(!validAppName("2app"));
    try std.testing.expect(std.mem.indexOf(u8, tmpl_build_zon, ".name = .{{NAME_ENUM}}") != null);
}

pub fn generate(alloc: std.mem.Allocator, opts: InitOpts) !void {
    // 1. Create directory `name`
    try makeDirRecursive(opts.name);
    try makeDirRecursive(try std.fmt.allocPrint(alloc, "{s}/src", .{opts.name}));

    // 2. Write files
    try renderFile(alloc, opts.name, "build.zig", tmpl_build_zig, &.{
        .{ .key = "{{NAME}}", .val = opts.name },
    });
    const package_name = try alloc.dupe(u8, opts.name);
    for (package_name) |*c| if (c.* == '-') {
        c.* = '_';
    };
    const fingerprint_str = try std.fmt.allocPrint(alloc, "0x{x:0>16}", .{computeFingerprint(package_name)});
    defer alloc.free(fingerprint_str);
    try renderFile(alloc, opts.name, "build.zig.zon", tmpl_build_zon, &.{
        .{ .key = "{{NAME}}", .val = opts.name },
        .{ .key = "{{NAME_ENUM}}", .val = package_name },
        .{ .key = "{{FINGERPRINT}}", .val = fingerprint_str },
    });
    try renderFile(alloc, opts.name, "src/main.zig", if (opts.template == .minimal) @import("templates.zig").tmpl_minimal_main else tmpl_main, &.{
        .{ .key = "{{NAME}}", .val = opts.name },
    });
    try renderFile(alloc, opts.name, ".gitignore", tmpl_gitignore, &.{});
    try renderFile(alloc, opts.name, "README.md", if (opts.template == .minimal) @import("templates.zig").tmpl_minimal_readme else tmpl_readme, &.{
        .{ .key = "{{NAME}}", .val = opts.name },
    });

    if (opts.target == .workers or opts.target == .both) {
        try renderFile(alloc, opts.name, "src/worker.zig", if (opts.template == .minimal) @import("templates.zig").tmpl_minimal_worker else tmpl_worker, &.{
            .{ .key = "{{NAME}}", .val = opts.name },
        });
        try makeDirRecursive(try std.fmt.allocPrint(alloc, "{s}/deploy/worker", .{opts.name}));
        const config = try scaffoldConfig(alloc, opts.name, opts.capabilities);
        try renderFile(alloc, opts.name, config.path, config.content, &.{});
        const worker_index = try renderWorkerIndex(alloc, opts.name, opts.capabilities);
        try renderFile(alloc, opts.name, "deploy/worker/index.mjs", worker_index, &.{});
        try renderFile(alloc, opts.name, "deploy/worker/wasm_dispatch.mjs", tmpl_wasm_dispatch, &.{});
        if (opts.capabilities.realtime) {
            try renderFile(alloc, opts.name, "deploy/worker/internal_routes.mjs", tmpl_internal_routes, &.{});
            try renderFile(alloc, opts.name, "deploy/worker/realtime_object.mjs", tmpl_realtime_object, &.{});
            try writeInitialManagedManifest(alloc, opts.name, &.{ "deploy/worker/index.mjs", "deploy/worker/wasm_dispatch.mjs", "deploy/worker/internal_routes.mjs", "deploy/worker/realtime_object.mjs" });
        } else try writeInitialManagedManifest(alloc, opts.name, &.{ "deploy/worker/index.mjs", "deploy/worker/wasm_dispatch.mjs" });
    }
    if (opts.target == .containers or opts.target == .both) {
        try makeDirRecursive(try std.fmt.allocPrint(alloc, "{s}/deploy", .{opts.name}));
        try renderFile(alloc, opts.name, "deploy/Dockerfile", tmpl_dockerfile, &.{
            .{ .key = "{{NAME}}", .val = opts.name },
        });
    }
    if (opts.template == .notes) {
        try makeDirRecursive(try std.fmt.allocPrint(alloc, "{s}/migrations", .{opts.name}));
        try renderFile(alloc, opts.name, "migrations/.gitkeep", "", &.{});
    }

    std.debug.print(
        \\
        \\Created {s}/
        \\
        \\Next steps:
        \\  cd {s}
        \\  zig build run           # native dev server
        \\
    , .{ opts.name, opts.name });
}
