const std = @import("std");
const D1Info = @import("../cloudflare/config.zig").D1Info;
const defaultConfigPath = @import("../cloudflare/config.zig").defaultConfigPath;
const readD1FromConfig = @import("../cloudflare/config.zig").readD1FromConfig;
const cloudflare = @import("../cloudflare/operations.zig");

// ---- db ----
pub fn cmdDb(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    if (args.len == 0) {
        std.debug.print("db: missing SQL file path\n", .{});
        return error.UsageError;
    }
    const sql_file: []const u8 = std.mem.sliceTo(args[0], 0);
    var mode: []const u8 = "--local";
    var config_path: ?[]const u8 = null;
    for (args[1..]) |raw| {
        const a = std.mem.sliceTo(raw, 0);
        if (std.mem.eql(u8, a, "--remote")) mode = "--remote" else if (std.mem.eql(u8, a, "--local")) mode = "--local" else if (std.mem.startsWith(u8, a, "--config=")) config_path = a[9..];
    }

    // Pick the D1 name from the wrangler.toml (so we don't hard-code "DB").
    const cfg = config_path orelse defaultConfigPath();
    var db_name: []const u8 = "DB";
    var owned: ?D1Info = null;
    defer if (owned) |i| {
        alloc.free(i.binding);
        alloc.free(i.name);
        alloc.free(i.id);
    };
    if (cfg) |c| {
        if (try readD1FromConfig(alloc, c)) |info| {
            owned = info;
            db_name = info.name;
            return cloudflare.default.executeD1(alloc, .{ .database = db_name, .file = sql_file, .location = if (std.mem.eql(u8, mode, "--remote")) .remote else .local, .config = if (config_path != null) c else null });
        }
    }
    try cloudflare.default.executeD1(alloc, .{ .database = db_name, .file = sql_file, .location = if (std.mem.eql(u8, mode, "--remote")) .remote else .local });
}
