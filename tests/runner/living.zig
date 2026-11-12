//! Full learning-path builds and real WASM/JSPI host checks, with checkpoints.
const std = @import("std");
const builtin = @import("builtin");
const s = @import("support.zig");
const examples = [_][]const u8{ "guestbook", "tasks", "chat", "device_messaging" };
const Row = struct { command: []const []const u8, seconds: f64, returncode: ?u8, test_summaries: []const []const u8 };
const Recorder = struct {
    h: s.H,
    path: []const u8,
    rows: std.ArrayList(Row) = .empty,
    evidence: std.json.ObjectMap = .empty,
    fn save(r: *Recorder) !void {
        try r.evidence.put(r.h.a, "commands", try r.h.json(try r.h.encode(r.rows.items)));
        try r.h.write(r.path, try r.h.encode(std.json.Value{ .object = r.evidence }));
    }
    fn put(r: *Recorder, name: []const u8, value: std.json.Value) !void {
        try r.evidence.put(r.h.a, name, value);
        try r.save();
    }
    fn run(r: *Recorder, argv: []const []const u8) ![]const u8 {
        const h = r.h;
        std.debug.print("+", .{});
        for (argv) |arg| std.debug.print(" {s}", .{arg});
        std.debug.print("\n", .{});
        const start = h.now();
        const result = h.command(argv, null, h.env) catch |err| {
            try r.rows.append(h.a, .{ .command = try h.a.dupe([]const u8, argv), .seconds = @as(f64, @floatFromInt(h.now() - start)) / std.time.ns_per_s, .returncode = null, .test_summaries = &.{} });
            try r.save();
            return err;
        };
        var summaries: std.ArrayList([]const u8) = .empty;
        var lines = std.mem.splitScalar(u8, result.stderr, '\n');
        while (lines.next()) |line| {
            if (std.mem.indexOf(u8, line, "Build Summary:") != null or std.mem.indexOf(u8, line, "run test") != null or std.mem.indexOf(u8, line, "compile ") != null) try summaries.append(h.a, line);
        }
        try r.rows.append(h.a, .{ .command = try h.a.dupe([]const u8, argv), .seconds = @as(f64, @floatFromInt(h.now() - start)) / std.time.ns_per_s, .returncode = if (result.term == .exited) result.term.exited else null, .test_summaries = summaries.items });
        try r.save();
        if (!s.success(result.term)) {
            std.debug.print("{s}\n{s}\n", .{ result.stdout, result.stderr });
            return error.LivingCommandFailed;
        }
        return result.stdout;
    }
};
pub fn failureContract(h: s.H) !void {
    const temp = try h.temp();
    defer temp.deinit();
    var r: Recorder = .{ .h = h, .path = try temp.file("partial.json") };
    const result = r.run(&.{ "sh", "-c", "printf 'failure context'; exit 9" });
    try s.check(result == error.LivingCommandFailed, "living failure propagates");
    const report = try h.json(try h.read(r.path));
    const rows = (try s.field(report, "commands")).array.items;
    try s.check(rows.len == 1 and (try s.field(rows[0], "returncode")).integer == 9, "living failure saves partial command evidence");
}
pub fn run(h: s.H) !void {
    if (h.env.get("GITHUB_ACTIONS") != null and h.env.get("AKAMATA_DX_TSC") == null) return error.CiTypeScriptCompilerMissing;
    var r: Recorder = .{ .h = h, .path = h.env.get("AKAMATA_LIVING_REPORT") orelse ".zig-cache/living-examples.json" };
    const zig = h.env.get("ZIG") orelse "zig";
    try r.put("typecheck_enabled", .{ .bool = h.env.get("AKAMATA_DX_TSC") != null });
    try r.put("os", .{ .string = @tagName(builtin.os.tag) });
    try r.put("zig", .{ .string = std.mem.trim(u8, try r.run(&.{ zig, "version" }), "\r\n") });
    try r.put("node", .{ .string = std.mem.trim(u8, try r.run(&.{ "node", "--version" }), "\r\n") });
    try r.put("commit", .{ .string = std.mem.trim(u8, try r.run(&.{ "git", "rev-parse", "HEAD" }), "\r\n") });
    try r.put("evidence", .{ .string = "Native application + actual WASM/managed JSPI/offline host; not live Cloudflare" });
    var artifacts: std.json.Array = .init(h.a);
    const temp = try h.temp();
    defer temp.deinit();
    for ([_][]const u8{ "Debug", "ReleaseSafe" }) |mode| {
        _ = try r.run(&.{ zig, "build", "living-native-check", try h.fmt("-Doptimize={s}", .{mode}), "--summary", "all" });
        for (examples) |example| {
            try artifacts.append(try h.json(try h.encode(.{ .example = example, .target = "native", .mode = mode, .sha256 = try sha(h, try h.fmt("zig-out/bin/{s}", .{example})) })));
            try r.put("artifacts", .{ .array = artifacts });
        }
    }
    _ = try r.run(&.{ zig, "build", "ci-sqlite-host", "--summary", "all" });
    const database = try temp.file("migration.sqlite");
    try h.env.put("DATABASE_URL", try h.fmt("file:{s}", .{database}));
    const device = try h.absolute("zig-out/bin/device_messaging");
    _ = try r.run(&.{ device, "migrate-up" });
    _ = try r.run(&.{ device, "migrate-up" });
    const input = try temp.file("query.json");
    try h.write(input, "{\"sql\":\"SELECT (SELECT count(*) FROM schema_migrations) AS history, (SELECT count(*) FROM portable_records) AS records\",\"args\":[]}");
    const host = try h.absolute("zig-out/bin/akamata-sqlite-host");
    const result = try h.json(try r.run(&.{ "sh", "-c", "exec \"$1\" \"$2\" < \"$3\"", "sqlite-host", host, database, input }));
    const row = (try s.field(result, "results")).array.items[0];
    try s.check((try s.field(row, "history")).integer == 1 and (try s.field(row, "records")).integer == 0, "idempotent versioned migration");
    try r.put("versioned_migration", .{ .string = "two invocations; one history entry" });
    for (examples) |example| {
        const readme = try h.read(try h.fmt("examples/{s}/README.md", .{example}));
        for ([_][]const u8{ "What you will learn", "Why this example exists", "Run Native", "Test", "Architecture", "Next" }) |section| try s.contains(readme, try h.fmt("## {s}", .{section}));
    }
    try r.put("native_wire", try h.json(try r.run(&.{ h.self, "chat", try h.absolute("zig-out/bin/chat") })));
    try h.env.put("AKAMATA_SQLITE_HOST", host);
    for (examples) |example| {
        const binary = try h.absolute(try h.fmt("zig-out/bin/{s}", .{example}));
        const schema = try temp.file(try h.fmt("{s}.sql", .{example}));
        try h.write(schema, try r.run(&.{ binary, "--print-schema" }));
        for ([_][]const u8{ "native", "workers" }) |target| {
            const manifest = try h.json(try r.run(&.{ binary, "akamata-capabilities", target }));
            try s.check(manifest == .object and manifest.object.count() > 0, "example capability metadata");
        }
        if (!std.mem.eql(u8, example, "device_messaging")) {
            const document = try h.json(try r.run(&.{ binary, "akamata-openapi" }));
            try s.check((try s.field(document, "paths")).object.count() > 0, "example OpenAPI paths");
            const client = try temp.file(try h.fmt("{s}.ts", .{example}));
            try h.write(client, try r.run(&.{ binary, "akamata-client" }));
            try typecheck(&r, client);
        }
        if (std.mem.eql(u8, example, "chat") or std.mem.eql(u8, example, "device_messaging")) {
            const protocol = try temp.file(try h.fmt("{s}-protocol.ts", .{example}));
            try h.write(protocol, try r.run(&.{ binary, "akamata-protocol-ts" }));
            try typecheck(&r, protocol);
            const header = try temp.file(try h.fmt("{s}-protocol.c", .{example}));
            try h.write(header, try r.run(&.{ binary, "akamata-protocol-c" }));
            _ = try r.run(&.{ zig, "cc", "-c", header, "-o", try temp.file(try h.fmt("{s}-protocol.o", .{example})) });
        }
        _ = try r.run(&.{ zig, "build", try h.fmt("-Dexample={s}", .{example}), "-Dbackend=workers", "-Doptimize=ReleaseSafe", "--summary", "all" });
        const artifact = try h.fmt("zig-out/bin/{s}_worker.wasm", .{example});
        const tested = try h.json(try r.run(&.{ "node", "--experimental-wasm-jspi", "tests/living_workers.mjs", example, artifact, schema }));
        try artifacts.append(try h.json(try h.encode(.{ .example = example, .target = "workers", .sha256 = try sha(h, artifact), .host = tested })));
        try r.put("artifacts", .{ .array = artifacts });
    }
    _ = try r.run(&.{ zig, "build", "documentation-test", "-Doptimize=ReleaseSafe", "--summary", "all" });
    _ = try r.run(&.{ "node", "--test", "tests/workers_wasm_dispatch_test.mjs" });
    _ = try r.run(&.{ h.self, "docs" });
    _ = try r.run(&.{ zig, "fmt", "--check", "examples", "tests/docs/minimal.zig" });
    try s.eq(try h.read("deploy/worker/index.mjs"), try h.read("tools/akamata/src/templates/worker_index.mjs.tpl"));
    try s.eq(try h.read("examples/chat/src/schema.sql"), try h.read("deploy/worker/d1_schema.sql"));
    try r.save();
    std.debug.print("Living reference passed: {d} commands; evidence: {s}\n", .{ r.rows.items.len, r.path });
}
fn typecheck(r: *Recorder, path: []const u8) !void {
    if (r.h.env.get("AKAMATA_DX_TSC")) |compiler| _ = try r.run(&.{ "node", compiler, "--strict", "--noEmit", "--target", "ES2022", "--lib", "ES2022,DOM", path });
}
fn sha(h: s.H, path: []const u8) ![]const u8 {
    return h.a.dupe(u8, &try h.sha256(path));
}
