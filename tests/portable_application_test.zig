const std = @import("std");
const am = @import("akamata");
const fixture = @import("portable_application_fixture.zig");
test "portable application effects, typed HTTP and generated contract" {
    try fixture.run(std.testing.allocator);
}
test "filesystem and in-memory storage satisfy the same provider contract" {
    var temporary = std.testing.tmpDir(.{});
    defer temporary.cleanup();
    var filesystem = am.storage.filesystem.FileStore.init(std.testing.allocator, std.testing.io, temporary.dir);
    try fixture.storageContract(std.testing.allocator, filesystem.store());
}

fn pageAllocationFailure(allocator: std.mem.Allocator) !void {
    var memory = am.testing.MemoryStore.init(std.testing.allocator);
    // Use the shared contract to populate and exercise metadata snapshots.
    fixture.paginationContract(allocator, memory.store()) catch |err| {
        if (err == error.Unavailable) return error.OutOfMemory;
        return err;
    };
}

test "owned storage pages clean up every allocation failure" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, pageAllocationFailure, .{});
}

const QueueEvent = struct { value: u32 };
const QueueDescriptor = am.events.Descriptor(QueueEvent, .{ .name = "provider-test", .version = 2 });
const QueueHandler = struct {
    var calls: usize = 0;
    fn consume(value: QueueEvent, delivery: am.queue.Delivery) !void {
        calls += 1;
        try std.testing.expectEqual(@as(u32, 42), value.value);
        try std.testing.expectEqual(@as(u16, @intCast(calls)), delivery.attempt);
        try std.testing.expectEqual(@as(u16, 2), delivery.max_attempts);
        try std.testing.expectEqualStrings("event-1", delivery.event_id);
        try std.testing.expectEqualStrings("request-1", delivery.correlation_id.?);
        try std.testing.expectEqualStrings("operation-1", delivery.idempotency_key.?);
        if (calls == 1) return error.RetryExpected;
    }
};

test "native queue provider preserves envelopes and actual retry delivery" {
    var db = try am.db.open(std.testing.allocator, "file::memory:");
    defer db.close();
    const owner = try am.jobs.Provider(QueueDescriptor).create(std.testing.allocator, db, .{ .handler = QueueHandler.consume }, .{ .initial_backoff_seconds = 0 });
    defer owner.deinit();
    QueueHandler.calls = 0;
    try owner.producer().dispatchDescriptor(std.testing.allocator, QueueDescriptor, .{ .value = 42 }, .{ .event_id = "event-1", .correlation_id = "request-1", .idempotency_key = "operation-1", .max_attempts = 2 });
    var worker = owner.worker();
    try worker.tick();
    try worker.tick();
    try std.testing.expectEqual(@as(usize, 2), QueueHandler.calls);
    owner.stop();
    try std.testing.expectError(error.Unavailable, owner.producer().dispatchDescriptor(std.testing.allocator, QueueDescriptor, .{ .value = 42 }, .{ .event_id = "stopped" }));
}

fn ownerAllocationFailure(allocator: std.mem.Allocator, db: am.db.Db) !void {
    const owner = try am.jobs.Provider(QueueDescriptor).create(allocator, db, .{ .handler = QueueHandler.consume }, .{});
    owner.deinit();
}

test "queue startup failure cleans partially initialized owner" {
    var db = try am.db.open(std.testing.allocator, "file::memory:");
    defer db.close();
    try std.testing.checkAllAllocationFailures(std.testing.allocator, ownerAllocationFailure, .{db});
    // The caller still owns and can use the earlier resource after failure.
    try db.execAll("CREATE TABLE provider_survived(id INTEGER)");
}
