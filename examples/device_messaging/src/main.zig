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
    if (args.len == 2 and std.mem.eql(u8, std.mem.sliceTo(args[1], 0), "--print-schema")) {
        var buffer: [4096]u8 = undefined;
        var stdout = std.Io.File.stdout().writer(init.io, &buffer);
        try stdout.interface.writeAll(application.schema_sql);
        return stdout.interface.flush();
    }
    if (args.len >= 2 and std.mem.eql(u8, std.mem.sliceTo(args[1], 0), "migrate-up")) {
        var dir: []const u8 = "examples/device_messaging/migrations";
        if (args.len == 3) dir = std.mem.sliceTo(args[2], 0);
        const url = am.env.get(allocator, "DATABASE_URL") orelse try allocator.dupe(u8, "file:device_messaging.db");
        defer allocator.free(url);
        const db = try am.db.openForContract(allocator, contracts.For(.native), url);
        defer db.close();
        const migrations = try am.model.migrate.loadMigrationsFromDir(arena.allocator(), dir);
        const migrator: am.model.migrate.Migrator = .{ .arena = arena.allocator(), .db = db };
        try migrator.applyAll(migrations);
        return;
    }
    if (args.len == 2 and (std.mem.eql(u8, std.mem.sliceTo(args[1], 0), "akamata-protocol-ts") or std.mem.eql(u8, std.mem.sliceTo(args[1], 0), "akamata-protocol-c"))) {
        const target: am.protocol_gen.Target = if (std.mem.eql(u8, std.mem.sliceTo(args[1], 0), "akamata-protocol-ts")) .typescript else .c;
        const bytes = try am.protocol_gen.generateProtocol(contracts.Protocol, allocator, .{ .target = target });
        defer allocator.free(bytes);
        var buffer: [4096]u8 = undefined;
        var stdout = std.Io.File.stdout().writer(init.io, &buffer);
        try stdout.interface.writeAll(bytes);
        return stdout.interface.flush();
    }
    if (args.len > 1 and !(args.len == 2 and std.mem.eql(u8, std.mem.sliceTo(args[1], 0), "--dev-init"))) return error.UnknownCommand;
    const io = std.Io.Threaded.global_single_threaded.io();
    try std.Io.Dir.cwd().createDirPath(io, ".akamata-device-objects");
    var root = try std.Io.Dir.cwd().openDir(io, ".akamata-device-objects", .{ .iterate = true });
    defer root.close(io);
    const C = contracts.For(.native);
    var files = try am.StorageFactory.initForContract(allocator, C, .{ .native_io = io, .native_root = root });
    var realtime = am.realtime.Native.initForContract(allocator, C);
    defer realtime.deinit();
    const url = am.env.get(allocator, "DATABASE_URL") orelse try allocator.dupe(u8, "file:device_messaging.db");
    defer allocator.free(url);
    const database = try am.db.openForContract(allocator, C, url);
    defer database.close();
    if (args.len == 2 and std.mem.eql(u8, std.mem.sliceTo(args[1], 0), "--dev-init")) try application.ensureSchema(database);
    var schema_check = try database.prepare("SELECT id FROM portable_records LIMIT 1");
    schema_check.deinit();
    const jwt_secret = am.env.get(allocator, "JWT_SECRET") orelse return error.MissingJwtSecret;
    defer allocator.free(jwt_secret);
    const login_secret = am.env.get(allocator, "LOGIN_SECRET") orelse return error.MissingLoginSecret;
    defer allocator.free(login_secret);
    const test_deployment = am.env.get(allocator, "AKAMATA_CONTRACT_TEST_DEPLOYMENT");
    defer if (test_deployment) |value| allocator.free(value);
    var effects: application.ReportEffects = .{ .db = database };
    const queue = try am.jobs.Provider(contracts.ReportDescriptor).createForContract(allocator, C, database, .{ .context = &effects, .handler_with_context = application.consumeReport }, .{ .poll_interval_ms = 100 });
    defer queue.deinit();
    var gate = am.sync.Mutex.init();
    defer gate.deinit();
    var app = am.App(application.State).init(allocator, .{ .db = database, .store = files.store(), .queue = queue.producer(), .jwt_secret = jwt_secret, .login_secret = login_secret, .realtime = realtime.service(), .test_deployment = test_deployment, .native_transport_gate = &gate });
    defer app.deinit();
    try application.register(&app);
    var worker = queue.worker();
    const thread = try std.Thread.spawn(.{}, runWorker, .{&worker});
    defer {
        worker.stop();
        thread.join();
    }

    try app.serve(.{ .port = 8080 });
}

fn runWorker(worker: *am.jobs.Worker) void {
    worker.run() catch |err| {
        std.log.err("queue worker stopped: {t}", .{err});
        worker.stop();
    };
}
