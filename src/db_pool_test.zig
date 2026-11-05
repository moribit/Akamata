//! Standalone native pool race fixture; root imports keep core code TSan-instrumented.
const std = @import("std");
const Pool = @import("db/pool.zig").Pool;
const open = @import("db/sqlite.zig").open;
const Race = struct {
    pool: *Pool,
    inside: std.atomic.Value(u32) = .init(0),
    errors: std.atomic.Value(u32) = .init(0),
    fn run(self: *Race) void {
        for (0..1000) |_| {
            var lease = self.pool.acquireWithDeadline(self.pool.deadlineAfter(2)) catch |err| {
                switch (err) {
                    error.PoolClosed => return,
                    error.Timeout => continue,
                    else => {
                        _ = self.errors.fetchAdd(1, .monotonic);
                        return;
                    },
                }
            };
            if (self.inside.fetchAdd(1, .seq_cst) != 0) _ = self.errors.fetchAdd(1, .monotonic);
            _ = self.inside.fetchSub(1, .seq_cst);
            lease.deinit();
        }
    }
};
test "deadline release close races preserve exclusive lending and clean shutdown" {
    for (0..20) |_| {
        const db = try open(std.testing.allocator, ":memory:");
        var pool = try Pool.init(std.testing.allocator, &.{db});
        defer pool.deinit();
        var race: Race = .{ .pool = &pool };
        var threads: [8]std.Thread = undefined;
        var started: usize = 0;
        defer {
            pool.close();
            for (threads[0..started]) |t| t.join();
        }
        for (&threads) |*t| {
            t.* = try std.Thread.spawn(.{}, Race.run, .{&race});
            started += 1;
        }
        try std.Io.sleep(pool.io, .fromMilliseconds(2), .awake);
        pool.close();
        for (threads) |t| t.join();
        started = 0;
        try std.testing.expectEqual(@as(u32, 0), race.errors.load(.acquire));
        try std.testing.expectEqual(@as(usize, 0), pool.snapshot().active);
        try std.testing.expectEqual(@as(usize, 0), pool.snapshot().waiters);
    }
}

const sqlite = @import("db/sqlite.zig");
const c = @import("db/sqlite_c.zig").c;
fn handleOf(database: @import("db/db.zig").Db) *c.sqlite3 {
    const backend: *sqlite.Backend = @ptrCast(@alignCast(database.ptr));
    return backend.handle;
}
test "SQLite statement errors finalize and recover without outstanding handles" {
    const database = try open(std.testing.allocator, ":memory:");
    defer database.close();
    const handle = handleOf(database);
    try std.testing.expectError(error.PrepareFailed, database.prepare("SELECT no_such_column"));
    try std.testing.expect(c.sqlite3_next_stmt(handle, null) == null);
    try database.exec("CREATE TABLE unique_values (n INTEGER UNIQUE)");
    try database.exec("INSERT INTO unique_values VALUES (1)");
    {
        var statement = try database.prepare("INSERT INTO unique_values VALUES (?)");
        defer statement.deinit();
        try std.testing.expectError(error.BindFailed, statement.bind(2, .{ .int = 1 }));
        try statement.bind(1, .{ .int = 1 });
        try std.testing.expectError(error.StepFailed, statement.step());
        try statement.reset(); // reset clears bindings even after a failed step
        try statement.bind(1, .{ .int = 2 });
        try std.testing.expectEqual(.done, try statement.step());
        // SQLite itself refuses to destroy a connection with a live statement.
        try std.testing.expectEqual(c.SQLITE_BUSY, c.sqlite3_close(handle));
    }
    try std.testing.expect(c.sqlite3_next_stmt(handle, null) == null);
    try database.ping();
}
test "SQLite row borrows are copied before reset and finalize" {
    const allocator = std.testing.allocator;
    const database = try open(allocator, ":memory:");
    defer database.close();
    const text = try allocator.alloc(u8, 65536);
    defer allocator.free(text);
    @memset(text, 'x');
    @memcpy(text[0..6], "日本");
    const blob = [_]u8{ 0, 1, 255, 0, 42 };
    var insert = try database.prepare("SELECT ?, ?, NULL, '', 42, 1.5");
    defer insert.deinit();
    try insert.bind(1, .{ .text = text });
    try insert.bind(2, .{ .blob = &blob });
    try std.testing.expectEqual(.row, try insert.step());
    const row = try insert.readRow(struct { text: []const u8, blob_as_text: []const u8, absent: ?i64, empty: []const u8, number: i64, real: f64 });
    try std.testing.expect(row.absent == null);
    try std.testing.expectEqualStrings("", row.empty);
    try std.testing.expectEqual(@as(i64, 42), row.number);
    try std.testing.expectEqual(@as(f64, 1.5), row.real);
    const owned_text = try allocator.dupe(u8, row.text);
    defer allocator.free(owned_text);
    const owned_blob = try allocator.dupe(u8, try insert.columnBlob(1));
    defer allocator.free(owned_blob);
    try std.testing.expectEqualSlices(u8, &blob, owned_blob);
    try insert.reset();
    try std.testing.expectEqualStrings(text, owned_text);
    try std.testing.expectEqualSlices(u8, &blob, owned_blob);
    try std.testing.expectEqual(.row, try insert.step());
    try std.testing.expect(try insert.columnIsNull(0));
    try std.testing.expectError(error.InvalidType, insert.readRow(struct { required: []const u8 }));
}
test "SQLite wrapper allocation failure finalizes the prepared handle" {
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{});
    const database = try open(failing.allocator(), ":memory:");
    defer database.close();
    failing.fail_index = failing.alloc_index;
    try std.testing.expectError(error.OutOfMemory, database.prepare("SELECT 1"));
    try std.testing.expect(c.sqlite3_next_stmt(handleOf(database), null) == null);
    failing.fail_index = std.math.maxInt(usize);
    try database.ping();
    try std.testing.expect(c.sqlite3_next_stmt(handleOf(database), null) == null);
}

