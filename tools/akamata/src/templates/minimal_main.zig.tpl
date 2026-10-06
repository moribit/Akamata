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

pub fn main(init: std.process.Init) !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    var args_arena: std.heap.ArenaAllocator = .init(gpa.allocator());
    defer args_arena.deinit();
    const args = try init.minimal.args.toSlice(args_arena.allocator());
    if (args.len > 1) {
        const command = std.mem.sliceTo(args[1], 0);
        if (std.mem.eql(u8, command, "akamata-openapi") or std.mem.eql(u8, command, "akamata-capabilities")) {
            if (comptime !@hasDecl(ak, "get")) return error.ToolingRequiresLatestMain;
            var buffer: [4096]u8 = undefined;
            var stdout = std.Io.File.stdout().writer(init.io, &buffer);
            if (std.mem.eql(u8, command, "akamata-openapi")) {
                var metadata: Application.Metadata = .{};
                const document = try ak.openapi.generate(Application.Metadata, &metadata, gpa.allocator(), .{ .title = "{{NAME}}", .version = "1.0.0" });
                defer gpa.allocator().free(document);
                try stdout.interface.writeAll(document);
            } else {
                const Contract = ak.capability.Contract("{{NAME}}", &.{}, &.{});
                const target = if (args.len == 3) std.mem.sliceTo(args[2], 0) else "native";
                if (std.mem.eql(u8, target, "workers")) try Contract.writeManifest(.workers, &stdout.interface, Application.Endpoints)
                else if (std.mem.eql(u8, target, "native")) try Contract.writeManifest(.native, &stdout.interface, Application.Endpoints)
                else if (std.mem.eql(u8, target, "containers")) try Contract.writeManifest(.containers, &stdout.interface, Application.Endpoints)
                else return error.InvalidTarget;
            }
            return stdout.interface.flush();
        }
        return error.UnknownCommand;
    }
    var app = try buildApplication(gpa.allocator());
    defer app.deinit();
    const configured_port = ak.env.get(gpa.allocator(), "PORT");
    defer if (configured_port) |value| gpa.allocator().free(value);
    const port = if (configured_port) |value| try std.fmt.parseInt(u16, value, 10) else 8080;
    try app.serve(.{ .port = port });
}
