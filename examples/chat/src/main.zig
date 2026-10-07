const std = @import("std");
const am = @import("akamata");
const setup = @import("setup.zig");
const C = @import("app.zig").App.application_contract;
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
            try stdout.interface.writeAll(@embedFile("schema.sql"));
            return stdout.interface.flush();
        }
        if (std.mem.eql(u8, command, "akamata-openapi") or std.mem.eql(u8, command, "akamata-client")) {
            var metadata: setup.Application.Metadata = .{};
            const bytes = if (std.mem.eql(u8, command, "akamata-openapi"))
                try am.openapi.generate(@TypeOf(metadata), &metadata, arena.allocator(), .{ .title = "Chat", .version = "1" })
            else
                try am.client_gen.generate(@TypeOf(metadata), &metadata, arena.allocator(), .{ .target = .typescript });
            try stdout.interface.writeAll(bytes);
            return stdout.interface.flush();
        }
        if (std.mem.eql(u8, command, "akamata-capabilities")) {
            const contracts = @import("contract.zig");
            const endpoints = comptime blk: {
                var result: [contracts.routes.len]type = undefined;
                for (contracts.routes, 0..) |R, i| result[i] = R.For(@import("app.zig").App);
                break :blk result;
            };
            const target = if (args.len == 3) std.mem.sliceTo(args[2], 0) else "native";
            if (std.mem.eql(u8, target, "workers")) try contracts.For(.workers).writeManifest(.workers, &stdout.interface, endpoints) else if (std.mem.eql(u8, target, "native")) try C.writeManifest(.native, &stdout.interface, endpoints) else return error.InvalidTarget;
            return stdout.interface.flush();
        }
        return error.UnknownCommand;
    }
    try am.env.loadDotEnv(alloc, ".env");
    const url = am.env.get(alloc, "DATABASE_URL") orelse try alloc.dupe(u8, "file:chat.db");
    defer alloc.free(url);
    const db = try am.db.openForContract(alloc, C, url);
    defer db.close();
    try setup.migrateDevelopment(db); // Tutorial convenience, never request-time DDL.
    var realtime = am.realtime.Native.initForContract(alloc, C);
    defer realtime.deinit();
    var gate = am.sync.Mutex.init();
    defer gate.deinit();
    var app = try setup.Application.initWithState(alloc, .{ .db = db, .realtime = realtime.service(), .native_transport_gate = &gate });
    defer app.deinit();
    const port_str = am.env.get(alloc, "PORT");
    defer if (port_str) |value| alloc.free(value);
    const port: u16 = if (port_str) |value| try std.fmt.parseInt(u16, value, 10) else 8080;
    std.log.info("Chat: http://localhost:{d}; create a room before joining", .{port});
    try app.serve(.{ .port = port });
}
