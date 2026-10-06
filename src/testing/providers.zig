//! Bounded test providers using production facades. No network or global state.
const std = @import("std");
const storage = @import("../storage.zig");
const stream = @import("../stream.zig");
const queue = @import("../queue.zig");
const events = @import("../events.zig");

/// A small deterministic object store for unit tests, not a production cache.
/// Metadata from head/put/list borrows the owner until mutation/deinit.
/// get returns an independent snapshot, valid until body.close().
pub const MemoryStore = struct {
    allocator: std.mem.Allocator,
    entries: [16]Entry = @splat(.{}),
    const Entry = struct {
        used: bool = false,
        key: [1024]u8 = undefined,
        key_len: usize = 0,
        bytes: [4096]u8 = undefined,
        len: usize = 0,
        content_type: [128]u8 = undefined,
        content_type_len: usize = 0,
        etag: [66]u8 = undefined,
        fn metadata(self: *const Entry) storage.Metadata {
            return .{ .size = self.len, .etag = &self.etag, .content_type = self.content_type[0..self.content_type_len] };
        }
    };
    pub fn init(allocator: std.mem.Allocator) MemoryStore {
        return .{ .allocator = allocator };
    }
    pub fn store(self: *MemoryStore) storage.Store {
        return .{ .ptr = self, .vtable = &vtable };
    }
    fn lookup(self: *MemoryStore, key: []const u8) ?*Entry {
        for (&self.entries) |*entry| if (entry.used and std.mem.eql(u8, entry.key[0..entry.key_len], key)) return entry;
        return null;
    }
    fn put(ptr: *anyopaque, key: []const u8, body: stream.Reader, options: storage.PutOptions) storage.Error!storage.Metadata {
        const self: *MemoryStore = @ptrCast(@alignCast(ptr));
        try storage.validateKey(key);
        const old = self.lookup(key);
        if (options.if_match) |etag| if (old == null or !std.mem.eql(u8, &old.?.etag, etag)) return error.PreconditionFailed;
        const destination = old orelse blk: {
            for (&self.entries) |*entry| if (!entry.used) break :blk entry;
            return error.Unavailable;
        };
        const content_type = options.content_type orelse "application/octet-stream";
        if (content_type.len > 128 or std.mem.indexOfAny(u8, content_type, "\r\n\x00") != null) return error.PermissionDenied;
        if (options.metadata_json != null) return error.Unavailable;
        defer body.close();
        var fresh: Entry = .{};
        while (fresh.len < fresh.bytes.len) {
            const n = body.read(fresh.bytes[fresh.len..]) catch return error.BackendFailure;
            if (n == 0) break;
            fresh.len += n;
        }
        var extra: [1]u8 = undefined;
        if ((body.read(&extra) catch return error.BackendFailure) != 0) return error.Unavailable;
        fresh.used = true;
        @memcpy(fresh.key[0..key.len], key);
        fresh.key_len = key.len;
        @memcpy(fresh.content_type[0..content_type.len], content_type);
        fresh.content_type_len = content_type.len;
        var digest: [32]u8 = undefined;
        std.crypto.hash.sha2.Sha256.hash(fresh.bytes[0..fresh.len], &digest, .{});
        fresh.etag[0] = '"';
        @memcpy(fresh.etag[1..65], &std.fmt.bytesToHex(digest, .lower));
        fresh.etag[65] = '"';
        destination.* = fresh;
        return destination.metadata();
    }
    const Snapshot = struct {
        allocator: std.mem.Allocator,
        entry: Entry,
        position: usize,
        end: usize,
        fn read(ptr: *anyopaque, buffer: []u8) stream.Error!usize {
            const self: *Snapshot = @ptrCast(@alignCast(ptr));
            const n = @min(buffer.len, self.end - self.position);
            @memcpy(buffer[0..n], self.entry.bytes[self.position..][0..n]);
            self.position += n;
            return n;
        }
        fn close(ptr: *anyopaque) void {
            const self: *Snapshot = @ptrCast(@alignCast(ptr));
            self.allocator.destroy(self);
        }
    };
    fn get(ptr: *anyopaque, key: []const u8, options: storage.GetOptions) storage.Error!storage.Object {
        const self: *MemoryStore = @ptrCast(@alignCast(ptr));
        try storage.validateKey(key);
        const entry = self.lookup(key) orelse return error.NotFound;
        if (storage.evaluate(&entry.etag, options.if_none_match, options.if_match) != .send) return error.PreconditionFailed;
        var start: usize = 0;
        var end = entry.len;
        if (options.range) |range| {
            if (range.offset >= entry.len) return error.InvalidRange;
            start = @intCast(range.offset);
            end = start + @as(usize, @intCast(@min(range.length orelse entry.len - start, entry.len - start)));
        }
        const snapshot = self.allocator.create(Snapshot) catch return error.Unavailable;
        snapshot.* = .{ .allocator = self.allocator, .entry = entry.*, .position = start, .end = end };
        var metadata = snapshot.entry.metadata();
        metadata.size = end - start;
        return .{ .metadata = metadata, .body = .{ .ptr = snapshot, .read_fn = Snapshot.read, .close_fn = Snapshot.close } };
    }
    fn delete(ptr: *anyopaque, key: []const u8) storage.Error!void {
        const self: *MemoryStore = @ptrCast(@alignCast(ptr));
        try storage.validateKey(key);
        const entry = self.lookup(key) orelse return error.NotFound;
        entry.used = false;
    }
    fn head(ptr: *anyopaque, key: []const u8) storage.Error!storage.Metadata {
        const self: *MemoryStore = @ptrCast(@alignCast(ptr));
        try storage.validateKey(key);
        return (self.lookup(key) orelse return error.NotFound).metadata();
    }
    fn list(ptr: *anyopaque, allocator: std.mem.Allocator, prefix: []const u8, cursor: ?[]const u8, limit: usize) storage.Error![]storage.ListEntry {
        const self: *MemoryStore = @ptrCast(@alignCast(ptr));
        if (prefix.len > 1024 or std.mem.indexOf(u8, prefix, "..") != null or std.mem.indexOfScalar(u8, prefix, '\\') != null) return error.PermissionDenied;
        var results: std.ArrayList(storage.ListEntry) = .empty;
        errdefer {
            for (results.items) |entry| allocator.free(entry.key);
            results.deinit(allocator);
        }
        for (&self.entries) |*entry| {
            const key = entry.key[0..entry.key_len];
            if (!entry.used or !std.mem.startsWith(u8, key, prefix)) continue;
            if (cursor) |after| if (std.mem.order(u8, key, after) != .gt) continue;
            const owned_key = allocator.dupe(u8, key) catch return error.Unavailable;
            results.append(allocator, .{ .key = owned_key, .metadata = entry.metadata() }) catch {
                allocator.free(owned_key);
                return error.Unavailable;
            };
        }
        std.mem.sort(storage.ListEntry, results.items, {}, struct {
            fn less(_: void, a: storage.ListEntry, b: storage.ListEntry) bool {
                return std.mem.order(u8, a.key, b.key) == .lt;
            }
        }.less);
        while (results.items.len > limit) allocator.free(results.pop().?.key);
        return results.toOwnedSlice(allocator) catch return error.Unavailable;
    }
    const vtable: storage.Store.VTable = .{ .put = put, .get = get, .delete = delete, .head = head, .list = list };
};

