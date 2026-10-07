//! Isolate-owned DB and DO control-plane owner, borrowed by the shared graph.
const std = @import("std");
const am = @import("akamata");
const setup = @import("setup.zig");
const C = @import("contract.zig").For(.workers);
pub const std_options: std.Options = .{ .logFn = noopLog };
fn noopLog(comptime _: std.log.Level, comptime _: @TypeOf(.enum_literal), comptime _: []const u8, _: anytype) void {}
var app: setup.Application = undefined;
var realtime: *am.platform.workers.RealtimeOwner = undefined;
var initialized = false;
fn ensureInit() !void {
    if (initialized) return;
    const alloc = std.heap.wasm_allocator;
    const url = am.env.get(alloc, "DATABASE_URL") orelse try alloc.dupe(u8, "d1:DB");
    defer alloc.free(url);
    const db = try am.db.openForContract(alloc, C, url);
    errdefer db.close();
    realtime = try am.platform.workers.RealtimeOwner.createForContract(alloc, C);
    errdefer realtime.deinit();
    app = try setup.Application.initWithState(alloc, .{ .db = db, .realtime = realtime.service() });
    errdefer app.deinit();
    initialized = true;
}
export fn akamata_init() void {
    ensureInit() catch return;
    app.serve(.{}) catch {};
}
