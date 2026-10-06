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

test "short empty pages continue by cursor and reject a nonadvancing backend" {
    const PageBackend = struct {
        fn page(_: *anyopaque, allocator: std.mem.Allocator, _: []const u8, _: ?[]const u8, _: usize) am.storage.Error!am.storage.PageData {
            return .{ .entries = allocator.alloc(am.storage.ListEntry, 0) catch return error.Unavailable, .cursor = "next-page" };
        }
    };
    var memory = am.testing.MemoryStore.init(std.testing.allocator);
    var vtable = memory.store().vtable.*;
    vtable.list_page = PageBackend.page;
    var store = memory.store();
    store.vtable = &vtable;
    var first = try store.listPage(std.testing.allocator, "", null, 2);
    defer first.deinit();
    try std.testing.expectEqual(@as(usize, 0), first.entries.len);
    try std.testing.expectEqualStrings("next-page", first.cursor.?);
    try std.testing.expectError(error.BackendFailure, store.listPage(std.testing.allocator, "", first.cursor, 2));
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
    const C = am.capability.Contract("queue-owner", &.{ .database, .queue }, &.{ .{ .capability = .database, .provider = .sqlite }, .{ .capability = .queue, .provider = .native_queue } });
    try std.testing.expectError(error.ProviderConfigurationDrift, am.db.openForContract(std.testing.allocator, C, "https://not-opened.invalid"));
    var db = try am.db.openForContract(std.testing.allocator, C, "file::memory:");
    defer db.close();
    const owner = try am.jobs.Provider(QueueDescriptor).createForContract(std.testing.allocator, C, db, .{ .handler = QueueHandler.consume }, .{ .initial_backoff_seconds = 0 });
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

fn completeStartup(allocator: std.mem.Allocator) !void {
    var database = try am.db.open(allocator, "file::memory:");
    defer database.close();
    // The Store borrows its filesystem directory in production; this owned
    // test effect provider isolates allocation/cleanup ordering from OS paths.
    var storage = am.testing.MemoryStore.init(allocator);
    var realtime = am.realtime.Native.init(allocator);
    defer realtime.deinit();
    const owner = try am.jobs.Provider(QueueDescriptor).create(allocator, database, .{ .handler = QueueHandler.consume }, .{});
    defer owner.deinit();
    _ = storage.store();
    _ = realtime.service();
    owner.stop();
}

test "partial application startup releases earlier DB and realtime owners" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, completeStartup, .{});
}

fn metadataPageLifetime(allocator: std.mem.Allocator) !void {
    const Backend = struct {
        key: [7]u8 = "pages/a".*,
        etag: [6]u8 = "etag-a".*,
        content: [6]u8 = "test/x".*,
        custom: [7]u8 = "{\"v\":1}".*,
        cursor: [7]u8 = "token-a".*,
        fn list(ptr: *anyopaque, alloc: std.mem.Allocator, _: []const u8, _: ?[]const u8, _: usize) am.storage.Error!am.storage.PageData {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            const entries = alloc.alloc(am.storage.ListEntry, 1) catch return error.Unavailable;
            entries[0] = .{ .key = &self.key, .metadata = .{ .size = 1, .etag = &self.etag, .content_type = &self.content, .custom_json = &self.custom } };
            return .{ .entries = entries, .cursor = &self.cursor };
        }
    };
    var memory = am.testing.MemoryStore.init(std.testing.allocator);
    var vtable = memory.store().vtable.*;
    vtable.list_page = Backend.list;
    const owner = try std.testing.allocator.create(Backend);
    owner.* = .{};
    var alive = true;
    defer if (alive) std.testing.allocator.destroy(owner);
    const store: am.storage.Store = .{ .ptr = owner, .vtable = &vtable };
    var page = store.listPage(allocator, "pages/", null, 1) catch |err| {
        if (err == error.Unavailable) return error.OutOfMemory;
        return err;
    };
    defer page.deinit();
    // Destroy the adapter scratch/owner before inspecting every returned slice.
    owner.* = undefined;
    std.testing.allocator.destroy(owner);
    alive = false;
    try std.testing.expectEqualStrings("pages/a", page.entries[0].key);
    try std.testing.expectEqualStrings("etag-a", page.entries[0].metadata.etag.?);
    try std.testing.expectEqualStrings("test/x", page.entries[0].metadata.content_type.?);
    try std.testing.expectEqualStrings("{\"v\":1}", page.entries[0].metadata.custom_json.?);
    try std.testing.expectEqualStrings("token-a", page.cursor.?);
}

test "all page metadata survives adapter destruction with allocation-failure cleanup" {
    try metadataPageLifetime(std.testing.allocator);
    try std.testing.checkAllAllocationFailures(std.testing.allocator, metadataPageLifetime, .{});
}
