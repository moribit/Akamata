const std = @import("std");
const am = @import("akamata");
const application = @import("application.zig");
const contracts = @import("contracts.zig");

pub fn main(init: std.process.Init) !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const args = try init.minimal.args.toSlice(arena.allocator());
    if (args.len >= 2 and std.mem.eql(u8, std.mem.sliceTo(args[1], 0), "akamata-capabilities")) {
        const target = if (args.len == 3) std.mem.sliceTo(args[2], 0) else "native";
        var buffer: [4096]u8 = undefined;
        var stdout = std.Io.File.stdout().writer(init.io, &buffer);
        if (std.mem.eql(u8, target, "workers")) try contracts.For(.workers).writeManifest(.workers, &stdout.interface, application.endpoints) else if (std.mem.eql(u8, target, "native")) try contracts.For(.native).writeManifest(.native, &stdout.interface, application.endpoints) else if (std.mem.eql(u8, target, "containers")) try contracts.For(.containers).writeManifest(.containers, &stdout.interface, application.endpoints) else return error.InvalidTarget;
        return stdout.interface.flush();
    }
    const io = std.Io.Threaded.global_single_threaded.io();
    std.Io.Dir.cwd().createDirPath(io, ".akamata-device-objects") catch {};
    var root = try std.Io.Dir.cwd().openDir(io, ".akamata-device-objects", .{ .iterate = true });
    defer root.close(io);
    const C = contracts.For(.native);
    var files = try am.StorageFactory.initForContract(allocator, C, .{ .native_io = io, .native_root = root });
    var realtime = am.realtime.Native.initForContract(allocator, C);
    defer realtime.deinit();
    const database = try am.db.openForContract(allocator, C, "file:device_messaging.db");
    defer database.close();
    try application.ensureSchema(database);
    const jwt_secret = am.env.get(allocator, "JWT_SECRET") orelse try allocator.dupe(u8, "development-only-jwt-secret-change-me");
    defer allocator.free(jwt_secret);
    const login_secret = am.env.get(allocator, "LOGIN_SECRET") orelse try allocator.dupe(u8, "development-login-secret");
    defer allocator.free(login_secret);
    const test_deployment = am.env.get(allocator, "AKAMATA_CONTRACT_TEST_DEPLOYMENT");
    defer if (test_deployment) |value| allocator.free(value);
    var effects: application.ReportEffects = .{ .db = database };
    const queue = try am.jobs.Provider(contracts.ReportDescriptor).createForContract(allocator, C, database, .{ .context = &effects, .handler_with_context = application.consumeReport }, .{ .poll_interval_ms = 100 });
    defer queue.deinit();
    var worker = queue.worker();
    const thread = try std.Thread.spawn(.{}, am.jobs.Worker.run, .{&worker});
    defer {
        worker.stop();
        thread.join();
    }
    var app = am.App(application.State).init(allocator, .{ .db = database, .store = files.store(), .queue = queue.producer(), .jwt_secret = jwt_secret, .login_secret = login_secret, .realtime = realtime.service(), .test_deployment = test_deployment, .schema_ready = true });
    defer app.deinit();
    try application.register(&app);
    try app.serve(.{ .port = 8080 });
}
