//! Default scaffold contract: no providers until the application needs them.
const std = @import("std");
const s = @import("support.zig");
const wire = @import("wire.zig");
pub fn run(h: s.H, args: []const []const u8) !void {
    if (args.len < 1 or args.len > 2) return error.InvalidArguments;
    const cli = try h.absolute(args[0]);
    const checkout = if (args.len == 2) try h.absolute(args[1]) else null;
    const temp = try h.temp();
    defer temp.deinit();
    _ = try h.run(&.{ cli, "init", "minimalapp", "--target=both" }, temp.path, h.env);
    const project = try temp.file("minimalapp");
    const source = try h.read(try h.fmt("{s}/src/main.zig", .{project}));
    try s.contains(source, "fn hello() []const u8");
    try s.check(std.mem.indexOf(u8, source, "Note") == null and std.mem.indexOf(u8, source, "db.open") == null, "minimal scaffold has no database");
    for ([_][]const u8{ "migrations", "controllers", "services", "repositories", "providers" }) |folder|
        try s.check(!h.exists(try h.fmt("{s}/{s}", .{ project, folder })), "no convention folders");
    const zig = h.env.get("ZIG") orelse "zig";
    for ([_][]const []const u8{ &.{"-Doptimize=ReleaseSafe"}, &.{ "test", "-Doptimize=ReleaseSafe" }, &.{ "-Dbackend=workers", "-Doptimize=ReleaseSafe" } }) |options| {
        var argv: std.ArrayList([]const u8) = .empty;
        try argv.appendSlice(h.a, &.{ zig, "build" });
        if (checkout) |path| try argv.append(h.a, try h.fmt("--fork={s}", .{path}));
        try argv.appendSlice(h.a, options);
        _ = try h.run(argv.items, project, h.env);
    }
    const binary = try h.fmt("{s}/zig-out/bin/minimalapp", .{project});
    if (checkout != null) {
        const spec = try h.json(try h.run(&.{ binary, "akamata-openapi" }, project, h.env));
        const content = try s.field(try s.field(try s.field(try s.field(try s.field(try s.field(spec, "paths"), "/"), "get"), "responses"), "200"), "content");
        _ = try s.field(content, "text/plain");
        const declaration = try h.run(&.{ binary, "akamata-capabilities", "workers" }, project, h.env);
        const contract = try h.json(declaration);
        try s.eq((try s.field(contract, "target")).string, "workers");
        try s.check((try s.field(contract, "requirements")).array.items.len == 0, "no capability requirements");
        const manifest = try h.fmt("{s}/contract.json", .{project});
        try h.write(manifest, declaration);
        const inspected = try h.command(&.{ cli, "inspect", "capabilities", "--target=workers", try h.fmt("--manifest={s}", .{manifest}) }, project, h.env);
        try s.check(s.success(inspected.term), "inspect succeeds");
        try s.contains(inspected.stderr, "GET /");
    }
    const port = try wire.freePort();
    try h.env.put("PORT", try h.fmt("{d}", .{port}));
    var server = try wire.Server.start(h, &.{binary}, project, h.env, port);
    defer server.deinit();
    var client: ?*wire.Client = null;
    const deadline = h.now() + 10 * std.time.ns_per_s;
    while (h.now() < deadline) {
        client = server.connect() catch {
            h.sleep(50);
            continue;
        };
        break;
    }
    const c = client orelse return error.StartupTimeout;
    try c.send("GET / HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n");
    const response = try c.response();
    try s.check(response.status == 200, "minimal HTTP status");
    try s.eq(response.body, "Hello, minimalapp!");
    server.signal(.TERM);
    try server.wait(5000);
    std.debug.print("minimal scaffold: Native HTTP/shutdown and Workers ReleaseSafe passed\n", .{});
}
