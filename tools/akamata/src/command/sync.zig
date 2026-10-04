const std = @import("std");
const SyncOptions = @import("../project/managed_files.zig").SyncOptions;
const syncManaged = @import("../project/managed_files.zig").syncManaged;

pub fn cmdSync(parent_alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    var arena_state: std.heap.ArenaAllocator = .init(parent_alloc);
    defer arena_state.deinit();
    const alloc = arena_state.allocator();
    var opts: SyncOptions = .{};
    for (args) |raw| {
        const a = std.mem.sliceTo(raw, 0);
        if (std.mem.eql(u8, a, "--force")) opts.force = true else if (std.mem.eql(u8, a, "--dry-run")) opts.dry_run = true else if (std.mem.startsWith(u8, a, "--config=")) opts.config_path = a["--config=".len..] else {
            std.debug.print("sync: unknown option {s}\n", .{a});
            return error.UsageError;
        }
    }
    try syncManaged(alloc, opts);
}

// ---- sync-glue (deprecated compatibility alias) ----

/// Regenerate `<config-dir>/worker/index.mjs` from the bundled template so the
/// JS host glue tracks the framework's current wasm ABI. The glue is generated
/// (not hand-authored) — the only project-specific value is `{{NAME}}` (the
/// wasm artifact name), read from the wrangler.toml top-level `name`.
pub fn cmdSyncGlue(parent_alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    var arena_state: std.heap.ArenaAllocator = .init(parent_alloc);
    defer arena_state.deinit();
    const alloc = arena_state.allocator();
    var opts: SyncOptions = .{};
    for (args) |raw| {
        const a = std.mem.sliceTo(raw, 0);
        if (std.mem.startsWith(u8, a, "--config=")) opts.config_path = a[9..] else if (std.mem.eql(u8, a, "--force")) opts.force = true else if (std.mem.eql(u8, a, "--dry-run")) opts.dry_run = true else return error.UsageError;
    }
    std.debug.print("sync-glue is deprecated; running the safe managed-file sync.\n", .{});
    try syncManaged(alloc, opts);
}
