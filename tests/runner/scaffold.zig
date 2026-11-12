//! Notes scaffold, managed glue and migration/provider metadata contracts.
const std = @import("std");
const s = @import("support.zig");
const Build = struct {
    h: s.H,
    project: []const u8,
    checkout: ?[]const u8,
    fn run(b: Build, options: []const []const u8) ![]const u8 {
        var argv: std.ArrayList([]const u8) = .empty;
        try argv.appendSlice(b.h.a, &.{ b.h.env.get("ZIG") orelse "zig", "build" });
        if (b.checkout) |path| try argv.append(b.h.a, try b.h.fmt("--fork={s}", .{path}));
        try argv.appendSlice(b.h.a, options);
        return b.h.run(argv.items, b.project, b.h.env);
    }
    fn migrate(b: Build, cli: []const u8) !void {
        if (b.checkout != null) {
            _ = try b.run(&.{ "run", "--", "migrate-up" });
        } else _ = try b.h.run(&.{ cli, "migrate", "up" }, b.project, b.h.env);
    }
};
pub fn run(h: s.H, args: []const []const u8) !void {
    if (args.len < 1 or args.len > 2) return error.InvalidArguments;
    const cli = try h.absolute(args[0]);
    const checkout = if (args.len == 2) try h.absolute(args[1]) else null;
    const temp = try h.temp();
    defer temp.deinit();
    _ = try h.run(&.{ cli, "init", "smokeapp", "--target=both", "--template=notes" }, temp.path, h.env);
    const project = try temp.file("smokeapp");
    const b: Build = .{ .h = h, .project = project, .checkout = checkout };
    const zon = try h.read(try h.fmt("{s}/build.zig.zon", .{project}));
    try s.check(!h.exists(try temp.file("Akamata")) and std.mem.indexOf(u8, zon, "../Akamata") == null, "scaffold is independent of checkout");
    try s.contains(zon, ".url = \"https://github.com/moribit/Akamata/archive/");
    try s.contains(zon, ".hash = \"akamata-");
    const glue = try h.read(try h.fmt("{s}/deploy/worker/index.mjs", .{project}));
    for ([_][]const u8{ "len === 0 ? new Uint8Array(0)", "if (bytes.length > 0) new Uint8Array(memory.buffer", "wasmDispatchQueue.run(() => dispatchWasmUnlocked(request))", "if (lower === \"host\" || lower === \"content-length\") continue" }) |fragment| try s.contains(glue, fragment);
    try s.contains(try h.read(try h.fmt("{s}/deploy/worker/wasm_dispatch.mjs", .{project})), "await previous");
    const managed = try h.read(try h.fmt("{s}/.akamata/managed-files.json", .{project}));
    try s.contains(managed, "deploy/worker/index.mjs");
    try s.check(std.mem.indexOf(u8, managed, "deploy/worker/realtime_object.mjs") == null and !h.exists(try h.fmt("{s}/deploy/worker/realtime_object.mjs", .{project})), "no default realtime glue");
    for ([_][]const []const u8{ &.{}, &.{ "-Dbackend=workers", "-Doptimize=ReleaseSmall" }, &.{"-Doptimize=ReleaseSafe"}, &.{ "-Dbackend=workers", "-Doptimize=ReleaseSafe" } }) |options| _ = try b.run(options);
    try b.migrate(cli);
    _ = try h.run(&.{ cli, "migrate", "generate", "create_smoke" }, project, h.env);
    const migrations = try h.fmt("{s}/migrations", .{project});
    var dir = try std.Io.Dir.cwd().openDir(h.io, migrations, .{ .iterate = true });
    defer dir.close(h.io);
    var it = dir.iterate();
    var found = false;
    while (try it.next(h.io)) |entry| {
        if (!std.mem.endsWith(u8, entry.name, "_create_smoke.sql")) continue;
        try s.check(!found, "single generated migration");
        found = true;
        try h.append(try h.fmt("{s}/{s}", .{ migrations, entry.name }), "\nCREATE TABLE IF NOT EXISTS smoke_items (id INTEGER PRIMARY KEY);\n");
    }
    try s.check(found, "migration generated");
    try b.migrate(cli);
    try b.migrate(cli);
    if (checkout) |path| {
        const build_file = try h.fmt("{s}/build.zig", .{project});
        const generated = try h.read(build_file);
        try h.write(try h.fmt("{s}/build_helper.zig", .{project}), try h.read(try h.fmt("{s}/src/build_helpers/akamata_build.zig", .{path})));
        try h.write(build_file,
            \\const std = @import("std");
            \\const helper = @import("build_helper.zig");
            \\pub fn build(b: *std.Build) void {
            \\    helper.app(b, .{ .name = "smokeapp", .root_source_file = "src/main.zig" });
            \\}
        );
        _ = try b.run(&.{ "run", "--", "migrate-up" });
        try h.write(build_file, generated);
        const main = try h.fmt("{s}/src/main.zig", .{project});
        const named = try s.replace(h, try h.read(main), "const DatabaseBinding = am.binding.D1(\"DB\")", "const DatabaseBinding = am.binding.D1(\"REPORTS\")");
        try h.write(main, named);
        const declaration = try b.run(&.{ "run", "--", "akamata-capabilities", "workers" });
        try h.write(try h.fmt("{s}/named-contract.json", .{project}), declaration);
        const provider = (try s.field(try h.json(declaration), "providers")).array.items[0];
        try s.eq((try s.field(provider, "binding")).string, "REPORTS");
        _ = try b.run(&.{ "-Dbackend=workers", "-Doptimize=ReleaseSafe" });
        const turso = try s.replace(h, try s.replace(h, named, ".provider = am.capability.defaultProvider(.database, target)", ".provider = .turso"), ".binding = if (target == .workers) DatabaseBinding.binding_name else null", ".binding = null");
        try h.write(main, turso);
        const turso_declaration = try b.run(&.{ "run", "--", "akamata-capabilities", "workers" });
        try h.write(try h.fmt("{s}/turso-contract.json", .{project}), turso_declaration);
        const p = (try s.field(try h.json(turso_declaration), "providers")).array.items[0];
        try s.eq((try s.field(p, "provider")).string, "turso");
        try s.check((try s.field(p, "binding")) == .null, "Turso has no D1 binding");
        _ = try b.run(&.{ "-Dbackend=workers", "-Doptimize=ReleaseSafe" });
    }
    std.debug.print("scaffold smoke test: OK\n", .{});
}
