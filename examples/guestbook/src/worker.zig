// Workers entry. Same setup.zig as native; only DATABASE_URL changes.
//
// Default URL on Workers is `d1:DB` (the D1 binding named "DB"). Set
// DATABASE_URL=libsql://… in wrangler.toml `[vars]` if you want Turso instead.

const std = @import("std");
const am = @import("akamata");
const App = @import("app.zig").App;
const setup = @import("setup.zig");

pub const std_options: std.Options = .{ .logFn = noopLog };
fn noopLog(comptime _: std.log.Level, comptime _: @TypeOf(.enum_literal), comptime _: []const u8, _: anytype) void {}

const wasm_gpa = std.heap.wasm_allocator;

var app_storage: setup.Application = undefined;
var initialized: bool = false;

fn ensureInit() !void {
    if (initialized) return;
    const state = try setup.buildState(wasm_gpa);
    errdefer state.db.close();
    app_storage = try setup.Application.initWithState(wasm_gpa, state);
    errdefer app_storage.deinit();
    // Successful owners live with the Workers isolate, not individual requests.
    initialized = true;
}

export fn akamata_init() void {
    ensureInit() catch return;
    app_storage.serve(.{}) catch {};
}
