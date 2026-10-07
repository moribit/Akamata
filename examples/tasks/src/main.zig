//! Native owners outlive every facade and consumer. Join before deinit.
const std = @import("std");
const am = @import("akamata");
const setup = @import("setup.zig");
const contracts = @import("contract.zig");
const State = @import("app.zig").App;
const h = @import("handlers.zig");
pub fn main(init: std.process.Init) !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var arena: std.heap.ArenaAllocator = .init(alloc);
    defer arena.deinit();
    const args = try init.minimal.args.toSlice(arena.allocator());
    if (args.len > 1) {
        const command = std.mem.sliceTo(args[1], 0);
        var buffer: [4096]u8 = undefined;
        var stdout = std.Io.File.stdout().writer(init.io, &buffer);
        if (std.mem.eql(u8, command, "--print-schema")) {
            for (@import("models.zig").all_models) |td| {
                try stdout.interface.writeAll(try am.model.ddl.fullSchema(arena.allocator(), td, .{}));
                try stdout.interface.writeAll("\n");
            }
            try stdout.interface.writeAll("CREATE TABLE IF NOT EXISTS task_deliveries (event_id TEXT PRIMARY KEY, task_id INTEGER NOT NULL, attempt INTEGER NOT NULL);\n");
            return stdout.interface.flush();
        }
        if (std.mem.eql(u8, command, "akamata-openapi") or std.mem.eql(u8, command, "akamata-client")) {
            var metadata: setup.Application.Metadata = .{};
            const bytes = if (std.mem.eql(u8, command, "akamata-openapi"))
                try am.openapi.generate(@TypeOf(metadata), &metadata, arena.allocator(), .{ .title = "Tasks", .version = "1" })
            else
                try am.client_gen.generate(@TypeOf(metadata), &metadata, arena.allocator(), .{ .target = .typescript });
            try stdout.interface.writeAll(bytes);
            return stdout.interface.flush();
        }
        if (std.mem.eql(u8, command, "akamata-capabilities")) {
            const endpoints = comptime blk: {
                var result: [contracts.routes.len]type = undefined;
                for (contracts.routes, 0..) |R, i| result[i] = R.For(State);
                break :blk result;
            };
            const target = if (args.len == 3) std.mem.sliceTo(args[2], 0) else "native";
            if (std.mem.eql(u8, target, "workers")) try contracts.For(.workers).writeManifest(.workers, &stdout.interface, endpoints) else if (std.mem.eql(u8, target, "native")) try contracts.For(.native).writeManifest(.native, &stdout.interface, endpoints) else return error.InvalidTarget;
            return stdout.interface.flush();
        }
        return error.UnknownCommand;
    }
    try am.env.loadDotEnv(alloc, ".env");
    const url = am.env.get(alloc, "DATABASE_URL") orelse try alloc.dupe(u8, "file:tasks.db");
    defer alloc.free(url);
    const db = try am.db.openForContract(alloc, State.application_contract, url);
    defer db.close();
    try setup.migrateDevelopment(alloc, db); // Tutorial convenience; no request-time DDL.
    const events = try alloc.create(@import("app.zig").EventChannel);
    defer alloc.destroy(events);
    events.* = .init(alloc);
    defer events.deinit();
    var effects: h.Effects = .{ .db = db, .events = events };
    const queue = try am.jobs.Provider(contracts.TaskCreatedDescriptor).createForContract(alloc, State.application_contract, db, .{ .context = &effects, .handler_with_context = h.consumeCreated }, .{ .poll_interval_ms = 100 });
    defer queue.deinit();
    var app = try setup.Application.initWithState(alloc, .{ .db = db, .queue = queue.producer(), .events = events });
    defer app.deinit();
    var worker = queue.worker();
    const thread = try std.Thread.spawn(.{}, runWorker, .{&worker});
    defer {
        worker.stop();
        thread.join();
    }
    const port_str = am.env.get(alloc, "PORT");
    defer if (port_str) |s| alloc.free(s);
    const port: u16 = if (port_str) |s| try std.fmt.parseInt(u16, s, 10) else 8080;
    std.log.info("Tasks: http://localhost:{d}; /openapi.json; /events", .{port});
    try app.serve(.{ .port = port });
}
fn runWorker(worker: *am.jobs.Worker) void {
    worker.run() catch |err| {
        std.log.err("queue worker stopped: {t}", .{err});
        worker.stop();
    };
}
