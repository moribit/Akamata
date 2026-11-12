const std = @import("std");
const s = @import("support.zig");
const Case = struct { name: []const u8, flags: []const []const u8 };
pub fn run(h: s.H, cli_path: []const u8) !void {
    const cli = try h.absolute(cli_path);
    const checkout = try h.absolute(".");
    const temp = try h.temp();
    defer temp.deinit();
    for ([_]Case{ .{ .name = "d1_only", .flags = &.{"--d1"} }, .{ .name = "d1_r2", .flags = &.{ "--d1", "--r2" } }, .{ .name = "queue_only", .flags = &.{"--queue"} }, .{ .name = "realtime_only", .flags = &.{"--realtime"} }, .{ .name = "combined", .flags = &.{ "--d1", "--r2", "--queue", "--realtime" } } }) |case| {
        var argv: std.ArrayList([]const u8) = .empty;
        try argv.appendSlice(h.a, &.{ cli, "init", case.name, "--target=workers" });
        try argv.appendSlice(h.a, case.flags);
        _ = try h.run(argv.items, temp.path, h.env);
        const project = try temp.file(case.name);
        const glue = try h.fmt("{s}/deploy/worker/index.mjs", .{project});
        const manifest = try h.fmt("{s}/.akamata/managed-files.json", .{project});
        try h.write(glue, try s.replace(h, try h.read("tests/fixtures/v0.1.0_worker_index.mjs.tpl"), "{{NAME}}", case.name));
        for ([_][]const u8{ "deploy/worker/wasm_dispatch.mjs", "deploy/worker/internal_routes.mjs", "deploy/worker/realtime_object.mjs", ".akamata/managed-files.json" }) |file|
            std.Io.Dir.cwd().deleteFile(h.io, try h.fmt("{s}/{s}", .{ project, file })) catch |err| {
                if (err != error.FileNotFound) return err;
            };
        const dry = try h.command(&.{ cli, "sync", "--dry-run" }, project, h.env);
        try s.check(s.success(dry.term), "capability sync dry-run");
        const output = try h.fmt("{s}{s}", .{ dry.stdout, dry.stderr });
        try s.contains(output, "capabilities:");
        try s.contains(output, "would update deploy/worker/index.mjs");
        try s.check(!h.exists(manifest), "dry run does not create manifest");
        _ = try h.run(&.{ cli, "sync" }, project, h.env);
        try s.contains(try h.read(glue), "if (lower === \"host\" || lower === \"content-length\") continue");
        try s.contains(try h.read(glue), "dispatchWasmUnlocked(request)");
        try build(h, project, checkout);
        const realtime = try h.fmt("{s}/deploy/worker/realtime_object.mjs", .{project});
        const internal = try h.fmt("{s}/deploy/worker/internal_routes.mjs", .{project});
        const config = try h.fmt("{s}/deploy/wrangler.toml", .{project});
        if (std.mem.eql(u8, case.name, "d1_only")) {
            const second = try h.command(&.{ cli, "sync", "--dry-run" }, project, h.env);
            try s.check(s.success(second.term), "D1-only repeat sync");
            try s.contains(try h.fmt("{s}{s}", .{ second.stdout, second.stderr }), "D1=keep, R2=disabled, Queue=disabled, Realtime=disabled");
            try s.check(!h.exists(realtime), "D1 has no realtime glue");
        } else if (std.mem.eql(u8, case.name, "d1_r2")) {
            for ([_][]const u8{ "akamata_r2_put_begin", "akamata_r2_get_begin" }) |symbol| try s.contains(try h.read(glue), symbol);
            try s.contains(try h.read(config), "binding = \"FILES\"");
            try h.append(try h.fmt("{s}/src/worker.zig", .{project}), "\ncomptime { _ = am.platform.workers.R2Store; _ = am.storage.Store; }\n");
            try build(h, project, checkout);
        } else if (std.mem.eql(u8, case.name, "queue_only")) {
            try s.contains(try h.read(glue), "async queue(batch, env)");
            try s.contains(try h.read(glue), "akamata_queue_send");
        } else if (std.mem.eql(u8, case.name, "realtime_only")) {
            try s.contains(try h.read(glue), "AkamataRealtimeApplication");
            try s.check(h.exists(internal) and h.exists(realtime), "realtime sidecar files");
            try s.contains(try h.read(manifest), "deploy/worker/realtime_object.mjs");
            const original = try h.read(config);
            const at = std.mem.indexOf(u8, original, "[[services]]") orelse return error.MissingRealtimeService;
            try h.write(config, original[0..at]);
            const removal = try h.command(&.{ cli, "sync", "--dry-run" }, project, h.env);
            try s.check(s.success(removal.term), "realtime removal dry run");
            try s.contains(try h.fmt("{s}{s}", .{ removal.stdout, removal.stderr }), "would delete deploy/worker/realtime_object.mjs");
            try s.check(h.exists(realtime), "dry run retains removed sidecar");
            _ = try h.run(&.{ cli, "sync" }, project, h.env);
            try s.check(!h.exists(internal) and !h.exists(realtime), "disabled realtime sidecars removed");
            try s.check(std.mem.indexOf(u8, try h.read(glue), "./internal_routes.mjs") == null and std.mem.indexOf(u8, try h.read(manifest), "realtime_object.mjs") == null, "disabled realtime has no dangling module or manifest entry");
        } else for ([_][]const u8{ "akamata_r2_put_begin", "akamata_queue_send", "AkamataRealtimeRoom" }) |symbol| try s.contains(try h.read(glue), symbol);
    }
    std.debug.print("Workers capability sync regression test: OK\n", .{});
}
fn build(h: s.H, project: []const u8, checkout: []const u8) !void {
    _ = try h.run(&.{ h.env.get("ZIG") orelse "zig", "build", try h.fmt("--fork={s}", .{checkout}), "-Dbackend=workers", "-Doptimize=ReleaseSmall" }, project, h.env);
}
