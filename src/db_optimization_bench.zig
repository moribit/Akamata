//! Private diagnostic. A/B use the same pthread gate; C-F use production Pool.
const std = @import("std");
const db = @import("db/db.zig");
const sqlite = @import("db/sqlite.zig");
const c = @import("db/sqlite_c.zig").c;
const Pool = @import("db/pool.zig").Pool;
const sync = @import("sync.zig");
const clock = @import("observability/clock.zig");
const profile = @import("db/profile.zig");
pub const db_diagnostics = @import("db_bench_options").diagnostics;
const Row = struct { id: i64, name: []const u8, weight: f64 };
const sql = "SELECT id, name, weight FROM items WHERE id = ?";
const schema = "PRAGMA journal_mode=MEMORY; PRAGMA synchronous=OFF; PRAGMA temp_store=MEMORY; CREATE TABLE items(id INTEGER PRIMARY KEY,name TEXT NOT NULL,weight REAL); INSERT INTO items VALUES(1,'alpha',1.5),(2,'beta',2.5),(3,'gamma',3.5);";
const Gate = struct {
    mu: sync.Mutex,
    cond: sync.Condition,
    used: [8]bool = @splat(false),
    fn acquire(self: *Gate) usize {
        self.mu.lock();
        defer self.mu.unlock();
        while (true) {
            for (&self.used, 0..) |*used, i| if (!used.*) {
                used.* = true;
                return i;
            };
            self.cond.wait(&self.mu);
        }
    }
    fn release(self: *Gate, i: usize) void {
        self.mu.lock();
        defer self.mu.unlock();
        self.used[i] = false;
        self.cond.signal();
    }
};
const Shared = struct { pool: *Pool, gate: *Gate, handles: *[8]db.Db, ready: std.atomic.Value(usize) = .init(0), go: std.atomic.Value(bool) = .init(false) };
const Work = struct {
    shared: *Shared,
    kind: u8,
    latencies: []u64,
    counts: profile.Counts = .{},
    checksum: u64 = 0,
    errors: usize = 0,
    fn operation(self: *Work, arena: std.mem.Allocator) !void {
        var t = profile.begin();
        var lease: ?@import("db/pool.zig").Lease = null;
        const index = if (self.kind <= 'B') self.shared.gate.acquire() else blk: {
            lease = try self.shared.pool.acquire();
            break :blk lease.?.index;
        };
        profile.end(.pool_acquire, t);
        const handle = self.shared.handles[index];
        defer {
            const start = profile.begin();
            if (lease) |*l| l.deinit() else self.shared.gate.release(index);
            profile.end(.pool_release, start);
        }
        var row: Row = undefined;
        if (self.kind == 'A') {
            const backend: *sqlite.Backend = @ptrCast(@alignCast(handle.ptr));
            var stmt: ?*c.sqlite3_stmt = null;
            t = profile.begin();
            const rc = c.sqlite3_prepare_v2(backend.handle, sql, sql.len, &stmt, null);
            profile.end(.sqlite_prepare, t);
            if (rc != c.SQLITE_OK or stmt == null) return error.PrepareFailed;
            defer {
                const start = profile.begin();
                _ = c.sqlite3_finalize(stmt.?);
                profile.end(.stmt_finalize, start);
            }
            t = profile.begin();
            const bound = c.sqlite3_bind_int64(stmt.?, 1, 1);
            profile.end(.bind, t);
            if (bound != c.SQLITE_OK) return error.BindFailed;
            t = profile.begin();
            const stepped = c.sqlite3_step(stmt.?);
            profile.end(.step, t);
            if (stepped != c.SQLITE_ROW) return error.StepFailed;
            t = profile.begin();
            for (0..3) |i| if (c.sqlite3_column_type(stmt.?, @intCast(i)) == c.SQLITE_NULL) return error.InvalidType;
            const text = c.sqlite3_column_text(stmt.?, 1);
            const length = c.sqlite3_column_bytes(stmt.?, 1);
            row = .{ .id = c.sqlite3_column_int64(stmt.?, 0), .name = text[0..@intCast(length)], .weight = c.sqlite3_column_double(stmt.?, 2) };
            profile.end(.row_decode, t);
            // Consume all borrowed bytes before finalize, exactly like B-D.
            self.consume(row);
        } else {
            var stmt = try handle.prepare(sql);
            defer stmt.deinit();
            t = profile.begin();
            try stmt.bindAll(.{@as(i64, 1)});
            profile.end(.bind, t);
            t = profile.begin();
            const stepped = try stmt.step();
            profile.end(.step, t);
            if (stepped != .row) return error.MissingRow;
            t = profile.begin();
            row = if (self.kind >= 'D') try stmt.readRow(Row) else blk: {
                for (0..3) |i| if (try stmt.columnIsNull(i)) return error.InvalidType;
                break :blk .{ .id = try stmt.columnInt(0), .name = try stmt.columnText(1), .weight = try stmt.columnFloat(2) };
            };
            profile.end(.row_decode, t);
            if (self.kind >= 'E') {
                t = profile.begin();
                row.name = try arena.dupe(u8, row.name);
                profile.end(.row_copy, t);
            }
            self.consume(row);
        }
        // F serializes copied row AFTER finalize, while retaining the lease as
        // this microbenchmark's explicit scope. HTTP releases before serialize.
        if (self.kind == 'F') {
            t = profile.begin();
            var writer: std.Io.Writer.Allocating = .init(arena);
            try @import("json.zig").stringify(row, &writer.writer);
            if (!std.mem.eql(u8, writer.written(), "{\"id\":1,\"name\":\"alpha\",\"weight\":1.5}")) return error.JsonMismatch;
            std.mem.doNotOptimizeAway(writer.written());
            profile.end(.json_serialize, t);
        }
    }
    fn consume(self: *Work, row: Row) void {
        std.mem.doNotOptimizeAway(row);
        self.checksum +%= @as(u64, @intCast(row.id)) + @as(u64, @intFromFloat(row.weight * 10));
        for (row.name) |byte| self.checksum +%= byte;
    }
    fn run(self: *Work) void {
        const allocator = if (db_diagnostics) profile.allocator() else std.heap.smp_allocator;
        var arena: std.heap.ArenaAllocator = .init(allocator);
        defer arena.deinit();
        // Warm allocator and SQLite instruction/data cache before admission.
        for (0..100) |_| {
            self.operation(arena.allocator()) catch {
                self.errors += 1;
            };
            _ = arena.reset(.retain_capacity);
        }
        profile.counts = .{ .live = profile.counts.live, .peak = profile.counts.live };
        _ = self.shared.ready.fetchAdd(1, .release);
        while (!self.shared.go.load(.acquire)) std.atomic.spinLoopHint();
        for (self.latencies) |*latency| {
            const start = clock.monotonicNs();
            self.operation(arena.allocator()) catch {
                self.errors += 1;
            };
            _ = arena.reset(.retain_capacity);
            latency.* = clock.elapsedNs(start);
        }
        self.counts = profile.counts;
    }
};
fn number(name: []const u8, default: usize) !usize {
    const value = @import("env.zig").get(std.heap.smp_allocator, name) orelse return default;
    defer std.heap.smp_allocator.free(value);
    return std.fmt.parseInt(usize, value, 10);
}
pub fn main() !void {
    const kind_num = try number("DB_CASE", 0);
    if (kind_num > 5) return error.InvalidCase;
    const kind: u8 = @intCast('A' + kind_num);
    const threads_count = try number("DB_THREADS", 1);
    const operations = try number("DB_OPS", 20_000);
    if (threads_count == 0 or threads_count > 128 or operations == 0) return error.InvalidSize;
    const allocator = if (db_diagnostics) profile.allocator() else std.heap.smp_allocator;
    var handles: [8]db.Db = undefined;
    var opened: usize = 0;
    errdefer for (handles[0..opened]) |handle| handle.close();
    for (&handles) |*handle| {
        handle.* = try sqlite.open(allocator, ":memory:");
        opened += 1;
        try handle.exec(schema);
    }
    var pool = try Pool.init(allocator, &handles);
    opened = 0;
    defer pool.deinit();
    var gate: Gate = .{ .mu = sync.Mutex.init(), .cond = sync.Condition.init() };
    defer gate.mu.deinit();
    defer gate.cond.deinit();
    var shared: Shared = .{ .pool = &pool, .gate = &gate, .handles = &handles };
    const workers = try std.heap.smp_allocator.alloc(Work, threads_count);
    defer std.heap.smp_allocator.free(workers);
    const threads = try std.heap.smp_allocator.alloc(std.Thread, threads_count);
    defer std.heap.smp_allocator.free(threads);
    const latencies = try std.heap.smp_allocator.alloc(u64, operations * threads_count);
    defer std.heap.smp_allocator.free(latencies);
    var started: usize = 0;
    defer {
        shared.go.store(true, .release);
        for (threads[0..started]) |thread| thread.join();
    }
    for (workers, threads, 0..) |*worker, *thread, i| {
        worker.* = .{ .shared = &shared, .kind = kind, .latencies = latencies[i * operations ..][0..operations] };
        thread.* = try std.Thread.spawn(.{}, Work.run, .{worker});
        started += 1;
    }
    while (shared.ready.load(.acquire) != threads_count) std.atomic.spinLoopHint();
    const beginning = clock.monotonicNs();
    shared.go.store(true, .release);
    for (threads) |thread| thread.join();
    started = 0;
    const elapsed = clock.elapsedNs(beginning);
    std.mem.sort(u64, latencies, {}, std.sort.asc(u64));
    var totals: profile.Counts = .{};
    var errors: usize = 0;
    var checksum: u64 = 0;
    for (workers) |worker| {
        errors += worker.errors;
        checksum +%= worker.checksum;
        for (0..10) |i| {
            totals.ns[i] += worker.counts.ns[i];
            totals.calls[i] += worker.counts.calls[i];
        }
        totals.allocations += worker.counts.allocations;
        totals.frees += worker.counts.frees;
        totals.bytes += worker.counts.bytes;
        totals.peak += worker.counts.peak;
    }
    std.debug.print("DB_MICRO {{\"case\":\"{c}\",\"diagnostics\":{},\"threads\":{d},\"operations\":{d},\"elapsed_ns\":{d},\"p50_ns\":{d},\"p95_ns\":{d},\"p99_ns\":{d},\"errors\":{d},\"checksum\":{d},\"allocations\":{d},\"frees\":{d},\"bytes\":{d},\"peak_sum_bytes\":{d},\"stage_ns\":{any},\"stage_calls\":{any}}}\n", .{ kind, db_diagnostics, threads_count, latencies.len, elapsed, latencies[latencies.len / 2], latencies[latencies.len * 95 / 100], latencies[latencies.len * 99 / 100], errors, checksum, totals.allocations, totals.frees, totals.bytes, totals.peak, totals.ns, totals.calls });
    if (errors != 0) return error.BenchmarkErrors;
}
