const std = @import("std");
const am = @import("akamata");
const application = @import("main.zig");

pub const std_options: std.Options = .{ .logFn = quietLog };
fn quietLog(comptime _: std.log.Level, comptime _: @TypeOf(.enum_literal), comptime _: []const u8, _: anytype) void {}

var app: application.Application = undefined;
var initialized = false;

export fn akamata_init() void {
    if (!initialized) {
        app = application.buildApplication(std.heap.wasm_allocator) catch return;
        initialized = true;
    }
    app.serve(.{}) catch {};
}
