const fileExists = @import("../project/files.zig").fileExists;
const std = @import("std");
const appendPrint = @import("../format.zig").appendPrint;
const readFileAlloc = @import("../project/files.zig").readFileAlloc;
const tmpl_wrangler = @import("../project/templates.zig").tmpl_wrangler;
const writeFileBytes = @import("../project/files.zig").writeFileBytes;

// ---- deploy ----
pub const PLACEHOLDER_UUID = "00000000-0000-0000-0000-000000000000";

pub const WorkerCapabilities = struct {
    d1: bool = false,
    r2: bool = false,
    queue: bool = false,
    realtime: bool = false,
};

pub fn activeToml(alloc: std.mem.Allocator, bytes: []const u8) ![]u8 {
    var out: std.ArrayList(u8) = .empty;
    var lines = std.mem.splitScalar(u8, bytes, '\n');
    while (lines.next()) |line| {
        const before_comment = if (std.mem.indexOfScalar(u8, line, '#')) |i| line[0..i] else line;
        try out.appendSlice(alloc, std.mem.trim(u8, before_comment, " \t\r"));
        try out.append(alloc, '\n');
    }
    return out.toOwnedSlice(alloc);
}

pub fn detectWorkerCapabilities(alloc: std.mem.Allocator, cfg: []const u8) !WorkerCapabilities {
    const raw = try readFileAlloc(alloc, cfg, 4 * 1024 * 1024);
    const toml = try activeToml(alloc, raw);
    return .{
        .d1 = std.mem.indexOf(u8, toml, "[[d1_databases]]") != null,
        .r2 = std.mem.indexOf(u8, toml, "[[r2_buckets]]") != null,
        .queue = std.mem.indexOf(u8, toml, "[[queues.producers]]") != null or std.mem.indexOf(u8, toml, "[[queues.consumers]]") != null,
        .realtime = std.mem.indexOf(u8, toml, "AKAMATA_REALTIME") != null or std.mem.indexOf(u8, toml, "AkamataRealtimeRoom") != null,
    };
}

pub fn renderWrangler(alloc: std.mem.Allocator, name: []const u8, caps: WorkerCapabilities) ![]u8 {
    const base = try std.mem.replaceOwned(u8, alloc, tmpl_wrangler, "{{NAME}}", name);
    var out: std.ArrayList(u8) = .empty;
    try out.appendSlice(alloc, base);
    if (caps.d1) try appendPrint(&out, alloc, "\n[[d1_databases]]\nbinding = \"DB\"\ndatabase_name = \"{s}\"\ndatabase_id = \"00000000-0000-0000-0000-000000000000\"\n", .{name});
    if (caps.r2) try appendPrint(&out, alloc, "\n[[r2_buckets]]\nbinding = \"FILES\"\nbucket_name = \"{s}-files\"\n", .{name});
    if (caps.queue) try appendPrint(&out, alloc, "\n[[queues.producers]]\nbinding = \"EVENTS\"\nqueue = \"{s}-events\"\n\n[[queues.consumers]]\nqueue = \"{s}-events\"\n", .{ name, name });
    if (caps.realtime) try appendPrint(&out, alloc, "\n[[services]]\nbinding = \"AKAMATA_REALTIME_HANDLER\"\nservice = \"{s}\"\nentrypoint = \"AkamataRealtimeApplication\"\n\n[[durable_objects.bindings]]\nname = \"AKAMATA_REALTIME\"\nclass_name = \"AkamataRealtimeRoom\"\n\n[[migrations]]\ntag = \"v1\"\nnew_sqlite_classes = [\"AkamataRealtimeRoom\"]\n", .{name});
    return out.toOwnedSlice(alloc);
}

pub fn printCapabilities(caps: WorkerCapabilities) void {
    std.debug.print("capabilities: D1={s}, R2={s}, Queue={s}, Realtime={s}\n", .{
        if (caps.d1) "keep" else "disabled",    if (caps.r2) "keep" else "disabled",
        if (caps.queue) "keep" else "disabled", if (caps.realtime) "keep" else "disabled",
    });
}

/// Read the top-level `name = "..."` from a wrangler.toml (the key before any
/// `[section]`). Returns an owned copy, or null if absent.
pub fn readWranglerName(alloc: std.mem.Allocator, path: []const u8) !?[]const u8 {
    const content = try readFileAlloc(alloc, path, 1 * 1024 * 1024);
    defer alloc.free(content);
    var it = std.mem.splitScalar(u8, content, '\n');
    while (it.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0 or line[0] == '#') continue;
        if (line[0] == '[') break; // entered a section; top-level keys are done
        const eq = std.mem.indexOfScalar(u8, line, '=') orelse continue;
        const k = std.mem.trim(u8, line[0..eq], " \t");
        if (!std.mem.eql(u8, k, "name")) continue;
        var v = std.mem.trim(u8, line[eq + 1 ..], " \t");
        if (v.len >= 2 and (v[0] == '"' or v[0] == '\'') and v[v.len - 1] == v[0]) v = v[1 .. v.len - 1];
        return try alloc.dupe(u8, v);
    }
    return null;
}

