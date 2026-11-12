const std = @import("std");
const s = @import("support.zig");
const wire = @import("wire.zig");
const uuid = "abcd1234-5678-9abc-def0-fedcba987654";
var watch_running: std.atomic.Value(bool) = .init(true);
fn stop(_: std.posix.SIG) callconv(.c) void {
    watch_running.store(false, .release);
}

/// Symlinks to this executable replace fake Python executables in the old test.
/// They can only record local commands; they never run wrangler/docker/builds.
pub fn mock(h: s.H, args: []const [:0]const u8) !bool {
    const name = std.fs.path.basename(args[0]);
    if (std.mem.eql(u8, name, "zig")) {
        if (h.env.get("AKAMATA_TEST_CHECKOUT")) |checkout| {
            const zig = h.env.get("AKAMATA_TEST_ZIG") orelse return error.MissingRealCompiler;
            var argv: std.ArrayList([]const u8) = .empty;
            try argv.append(h.a, zig);
            if (args.len > 1 and std.mem.eql(u8, args[1], "build")) {
                try argv.appendSlice(h.a, &.{ "build", try h.fmt("--fork={s}", .{checkout}) });
                for (args[2..]) |arg| try argv.append(h.a, arg);
            } else for (args[1..]) |arg| try argv.append(h.a, arg);
            const result = try h.command(argv.items, null, h.env);
            try std.Io.File.stdout().writeStreamingAll(h.io, result.stdout);
            try std.Io.File.stderr().writeStreamingAll(h.io, result.stderr);
            std.process.exit(if (result.term == .exited) result.term.exited else 1);
        }
    }
    if (!std.mem.eql(u8, name, "zig") and !std.mem.eql(u8, name, "npx") and !std.mem.eql(u8, name, "docker") and !std.mem.eql(u8, name, "watch_app")) return false;
    const log_path = h.env.get("MOCK_LOG") orelse return error.MockLogMissing;
    const log = try std.Io.Dir.cwd().openFile(h.io, log_path, .{ .mode = .write_only });
    defer log.close(h.io);
    const flags = std.c.fcntl(log.handle, std.c.F.GETFL);
    const append: c_int = @bitCast(std.c.O{ .APPEND = true });
    if (std.c.fcntl(log.handle, std.c.F.SETFL, flags | append) != 0) return error.Append;
    if (std.mem.eql(u8, name, "watch_app")) {
        try log.writeStreamingAll(h.io, try h.fmt("[\"watch_app\",{d}]\n", .{std.c.getpid()}));
        const action: std.posix.Sigaction = .{ .handler = .{ .handler = stop }, .mask = std.posix.sigemptyset(), .flags = 0 };
        std.posix.sigaction(.TERM, &action, null);
        while (watch_running.load(.acquire)) h.sleep(100);
        return true;
    }
    const call = try h.a.alloc([]const u8, args.len);
    call[0] = name;
    for (args[1..], 1..) |arg, i| call[i] = arg;
    try log.writeStreamingAll(h.io, try h.fmt("{s}\n", .{try h.encode(call)}));
    const mode = h.env.get("MOCK_MODE") orelse "create";
    if (std.mem.eql(u8, name, "npx") and args.len >= 4 and std.mem.eql(u8, args[1], "wrangler") and std.mem.eql(u8, args[2], "d1")) {
        if (std.mem.eql(u8, args[3], "create")) {
            if (std.mem.eql(u8, mode, "exists") or std.mem.eql(u8, mode, "fail")) {
                try std.Io.File.stdout().writeStreamingAll(h.io, if (std.mem.eql(u8, mode, "exists")) "already exists\n" else "permission denied\n");
                std.process.exit(1);
            }
            try std.Io.File.stdout().writeStreamingAll(h.io, "database_id = \"" ++ uuid ++ "\"\n");
        } else if (std.mem.eql(u8, args[3], "list")) try std.Io.File.stdout().writeStreamingAll(h.io, "[banner]\n[{\"name\":\"test-db\",\"uuid\":\"" ++ uuid ++ "\"}]\n");
    } else if (std.mem.eql(u8, mode, "fail-build") and std.mem.eql(u8, name, "zig")) std.process.exit(1);
    return true;
}
const Fixture = struct {
    h: s.H,
    cli: []const u8,
    temp: s.Temp,
    log: []const u8,
    env: *std.process.Environ.Map,
    fn run(f: Fixture, args: []const []const u8, mode: []const u8, expected: u8, calls: []const u8) !void {
        try f.h.write(f.log, "");
        try f.env.put("MOCK_MODE", mode);
        const command = try f.h.a.alloc([]const u8, args.len + 1);
        command[0] = f.cli;
        @memcpy(command[1..], args);
        const result = try f.h.command(command, f.temp.path, f.env);
        try s.check(result.term == .exited and result.term.exited == expected, result.stderr);
        var actual: std.json.Array = .init(f.h.a);
        var lines = std.mem.tokenizeScalar(u8, try f.h.read(f.log), '\n');
        while (lines.next()) |line| try actual.append(try f.h.json(line));
        try s.eq(try f.h.encode(std.json.Value{ .array = actual }), try f.h.encode(try f.h.json(calls)));
    }
};
pub fn run(h: s.H, cli_path: []const u8) !void {
    const cli = try h.absolute(cli_path);
    const temp = try h.temp();
    defer temp.deinit();
    const bin = try temp.file("bin");
    try std.Io.Dir.cwd().createDirPath(h.io, bin);
    for ([_][]const u8{ "zig", "npx", "docker" }) |name| try std.Io.Dir.cwd().symLink(h.io, h.self, try h.fmt("{s}/{s}", .{ bin, name }), .{});
    var env = try h.env.clone(h.a);
    try env.put("PATH", try h.fmt("{s}:{s}", .{ bin, h.env.get("PATH") orelse "" }));
    const log = try temp.file("commands.jsonl");
    try env.put("MOCK_LOG", log);
    const f: Fixture = .{ .h = h, .cli = cli, .temp = temp, .log = log, .env = &env };
    const config = try temp.file("custom.toml");
    const initial = "name = \"test\"\n# retain this comment\n[[d1_databases]]\nbinding = \"DB\"\ndatabase_name = \"test-db\"\ndatabase_id = \"00000000-0000-0000-0000-000000000000\"\n";
    const valid = try s.replace(h, initial, "00000000-0000-0000-0000-000000000000", uuid);
    try h.write(config, initial);
    try f.run(&.{ "deploy", "--workers", "--config=custom.toml", "--migrate=schema.sql" }, "create", 1, "[]");
    try s.eq(try h.read(config), initial);
    try h.write(config, valid);
    for ([_][]const u8{ "--dry-run", "--unknown-option" }) |option|
        try f.run(&.{ "deploy", "--workers", "--config=custom.toml", "--migrate=schema.sql", option }, "create", 1, "[]");
    try f.run(&.{ "deploy", "--workers", "--config=custom.toml", "--migrate=schema.sql" }, "create", 0,
        \\[["npx","wrangler","d1","execute","test-db","--remote","--config","custom.toml","--file","schema.sql","--yes"],["zig","build","-Dbackend=workers","-Doptimize=ReleaseFast"],["npx","wrangler","deploy","--config","custom.toml"]]
    );
    try f.run(&.{ "deploy", "--workers", "--config=custom.toml", "--optimize=ReleaseSafe" }, "create", 0,
        \\[["zig","build","-Dbackend=workers","-Doptimize=ReleaseSafe"],["npx","wrangler","deploy","--config","custom.toml"]]
    );
    try f.run(&.{ "deploy", "--workers", "--config=custom.toml" }, "fail-build", 1, "[[\"zig\",\"build\",\"-Dbackend=workers\",\"-Doptimize=ReleaseFast\"]]");
    try f.run(&.{ "db", "schema.sql", "--remote", "--config=custom.toml" }, "create", 0,
        \\[["npx","wrangler","d1","execute","test-db","--remote","--config","custom.toml","--file","schema.sql","--yes"]]
    );
    try f.run(&.{ "db", "schema.sql" }, "create", 0, "[[\"npx\",\"wrangler\",\"d1\",\"execute\",\"DB\",\"--local\",\"--file\",\"schema.sql\",\"--yes\"]]");
    try std.Io.Dir.cwd().rename(config, std.Io.Dir.cwd(), try temp.file("wrangler.toml"), h.io);
    try f.run(&.{ "db", "schema.sql" }, "create", 0, "[[\"npx\",\"wrangler\",\"d1\",\"execute\",\"test-db\",\"--local\",\"--file\",\"schema.sql\",\"--yes\"]]");
    try f.run(&.{ "deploy", "--containers" }, "create", 0, "[[\"zig\",\"build\",\"-Dtarget=x86_64-linux-musl\",\"-Doptimize=ReleaseFast\"],[\"docker\",\"build\",\"-f\",\"deploy/Dockerfile\",\"-t\",\"akamata-app\",\".\"]]");
    try f.run(&.{ "build", "--workers", "--optimize=ReleaseSmall" }, "create", 0, "[[\"zig\",\"build\",\"-Dbackend=workers\",\"-Doptimize=ReleaseSmall\"]]");
    try f.run(&.{ "dev", "--no-watch" }, "create", 0, "[[\"zig\",\"build\",\"run\"]]");
    try h.write(try temp.file("build.zig.zon"), ".{ .name = .watch_app }");
    const source = try temp.file("src/main.zig");
    try h.write(source, "first");
    const watched = try temp.file("zig-out/bin/watch_app");
    try std.Io.Dir.cwd().createDirPath(h.io, std.fs.path.dirname(watched).?);
    try std.Io.Dir.cwd().symLink(h.io, h.self, watched, .{});
    try h.write(log, "");
    try env.put("MOCK_MODE", "create");
    var process = try wire.Server.start(h, &.{ cli, "dev" }, temp.path, &env, 0);
    defer process.deinit();
    _ = try waitChildren(h, &process, log, 1);
    try h.write(source, "second version");
    const children = try waitChildren(h, &process, log, 2);
    process.signal(.INT);
    try process.wait(8000);
    for (children) |pid| try s.check(std.c.kill(pid, .CONT) != 0 and std.posix.errno(-1) == .SRCH, "dev must reap every child");
    try process.finish();
    std.debug.print("CLI operations: dispatch, side-effect safety, watcher restart and cleanup passed\n", .{});
}
fn waitChildren(h: s.H, process: *wire.Server, log: []const u8, count: usize) ![]std.c.pid_t {
    const deadline = h.now() + 8 * std.time.ns_per_s;
    while (h.now() < deadline) {
        var children: std.ArrayList(std.c.pid_t) = .empty;
        var lines = std.mem.tokenizeScalar(u8, try h.read(log), '\n');
        while (lines.next()) |line| {
            const row = try h.json(line);
            if (std.mem.eql(u8, row.array.items[0].string, "watch_app")) try children.append(h.a, @intCast(row.array.items[1].integer));
        }
        if (children.items.len >= count) return children.items;
        try s.check(!try process.poll(), "dev exited before restart");
        h.sleep(50);
    }
    return error.WatcherDeadline;
}
