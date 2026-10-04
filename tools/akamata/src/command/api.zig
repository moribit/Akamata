const readFileAlloc = @import("../project/files.zig").readFileAlloc;
const api_client = @import("../api_client.zig");
const runChild = @import("../process.zig").runChild;
const std = @import("std");

pub fn diffComponentSchemas(before: std.json.Value, after: std.json.Value) usize {
    const old_schemas = nestedObject(before, &.{ "components", "schemas" }) orelse return 0;
    const new_schemas = nestedObject(after, &.{ "components", "schemas" }) orelse return 0;
    var breaking: usize = 0;
    var schemas = old_schemas.iterator();
    while (schemas.next()) |schema| {
        const replacement = new_schemas.get(schema.key_ptr.*) orelse {
            std.debug.print("BREAKING removed schema {s}\n", .{schema.key_ptr.*});
            breaking += 1;
            continue;
        };
        if (schema.value_ptr.* != .object or replacement != .object) continue;
        const old_type = schema.value_ptr.*.object.get("type");
        const new_type = replacement.object.get("type");
        if (!jsonScalarEqual(old_type, new_type)) {
            std.debug.print("BREAKING changed type of schema {s}\n", .{schema.key_ptr.*});
            breaking += 1;
        }
        const old_props = schema.value_ptr.*.object.get("properties");
        const new_props = replacement.object.get("properties");
        if (old_props != null and old_props.? == .object) {
            var props = old_props.?.object.iterator();
            while (props.next()) |prop| {
                const next = if (new_props != null and new_props.? == .object) new_props.?.object.get(prop.key_ptr.*) else null;
                if (next == null) {
                    std.debug.print("BREAKING removed property {s}.{s}\n", .{ schema.key_ptr.*, prop.key_ptr.* });
                    breaking += 1;
                } else if (prop.value_ptr.* == .object and next.? == .object and !jsonScalarEqual(prop.value_ptr.*.object.get("type"), next.?.object.get("type"))) {
                    std.debug.print("BREAKING changed property type {s}.{s}\n", .{ schema.key_ptr.*, prop.key_ptr.* });
                    breaking += 1;
                }
            }
        }
        const old_required = schema.value_ptr.*.object.get("required");
        const new_required = replacement.object.get("required");
        if (new_required != null and new_required.? == .array) for (new_required.?.array.items) |name| {
            if (name == .string and !arrayContainsString(old_required, name.string)) {
                std.debug.print("BREAKING added required property {s}.{s}\n", .{ schema.key_ptr.*, name.string });
                breaking += 1;
            }
        };
    }
    return breaking;
}

pub fn nestedObject(root: std.json.Value, keys: []const []const u8) ?std.json.ObjectMap {
    var current = root;
    for (keys) |key| {
        if (current != .object) return null;
        current = current.object.get(key) orelse return null;
    }
    return if (current == .object) current.object else null;
}

pub fn jsonScalarEqual(a: ?std.json.Value, b: ?std.json.Value) bool {
    if (a == null and b == null) return true;
    if (a == null or b == null) return false;
    if (a.? == .string and b.? == .string) return std.mem.eql(u8, a.?.string, b.?.string);
    if (a.? == .null and b.? == .null) return true;
    if (a.? == .bool and b.? == .bool) return a.?.bool == b.?.bool;
    if (a.? == .integer and b.? == .integer) return a.?.integer == b.?.integer;
    if (a.? == .float and b.? == .float) return a.?.float == b.?.float;
    return false;
}

pub fn arrayContainsString(value: ?std.json.Value, needle: []const u8) bool {
    if (value == null or value.? != .array) return false;
    for (value.?.array.items) |item| if (item == .string and std.mem.eql(u8, item.string, needle)) return true;
    return false;
}

pub fn cmdApi(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    if (args.len >= 2 and std.mem.eql(u8, std.mem.sliceTo(args[0], 0), "call")) {
        api_client.runOperation(alloc, std.mem.sliceTo(args[1], 0), args[2..]) catch |err| {
            std.debug.print("akamata api call: {s}\n", .{@errorName(err)});
            std.process.exit(1);
        };
        return;
    }
    if (args.len != 3 or !std.mem.eql(u8, std.mem.sliceTo(args[0], 0), "diff")) return error.UsageError;
    const before_bytes = try readFileAlloc(alloc, std.mem.sliceTo(args[1], 0), 16 * 1024 * 1024);
    defer alloc.free(before_bytes);
    const after_bytes = try readFileAlloc(alloc, std.mem.sliceTo(args[2], 0), 16 * 1024 * 1024);
    defer alloc.free(after_bytes);
    var before = try std.json.parseFromSlice(std.json.Value, alloc, before_bytes, .{});
    defer before.deinit();
    var after = try std.json.parseFromSlice(std.json.Value, alloc, after_bytes, .{});
    defer after.deinit();
    const bp = if (before.value == .object) before.value.object.get("paths") else null;
    const ap = if (after.value == .object) after.value.object.get("paths") else null;
    if (bp == null or ap == null or bp.? != .object or ap.? != .object) return error.InvalidOpenApi;
    var breaking: usize = 0;
    var paths = bp.?.object.iterator();
    while (paths.next()) |entry| {
        const new_path = ap.?.object.get(entry.key_ptr.*) orelse {
            std.debug.print("BREAKING removed path {s}\n", .{entry.key_ptr.*});
            breaking += 1;
            continue;
        };
        if (entry.value_ptr.* != .object or new_path != .object) continue;
        var methods = entry.value_ptr.*.object.iterator();
        while (methods.next()) |method| {
            if (isHttpMethod(method.key_ptr.*) and new_path.object.get(method.key_ptr.*) == null) {
                std.debug.print("BREAKING removed operation {s} {s}\n", .{ method.key_ptr.*, entry.key_ptr.* });
                breaking += 1;
            }
        }
    }
    breaking += diffComponentSchemas(before.value, after.value);
    if (breaking != 0) return error.BreakingApiChange;
    std.debug.print("api diff: no breaking path, operation, or schema changes\n", .{});
}

pub fn isHttpMethod(value: []const u8) bool {
    return std.mem.eql(u8, value, "get") or std.mem.eql(u8, value, "post") or std.mem.eql(u8, value, "put") or std.mem.eql(u8, value, "patch") or std.mem.eql(u8, value, "delete") or std.mem.eql(u8, value, "head") or std.mem.eql(u8, value, "options");
}
