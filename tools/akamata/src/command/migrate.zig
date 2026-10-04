const std = @import("std");
const commandUsage = @import("../help.zig").commandUsage;
const directoryExists = @import("../project/files.zig").directoryExists;
const isHelpArg = @import("../help.zig").isHelpArg;
const makeDirRecursive = @import("../project/files.zig").makeDirRecursive;
const runChild = @import("../process.zig").runChild;
const writeFileBytes = @import("../project/files.zig").writeFileBytes;

test "generated migration comments do not contain statement separators" {
    var lines = std.mem.splitScalar(u8, migration_file_template, '\n');
    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, line, "--")) {
            try std.testing.expect(std.mem.indexOfScalar(u8, line, ';') == null);
        }
    }
}

// ---- migrate ----
pub fn cmdMigrate(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    if (args.len == 0) {
        std.debug.print("usage: akamata migrate <generate|up> ...\n", .{});
        return error.UsageError;
    }
    const sub = std.mem.sliceTo(args[0], 0);
    if (isHelpArg(sub)) return commandUsage("migrate");
    if (args.len >= 2 and isHelpArg(std.mem.sliceTo(args[1], 0))) return commandUsage("migrate");
    if (std.mem.eql(u8, sub, "generate")) return migrateGenerate(alloc, args[1..]);
    if (std.mem.eql(u8, sub, "up")) return migrateRun(alloc, "migrate-up", args[1..]);
    if (std.mem.eql(u8, sub, "status")) return migrateRun(alloc, "migrate-status", args[1..]);
    if (std.mem.eql(u8, sub, "plan")) return migrateRun(alloc, "migrate-plan", args[1..]);
    if (std.mem.eql(u8, sub, "rollback")) return migrateRun(alloc, "migrate-rollback", args[1..]);
    if (std.mem.eql(u8, sub, "redo")) return migrateRun(alloc, "migrate-redo", args[1..]);
    std.debug.print("unknown migrate subcommand: {s}\n", .{sub});
    return error.UsageError;
}

pub const migration_file_template =
    \\-- akamata migration
    \\-- Generated: {s}
    \\-- Name: {s}
    \\
    \\-- migrate:up
    \\-- Write forward SQL here. Statements run in the order they appear.
    \\
    \\-- migrate:down
    \\-- Write rollback SQL here. Leave empty only for an intentionally irreversible migration.
    \\
;

pub fn migrateGenerate(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    if (args.len == 0) {
        std.debug.print("usage: akamata migrate generate <name> [--dir=migrations]\n", .{});
        return error.UsageError;
    }
    const name = std.mem.sliceTo(args[0], 0);
    var dir: []const u8 = "migrations";
    for (args[1..]) |raw| {
        const a = std.mem.sliceTo(raw, 0);
        if (std.mem.startsWith(u8, a, "--dir=")) dir = a[6..];
    }
    try makeDirRecursive(dir);

    // Timestamp version: YYYYMMDDHHMMSS in UTC.
    var arena_state: std.heap.ArenaAllocator = .init(alloc);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const ts = nowVersion(arena);
    const fname = try std.fmt.allocPrint(arena, "{s}/{s}_{s}.sql", .{ dir, ts, name });
    const body = try std.fmt.allocPrint(arena, migration_file_template, .{ ts, name });
    try writeFileBytes(fname, body);
    std.debug.print("created {s}\n", .{fname});
}

pub extern "c" fn time(t: ?*c_long) c_long;

pub extern "c" fn gmtime(timer: *const c_long) ?*Tm;

pub const Tm = extern struct {
    tm_sec: c_int,
    tm_min: c_int,
    tm_hour: c_int,
    tm_mday: c_int,
    tm_mon: c_int,
    tm_year: c_int,
    tm_wday: c_int,
    tm_yday: c_int,
    tm_isdst: c_int,
    tm_gmtoff: c_long,
    tm_zone: ?[*:0]const u8,
};

pub fn nowVersion(arena: std.mem.Allocator) []const u8 {
    const t = time(null);
    const tm = gmtime(&t) orelse return "00000000000000";
    return std.fmt.allocPrint(arena, "{d:0>4}{d:0>2}{d:0>2}{d:0>2}{d:0>2}{d:0>2}", .{
        @as(u32, @intCast(tm.tm_year + 1900)),
        @as(u32, @intCast(tm.tm_mon + 1)),
        @as(u32, @intCast(tm.tm_mday)),
        @as(u32, @intCast(tm.tm_hour)),
        @as(u32, @intCast(tm.tm_min)),
        @as(u32, @intCast(tm.tm_sec)),
    }) catch "00000000000000";
}

/// `akamata migrate up` is a thin wrapper that delegates to the app binary's
/// `migrate-up` subcommand (cargo-style). The app sets up its DB url, loads
/// the migration directory, and runs `am.model.migrate.Migrator.applyAll`.
pub fn migrateRun(alloc: std.mem.Allocator, mode: []const u8, args: []const [:0]const u8) !void {
    var dir: []const u8 = "migrations";
    for (args) |raw| {
        const arg = std.mem.sliceTo(raw, 0);
        if (std.mem.startsWith(u8, arg, "--dir=")) dir = arg[6..];
    }
    if (!directoryExists(dir)) {
        std.debug.print("migrate: {s}/ does not exist; nothing to apply. Create one with `akamata migrate generate <name>`.\n", .{dir});
        return;
    }
    var argv: std.ArrayList([]const u8) = .empty;
    defer argv.deinit(alloc);
    try argv.appendSlice(alloc, &.{ "zig", "build", "run", "--", mode });
    for (args) |raw| try argv.append(alloc, std.mem.sliceTo(raw, 0));
    runChild(alloc, argv.items, null) catch |err| {
        std.debug.print("migrate: application runner failed. Ensure `zig build run -- migrate-up` works in this project and DATABASE_URL is valid.\n", .{});
        return err;
    };
}
