//! Semantic Cloudflare operations. Provider selection stays at this boundary.
//! Wrangler is the sole supported provider in Phase 1; add future providers here.
const std = @import("std");
const wrangler = @import("wrangler.zig");
const process = @import("../process.zig");

pub const Location = enum { local, remote };
pub const ExecuteOptions = struct {
    database: []const u8,
    file: []const u8,
    location: Location = .local,
    config: ?[]const u8 = null,
};

/// Injectable transport allows operation contract tests without credentials or
/// external tools. Captured output is owned by the caller's allocator.
pub const Runner = struct {
    run: *const fn (std.mem.Allocator, []const []const u8, ?[]const u8) anyerror!void = process.runChild,
    capture: *const fn (std.mem.Allocator, []const []const u8) anyerror!process.CapturedCmd = process.captureCmdAllowFail,
};

pub const Operations = struct {
    runner: Runner = .{},

    pub fn deploy(self: Operations, alloc: std.mem.Allocator, config: []const u8) !void {
        return wrangler.deploy(self.runner, alloc, config);
    }
    pub fn executeD1(self: Operations, alloc: std.mem.Allocator, opts: ExecuteOptions) !void {
        return wrangler.executeD1(self.runner, alloc, opts);
    }
    pub fn createD1(self: Operations, alloc: std.mem.Allocator, name: []const u8) !process.CapturedCmd {
        return wrangler.createD1(self.runner, alloc, name);
    }
    pub fn listD1(self: Operations, alloc: std.mem.Allocator) !process.CapturedCmd {
        return wrangler.listD1(self.runner, alloc);
    }
    pub fn ensureD1(self: Operations, alloc: std.mem.Allocator, config: []const u8) !void {
        return @import("provision.zig").ensureD1Provisioned(self, alloc, config);
    }
};

pub const default: Operations = .{};

const Contract = struct {
    fn run(_: std.mem.Allocator, argv: []const []const u8, cwd: ?[]const u8) !void {
        try std.testing.expect(cwd == null);
        const expected: []const []const u8 = if (std.mem.eql(u8, argv[2], "deploy"))
            &.{ "npx", "wrangler", "deploy", "--config", "custom.toml" }
        else if (std.mem.eql(u8, argv[5], "--remote"))
            &.{ "npx", "wrangler", "d1", "execute", "items", "--remote", "--config", "custom.toml", "--file", "schema.sql", "--yes" }
        else
            &.{ "npx", "wrangler", "d1", "execute", "items", "--local", "--file", "schema.sql", "--yes" };
        try std.testing.expectEqual(expected.len, argv.len);
        for (expected, argv) |a, b| try std.testing.expectEqualStrings(a, b);
    }
    fn capture(alloc: std.mem.Allocator, argv: []const []const u8) !process.CapturedCmd {
        const expected: []const []const u8 = if (std.mem.eql(u8, argv[3], "create"))
            &.{ "npx", "wrangler", "d1", "create", "items" }
        else
            &.{ "npx", "wrangler", "d1", "list", "--json" };
        try std.testing.expectEqual(expected.len, argv.len);
        for (expected, argv) |a, b| try std.testing.expectEqualStrings(a, b);
        return .{ .rc = 256, .stdout = try alloc.dupe(u8, "failure output") };
    }
    fn fail(_: std.mem.Allocator, _: []const []const u8, _: ?[]const u8) !void {
        return error.ChildFailed;
    }
};

test "Cloudflare operations preserve Wrangler argv and capture status" {
    const alloc = std.testing.allocator;
    const ops: Operations = .{ .runner = .{ .run = Contract.run, .capture = Contract.capture } };
    try ops.deploy(alloc, "custom.toml");
    try ops.executeD1(alloc, .{ .database = "items", .file = "schema.sql" });
    try ops.executeD1(alloc, .{ .database = "items", .file = "schema.sql", .location = .remote, .config = "custom.toml" });
    const created = try ops.createD1(alloc, "items");
    defer alloc.free(created.stdout);
    try std.testing.expectEqual(@as(c_int, 256), created.rc);
    const listed = try ops.listD1(alloc);
    defer alloc.free(listed.stdout);
    try std.testing.expectEqualStrings("failure output", listed.stdout);
}

test "Cloudflare operation failures propagate to the command" {
    const ops: Operations = .{ .runner = .{ .run = Contract.fail } };
    try std.testing.expectError(error.ChildFailed, ops.deploy(std.testing.allocator, "custom.toml"));
    try std.testing.expectError(error.ChildFailed, ops.executeD1(std.testing.allocator, .{ .database = "DB", .file = "schema.sql" }));
}
