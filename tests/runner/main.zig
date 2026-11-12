const std = @import("std");
const s = @import("support.zig");
pub fn main(init: std.process.Init) !void {
    const a = init.arena.allocator();
    const raw_args = try init.minimal.args.toSlice(a);
    var args = raw_args;
    if (args.len >= 4 and std.mem.eql(u8, args[1], "--zig")) {
        try init.environ_map.put("ZIG", args[2]);
        const filtered = try a.alloc([:0]const u8, args.len - 2);
        filtered[0] = args[0];
        @memcpy(filtered[1..], args[3..]);
        args = filtered;
    }
    if (init.environ_map.get("ZIG")) |zig| {
        if (std.fs.path.dirname(zig)) |directory| try init.environ_map.put("PATH", try std.fmt.allocPrint(a, "{s}:{s}", .{ directory, init.environ_map.get("PATH") orelse "" }));
    }
    if (args.len == 0) return error.MissingTestSuite;
    const mock_h: s.H = .{ .a = a, .io = init.io, .env = init.environ_map, .self = args[0] };
    if (try @import("operations.zig").mock(mock_h, args)) return;
    if (args.len < 2) return error.MissingTestSuite;
    try init.environ_map.put("AKAMATA_TEST_SUITE", args[1]);
    const h: s.H = .{ .a = a, .io = init.io, .env = init.environ_map, .self = try std.Io.Dir.cwd().realPathFileAlloc(init.io, args[0], a) };
    if (std.mem.eql(u8, args[1], "docs")) return @import("documents.zig").links(h);
    if (std.mem.eql(u8, args[1], "slides")) return @import("documents.zig").slides(h);
    if (std.mem.eql(u8, args[1], "support")) {
        const temp = try h.temp();
        defer temp.deinit();
        const file = try temp.file("sample");
        try h.write(file, "sample");
        try s.eq(try h.read(file), "sample");
        try s.eq(&try h.sha256(file), "af2bdbe1aa9b6ec1e2ade1d694f41fc71a831d0268e9891562113d8a62add1bf");
        const large_path = try temp.file("large-artifact");
        const large = try std.Io.Dir.cwd().createFile(h.io, large_path, .{});
        try large.setLength(h.io, 64 * 1024 * 1024 + 1);
        large.close(h.io);
        _ = try h.sha256(large_path); // ELF Debug artifacts can exceed the text-read limit.
        const failure = try h.command(&.{ "sh", "-c", "printf diagnostic; exit 7" }, temp.path, null);
        try s.check(!s.success(failure.term), "nonzero command rejected");
        try s.eq(failure.stdout, "diagnostic");
        try init.environ_map.put("AKAMATA_CI_TIMING_DIR", temp.path);
        const recorded = try h.command(&.{ "sh", "-c", "printf context; exit 9" }, temp.path, h.env);
        try s.check(recorded.term == .exited and recorded.term.exited == 9, "timing preserves exit status");
        try s.eq(recorded.stdout, "context");
        const row = try h.json(std.mem.trim(u8, try h.read(try temp.file("support.jsonl")), "\r\n"));
        try s.check((try s.field(row, "returncode")).integer == 9, "failure evidence records status");
        try s.check((try s.field(row, "seconds")).float > 0, "monotonic duration recorded");
        const checked = h.run(&.{ "sh", "-c", "exit 5" }, temp.path, h.env);
        try s.check(checked == error.CommandFailed, "checked failure propagates");
        var rows = std.mem.tokenizeScalar(u8, try h.read(try temp.file("support.jsonl")), '\n');
        _ = rows.next() orelse return error.MissingEvidence;
        const last = try h.json(rows.next() orelse return error.MissingEvidence);
        try s.check((try s.field(last, "returncode")).integer == 5, "checked failure saves partial evidence");
        try @import("living.zig").failureContract(h);
        const wire = @import("wire.zig");
        const port = try wire.freePort();
        var server = try wire.Server.start(h, &.{ "sh", "-c", "exit 0" }, temp.path, null, port);
        defer server.deinit();
        try server.wait(1000);
        try s.check(server.exitCode() == 0, "normal exit code preserved");
        var failed_child = try wire.Server.start(h, &.{ "sh", "-c", "exit 7" }, temp.path, null, port);
        defer failed_child.deinit();
        const failed_wait = failed_child.wait(1000);
        try s.check(failed_wait == error.FixtureExit and failed_child.exitCode() == 7, "wait status is decoded to the actual exit code");
        _ = wire.Client.connect(h, port) catch |err| {
            try s.check(err == error.ConnectionRefused, "bounded failed connect");
            return;
        };
        return error.UnexpectedListener;
    }
    if (std.mem.eql(u8, args[1], "capabilities")) return @import("capabilities.zig").run(h, args[2]);
    if (std.mem.eql(u8, args[1], "operations")) return @import("operations.zig").run(h, args[2]);
    if (std.mem.eql(u8, args[1], "transport")) return @import("transport.zig").run(h, args[2..]);
    if (std.mem.eql(u8, args[1], "minimal")) return @import("minimal.zig").run(h, args[2..]);
    if (std.mem.eql(u8, args[1], "journey")) return @import("journey.zig").run(h, args[2..]);
    if (std.mem.eql(u8, args[1], "repeat")) return @import("repeat.zig").run(h, args[2..]);
    if (std.mem.eql(u8, args[1], "scaffold")) return @import("scaffold.zig").run(h, args[2..]);
    if (std.mem.eql(u8, args[1], "chat")) return @import("chat.zig").run(h, args[2..]);
    if (std.mem.eql(u8, args[1], "living")) return @import("living.zig").run(h);
    if (std.mem.eql(u8, args[1], "update")) return @import("update.zig").run(h, args[2]);
    if (std.mem.eql(u8, args[1], "isolation")) return @import("isolation.zig").run(h, args[2..]);
    if (std.mem.eql(u8, args[1], "limit-exec")) return @import("resources.zig").execLimited(h, args[2..]);
    if (std.mem.eql(u8, args[1], "stress")) return @import("stress.zig").run(h, args[2..]);
    if (std.mem.eql(u8, args[1], "sessions")) return @import("sessions.zig").run(h, args[2..]);
    if (std.mem.eql(u8, args[1], "db-smoke")) return @import("db_smoke.zig").run(h, args[2]);
    if (std.mem.eql(u8, args[1], "db-regression")) return @import("db_regression.zig").run(h, args[2..]);
    if (std.mem.eql(u8, args[1], "reporting")) return @import("reporting.zig").run(h);
    if (std.mem.eql(u8, args[1], "evidence")) return @import("benchmark_evidence.zig").cli(h, args[2..]);
    if (std.mem.eql(u8, args[1], "compile-fail")) return @import("compile_fail.zig").run(h);
    if (std.mem.eql(u8, args[1], "capability-sync")) return @import("capability_sync.zig").run(h, args[2]);
    if (std.mem.eql(u8, args[1], "adversarial")) return @import("adversarial.zig").run(h, args[2]);
    if (std.mem.eql(u8, args[1], "scaffold-files")) {
        const cli = try h.absolute(args[2]);
        const temp = try h.temp();
        defer temp.deinit();
        _ = try h.run(&.{ cli, "init", "testapp", "--target=both", "--template=notes" }, temp.path, h.env);
        for ([_][]const u8{ "src/main.zig", "deploy/wrangler.toml", "deploy/Dockerfile" }) |file| try s.check(h.exists(try temp.file(try h.fmt("testapp/{s}", .{file}))), "default notes scaffold file");
        return;
    }
    return error.UnknownTestSuite;
}
