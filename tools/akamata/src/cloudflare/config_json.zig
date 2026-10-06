//! Read-only projection of Wrangler JSON/JSONC into the existing binding reader.
//! This does not rewrite user configuration or invent another deployment schema.
const std = @import("std");

pub fn normalize(alloc: std.mem.Allocator, bytes: []const u8) ![]u8 {
    const clean = try alloc.dupe(u8, bytes);
    defer alloc.free(clean);
    var i: usize = 0;
    while (i < clean.len) {
        if (clean[i] == '"') {
            i = try stringEnd(clean, i);
        } else if (i + 1 < clean.len and clean[i] == '/' and clean[i + 1] == '/') {
            while (i < clean.len and clean[i] != '\n') : (i += 1) clean[i] = ' ';
        } else if (i + 1 < clean.len and clean[i] == '/' and clean[i + 1] == '*') {
            clean[i] = ' ';
            clean[i + 1] = ' ';
            i += 2;
            var ended = false;
            while (i + 1 < clean.len) : (i += 1) {
                if (clean[i] == '*' and clean[i + 1] == '/') {
                    clean[i] = ' ';
                    clean[i + 1] = ' ';
                    i += 2;
                    ended = true;
                    break;
                }
                if (clean[i] != '\n' and clean[i] != '\r') clean[i] = ' ';
            }
            if (!ended) return error.InvalidConfigComment;
        } else i += 1;
    }
    i = 0;
    while (i < clean.len) {
        if (clean[i] == '"') {
            i = try stringEnd(clean, i);
            continue;
        }
        if (clean[i] == ',') {
            var next = i + 1;
            while (next < clean.len and std.ascii.isWhitespace(clean[next])) : (next += 1) {}
            var previous = i;
            while (previous > 0 and std.ascii.isWhitespace(clean[previous - 1])) : (previous -= 1) {}
            const after_value = previous > 0 and std.mem.indexOfScalar(u8, "{[,:", clean[previous - 1]) == null;
            if (after_value and next < clean.len and (clean[next] == '}' or clean[next] == ']')) clean[i] = ' ';
        }
        i += 1;
    }
    const parsed = try std.json.parseFromSlice(std.json.Value, alloc, clean, .{});
    defer parsed.deinit();
    if (parsed.value != .object) return error.InvalidDeploymentConfig;
    var out: std.Io.Writer.Allocating = .init(alloc);
    errdefer out.deinit();
    if (parsed.value.object.get("name")) |name| try assignment(&out.writer, "name", name);
    try project(&out.writer, parsed.value, null);
    if (parsed.value.object.get("env")) |env| {
        if (env != .object) return error.InvalidDeploymentConfig;
        var iter = env.object.iterator();
        while (iter.next()) |entry| {
            try @import("config.zig").validateEnvironment(entry.key_ptr.*);
            try project(&out.writer, entry.value_ptr.*, entry.key_ptr.*);
        }
    }
    return out.toOwnedSlice();
}

fn stringEnd(bytes: []const u8, start: usize) !usize {
    var i = start + 1;
    while (i < bytes.len) : (i += 1) {
        if (bytes[i] == '"') return i + 1;
        if (bytes[i] == '\\') i += 1;
    }
    return error.InvalidDeploymentConfig;
}

fn assignment(w: *std.Io.Writer, key: []const u8, value: std.json.Value) !void {
    if (value != .string) return error.InvalidDeploymentConfig;
    // The existing TOML borrowing reader does not decode escapes. Reject
    // unrepresentable projected strings instead of changing their meaning.
    for (value.string) |c| if (c == '"' or c == '\\' or c < 32) return error.UnsupportedConfigString;
    for (key) |c| if (!std.ascii.isAlphanumeric(c) and c != '_') return error.UnsupportedConfigKey;
    try w.print("{s} = \"{s}\"\n", .{ key, value.string });
}

fn project(w: *std.Io.Writer, root: std.json.Value, environment: ?[]const u8) !void {
    if (root != .object) return error.InvalidDeploymentConfig;
    if (root.object.get("vars")) |vars| {
        if (vars != .object) return error.InvalidDeploymentConfig;
        if (environment) |name| try w.print("[env.{s}.vars]\n", .{name}) else try w.writeAll("[vars]\n");
        var iter = vars.object.iterator();
        while (iter.next()) |entry| {
            // Only variables used by provider validation belong in this view.
            const key = entry.key_ptr.*;
            if (std.mem.eql(u8, key, "DATABASE_URL") or std.mem.eql(u8, key, "AKAMATA_REALTIME_BINDING")) try assignment(w, key, entry.value_ptr.*);
        }
    }
    try array(w, root.object.get("d1_databases"), "d1_databases", environment);
    try array(w, root.object.get("r2_buckets"), "r2_buckets", environment);
    if (root.object.get("queues")) |queues| {
        if (queues != .object) return error.InvalidDeploymentConfig;
        try array(w, queues.object.get("producers"), "queues.producers", environment);
        try array(w, queues.object.get("consumers"), "queues.consumers", environment);
    }
    if (root.object.get("durable_objects")) |objects| {
        if (objects != .object) return error.InvalidDeploymentConfig;
        try array(w, objects.object.get("bindings"), "durable_objects.bindings", environment);
    }
}

fn array(w: *std.Io.Writer, maybe: ?std.json.Value, section: []const u8, environment: ?[]const u8) !void {
    const list = maybe orelse return;
    if (list != .array) return error.InvalidDeploymentConfig;
    for (list.array.items) |item| {
        if (item != .object) return error.InvalidDeploymentConfig;
        if (environment) |name| try w.print("[[env.{s}.{s}]]\n", .{ name, section }) else try w.print("[[{s}]]\n", .{section});
        inline for (.{ "binding", "name", "database_id", "database_name", "bucket_name", "queue", "class_name", "script_name" }) |key| {
            if (item.object.get(key)) |value| try assignment(w, key, value);
        }
    }
}

test "JSONC projection respects strings environments comments and trailing commas" {
    const content = "{\"name\":\"fixture\",/* root */\"r2_buckets\":[{\"binding\":\"FILES\",\"bucket_name\":\"root\",},],\"env\":{\"production\":{\"vars\":{\"DATABASE_URL\":\"https://db.invalid/#id\",},\"r2_buckets\":[{\"binding\":\"FILES\",\"bucket_name\":\"production\"}],},},}// end";
    const result = try normalize(std.testing.allocator, content);
    defer std.testing.allocator.free(result);
    const config = @import("config.zig");
    try std.testing.expectEqualStrings("production", (try config.resource(result, "r2", "FILES", "production")).identifier.?);
    try std.testing.expect(!(try config.resource(result, "r2", "FILES", "preview")).present);
    try std.testing.expectEqualStrings("https://db.invalid/#id", (try config.environmentVar(result, "production", "DATABASE_URL")).?);
    try std.testing.expectError(error.InvalidConfigComment, normalize(std.testing.allocator, "{/*"));
    try std.testing.expectError(error.InvalidDeploymentConfig, normalize(std.testing.allocator, "{\"r2_buckets\":false}"));
    try std.testing.expectError(error.SyntaxError, normalize(std.testing.allocator, "{,}"));
}
