const std = @import("std");

// ---- deploy ----
const PLACEHOLDER_UUID = @import("config.zig").PLACEHOLDER_UUID;
const Operations = @import("operations.zig").Operations;
const extractUuid = @import("wrangler.zig").extractUuid;
const lookupD1UuidByName = @import("wrangler.zig").lookupD1UuidByName;
const readD1FromConfig = @import("config.zig").readD1FromConfig;
const readFileAlloc = @import("../project/files.zig").readFileAlloc;
const writeFileBytes = @import("../project/files.zig").writeFileBytes;

/// If the config's D1 database_id is the placeholder UUID, create the DB and
/// write the real UUID back. If a D1 with that name already exists in the
/// account, adopt its UUID instead (so re-running deploy after a failure
/// halfway through is idempotent). No-op otherwise.
pub fn ensureD1Provisioned(ops: Operations, alloc: std.mem.Allocator, cfg: []const u8) !void {
    const info = (try readD1FromConfig(alloc, cfg)) orelse return; // no D1 in this config
    defer {
        alloc.free(info.binding);
        alloc.free(info.name);
        alloc.free(info.id);
    }
    if (!std.mem.eql(u8, info.id, PLACEHOLDER_UUID)) return;
    std.debug.print("==> akamata: provisioning D1 \"{s}\" (database_id is placeholder)\n", .{info.name});

    // Try `wrangler d1 create`. If it fails with "already exists", look it up
    // via `wrangler d1 list --json` and adopt that UUID.
    var resolved_uuid: ?[]const u8 = null;
    var owned_create_out: ?[]u8 = null;
    var owned_list_out: ?[]u8 = null;
    var owned_list_uuid: ?[]u8 = null;
    defer {
        if (owned_create_out) |b| alloc.free(b);
        if (owned_list_out) |b| alloc.free(b);
        if (owned_list_uuid) |b| alloc.free(b);
    }

    const create = try ops.createD1(alloc, info.name);
    owned_create_out = create.stdout;
    if (create.rc == 0) {
        resolved_uuid = extractUuid(create.stdout);
    } else if (std.mem.indexOf(u8, create.stdout, "already exists") != null) {
        std.debug.print("==> akamata: D1 \"{s}\" already exists — looking up its UUID via `d1 list`\n", .{info.name});
        const listed = try ops.listD1(alloc);
        owned_list_out = listed.stdout;
        if (listed.rc != 0) {
            std.debug.print("wrangler d1 list failed (rc={d}):\n{s}\n", .{ listed.rc, listed.stdout });
            return error.ProvisionFailed;
        }
        if (try lookupD1UuidByName(alloc, listed.stdout, info.name)) |u| {
            owned_list_uuid = u;
            resolved_uuid = u;
        } else {
            std.debug.print("d1 list returned no matching name \"{s}\". Output:\n{s}\n", .{ info.name, listed.stdout });
        }
    } else {
        std.debug.print("wrangler d1 create failed (rc={d}):\n{s}\n", .{ create.rc, create.stdout });
        return error.ProvisionFailed;
    }

    const uuid = resolved_uuid orelse {
        std.debug.print("could not resolve database_id from wrangler output\n", .{});
        return error.ProvisionFailed;
    };
    std.debug.print("==> akamata: resolved D1 \"{s}\" (id={s})\n", .{ info.name, uuid });

    // Rewrite the config in place: replace the placeholder UUID with the real
    // one. We do a simple string replacement scoped to the file content.
    const old_content = try readFileAlloc(alloc, cfg, 1 * 1024 * 1024);
    defer alloc.free(old_content);
    const new_content = try std.mem.replaceOwned(u8, alloc, old_content, PLACEHOLDER_UUID, uuid);
    defer alloc.free(new_content);
    try writeFileBytes(cfg, new_content);
    std.debug.print("==> akamata: wrote new database_id back to {s}\n", .{cfg});
}
