//! Explicit isolate-owned adapter to the existing DO room control plane.
const std = @import("std");
const realtime = @import("../realtime.zig");
extern "akamata_realtime" fn akamata_realtime_operation([*]const u8, usize, [*]const u8, usize, [*]const u8, usize) i64;

pub const Owner = struct {
    allocator: std.mem.Allocator,
    binding: []const u8,
    pub fn create(allocator: std.mem.Allocator, binding: []const u8) !*Owner {
        if (binding.len == 0 or binding.len > 256) return error.InvalidBinding;
        const self = try allocator.create(Owner);
        errdefer allocator.destroy(self);
        self.* = .{ .allocator = allocator, .binding = try allocator.dupe(u8, binding) };
        return self;
    }
    /// Stop dispatch borrowing this stable owner before destruction. The host
    /// owns remote instances and sockets; deinit never deletes a remote room.
    pub fn deinit(self: *Owner) void {
        const allocator = self.allocator;
        allocator.free(self.binding);
        allocator.destroy(self);
    }
    pub fn service(self: *Owner) realtime.Service {
        return .{ .backend = .{ .ptr = self, .vtable = &vtable } };
    }
    fn operation(self: *Owner, room: []const u8, value: anytype) realtime.Error!i64 {
        if (room.len == 0 or room.len > 1024) return error.Unsupported;
        const bytes = std.json.Stringify.valueAlloc(self.allocator, value, .{}) catch return error.Backpressure;
        defer self.allocator.free(bytes);
        if (bytes.len > 128 * 1024) return error.Backpressure;
        const rc = akamata_realtime_operation(self.binding.ptr, self.binding.len, room.ptr, room.len, bytes.ptr, bytes.len);
        return if (rc >= 0) rc else switch (rc) {
            -1 => error.NotFound,
            -2 => error.Unsupported,
            -3 => error.Backpressure,
            else => error.BackendFailure,
        };
    }
    fn direct(raw: *anyopaque, room: []const u8, connection: realtime.ConnectionId, bytes: []const u8) realtime.Error!void {
        if (bytes.len > 64 * 1024) return error.Backpressure;
        const self: *Owner = @ptrCast(@alignCast(raw));
        var buffer: [20]u8 = undefined;
        const id = std.fmt.bufPrint(&buffer, "{d}", .{connection}) catch unreachable;
        _ = try self.operation(room, .{ .kind = "direct", .connection = id, .envelope = bytes });
    }
    fn broadcast(raw: *anyopaque, room: []const u8, bytes: []const u8, excluded: ?realtime.ConnectionId) realtime.Error!usize {
        if (bytes.len > 64 * 1024) return error.Backpressure;
        const self: *Owner = @ptrCast(@alignCast(raw));
        var buffer: [20]u8 = undefined;
        const id: ?[]const u8 = if (excluded) |value| std.fmt.bufPrint(&buffer, "{d}", .{value}) catch unreachable else null;
        return @intCast(try self.operation(room, .{ .kind = "broadcast", .excluded = id, .envelope = bytes }));
    }
    fn disconnect(raw: *anyopaque, room: []const u8, connection: realtime.ConnectionId, close: realtime.Close) realtime.Error!void {
        if (close.reason.len > 123) return error.Unsupported;
        const self: *Owner = @ptrCast(@alignCast(raw));
        var buffer: [20]u8 = undefined;
        const id = std.fmt.bufPrint(&buffer, "{d}", .{connection}) catch unreachable;
        _ = try self.operation(room, .{ .kind = "disconnect", .connection = id, .code = close.code, .reason = close.reason });
    }
    /// Existing portable presence() cannot return errors. Applications that
    /// need readiness/error evidence must use this explicit platform extension.
    pub fn presenceChecked(self: *Owner, room: []const u8) realtime.Error!realtime.Presence {
        const bits: u64 = @intCast(try self.operation(room, .{ .kind = "presence" }));
        return .{ .connections = @intCast(bits >> 32), .members = @intCast(bits & 0xffffffff) };
    }
    fn presence(raw: *anyopaque, room: []const u8) realtime.Presence {
        const self: *Owner = @ptrCast(@alignCast(raw));
        return self.presenceChecked(room) catch .{ .connections = 0, .members = 0 };
    }
    const vtable: realtime.Backend.VTable = .{ .direct = direct, .broadcast = broadcast, .disconnect = disconnect, .presence = presence };
};