test "owned SQLite row JSON remains correct after finalize" {
    const allocator = std.testing.allocator;
    const database = try open(allocator, ":memory:");
    defer database.close();
    const Row = struct { id: i64, name: []const u8, absent: ?i64 };
    var row: Row = undefined;
    {
        var statement = try database.prepare("SELECT 42, '日本語 🌍', NULL");
        defer statement.deinit();
        try std.testing.expectEqual(.row, try statement.step());
        row = try statement.readRow(Row);
        row.name = try allocator.dupe(u8, row.name);
    }
    defer allocator.free(row.name);
    var writer: std.Io.Writer.Allocating = .init(allocator);
    defer writer.deinit();
    try @import("json.zig").stringify(row, &writer.writer);
    const decoded = try std.json.parseFromSlice(Row, allocator, writer.written(), .{});
    defer decoded.deinit();
    try std.testing.expectEqual(@as(i64, 42), decoded.value.id);
    try std.testing.expectEqualStrings("日本語 🌍", decoded.value.name);
    try std.testing.expect(decoded.value.absent == null);
    try std.testing.expect(c.sqlite3_next_stmt(handleOf(database), null) == null);
    for (0..1000) |_| {
        var statement = try database.prepare("SELECT 1");
        try std.testing.expectEqual(.row, try statement.step());
        statement.deinit();
    }
    try std.testing.expect(c.sqlite3_next_stmt(handleOf(database), null) == null);
}

const QueryStress = struct {
    pool: *Pool,
    errors: std.atomic.Value(u32) = .init(0),
    fn query(self: *QueryStress, id: i64) !void {
        // This is an ownership/cleanup stress, not a scheduling SLO. Debug
        // SQLite plus the validating allocator can legitimately wait >1s.
        // Deadline expiry/close races are tested independently above.
        var lease = try self.pool.acquire();
        defer lease.deinit();
        var statement = try lease.db.prepare("SELECT ?, ?, NULL");
        defer statement.deinit();
        try statement.bindAll(.{ id, "日本語 🌍" });
        try std.testing.expectEqual(.row, try statement.step());
        const row = try statement.readRow(struct { id: i64, name: []const u8, absent: ?u32 });
        try std.testing.expectEqual(id, row.id);
        try std.testing.expectEqualStrings("日本語 🌍", row.name);
        try std.testing.expect(row.absent == null);
    }
    fn run(self: *QueryStress, id: i64) void {
        for (0..1000) |_| self.query(id) catch |err| {
            std.debug.print("query stress failure: {s}\n", .{@errorName(err)});
            _ = self.errors.fetchAdd(1, .monotonic);
            return;
        };
    }
};
test "32 SQLite borrowers retain statement ownership across an eight-handle pool" {
    const allocator = std.testing.allocator;
    var handles: [8]@import("db/db.zig").Db = undefined;
    var opened: usize = 0;
    errdefer for (handles[0..opened]) |database| database.close();
    for (&handles) |*database| {
        database.* = try open(allocator, ":memory:");
        opened += 1;
    }
    var pool = try Pool.init(allocator, &handles);
    opened = 0;
    defer pool.deinit();
    var stress: QueryStress = .{ .pool = &pool };
    var threads: [32]std.Thread = undefined;
    var started: usize = 0;
    defer for (threads[0..started]) |thread| thread.join();
    for (&threads, 0..) |*thread, i| {
        thread.* = try std.Thread.spawn(.{}, QueryStress.run, .{ &stress, @as(i64, @intCast(i)) });
        started += 1;
    }
    for (threads) |thread| thread.join();
    started = 0;
    try std.testing.expectEqual(@as(u32, 0), stress.errors.load(.acquire));
    try std.testing.expectEqual(@as(usize, 8), pool.snapshot().idle);
    for (pool.handles) |database| try std.testing.expect(c.sqlite3_next_stmt(handleOf(database), null) == null);
}