/// A bounded, owned queue-effect recorder. It does not simulate delivery,
/// retry scheduling or durability; use Consumer for delivery behavior tests.
pub const QueueRecorder = struct {
    allocator: std.mem.Allocator,
    items: std.ArrayList(Item) = .empty,
    limit: usize = 64,
    pub const Item = struct { meta: events.EnvelopeMeta, payload: []const u8 };
    pub fn init(allocator: std.mem.Allocator) QueueRecorder {
        return .{ .allocator = allocator };
    }
    pub fn deinit(self: *QueueRecorder) void {
        for (self.items.items) |item| {
            self.allocator.free(item.meta.event_type);
            if (item.meta.event_id) |v| self.allocator.free(v);
            if (item.meta.correlation_id) |v| self.allocator.free(v);
            if (item.meta.idempotency_key) |v| self.allocator.free(v);
            self.allocator.free(item.payload);
        }
        self.items.deinit(self.allocator);
    }
    pub fn producer(self: *QueueRecorder) queue.Producer {
        return .{ .ptr = self, .enqueue_fn = enqueue };
    }
    fn enqueue(ptr: *anyopaque, meta: events.EnvelopeMeta, bytes: []const u8) queue.Error!void {
        const self: *QueueRecorder = @ptrCast(@alignCast(ptr));
        if (self.items.items.len >= self.limit) return error.Rejected;
        if (bytes.len > 64 * 1024) return error.PayloadTooLarge;
        if (meta.event_type.len > 1024) return error.PayloadTooLarge;
        inline for (.{ meta.event_id, meta.correlation_id, meta.idempotency_key }) |value| if (value) |v| {
            if (v.len > 1024) return error.PayloadTooLarge;
        };
        var copied = meta;
        copied.event_type = self.allocator.dupe(u8, meta.event_type) catch return error.Unavailable;
        errdefer self.allocator.free(copied.event_type);
        copied.event_id = if (meta.event_id) |v| self.allocator.dupe(u8, v) catch return error.Unavailable else null;
        errdefer if (copied.event_id) |v| self.allocator.free(v);
        copied.correlation_id = if (meta.correlation_id) |v| self.allocator.dupe(u8, v) catch return error.Unavailable else null;
        errdefer if (copied.correlation_id) |v| self.allocator.free(v);
        copied.idempotency_key = if (meta.idempotency_key) |v| self.allocator.dupe(u8, v) catch return error.Unavailable else null;
        errdefer if (copied.idempotency_key) |v| self.allocator.free(v);
        const payload = self.allocator.dupe(u8, bytes) catch return error.Unavailable;
        errdefer self.allocator.free(payload);
        self.items.append(self.allocator, .{ .meta = copied, .payload = payload }) catch return error.Unavailable;
    }
};
