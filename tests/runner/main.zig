const std = @import("std");
const s = @import("support.zig");
pub fn main(init: std.process.Init) !void {
    const a = init.arena.allocator();
    const args = try init.minimal.args.toSlice(a);
    if (init.environ_map.get("ZIG")) |zig| {
        if (std.fs.path.dirname(zig)) |directory| try init.environ_map.put("PATH", try std.fmt.allocPrint(a, "{s}:{s}", .{ directory, init.environ_map.get("PATH") orelse "" }));
    }
    if (args.len == 0) return error.MissingTestSuite;
    const mock_h: s.H = .{ .a = a, .io = init.io, .env = init.environ_map, .self = args[0] };
    if (try @import("operations.zig").mock(mock_h, args)) return;
    if (args.len < 2) return error.MissingTestSuite;
    const h: s.H = .{ .a = a, .io = init.io, .env = init.environ_map, .self = try std.Io.Dir.cwd().realPathFileAlloc(init.io, args[0], a) };
    if (std.mem.eql(u8, args[1], "docs")) return @import("documents.zig").links(h);
    if (std.mem.eql(u8, args[1], "slides")) return @import("documents.zig").slides(h);
    if (std.mem.eql(u8, args[1], "support")) {
        const temp = try h.temp();
        defer temp.deinit();
        const file = try temp.file("sample");
        try h.write(file, "sample");
        try s.eq(try h.read(file), "sample");
        const failure = try h.command(&.{ "sh", "-c", "printf diagnostic; exit 7" }, temp.path, null);
        try s.check(!s.success(failure.term), "nonzero command rejected");
        try s.eq(failure.stdout, "diagnostic");
        const wire = @import("wire.zig");
        const port = try wire.freePort();
        var server = try wire.Server.start(h, &.{ "sh", "-c", "exit 0" }, temp.path, null, port);
        defer server.deinit();
        try server.wait(1000);
        _ = wire.Client.connect(h, port) catch |err| {
            try s.check(err == error.ConnectionRefused, "bounded failed connect");
            return;
        };
        return error.UnexpectedListener;
    }
    if (std.mem.eql(u8, args[1], "capabilities")) return @import("capabilities.zig").run(h, args[2]);
    if (std.mem.eql(u8, args[1], "operations")) return @import("operations.zig").run(h, args[2]);
    return error.UnknownTestSuite;
}
