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

pub const Resource = struct {
    present: bool = false,
    matches: usize = 0,
    identifier: ?[]const u8 = null,
    class_name: ?[]const u8 = null,
    script_name: ?[]const u8 = null,

    pub fn validated(self: Resource, provider: []const u8) bool {
        if (!self.present or self.matches != 1) return false;
        if (std.mem.eql(u8, provider, "durable_objects")) return self.class_name != null and self.class_name.?.len != 0;
        const id = self.identifier orelse return false;
        if (std.mem.eql(u8, provider, "d1")) {
            if (id.len != 36 or std.mem.eql(u8, id, PLACEHOLDER_UUID)) return false;
            for (id, 0..) |c, index| {
                if (index == 8 or index == 13 or index == 18 or index == 23) {
                    if (c != '-') return false;
                } else if (!std.ascii.isHex(c)) return false;
            }
        }
        return id.len != 0;
    }
};

pub fn validateEnvironment(environment: ?[]const u8) !void {
    if (environment) |name| {
        if (name.len == 0 or name.len > 128) return error.InvalidEnvironment;
        for (name) |c| if (!std.ascii.isAlphanumeric(c) and c != '-' and c != '_') return error.UnsupportedEnvironmentSyntax;
    }
}

fn quotedAssignment(line: []const u8, key: []const u8) ?[]const u8 {
    const eq = std.mem.indexOfScalar(u8, line, '=') orelse return null;
    if (!std.mem.eql(u8, std.mem.trim(u8, line[0..eq], " \t"), key)) return null;
    const value = std.mem.trim(u8, line[eq + 1 ..], " \t");
    if (value.len < 2 or (value[0] != '"' and value[0] != '\'')) return null;
    const end = std.mem.indexOfScalarPos(u8, value, 1, value[0]) orelse return null;
    const rest = std.mem.trim(u8, value[end + 1 ..], " \t");
    if (rest.len > 0 and rest[0] != '#') return null;
    const bytes = value[1..end];
    if (std.mem.indexOfScalar(u8, bytes, '\\') != null) return null;
    return bytes;
}

/// Bindings/vars are non-inheritable: named environments never borrow root
/// resource declarations. Results borrow config bytes, not global scratch.
pub fn resource(content: []const u8, provider: []const u8, name: []const u8, environment: ?[]const u8) !Resource {
    try validateEnvironment(environment);
    const suffix = if (std.mem.eql(u8, provider, "d1")) "d1_databases" else if (std.mem.eql(u8, provider, "r2")) "r2_buckets" else if (std.mem.eql(u8, provider, "workers_queue")) "queues.producers" else if (std.mem.eql(u8, provider, "durable_objects")) "durable_objects.bindings" else return Resource{};
    var buffer: [256]u8 = undefined;
    const section = if (environment) |env| try std.fmt.bufPrint(&buffer, "[[env.{s}.{s}]]", .{ env, suffix }) else try std.fmt.bufPrint(&buffer, "[[{s}]]", .{suffix});
    const binding_key = if (std.mem.eql(u8, provider, "durable_objects")) "name" else "binding";
    const id_key = if (std.mem.eql(u8, provider, "d1")) "database_id" else if (std.mem.eql(u8, provider, "r2")) "bucket_name" else "queue";
    var found: Resource = .{};
    var current: Resource = .{};
    var binding: ?[]const u8 = null;
    var active = false;
    var lines = std.mem.splitScalar(u8, content, '\n');
    while (true) {
        const raw = lines.next();
        const line = if (raw) |bytes| std.mem.trim(u8, bytes, " \t\r") else "[end]";
        if (std.mem.startsWith(u8, line, "[")) {
            if (active and binding != null and std.mem.eql(u8, binding.?, name)) {
                const count = found.matches + 1;
                found = current;
                found.present = true;
                found.matches = count;
            }
            current = .{};
            binding = null;
            active = std.mem.startsWith(u8, line, section) and (line.len == section.len or std.mem.trim(u8, line[section.len..], " \t")[0] == '#');
        } else if (active) {
            if (quotedAssignment(line, binding_key)) |value| binding = value;
            if (quotedAssignment(line, id_key)) |value| current.identifier = value;
            if (quotedAssignment(line, "class_name")) |value| current.class_name = value;
            if (quotedAssignment(line, "script_name")) |value| current.script_name = value;
        }
        if (raw == null) break;
    }
    return found;
}

