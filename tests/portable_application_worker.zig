const std = @import("std");
const fixture = @import("portable_application_fixture.zig");
const am = @import("akamata");
var last_error: []const u8 = "";
pub const std_options: std.Options = .{ .logFn = log };
fn log(comptime _: std.log.Level, comptime _: @TypeOf(.enum_literal), comptime _: []const u8, _: anytype) void {}
export fn run_contract() u32 {
    fixture.run(std.heap.wasm_allocator) catch |err| {
        last_error = @errorName(err);
        return 1;
    };
    return 0;
}

fn databaseAdapterContract() !void {
    const allocator = std.heap.wasm_allocator;
    var url = "d1:REPORTS".*;
    const named = try am.db.open(allocator, &url);
    defer named.close();
    // The provider owns its binding name, not the caller's mutable URL.
    @memset(&url, 'x');
    try named.exec("INSERT INTO effects DEFAULT VALUES");
    var statement = try named.prepare("SELECT ?");
    defer statement.deinit();
    try statement.bind(1, .{ .int = 42 });
    if (try statement.step() != .row or try statement.columnInt(0) != 42) return error.DatabaseContractFailed;
    const default = try am.db.open(allocator, "d1:DB");
    defer default.close();
    try default.exec("INSERT INTO effects DEFAULT VALUES");
    if (am.db.open(allocator, "d1:")) |unexpected| {
        unexpected.close();
        return error.DatabaseContractFailed;
    } else |err| {
        if (err != error.InvalidUrl) return err;
    }
    // FixedBufferAllocator is freestanding; std.testing.FailingAllocator in
    // Zig 0.17 pulls host-only stack tracing/Io into this WASM fixture.
    var buffer: [256]u8 = undefined;
    var failing = std.heap.FixedBufferAllocator.init(&buffer);
    const limited = try am.db.open(failing.allocator(), "d1:REPORTS");
    defer limited.close();
    failing.end_index = buffer.len;
    if (limited.prepare("SELECT ?")) |unexpected| {
        var cleanup = unexpected;
        cleanup.deinit();
        return error.DatabaseContractFailed;
    } else |err| if (err != error.OutOfMemory) return err;
}
export fn run_database_adapter_contract() u32 {
    databaseAdapterContract() catch |err| {
        last_error = @errorName(err);
        return 1;
    };
    return 0;
}
fn platformAdapterContract() !void {
    // R2 list metadata currently uses the supplied allocator's lifetime;
    // isolate adapter allocations in a bounded operation arena.
    var arena: std.heap.ArenaAllocator = .init(std.heap.wasm_allocator);
    defer arena.deinit();
    var store = am.platform.workers.R2Store.init(arena.allocator(), "FILES");
    try fixture.storageContract(arena.allocator(), store.store());
    try fixture.paginationContract(std.heap.wasm_allocator, store.store());
    const Payload = struct { text: []const u8 };
    const D = am.events.Descriptor(Payload, .{ .name = "created", .version = 2 });
    const Handler = struct {
        fn consume(value: Payload, delivery: am.queue.Delivery) !void {
            if (!std.mem.eql(u8, value.text, "hello") or delivery.attempt != 3 or delivery.max_attempts != 7 or !std.mem.eql(u8, delivery.event_id, "application-event")) return error.QueueContractFailed;
        }
    };
    var binding = "EVENTS".*;
    const owner = try am.platform.workers.QueueOwner(D).create(std.heap.wasm_allocator, &binding, .{ .handler = Handler.consume });
    defer owner.deinit();
    @memset(&binding, 'x');
    try owner.consume(
        \\{"body":{"protocol_version":2,"event_type":"created","event_id":"application-event","attempt":1,"max_attempts":7,"payload":{"text":"hello"}},"event_id":"cloudflare-message","attempt":3}
    );
    const realtime = try am.platform.workers.RealtimeOwner.create(std.heap.wasm_allocator, "ROOMS");
    defer realtime.deinit();
    const Protocol = am.events.Protocol(union(enum) { created: Payload }, 2);
    const room = realtime.service().room(Protocol, "room-1");
    const presence = try realtime.presenceChecked("room-1");
    if (presence.connections != 2 or presence.members != 1) return error.RealtimeContractFailed;
    if (try room.broadcast(std.heap.wasm_allocator, .{ .created = .{ .text = "hello" } }) != 2) return error.RealtimeContractFailed;
    try room.send(std.heap.wasm_allocator, std.math.maxInt(u64), .{ .created = .{ .text = "hello" } });
    try room.disconnect(std.math.maxInt(u64), 1000);
    const FailingReader = struct {
        closed: bool = false,
        fn read(_: *anyopaque, _: []u8) am.stream.Error!usize {
            return error.BackendFailure;
        }
        fn close(ptr: *anyopaque) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.closed = true;
        }
    };
    var failing: FailingReader = .{};
    if (store.store().put("objects/failing", .{ .ptr = &failing, .read_fn = FailingReader.read, .close_fn = FailingReader.close }, .{})) |_| {
        return error.StorageContractFailed;
    } else |err| if (err != error.BackendFailure) return err;
    if (!failing.closed) return error.StorageContractFailed;
    var producer: am.platform.workers.QueueProducer = .{ .binding = "EVENTS" };
    const Event = am.events.Descriptor(struct { text: []const u8 }, .{ .name = "created", .version = 2 });
    try producer.producer().dispatchDescriptor(arena.allocator(), Event, .{ .text = "hello" }, .{
        .event_id = "event-1",
        .correlation_id = "request-1",
        .idempotency_key = "message:1",
        .attempt = 2,
        .max_attempts = 7,
    });
}
export fn run_platform_adapter_contract() u32 {
    platformAdapterContract() catch |err| {
        last_error = @errorName(err);
        return 1;
    };
    return 0;
}
export fn error_ptr() [*]const u8 {
    return last_error.ptr;
}
export fn error_len() usize {
    return last_error.len;
}
