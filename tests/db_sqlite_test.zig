const std = @import("std");
const am = @import("akamata");

const NullableModel = struct {
    id: ?i64 = null,
    n: ?i64 = null,
    s: ?[]const u8 = null,
    pub const __schema = .{ .table = "nullable_models" };
};

test "open in-memory, insert, and read back" {
    const alloc = std.testing.allocator;
    var db = try am.db.openSqlite(alloc, ":memory:");
    defer db.close();

    try db.exec("CREATE TABLE t (id INTEGER PRIMARY KEY, name TEXT NOT NULL, weight REAL)");
    try db.exec("INSERT INTO t(name, weight) VALUES ('alice', 1.5)");

    var stmt = try db.prepare("INSERT INTO t(name, weight) VALUES (?, ?) RETURNING id");
    try stmt.bindAll(.{ @as([]const u8, "bob"), @as(f64, 2.5) });
    const Row = struct { id: i64 };
    const row = try stmt.fetchOne(Row);
    try std.testing.expect(row.id >= 1);
    stmt.deinit();

    var sel = try db.prepare("SELECT id, name, weight FROM t ORDER BY id");
    defer sel.deinit();
    var seen: usize = 0;
    while ((try sel.step()) == .row) {
        const r = try sel.readRow(struct { id: i64, name: []const u8, weight: f64 });
        try std.testing.expect(r.id >= 1);
        try std.testing.expect(r.weight > 0);
        try std.testing.expect(r.name.len > 0);
        seen += 1;
    }
    try std.testing.expectEqual(@as(usize, 2), seen);
}

test "execAll runs multiple statements" {
    const alloc = std.testing.allocator;
    var db = try am.db.openSqlite(alloc, ":memory:");
    defer db.close();

    try db.execAll(
        \\CREATE TABLE a (x INTEGER);
        \\CREATE TABLE b (y TEXT);
        \\INSERT INTO a VALUES (1);
        \\INSERT INTO a VALUES (2);
    );

    var stmt = try db.prepare("SELECT COUNT(*) FROM a");
    defer stmt.deinit();
    _ = try stmt.step();
    try std.testing.expectEqual(@as(i64, 2), try stmt.columnInt(0));
}

test "execAll preserves semicolons in strings and trigger bodies" {
    const alloc = std.testing.allocator;
    var db = try am.db.openSqlite(alloc, ":memory:");
    defer db.close();
    try db.execAll(
        \\CREATE TABLE source (value TEXT);
        \\CREATE TABLE audit (value TEXT);
        \\CREATE TRIGGER source_audit AFTER INSERT ON source BEGIN
        \\  INSERT INTO audit(value) VALUES (NEW.value);
        \\END;
        \\INSERT INTO source(value) VALUES ('a;b');
    );
    var stmt = try db.prepare("SELECT value FROM audit");
    defer stmt.deinit();
    _ = try stmt.step();
    try std.testing.expectEqualStrings("a;b", try stmt.columnText(0));
}

test "columnIsNull distinguishes SQL NULL from zero and empty text" {
    const alloc = std.testing.allocator;
    var db = try am.db.openSqlite(alloc, ":memory:");
    defer db.close();
    try db.exec("CREATE TABLE nullable (n INTEGER, s TEXT)");
    try db.exec("INSERT INTO nullable VALUES (NULL, NULL), (0, '')");
    var stmt = try db.prepare("SELECT n, s FROM nullable ORDER BY rowid");
    defer stmt.deinit();
    _ = try stmt.step();
    try std.testing.expect(try stmt.columnIsNull(0));
    try std.testing.expect(try stmt.columnIsNull(1));
    _ = try stmt.step();
    try std.testing.expect(!try stmt.columnIsNull(0));
    try std.testing.expect(!try stmt.columnIsNull(1));
}

test "model repository preserves optional NULL values" {
    const alloc = std.testing.allocator;
    var db = try am.db.openSqlite(alloc, ":memory:");
    defer db.close();
    try db.exec("CREATE TABLE nullable_models (id INTEGER PRIMARY KEY, n INTEGER, s TEXT)");
    try db.exec("INSERT INTO nullable_models(id, n, s) VALUES (1, NULL, NULL), (2, 0, '')");
    var arena_state: std.heap.ArenaAllocator = .init(alloc);
    defer arena_state.deinit();
    const Models = am.model.repo(NullableModel);
    const null_row = (try Models.find(db, arena_state.allocator(), 1)).?;
    try std.testing.expect(null_row.n == null);
    try std.testing.expect(null_row.s == null);
    const value_row = (try Models.find(db, arena_state.allocator(), 2)).?;
    try std.testing.expectEqual(@as(?i64, 0), value_row.n);
    try std.testing.expect(value_row.s != null);
    try std.testing.expectEqualStrings("", value_row.s.?);
}

