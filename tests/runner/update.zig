//! Upgrade an old project while protecting application-owned and edited files.
const std = @import("std");
const s = @import("support.zig");
fn quoted(h: s.H, text: []const u8, marker: []const u8, replacement: []const u8) ![]const u8 {
    const begin = (std.mem.indexOf(u8, text, marker) orelse return error.MissingMarker) + marker.len;
    const end = std.mem.indexOfScalarPos(u8, text, begin, '"') orelse return error.MissingQuote;
    return h.fmt("{s}{s}{s}", .{ text[0..begin], replacement, text[end..] });
}
fn value(text: []const u8, marker: []const u8) ![]const u8 {
    const begin = (std.mem.indexOf(u8, text, marker) orelse return error.MissingMarker) + marker.len;
    const end = std.mem.indexOfScalarPos(u8, text, begin, '"') orelse return error.MissingQuote;
    return text[begin..end];
}
pub fn run(h: s.H, cli_path: []const u8) !void {
    const cli = try h.absolute(cli_path);
    const checkout = try h.absolute(".");
    const release = try h.read("tools/akamata/src/release.zig");
    const stable = try value(release, "pub const STABLE_VERSION = \"");
    const version = try value(release, "pub const VERSION = \"");
    for ([_][]const u8{ "wasm_dispatch", "internal_routes", "realtime_object" }) |name|
        try s.eq(try h.read(try h.fmt("deploy/worker/{s}.mjs", .{name})), try h.read(try h.fmt("tools/akamata/src/templates/{s}.mjs.tpl", .{name})));
    const temp = try h.temp();
    defer temp.deinit();
    const bin = try temp.file("bin");
    try std.Io.Dir.cwd().createDir(h.io, bin, .default_dir);
    try std.Io.Dir.cwd().symLink(h.io, h.self, try h.fmt("{s}/zig", .{bin}), .{});
    var env = try h.env.clone(h.a);
    try env.put("AKAMATA_TEST_ZIG", h.env.get("ZIG") orelse return error.MissingRealCompiler);
    try env.put("AKAMATA_TEST_CHECKOUT", checkout);
    try env.put("PATH", try h.fmt("{s}:{s}", .{ bin, h.env.get("PATH") orelse "" }));
    _ = try h.run(&.{ cli, "init", "legacyapp", "--target=both" }, temp.path, &env);
    const project = try temp.file("legacyapp");
    const main = try h.fmt("{s}/src/main.zig", .{project});
    const config = try h.fmt("{s}/deploy/wrangler.toml", .{project});
    const glue = try h.fmt("{s}/deploy/worker/index.mjs", .{project});
    const dispatch = try h.fmt("{s}/deploy/worker/wasm_dispatch.mjs", .{project});
    const zon = try h.fmt("{s}/build.zig.zon", .{project});
    try h.append(config, "\n# user-owned-wrangler-setting\n");
    try h.append(main, "\n// user-owned-source-marker\n");
    try h.write(glue, try s.replace(h, try h.read("tests/fixtures/v0.1.0_worker_index.mjs.tpl"), "{{NAME}}", "legacyapp"));
    for ([_][]const u8{ "deploy/worker/wasm_dispatch.mjs", "deploy/worker/internal_routes.mjs", "deploy/worker/realtime_object.mjs", ".akamata/managed-files.json" }) |file|
        std.Io.Dir.cwd().deleteFile(h.io, try h.fmt("{s}/{s}", .{ project, file })) catch |err| {
            if (err != error.FileNotFound) return err;
        };
    const old = try quoted(h, try quoted(h, try h.read(zon), ".url = \"", "https://github.com/appleuser634/Akamata/archive/refs/tags/v0.1.0.tar.gz"), ".hash = \"", "akamata-0.1.0-uJIoI4fvKwH--xMKwulRpDc6xEEUfaP0oilU6-dfUqbw");
    try h.write(zon, old);
    const old_glue = try h.read(glue);
    const dry = try h.command(&.{ cli, "update", try h.fmt("--to={s}", .{stable}), "--sync", "--dry-run" }, project, &env);
    try s.check(s.success(dry.term), "update dry run succeeds");
    const dry_output = try h.fmt("{s}{s}", .{ dry.stdout, dry.stderr });
    try s.contains(dry_output, "would update build.zig.zon");
    try s.contains(dry_output, "would update deploy/worker/index.mjs");
    try s.eq(try h.read(zon), old);
    try s.eq(try h.read(glue), old_glue);
    try s.check(!h.exists(dispatch), "dry run creates no glue");
    _ = try h.run(&.{ cli, "update", try h.fmt("--to={s}", .{stable}), "--sync" }, project, &env);
    try s.contains(try h.read(zon), try h.fmt("refs/tags/{s}.tar.gz", .{stable}));
    try s.contains(try h.read(glue), "wasmDispatchQueue.run(() => dispatchWasmUnlocked(request))");
    try s.contains(try h.read(dispatch), "await previous");
    for ([_][]const u8{ "internal_routes", "realtime_object" }) |name| try s.check(!h.exists(try h.fmt("{s}/deploy/worker/{s}.mjs", .{ project, name })), "no undeclared capability glue");
    try s.check(h.exists(try h.fmt("{s}/.akamata/managed-files.json", .{project})), "managed manifest created");
    try preserved(h, main, config);
    try h.append(glue, "\n// local glue customization\n");
    try std.Io.Dir.cwd().deleteFile(h.io, dispatch);
    const edited = try h.read(glue);
    const refused = try h.command(&.{ cli, "sync" }, project, &env);
    try s.check(!s.success(refused.term), "modified managed glue rejected");
    try s.contains(try h.fmt("{s}{s}", .{ refused.stdout, refused.stderr }), "REFUSED: local changes detected");
    try s.eq(try h.read(glue), edited);
    try s.check(!h.exists(dispatch), "refused sync creates no files");
    _ = try h.run(&.{ cli, "sync", "--force" }, project, &env);
    try s.contains(try h.read(try h.fmt("{s}.bak", .{glue})), "// local glue customization");
    try s.check(std.mem.indexOf(u8, try h.read(glue), "// local glue customization") == null and h.exists(dispatch), "force restores framework glue and saves backup");
    try preserved(h, main, config);
    const zig = try h.fmt("{s}/zig", .{bin});
    _ = try h.run(&.{ zig, "build" }, project, &env);
    _ = try h.run(&.{ zig, "build", "-Dbackend=workers", "-Doptimize=ReleaseSmall" }, project, &env);
    const original = try h.read(zon);
    for ([_][]const u8{ try h.fmt("v{s}", .{version}), "v99.0.0" }, 0..) |tag, index| {
        const current = try quoted(h, original, ".url = \"", try h.fmt("https://github.com/moribit/Akamata/archive/refs/tags/{s}.tar.gz", .{tag}));
        try h.write(zon, current);
        const result = try h.command(&.{ cli, "sync", "--dry-run" }, project, &env);
        try s.check(s.success(result.term) == (index == 0), "template version compatibility");
        if (index != 0) try s.contains(result.stderr, "TemplateVersionMismatch");
        try s.eq(try h.read(zon), current);
    }
    try h.write(zon, original);
    std.debug.print("project update/sync regression test: OK\n", .{});
}
fn preserved(h: s.H, main: []const u8, config: []const u8) !void {
    try s.contains(try h.read(config), "# user-owned-wrangler-setting");
    try s.contains(try h.read(main), "// user-owned-source-marker");
}
