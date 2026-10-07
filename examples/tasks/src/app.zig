//! Borrowed application services. Owners live in the entrypoint, not Context.
const am = @import("akamata");
const std = @import("std");
pub const App = struct {
    pub const application_contract = @import("contract.zig").For(if (am.backend == .native) .native else .workers);
    db: am.db.Db,
    queue: am.queue.Producer,
    events: ?*EventChannel = null,
};

/// Bounded, lossy UI notification channel. Durable delivery belongs to Queue.
/// A snapshot is copied while locked, so eviction cannot invalidate SSE bytes.
pub const EventChannel = struct {
    pub const Snapshot = struct {
        seq: u64 = 0,
        len: usize = 0,
        bytes: [4096]u8 = undefined,
    };
    mutex: am.sync.Mutex,
    next_seq: u64 = 1,
    slots: [64]Snapshot = @splat(.{}),
    pub fn init(_: std.mem.Allocator) EventChannel {
        return .{ .mutex = .init() };
    }
    pub fn deinit(self: *EventChannel) void {
        self.mutex.deinit();
    }
    pub fn publish(self: *EventChannel, bytes: []const u8) !void {
        if (bytes.len > 4096) return error.EventTooLarge;
        self.mutex.lock();
        defer self.mutex.unlock();
        const slot = &self.slots[@intCast(self.next_seq % self.slots.len)];
        slot.seq = self.next_seq;
        slot.len = bytes.len;
        @memcpy(slot.bytes[0..bytes.len], bytes);
        self.next_seq += 1;
    }
    pub fn pollAfter(self: *EventChannel, since: u64) ?Snapshot {
        self.mutex.lock();
        defer self.mutex.unlock();
        if (self.next_seq - 1 <= since) return null;
        return self.slots[@intCast((self.next_seq - 1) % self.slots.len)];
    }
};
