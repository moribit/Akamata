//! Developer entry point over the existing App and compile-time route graph.
const std = @import("std");
const core = @import("app.zig");
const typed = @import("contract/handler.zig");

pub fn App(comptime declaration: anytype) type {
    if (@TypeOf(declaration) == type) return core.App(declaration);
    if (!@hasField(@TypeOf(declaration), "routes")) @compileError("Akamata App requires .routes or an explicit State type");
    const State = if (@hasField(@TypeOf(declaration), "State")) declaration.State else struct {};
    const endpoints = blk: {
        comptime var list: []const type = &.{};
        for (declaration.routes) |route| list = list ++ .{route.For(State)};
        break :blk list;
    };
    const Graph = @import("static_router.zig").Graph(endpoints);
    comptime Graph.validate();
    return struct {
        const Self = @This();
        pub const StateType = State;
        pub const Ctx = @import("context.zig").Context(State);
        pub const Endpoints = endpoints;
        pub const Core = core.App(State);
        /// Explicit escape hatch; this owns the existing App, not providers.
        core: Core,
        pub fn init(allocator: std.mem.Allocator) !Self {
            return initWithState(allocator, .{});
        }
        pub fn initWithState(allocator: std.mem.Allocator, state: State) !Self {
            var app = Core.init(allocator, state);
            errdefer app.deinit();
            _ = try app.mountStatic(Graph);
            return .{ .core = app };
        }
        pub fn deinit(self: *Self) void {
            self.core.deinit();
        }
        pub fn serve(self: *Self, options: core.ServeOptions) !void {
            try self.core.serve(options);
        }
        pub fn client(self: *Self, allocator: std.mem.Allocator) @import("testing.zig").Client(Core) {
            return .init(allocator, &self.core);
        }
    };
}

pub fn endpoint(comptime options: anytype) type {
    return struct {
        pub fn For(comptime State: type) type {
            return typed.Endpoint(State, options);
        }
    };
}
pub fn get(comptime path: []const u8, comptime handler: anytype) type {
    return endpoint(.{ .method = .GET, .path = path, .handler = handler });
}
pub fn post(comptime path: []const u8, comptime handler: anytype) type {
    return endpoint(.{ .method = .POST, .path = path, .handler = handler });
}
