const std = @import("std");

/// Parse the JSON array returned by `wrangler d1 list --json` and find the
/// `uuid` whose `name` matches. Returns owned memory (caller frees).
///
/// We search for the JSON payload by scanning for `[` that's followed (after
/// whitespace) by `{` or `]` — wrangler prefixes the JSON with a banner that
/// itself contains a `[fake-npx]` style bracket on some setups, so a naïve
/// `indexOfScalar(_, '[')` lands on the wrong bracket.
pub fn lookupD1UuidByName(alloc: std.mem.Allocator, json_bytes: []const u8, want_name: []const u8) !?[]u8 {
    const start = findJsonArrayStart(json_bytes) orelse return null;
    var parsed = std.json.parseFromSlice(std.json.Value, alloc, json_bytes[start..], .{}) catch return null;
    defer parsed.deinit();
    if (parsed.value != .array) return null;
    for (parsed.value.array.items) |item| {
        if (item != .object) continue;
        const name_v = item.object.get("name") orelse continue;
        if (name_v != .string) continue;
        if (!std.mem.eql(u8, name_v.string, want_name)) continue;
        const uuid_v = item.object.get("uuid") orelse continue;
        if (uuid_v != .string) continue;
        return try alloc.dupe(u8, uuid_v.string);
    }
    return null;
}

/// Locate an opening `[` whose next non-whitespace char is `{` or `]` — i.e.
/// the start of a JSON array of objects (or an empty array). Returns the
/// index of the `[`, or null if none found.
pub fn findJsonArrayStart(text: []const u8) ?usize {
    var i: usize = 0;
    while (i < text.len) : (i += 1) {
        if (text[i] != '[') continue;
        var j: usize = i + 1;
        while (j < text.len and (text[j] == ' ' or text[j] == '\t' or text[j] == '\n' or text[j] == '\r')) : (j += 1) {}
        if (j < text.len and (text[j] == '{' or text[j] == ']')) return i;
    }
    return null;
}

/// Find a 36-char UUID in text (8-4-4-4-12 lowercase hex form).
pub fn extractUuid(text: []const u8) ?[]const u8 {
    if (text.len < 36) return null;
    var i: usize = 0;
    while (i + 36 <= text.len) : (i += 1) {
        const win = text[i .. i + 36];
        if (isUuid(win)) return win;
    }
    return null;
}

pub fn isUuid(s: []const u8) bool {
    if (s.len != 36) return false;
    for (s, 0..) |c, i| {
        if (i == 8 or i == 13 or i == 18 or i == 23) {
            if (c != '-') return false;
        } else if (!std.ascii.isHex(c)) return false;
    }
    return true;
}

test "extractUuid finds the UUID in wrangler create output" {
    const sample =
        \\ ⛅️ wrangler 4.93.1
        \\Successfully created DB 'guestbook' in region APAC
        \\
        \\[[d1_databases]]
        \\binding = "DB"
        \\database_name = "guestbook"
        \\database_id = "abcd1234-5678-9abc-def0-fedcba987654"
        \\
    ;
    const got = extractUuid(sample) orelse return error.TestUnexpectedNullUuid;
    try std.testing.expectEqualStrings("abcd1234-5678-9abc-def0-fedcba987654", got);
}

test "extractUuid rejects strings without a UUID" {
    try std.testing.expect(extractUuid("no uuid here") == null);
    // Almost — wrong hex length in last group
    try std.testing.expect(extractUuid("abcd1234-5678-9abc-def0-fedcba98765") == null);
}

test "isUuid: positive and negative cases" {
    try std.testing.expect(isUuid("00000000-0000-0000-0000-000000000000"));
    try std.testing.expect(isUuid("abcd1234-5678-9abc-def0-fedcba987654"));
    try std.testing.expect(!isUuid("abcd1234_5678_9abc_def0_fedcba987654")); // underscores
    try std.testing.expect(!isUuid("abcd1234-5678-9abc-def0-fedcba98765z")); // non-hex
    try std.testing.expect(!isUuid("short"));
}

test "lookupD1UuidByName: skips bracketed banner text before the JSON" {
    // Reproduces the bug where the shim's `[fake-npx]` log got picked up as
    // the start of the JSON array. wrangler itself can also emit warnings
    // containing `[` before the actual payload.
    const sample =
        \\[fake-npx] wrangler d1 list --json
        \\ ⛅️ wrangler 4.93.1 (fake)
        \\[
        \\  {
        \\    "uuid": "19c8e27f-d6af-420e-9683-1cfff695c25e",
        \\    "name": "guestbook"
        \\  }
        \\]
    ;
    const got = (try lookupD1UuidByName(std.testing.allocator, sample, "guestbook")) orelse return error.TestExpectedUuid;
    defer std.testing.allocator.free(got);
    try std.testing.expectEqualStrings("19c8e27f-d6af-420e-9683-1cfff695c25e", got);
}

test "lookupD1UuidByName: finds the matching name in JSON array" {
    const sample =
        \\ ⛅️ wrangler 4.93.1
        \\[
        \\  {
        \\    "uuid": "19c8e27f-d6af-420e-9683-1cfff695c25e",
        \\    "name": "guestbook",
        \\    "created_at": "2026-05-22T13:02:13.001Z"
        \\  },
        \\  {
        \\    "uuid": "deadbeef-1234-5678-9abc-def012345678",
        \\    "name": "other"
        \\  }
        \\]
    ;
    const got = (try lookupD1UuidByName(std.testing.allocator, sample, "guestbook")) orelse return error.TestExpectedUuid;
    defer std.testing.allocator.free(got);
    try std.testing.expectEqualStrings("19c8e27f-d6af-420e-9683-1cfff695c25e", got);

    // Name not in the list → null
    const missing = try lookupD1UuidByName(std.testing.allocator, sample, "nonexistent");
    try std.testing.expect(missing == null);
}

const operations = @import("operations.zig");
const process = @import("../process.zig");

pub fn deploy(runner: operations.Runner, alloc: std.mem.Allocator, config: []const u8) !void {
    std.debug.print("==> akamata: wrangler deploy\n", .{});
    return runner.run(alloc, &.{ "npx", "wrangler", "deploy", "--config", config }, null);
}
pub fn executeD1(runner: operations.Runner, alloc: std.mem.Allocator, opts: operations.ExecuteOptions) !void {
    const mode: []const u8 = switch (opts.location) {
        .local => "--local",
        .remote => "--remote",
    };
    if (opts.config) |cfg| {
        return runner.run(alloc, &.{ "npx", "wrangler", "d1", "execute", opts.database, mode, "--config", cfg, "--file", opts.file, "--yes" }, null);
    }
    return runner.run(alloc, &.{ "npx", "wrangler", "d1", "execute", opts.database, mode, "--file", opts.file, "--yes" }, null);
}
pub fn createD1(runner: operations.Runner, alloc: std.mem.Allocator, name: []const u8) !process.CapturedCmd {
    return runner.capture(alloc, &.{ "npx", "wrangler", "d1", "create", name });
}
pub fn listD1(runner: operations.Runner, alloc: std.mem.Allocator) !process.CapturedCmd {
    return runner.capture(alloc, &.{ "npx", "wrangler", "d1", "list", "--json" });
}
