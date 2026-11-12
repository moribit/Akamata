//! The published developer journey, exercised against a temporary project.
const std = @import("std");
const s = @import("support.zig");
const wire = @import("wire.zig");
pub fn run(h: s.H, args: []const []const u8) !void {
    if (args.len != 2) return error.InvalidArguments;
    const cli = try h.absolute(args[0]);
    const checkout = try h.absolute(args[1]);
    const temp = try h.temp();
    defer temp.deinit();
    _ = try h.run(&.{ cli, "init", "journey", "--target=both" }, temp.path, h.env);
    const project = try h.absolute(try temp.file("journey"));
    const zon = try h.fmt("{s}/build.zig.zon", .{project});
    const original = try h.read(zon);
    const begin = std.mem.indexOf(u8, original, ".url = \"") orelse return error.MissingDependency;
    const hash = std.mem.indexOfPos(u8, original, begin, ".hash = \"") orelse return error.MissingDependency;
    const end = (std.mem.indexOfPos(u8, original, hash + 9, "\",") orelse return error.MissingDependency) + 2;
    const relative = try std.fs.path.relativeAlloc(h.a, project, h.env, project, checkout);
    try h.write(zon, try h.fmt("{s}.path = \"{s}\",{s}", .{ original[0..begin], relative, original[end..] }));
    const main = try h.fmt("{s}/src/main.zig", .{project});
    const source = try s.replace(h, try h.read(main), ".routes = .{ak.get(\"/\", hello)}", ".routes = .{ak.get(\"/\", hello), ak.post(\"/users\", createUser)}");
    try h.write(main, try h.fmt("{s}\n{s}", .{ source, typed_source }));
    _ = try h.run(&.{ cli, "test" }, project, h.env);
    _ = try h.run(&.{ cli, "check", "--quick" }, project, h.env);
    _ = try h.run(&.{ h.env.get("ZIG") orelse "zig", "build", "-Dbackend=workers", "-Doptimize=ReleaseSafe" }, project, h.env);
    const port = try wire.freePort();
    try h.env.put("PORT", try h.fmt("{d}", .{port}));
    var server = try wire.Server.start(h, &.{ cli, "dev" }, project, h.env, port);
    defer server.deinit();
    const deadline = h.now() + 120 * std.time.ns_per_s;
    var client: ?*wire.Client = null;
    while (h.now() < deadline) {
        if (try server.poll()) return error.DevExited;
        client = server.connect() catch {
            h.sleep(100);
            continue;
        };
        break;
    }
    const c = client orelse {
        std.debug.print("{s}\n", .{try h.read(server.log_path)});
        return error.DevStartupTimeout;
    };
    try c.send("POST /users HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\nContent-Type: application/json\r\nContent-Length: 16\r\n\r\n{\"name\":\"Alice\"}");
    const response = try c.response();
    try s.check(response.status == 201, "typed route status");
    try s.contains(response.body, "\"Alice\"");
    server.signal(.TERM);
    try server.wait(10000);
    std.debug.print("public journey: init, typed JSON, dev HTTP/shutdown, CLI test/check, Workers build passed\n", .{});
}
const typed_source =
    \\const CreateUser = struct {
    \\    name: []const u8,
    \\    pub const validation = .{ .name = .{ak.model.rule.min_len(1)} };
    \\};
    \\fn createUser(input: ak.Json(CreateUser)) ak.Result(CreateUser, 201) {
    \\    return ak.created(input.value);
    \\}
    \\test "typed application" {
    \\    var app = try buildApplication(std.testing.allocator);
    \\    defer app.deinit();
    \\    var client = app.client(std.testing.allocator);
    \\    var response = try client.post("/users").json(.{ .name = "Alice" }).send();
    \\    defer response.deinit();
    \\    try response.expectStatus(.created);
    \\    try std.testing.expectEqualStrings("Alice", (try response.json(CreateUser)).name);
    \\}
;
