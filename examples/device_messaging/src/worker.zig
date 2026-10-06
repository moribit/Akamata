const std = @import("std");
const am = @import("akamata");
const application = @import("application.zig");
const contracts = @import("contracts.zig");

pub const std_options: std.Options = .{ .logFn = noopLog };
fn noopLog(comptime _: std.log.Level, comptime _: @TypeOf(.enum_literal), comptime _: []const u8, _: anytype) void {}
var app: am.App(application.State) = undefined;
var r2: am.StorageFactory = undefined;
var realtime: *am.platform.workers.RealtimeOwner = undefined;
var queue: *am.platform.workers.QueueOwner(contracts.ReportDescriptor) = undefined;
var effects: application.ReportEffects = undefined;
var initialized = false;

fn init() !void {
    if (initialized) return;
    const allocator = std.heap.wasm_allocator;
    const C = contracts.For(.workers);
    r2 = try am.StorageFactory.initForContract(allocator, C, .{});
    const default_url = comptime "d1:" ++ C.resolve(.database).binding.?;
    const url = am.env.get(allocator, "DATABASE_URL") orelse try allocator.dupe(u8, default_url);
    defer allocator.free(url);
    const database = try am.db.openForContract(allocator, C, url);
    errdefer database.close();
    const jwt_secret = am.env.get(std.heap.wasm_allocator, "JWT_SECRET") orelse return error.MissingJwtSecret;
    errdefer allocator.free(jwt_secret);
    const login_secret = am.env.get(std.heap.wasm_allocator, "LOGIN_SECRET") orelse return error.MissingLoginSecret;
    errdefer allocator.free(login_secret);
    const test_deployment = am.env.get(allocator, "AKAMATA_CONTRACT_TEST_DEPLOYMENT");
    errdefer if (test_deployment) |value| allocator.free(value);
    realtime = try am.platform.workers.RealtimeOwner.createForContract(allocator, C);
    errdefer realtime.deinit();
    effects = .{ .db = database };
    queue = try am.platform.workers.QueueOwner(contracts.ReportDescriptor).createForContract(allocator, C, .{ .context = &effects, .handler_with_context = application.consumeReport });
    errdefer queue.deinit();
    app = am.App(application.State).init(std.heap.wasm_allocator, .{
        .db = database,
        .store = r2.store(),
        .queue = queue.producer(),
        .realtime = realtime.service(),
        .jwt_secret = jwt_secret,
        .login_secret = login_secret,
        .test_deployment = test_deployment,
    });
    errdefer app.deinit();
    try application.register(&app);
    am.platform.workers.setQueueConsumer(consumeQueue);
    initialized = true;
}
fn consumeQueue(bytes: []const u8) !void {
    try queue.consume(bytes);
}
pub fn main() !void {
    try init();
    try app.serve(.{});
}
export fn akamata_init() void {
    init() catch return;
    app.serve(.{}) catch {};
}