test "explicit transaction rolls back unless committed" {
    const alloc = std.testing.allocator;
    var db = try am.db.openSqlite(alloc, ":memory:");
    defer db.close();
    try db.exec("CREATE TABLE tx_test (id INTEGER)");
    {
        var tx = try db.begin();
        defer tx.deinit();
        try tx.exec("INSERT INTO tx_test VALUES (1)");
    }
    var count = try db.prepare("SELECT count(*) FROM tx_test");
    defer count.deinit();
    _ = try count.step();
    try std.testing.expectEqual(@as(i64, 0), try count.columnInt(0));
}

test "database pool leases independent handles" {
    const alloc = std.testing.allocator;
    const first = try am.db.openSqlite(alloc, ":memory:");
    const second = try am.db.openSqlite(alloc, ":memory:");
    var pool = try am.db.Pool.init(alloc, &.{ first, second });
    defer pool.deinit();
    var a = try pool.acquire();
    var b = try pool.acquire();
    try std.testing.expect(a.db.ptr != b.db.ptr);
    a.deinit();
    b.deinit();
}
test "byte arrays, pointers, and slices bind their complete value" {
    const alloc = std.testing.allocator;
    var db = try am.db.openSqlite(alloc, ":memory:");
    defer db.close();
    try db.exec("CREATE TABLE bytes (kind TEXT, value TEXT)");

    var mutable: [64]u8 = @as([64]u8, @splat('x'));
    const direct: [4]u8 = .{ 'a', 'b', 'c', 'd' };
    const mutable_slice: []u8 = mutable[0..5];
    const const_slice: []const u8 = mutable[0..7];
    var stmt = try db.prepare("INSERT INTO bytes VALUES (?, ?), (?, ?), (?, ?), (?, ?)");
    defer stmt.deinit();
    try stmt.bindAll(.{ "array", direct, "pointer", &mutable, "mutable_slice", mutable_slice, "const_slice", const_slice });
    _ = try stmt.step();

    var rows = try db.prepare("SELECT length(value), value FROM bytes ORDER BY rowid");
    defer rows.deinit();
    const expected = [_]i64{ 4, 64, 5, 7 };
    const expected_values = [_][]const u8{ &direct, &mutable, mutable_slice, const_slice };
    for (expected, expected_values) |length, bytes| {
        try std.testing.expectEqual(am.db.StepResult.row, try rows.step());
        try std.testing.expectEqual(length, try rows.columnInt(0));
        try std.testing.expectEqualStrings(bytes, try rows.columnText(1));
    }
}

test "pool exhaustion, absolute expiry, and stale release" {
    const db = try am.db.openSqlite(std.testing.allocator, ":memory:");
    var pool = try am.db.Pool.init(std.testing.allocator, &.{db});
    defer pool.deinit();
    var a = try pool.acquire();
    var stale = a;
    try std.testing.expect((try pool.tryAcquire()) == null);
    try std.testing.expectError(error.Timeout, pool.acquireWithDeadline(pool.deadlineAfter(5)));
    a.deinit();
    a.deinit();
    var b = try pool.acquireWithDeadline(pool.deadlineAfter(1000));
    stale.deinit();
    try std.testing.expect((try pool.tryAcquire()) == null);
    b.deinit();
    try std.testing.expectError(error.Timeout, pool.acquireWithDeadline(pool.deadlineAfter(0)));
    pool.close();
    pool.close();
    try std.testing.expectError(error.PoolClosed, pool.tryAcquire());
    try std.testing.expectError(error.PoolClosed, pool.acquire());
}

const PoolWait = struct {
    pool: *am.db.Pool,
    result: ?anyerror = null,
    acquired: bool = false,
    fn run(self: *PoolWait) void {
        var lease = self.pool.acquireWithDeadline(self.pool.deadlineAfter(2000)) catch |err| {
            self.result = err;
            return;
        };
        self.acquired = true;
        lease.deinit();
    }
};
fn waitForPoolWaiter(pool: *am.db.Pool) !void {
    const deadline = pool.deadlineAfter(1000);
    while (pool.snapshot().waiters == 0) {
        if (deadline.untilNow(pool.io).raw.toNanoseconds() >= 0) return error.WaiterDidNotStart;
        try std.Io.sleep(pool.io, .fromMilliseconds(1), .awake);
    }
}

test "pool release wakes acquisition and close wakes blocked borrowers" {
    const db = try am.db.openSqlite(std.testing.allocator, ":memory:");
    var pool = try am.db.Pool.init(std.testing.allocator, &.{db});
    defer pool.deinit();
    var held = try pool.acquire();
    var waiter: PoolWait = .{ .pool = &pool };
    const thread = try std.Thread.spawn(.{}, PoolWait.run, .{&waiter});
    var joined = false;
    errdefer if (!joined) {
        pool.close();
        held.deinit();
        thread.join();
    };
    try waitForPoolWaiter(&pool);
    held.deinit();
    thread.join();
    joined = true;
    try std.testing.expect(waiter.acquired);
    held = try pool.acquire();
    var closing: PoolWait = .{ .pool = &pool };
    const close_thread = try std.Thread.spawn(.{}, PoolWait.run, .{&closing});
    var close_joined = false;
    errdefer if (!close_joined) {
        pool.close();
        close_thread.join();
    };
    defer held.deinit();
    defer pool.close();
    try waitForPoolWaiter(&pool);
    pool.close();
    close_thread.join();
    close_joined = true;
    try std.testing.expectEqual(error.PoolClosed, closing.result.?);
}

