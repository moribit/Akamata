const std = @import("std");
const db_mod = @import("db.zig");
const Metrics = @import("../mw/metrics.zig").Counters;

/// Owns independently opened Db handles. Keep the Pool and its optional Io /
/// metrics owner pointer-stable. Stop new callers before deinit; outstanding
/// leases must be released (including by the thread calling deinit).
pub const Pool = struct {
    gpa: std.mem.Allocator,
    handles: []db_mod.Db,
    slots: []Slot,
    io: std.Io,
    metrics: ?*Metrics,
    mu: std.Io.Mutex = .init,
    changed: std.Io.Condition = .init,
    closed: bool = false,
    active: usize = 0,
    waiters: usize = 0,
    callers: std.atomic.Value(usize) = .init(0),
    const Slot = struct { available: bool = true, generation: u64 = 0 };
    pub const Options = struct { io: ?std.Io = null, metrics: ?*Metrics = null };
    pub const Snapshot = struct { active: usize, idle: usize, waiters: usize, closed: bool };

    pub fn init(gpa: std.mem.Allocator, handles: []const db_mod.Db) !Pool {
        return initWithOptions(gpa, handles, .{});
    }
    /// Ownership transfers only on success. Provided Io must outlive deinit.
    /// The default Threaded Io supports native futex waits without task scheduling.
    pub fn initWithOptions(gpa: std.mem.Allocator, handles: []const db_mod.Db, options: Options) !Pool {
        if (handles.len == 0) return error.EmptyPool;
        const owned = try gpa.dupe(db_mod.Db, handles);
        errdefer gpa.free(owned);
        const slots = try gpa.alloc(Slot, handles.len);
        @memset(slots, .{});
        if (options.metrics) |m| _ = m.db_pool_idle_connections.fetchAdd(@intCast(handles.len), .monotonic);
        return .{ .gpa = gpa, .handles = owned, .slots = slots, .io = options.io orelse std.Io.Threaded.global_single_threaded.io(), .metrics = options.metrics };
    }
    pub fn deadlineAfter(self: *const Pool, milliseconds: u32) std.Io.Clock.Timestamp {
        return .fromNow(self.io, .{ .clock = .awake, .raw = .fromMilliseconds(milliseconds) });
    }
    pub fn acquire(self: *Pool) !Lease {
        return (try self.acquireInner(null, false)).?;
    }
    /// null means exhaustion; a closed pool still returns PoolClosed.
    pub fn tryAcquire(self: *Pool) !?Lease {
        return self.acquireInner(null, true);
    }
    /// Absolute .awake monotonic deadline. Progress/spurious wakeups do not
    /// renew it. Closure wins over expiry; expiry wins over an available slot.
    /// Timed standard Io waits can additionally propagate Canceled.
    pub fn acquireWithDeadline(self: *Pool, deadline: std.Io.Clock.Timestamp) !Lease {
        if (deadline.clock != .awake) return error.InvalidDeadlineClock;
        return (try self.acquireInner(deadline, false)).?;
    }
    fn acquireInner(self: *Pool, deadline: ?std.Io.Clock.Timestamp, nonblocking: bool) !?Lease {
        _ = self.callers.fetchAdd(1, .acq_rel);
        self.mu.lockUncancelable(self.io);
        defer {
            _ = self.callers.fetchSub(1, .acq_rel);
            self.changed.broadcast(self.io);
            self.mu.unlock(self.io);
        }
        var wait_started: ?std.Io.Timestamp = null;
        defer if (wait_started) |start| if (self.metrics) |m| {
            const ns = start.durationTo(.now(self.io, .awake)).toNanoseconds();
            m.recordPoolWait(@intCast(@max(ns, 0)));
        };
        while (true) {
            if (self.closed) return error.PoolClosed;
            if (deadline) |d| if (d.untilNow(self.io).raw.toNanoseconds() >= 0) {
                if (self.metrics) |m| _ = m.db_pool_acquire_timeouts_total.fetchAdd(1, .monotonic);
                return error.Timeout;
            };
            for (self.slots, 0..) |*slot, i| {
                if (slot.available) {
                    slot.available = false;
                    slot.generation +%= 1;
                    self.active += 1;
                    if (self.metrics) |m| {
                        _ = m.db_pool_active_connections.fetchAdd(1, .monotonic);
                        _ = m.db_pool_idle_connections.fetchSub(1, .monotonic);
                    }
                    return .{ .pool = self, .index = i, .generation = slot.generation, .db = self.handles[i] };
                }
            }
            if (nonblocking) return null;
            // std.Io.Condition uses a bounded u16 waiter count. Fail before
            // overflowing its state; no unbounded thread/queue is introduced.
            if (self.waiters >= 65_534) return error.PoolOverloaded;
            if (wait_started == null) wait_started = .now(self.io, .awake);
            self.waiters += 1;
            if (self.metrics) |m| _ = m.db_pool_waiters.fetchAdd(1, .monotonic);
            const result = if (deadline) |d| self.changed.waitTimeout(self.io, &self.mu, .{ .deadline = d }) else blk: {
                self.changed.waitUncancelable(self.io, &self.mu);
                break :blk @as(std.Io.Condition.WaitTimeoutError!void, {});
            };
            self.waiters -= 1;
            if (self.metrics) |m| _ = m.db_pool_waiters.fetchSub(1, .monotonic);
            // Inspect closed/absolute expiry under the same lock after wake.
            result catch |err| switch (err) {
                error.Timeout => {},
                error.Canceled => if (self.closed) return error.PoolClosed else return err,
            };
        }
    }
    /// Idempotent stop admission and wake all waiters; handles stay alive for
    /// borrowers until deinit joins them. No new callers may start at deinit.
    pub fn close(self: *Pool) void {
        self.mu.lockUncancelable(self.io);
        defer self.mu.unlock(self.io);
        if (!self.closed) {
            self.closed = true;
            if (self.metrics) |m| _ = m.db_pool_idle_connections.fetchSub(@intCast(self.handles.len - self.active), .monotonic);
        }
        self.changed.broadcast(self.io);
    }
    pub fn snapshot(self: *Pool) Snapshot {
        self.mu.lockUncancelable(self.io);
        defer self.mu.unlock(self.io);
        return .{ .active = self.active, .idle = if (self.closed) 0 else self.handles.len - self.active, .waiters = self.waiters, .closed = self.closed };
    }
    /// Cooperative join: does not preempt queries or revoke leased handles.
    pub fn deinit(self: *Pool) void {
        self.close();
        self.mu.lockUncancelable(self.io);
        while (self.active != 0 or self.callers.load(.acquire) != 0)
            self.changed.waitUncancelable(self.io, &self.mu);
        self.mu.unlock(self.io);
        for (self.handles) |db| db.close();
        self.gpa.free(self.handles);
        self.gpa.free(self.slots);
    }
    fn release(self: *Pool, index: usize, generation: u64) void {
        self.mu.lockUncancelable(self.io);
        defer self.mu.unlock(self.io);
        const slot = &self.slots[index];
        // A copied/stale lease cannot release a slot subsequently re-leased.
        if (slot.available or slot.generation != generation) return;
        slot.available = true;
        self.active -= 1;
        if (self.metrics) |m| {
            _ = m.db_pool_active_connections.fetchSub(1, .monotonic);
            if (!self.closed) _ = m.db_pool_idle_connections.fetchAdd(1, .monotonic);
        }
        self.changed.broadcast(self.io);
    }
};

/// Linear borrowed resource: do not copy or use after release. Generation
/// checking is defense against double release, not permission to retain Db.
pub const Lease = struct {
    pool: *Pool,
    index: usize,
    generation: u64 = 0,
    db: db_mod.Db,
    released: bool = false,
    pub fn deinit(self: *Lease) void {
        if (self.released) return;
        self.released = true;
        self.pool.release(self.index, self.generation);
    }
};
