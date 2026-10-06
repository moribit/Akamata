const std = @import("std");
const ak = @import("akamata");

fn hello() []const u8 {
    return "Hello, {{NAME}}!";
}

// The scaffold keeps its pinned release dependency. Latest main uses the
// ordinary-function API; the release bootstrap preserves the same HTTP text.
const ReleaseState = struct {};
pub const Application = if (@hasDecl(ak, "get"))
    ak.App(.{ .routes = .{ak.get("/", hello)} })
else
    ak.App(ReleaseState);

fn releaseHello(c: *ak.Context(ReleaseState)) !void {
    try c.text(hello());
}

pub fn buildApplication(allocator: std.mem.Allocator) !Application {
    if (comptime @hasDecl(ak, "get")) return Application.init(allocator);
    var app = Application.init(allocator, .{});
    errdefer app.deinit();
    _ = try app.get("/", releaseHello);
    return app;
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    var app = try buildApplication(gpa.allocator());
    defer app.deinit();
    const configured_port = ak.env.get(gpa.allocator(), "PORT");
    defer if (configured_port) |value| gpa.allocator().free(value);
    const port = if (configured_port) |value| try std.fmt.parseInt(u16, value, 10) else 8080;
    try app.serve(.{ .port = port });
}