pub fn environmentVar(content: []const u8, environment: ?[]const u8, key: []const u8) !?[]const u8 {
    try validateEnvironment(environment);
    var buffer: [256]u8 = undefined;
    const section = if (environment) |env| try std.fmt.bufPrint(&buffer, "[env.{s}.vars]", .{env}) else "[vars]";
    var active = false;
    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \t\r");
        const header = std.mem.trim(u8, line[0 .. std.mem.indexOfScalar(u8, line, '#') orelse line.len], " \t");
        if (std.mem.startsWith(u8, line, "[")) active = std.mem.eql(u8, header, section) else if (active) {
            if (quotedAssignment(line, key)) |value| return value;
        }
    }
    return null;
}

test "deployment bindings and vars do not inherit across environments" {
    const toml = "[[r2_buckets]]\nbinding=\"FILES\"\nbucket_name=\"root\"\n[[env.production.r2_buckets]]\nbinding=\"FILES\"\nbucket_name=\"production\"\n[vars]\nDATABASE_URL=\"d1:DB\"\n[env.production.vars]\nDATABASE_URL=\"d1:REPORTS\"\n";
    try std.testing.expectEqualStrings("production", (try resource(toml, "r2", "FILES", "production")).identifier.?);
    try std.testing.expect(!(try resource(toml, "r2", "FILES", "preview")).present);
    try std.testing.expectEqualStrings("d1:REPORTS", (try environmentVar(toml, "production", "DATABASE_URL")).?);
    try std.testing.expect((try environmentVar(toml, "preview", "DATABASE_URL")) == null);
}

/// Read generated/supported TOML binding declarations by section and key.
/// A match is configuration presence only, never remote resource readiness.
pub fn hasResourceBinding(content: []const u8, provider: []const u8, name: []const u8) bool {
    const section: []const u8 = if (std.mem.eql(u8, provider, "d1")) "[[d1_databases]]" else if (std.mem.eql(u8, provider, "r2")) "[[r2_buckets]]" else if (std.mem.eql(u8, provider, "workers_queue")) "[[queues.producers]]" else if (std.mem.eql(u8, provider, "durable_objects")) "[[durable_objects.bindings]]" else return false;
    const key = if (std.mem.eql(u8, provider, "durable_objects")) "name" else "binding";
    var active = false;
    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0 or line[0] == '#') continue;
        if (line[0] == '[') {
            const closing = std.mem.indexOf(u8, line, "]]") orelse {
                active = false;
                continue;
            };
            active = std.mem.eql(u8, line[0 .. closing + 2], section);
            continue;
        }
        if (!active) continue;
        const eq = std.mem.indexOfScalar(u8, line, '=') orelse continue;
        if (!std.mem.eql(u8, std.mem.trim(u8, line[0..eq], " \t"), key)) continue;
        const value = std.mem.trim(u8, line[eq + 1 ..], " \t");
        if (value.len < 2 or (value[0] != '"' and value[0] != '\'')) continue;
        const end = std.mem.indexOfScalarPos(u8, value, 1, value[0]) orelse continue;
        const rest = std.mem.trim(u8, value[end + 1 ..], " \t");
        if (rest.len > 0 and rest[0] != '#') continue;
        if (std.mem.eql(u8, value[1..end], name)) return true;
    }
    return false;
}

test "provider binding comparison does not match comments or wrong sections" {
    const toml = "# [[r2_buckets]]\n# binding = \"FILES\"\n[[d1_databases]]\nbinding = \"FILES\"\n[[r2_buckets]] # actual\nbinding = 'OBJECTS' # configured\n";
    try std.testing.expect(!hasResourceBinding(toml, "r2", "FILES"));
    try std.testing.expect(hasResourceBinding(toml, "r2", "OBJECTS"));
    try std.testing.expect(hasResourceBinding(toml, "d1", "FILES"));
}

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
