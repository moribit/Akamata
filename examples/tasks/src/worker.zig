//! Successful owners persist for the isolate; failures unwind before retry.
const std = @import("std");
const am = @import("akamata");
const setup = @import("setup.zig");
const contracts = @import("contract.zig");
const h = @import("handlers.zig");
pub const std_options: std.Options = .{ .logFn = noopLog };
fn noopLog(comptime _: std.log.Level, comptime _: @TypeOf(.enum_literal), comptime _: []const u8, _: anytype) void {}
var app: setup.Application = undefined;
var effects: h.Effects = undefined;
var queue: *am.platform.workers.QueueOwner(contracts.TaskCreatedDescriptor) = undefined;
var initialized = false;
fn ensureInit() !void {
    if (initialized) return;
    const alloc = std.heap.wasm_allocator;
    const C = contracts.For(.workers);
    const url = am.env.get(alloc, "DATABASE_URL") orelse try alloc.dupe(u8, comptime "d1:" ++ C.resolve(.database).binding.?);
    defer alloc.free(url);
    const db = try am.db.openForContract(alloc, C, url);
    errdefer db.close();
    effects = .{ .db = db };
    queue = try am.platform.workers.QueueOwner(contracts.TaskCreatedDescriptor).createForContract(alloc, C, .{ .context = &effects, .handler_with_context = h.consumeCreated });
    errdefer queue.deinit();
    app = try setup.Application.initWithState(alloc, .{ .db = db, .queue = queue.producer() });
    errdefer app.deinit();
    am.platform.workers.setQueueConsumer(consume);
    initialized = true;
}
fn consume(bytes: []const u8) !void {
    try queue.consume(bytes);
}
export fn akamata_init() void {
    ensureInit() catch return;
    app.serve(.{}) catch {};
}
