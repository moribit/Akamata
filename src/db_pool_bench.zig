//! Opt-in saturation diagnostic, not a CI performance threshold.
const std = @import("std");
const Pool = @import("db/pool.zig").Pool;
const Db = @import("db/db.zig").Db;
const clock = @import("observability/clock.zig");
const Work = struct {
    pool: *Pool,
    waits: [200]u64 = undefined,
    acquired: usize = 0,
    timeouts: usize = 0,
    failed: bool = false,
    fn run(self: *Work) void {
        for (&self.waits) |*wait| {
            const start = clock.monotonicNs();
            var lease = self.pool.acquireWithDeadline(self.pool.deadlineAfter(2)) catch |err| {
                wait.* = clock.elapsedNs(start);
                if (err == error.Timeout) self.timeouts += 1 else self.failed = true;
                continue;
            };
            wait.* = clock.elapsedNs(start);
            self.acquired += 1;
            std.Io.sleep(self.pool.io, .fromMilliseconds(1), .awake) catch {
                self.failed = true;
            };
            lease.deinit();
        }
    }
};
pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();
    for (0..3) |round| {
        var handles: [4]Db = undefined;
        var opened: usize = 0;
        errdefer for (handles[0..opened]) |*db| db.close();
        for (&handles) |*db| {
            db.* = try @import("db/sqlite.zig").open(allocator, ":memory:");
            opened += 1;
        }
        var pool = try Pool.init(allocator, &handles);
        opened = 0;
        defer pool.deinit();
        var work: [16]Work = undefined;
        var threads: [16]std.Thread = undefined;
        var started: usize = 0;
        defer {
            pool.close();
            for (threads[0..started]) |thread| thread.join();
        }
        const beginning = clock.monotonicNs();
        for (&work, &threads) |*worker, *thread| {
            worker.* = .{ .pool = &pool };
            thread.* = try std.Thread.spawn(.{}, Work.run, .{worker});
            started += 1;
        }
        for (threads) |thread| thread.join();
        started = 0;
        const elapsed = clock.elapsedNs(beginning);
        var waits: [3200]u64 = undefined;
        var acquired: usize = 0;
        var timeouts: usize = 0;
        for (work, 0..) |worker, i| {
            if (worker.failed) return error.UnexpectedAcquisitionFailure;
            @memcpy(waits[i * 200 ..][0..200], &worker.waits);
            acquired += worker.acquired;
            timeouts += worker.timeouts;
        }
        std.mem.sort(u64, &waits, {}, std.sort.asc(u64));
        const snapshot = pool.snapshot();
        if (snapshot.active != 0 or snapshot.waiters != 0) return error.LeakedLease;
        std.debug.print("POOL_SATURATION {{\"round\":{d},\"handles\":4,\"workers\":16,\"attempts\":3200,\"deadline_ms\":2,\"hold_ms\":1,\"elapsed_ns\":{d},\"acquired\":{d},\"timeouts\":{d},\"p50_wait_ns\":{d},\"p95_wait_ns\":{d},\"p99_wait_ns\":{d},\"active_final\":0,\"waiters_final\":0}}\n", .{ round + 1, elapsed, acquired, timeouts, waits[1600], waits[3040], waits[3168] });
    }
}
