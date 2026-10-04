//! CLI argument handling and command dispatch.
const std = @import("std");
const api_client = @import("api_client.zig");
const client_tui = @import("client_tui.zig");
const VERSION = @import("release.zig").VERSION;
const cmdApi = @import("command/api.zig").cmdApi;
const cmdBuild = @import("command/build.zig").cmdBuild;
const cmdCheck = @import("command/inspect.zig").cmdCheck;
const cmdConfig = @import("command/inspect.zig").cmdConfig;
const cmdDb = @import("command/db.zig").cmdDb;
const cmdDeploy = @import("command/deploy.zig").cmdDeploy;
const cmdDestroy = @import("command/generate.zig").cmdDestroy;
const cmdDev = @import("command/dev.zig").cmdDev;
const cmdDoctor = @import("command/inspect.zig").cmdDoctor;
const cmdGenerate = @import("command/generate.zig").cmdGenerate;
const cmdInit = @import("command/init.zig").cmdInit;
const cmdInspect = @import("command/inspect.zig").cmdInspect;
const cmdMigrate = @import("command/migrate.zig").cmdMigrate;
const cmdRoutes = @import("command/inspect.zig").cmdRoutes;
const cmdRunner = @import("command/inspect.zig").cmdRunner;
const cmdSync = @import("command/sync.zig").cmdSync;
const cmdSyncGlue = @import("command/sync.zig").cmdSyncGlue;
const cmdTest = @import("command/inspect.zig").cmdTest;
const cmdUpdate = @import("command/update.zig").cmdUpdate;
const commandUsage = @import("help.zig").commandUsage;
const isHelpArg = @import("help.zig").isHelpArg;
const suggestCommand = @import("help.zig").suggestCommand;
const usage = @import("help.zig").usage;

pub fn main(init: std.process.Init) !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var arena_state: std.heap.ArenaAllocator = .init(alloc);
    defer arena_state.deinit();
    const args = try init.minimal.args.toSlice(arena_state.allocator());

    if (args.len < 2) {
        try usage();
        return;
    }
    const cmd = args[1];
    if (std.mem.eql(u8, cmd, "help")) {
        if (args.len >= 3) try commandUsage(std.mem.sliceTo(args[2], 0)) else try usage();
        return;
    }
    if (args.len >= 3 and isHelpArg(std.mem.sliceTo(args[2], 0))) {
        try commandUsage(cmd);
        return;
    }
    if (std.mem.eql(u8, cmd, "init")) {
        try cmdInit(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "build")) {
        try cmdBuild(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "dev")) {
        try cmdDev(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "deploy")) {
        try cmdDeploy(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "sync-glue")) {
        try cmdSyncGlue(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "sync")) {
        try cmdSync(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "update")) {
        try cmdUpdate(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "db")) {
        try cmdDb(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "migrate")) {
        try cmdMigrate(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "check")) {
        try cmdCheck(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "inspect")) {
        try cmdInspect(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "routes")) {
        try cmdRoutes(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "doctor")) {
        try cmdDoctor(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "config")) {
        try cmdConfig(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "test")) {
        try cmdTest(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "runner")) {
        try cmdRunner(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "generate")) {
        try cmdGenerate(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "destroy")) {
        try cmdDestroy(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "api")) {
        try cmdApi(alloc, args[2..]);
    } else if (std.mem.eql(u8, cmd, "client")) {
        const client_args = args[2..];
        const use_tui = client_args.len == 0 or std.mem.eql(u8, std.mem.sliceTo(client_args[0], 0), "--tui");
        (if (use_tui) client_tui.run(alloc, client_args) else api_client.run(alloc, client_args)) catch |err| {
            std.debug.print("akamata client: {s}\n", .{@errorName(err)});
            std.process.exit(1);
        };
    } else if (std.mem.eql(u8, cmd, "--help") or std.mem.eql(u8, cmd, "-h")) {
        try usage();
    } else if (std.mem.eql(u8, cmd, "--version") or std.mem.eql(u8, cmd, "-v") or std.mem.eql(u8, cmd, "version")) {
        std.debug.print("akamata {s}\n", .{VERSION});
    } else {
        std.debug.print("akamata: unknown subcommand `{s}`\n", .{cmd});
        if (suggestCommand(cmd)) |s| {
            std.debug.print("\nDid you mean `akamata {s}`?\n\n", .{s});
        } else {
            std.debug.print("\nRun `akamata help` for the full list.\n\n", .{});
        }
        std.process.exit(2);
    }
}

test "CLI modules retain their unit tests" {
    _ = @import("cloudflare/config.zig");
    _ = @import("cloudflare/operations.zig");
    _ = @import("cloudflare/provision.zig");
    _ = @import("cloudflare/wrangler.zig");
    _ = @import("command/api.zig");
    _ = @import("command/build.zig");
    _ = @import("command/db.zig");
    _ = @import("command/deploy.zig");
    _ = @import("command/dev.zig");
    _ = @import("command/generate.zig");
    _ = @import("command/init.zig");
    _ = @import("command/inspect.zig");
    _ = @import("command/migrate.zig");
    _ = @import("command/sync.zig");
    _ = @import("command/update.zig");
    _ = @import("format.zig");
    _ = @import("help.zig");
    _ = @import("native.zig");
    _ = @import("process.zig");
    _ = @import("project/files.zig");
    _ = @import("project/managed_files.zig");
    _ = @import("project/manifest.zig");
    _ = @import("project/scaffold.zig");
    _ = @import("project/templates.zig");
    _ = @import("project/worker_glue.zig");
    _ = @import("release.zig");
    _ = @import("project/templates.zig");
}