const PoolContention = struct {
    pool: *am.db.Pool,
    inside: std.atomic.Value(u32) = .init(0),
    violations: std.atomic.Value(u32) = .init(0),
    fn run(self: *PoolContention) void {
        for (0..100) |_| {
            var lease = self.pool.acquire() catch {
                _ = self.violations.fetchAdd(1, .monotonic);
                return;
            };
            if (self.inside.fetchAdd(1, .seq_cst) != 0) _ = self.violations.fetchAdd(1, .monotonic);
            _ = self.inside.fetchSub(1, .seq_cst);
            lease.deinit();
        }
    }
};
test "pool serializes concurrent borrowers without double lending" {
    const db = try am.db.openSqlite(std.testing.allocator, ":memory:");
    var pool = try am.db.Pool.init(std.testing.allocator, &.{db});
    defer pool.deinit();
    var contention: PoolContention = .{ .pool = &pool };
    var threads: [8]std.Thread = undefined;
    var started: usize = 0;
    defer for (threads[0..started]) |thread| thread.join();
    for (&threads) |*thread| {
        thread.* = try std.Thread.spawn(.{}, PoolContention.run, .{&contention});
        started += 1;
    }
    for (threads) |thread| thread.join();
    started = 0;
    try std.testing.expectEqual(@as(u32, 0), contention.violations.load(.acquire));
    try std.testing.expectEqual(@as(usize, 1), pool.snapshot().idle);
}
const PoolDestroy = struct {
    pool: *am.db.Pool,
    done: std.atomic.Value(bool) = .init(false),
    fn run(self: *PoolDestroy) void {
        self.pool.deinit();
        self.done.store(true, .release);
    }
};
test "pool deinit joins waiters and outstanding leases before freeing handles" {
    const db = try am.db.openSqlite(std.testing.allocator, ":memory:");
    var pool = try am.db.Pool.init(std.testing.allocator, &.{db});
    var held = try pool.acquire();
    var waiter: PoolWait = .{ .pool = &pool };
    const blocked = try std.Thread.spawn(.{}, PoolWait.run, .{&waiter});
    var observed = false;
    errdefer if (!observed) {
        pool.close();
        held.deinit();
        blocked.join();
        pool.deinit();
    };
    try waitForPoolWaiter(&pool);
    pool.close();
    blocked.join();
    observed = true;
    try std.testing.expectEqual(error.PoolClosed, waiter.result.?);
    var destroy: PoolDestroy = .{ .pool = &pool };
    const shutdown = try std.Thread.spawn(.{}, PoolDestroy.run, .{&destroy});
    defer shutdown.join();
    defer held.deinit();
    try std.testing.expect(!destroy.done.load(.acquire));
    // Db remains usable until the last lease is released.
    try held.db.exec("CREATE TABLE shutdown_safe (id INTEGER)");
}

fn poolAllocationFailure(allocator: std.mem.Allocator) !void {
    const db = try am.db.openSqlite(allocator, ":memory:");
    var transferred = false;
    defer if (!transferred) db.close();
    var pool = try am.db.Pool.init(allocator, &.{db});
    transferred = true;
    defer pool.deinit();
    var lease = try pool.acquire();
    lease.deinit();
}
test "pool initialization failure retains caller ownership without leaks" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, poolAllocationFailure, .{});
}
test "pool gauges and wait timeout counts balance through close" {
    var counters: am.mw.MetricsCounters = .{};
    const db = try am.db.openSqlite(std.testing.allocator, ":memory:");
    var pool = try am.db.Pool.initWithOptions(std.testing.allocator, &.{db}, .{ .metrics = &counters });
    defer pool.deinit();
    var lease = try pool.acquire();
    try std.testing.expectEqual(@as(i64, 1), counters.db_pool_active_connections.load(.monotonic));
    try std.testing.expectError(error.Timeout, pool.acquireWithDeadline(pool.deadlineAfter(2)));
    try std.testing.expectEqual(@as(u64, 1), counters.db_pool_acquire_timeouts_total.load(.monotonic));
    try std.testing.expectEqual(@as(u64, 1), counters.db_pool_acquire_wait_count.load(.monotonic));
    pool.close();
    lease.deinit();
    try std.testing.expectEqual(@as(i64, 0), counters.db_pool_active_connections.load(.monotonic));
    try std.testing.expectEqual(@as(i64, 0), counters.db_pool_idle_connections.load(.monotonic));
    try std.testing.expectEqual(@as(i64, 0), counters.db_pool_waiters.load(.monotonic));
}
