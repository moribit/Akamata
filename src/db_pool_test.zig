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