pub fn defaultConfigPath() ?[]const u8 {
    if (fileExists("deploy/wrangler.toml")) return "deploy/wrangler.toml";
    if (fileExists("wrangler.toml")) return "wrangler.toml";
    return null;
}

pub const D1Info = struct {
    binding: []u8,
    name: []u8,
    id: []u8,
};

/// Parse the *first* `[[d1_databases]]` block in a wrangler.toml. Returns
/// null if none exists. Caller owns the strings (free with the same allocator).
/// Hand-rolled minimal TOML reader — wrangler files we generate are simple
/// enough that this stays robust.
pub fn readD1FromConfig(alloc: std.mem.Allocator, path: []const u8) !?D1Info {
    const content = try readFileAlloc(alloc, path, 1 * 1024 * 1024);
    defer alloc.free(content);

    var binding: ?[]const u8 = null;
    var name: ?[]const u8 = null;
    var id: ?[]const u8 = null;
    var in_block = false;

    var it = std.mem.splitScalar(u8, content, '\n');
    while (it.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0 or line[0] == '#') continue;
        if (std.mem.eql(u8, line, "[[d1_databases]]")) {
            if (in_block and binding != null and name != null and id != null) break;
            in_block = true;
            continue;
        }
        // A new section starts: stop collecting if we already had a complete one.
        if (line[0] == '[') {
            if (in_block and binding != null and name != null and id != null) break;
            in_block = false;
            continue;
        }
        if (!in_block) continue;
        const eq = std.mem.indexOfScalar(u8, line, '=') orelse continue;
        const k = std.mem.trim(u8, line[0..eq], " \t");
        var v = std.mem.trim(u8, line[eq + 1 ..], " \t");
        // strip surrounding quotes
        if (v.len >= 2 and (v[0] == '"' or v[0] == '\'') and v[v.len - 1] == v[0]) {
            v = v[1 .. v.len - 1];
        }
        if (std.mem.eql(u8, k, "binding")) binding = v else if (std.mem.eql(u8, k, "database_name")) name = v else if (std.mem.eql(u8, k, "database_id")) id = v;
    }
    if (binding == null or name == null or id == null) return null;
    return .{
        .binding = try alloc.dupe(u8, binding.?),
        .name = try alloc.dupe(u8, name.?),
        .id = try alloc.dupe(u8, id.?),
    };
}

test "readD1FromConfig: extracts first [[d1_databases]] block" {
    const path = "/tmp/akamata_test_wrangler.toml";
    // Write a fixture so the parser has something to read.
    const content =
        \\name = "guestbook"
        \\main = "worker/index.mjs"
        \\
        \\[vars]
        \\DATABASE_URL = "d1:DB"
        \\
        \\[[d1_databases]]
        \\binding = "DB"
        \\database_name = "guestbook"
        \\database_id = "00000000-0000-0000-0000-000000000000"
        \\
    ;
    try writeFileBytes(path, content);
    const info = (try readD1FromConfig(std.testing.allocator, path)) orelse return error.TestExpectedD1;
    defer {
        std.testing.allocator.free(info.binding);
        std.testing.allocator.free(info.name);
        std.testing.allocator.free(info.id);
    }
    try std.testing.expectEqualStrings("DB", info.binding);
    try std.testing.expectEqualStrings("guestbook", info.name);
    try std.testing.expectEqualStrings(PLACEHOLDER_UUID, info.id);
}

test "readD1FromConfig: ignores commented-out blocks" {
    const path = "/tmp/akamata_test_wrangler_commented.toml";
    const content =
        \\name = "x"
        \\# [[d1_databases]]
        \\# binding = "DB"
        \\# database_name = "x"
        \\# database_id = "00000000-0000-0000-0000-000000000000"
        \\
        \\[vars]
        \\KEY = "v"
        \\
    ;
    try writeFileBytes(path, content);
    try std.testing.expect((try readD1FromConfig(std.testing.allocator, path)) == null);
}

/// The provider owns the configuration artifact path and format.
pub fn scaffoldConfig(alloc: std.mem.Allocator, name: []const u8, caps: WorkerCapabilities) !struct { path: []const u8, content: []const u8 } {
    return .{ .path = "deploy/wrangler.toml", .content = try renderWrangler(alloc, name, caps) };
}
pub fn deployConfigPath(explicit: ?[]const u8) ![]const u8 {
    return explicit orelse defaultConfigPath() orelse {
        std.debug.print("deploy: no wrangler.toml found at deploy/wrangler.toml or ./wrangler.toml. Pass --config=PATH.\n", .{});
        return error.UsageError;
    };
}
