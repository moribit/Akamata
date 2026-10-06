//! Cloudflare Workers adapters. This module is only exposed for the Workers
//! target, keeping JSPI imports out of native binaries.
const std = @import("std");
const queue = @import("../queue.zig");
const events = @import("../events.zig");
const storage = @import("../storage.zig");
const stream = @import("../stream.zig");
pub const RealtimeOwner = @import("workers_realtime.zig").Owner;

extern "akamata_queue" fn akamata_queue_send(
    binding_ptr: [*]const u8,
    binding_len: usize,
    meta_ptr: [*]const u8,
    meta_len: usize,
    payload_ptr: [*]const u8,
    payload_len: usize,
) i32;

pub const QueueProducer = struct {
    binding: []const u8,

    pub fn producer(self: *QueueProducer) queue.Producer {
        return .{ .ptr = self, .enqueue_fn = enqueue };
    }

    fn enqueue(ptr: *anyopaque, meta: events.EnvelopeMeta, payload: []const u8) queue.Error!void {
        const self: *QueueProducer = @ptrCast(@alignCast(ptr));
        try queue.validateEnvelope(meta, payload);
        var buffer: [1024]u8 = undefined;
        var writer: std.Io.Writer = .fixed(&buffer);
        std.json.Stringify.value(meta, .{}, &writer) catch return error.BackendFailure;
        const encoded = writer.buffered();
        return switch (akamata_queue_send(self.binding.ptr, self.binding.len, encoded.ptr, encoded.len, payload.ptr, payload.len)) {
            0 => {},
            -2 => error.Unavailable,
            -3 => error.PayloadTooLarge,
            else => error.BackendFailure,
        };
    }
};

/// Isolate-owned binding + typed consumer. The application explicitly calls
/// consume from its existing setQueueConsumer dispatch function. This owner
/// installs no global callback and creates no remote queue resource.
pub fn QueueOwner(comptime D: type) type {
    return struct {
        const Self = @This();
        allocator: std.mem.Allocator,
        adapter: QueueProducer,
        consumer: queue.Consumer(D.Payload),

        pub fn create(allocator: std.mem.Allocator, binding: []const u8, consumer: queue.Consumer(D.Payload)) !*Self {
            if (binding.len == 0) return error.InvalidBinding;
            const self = try allocator.create(Self);
            errdefer allocator.destroy(self);
            self.* = .{ .allocator = allocator, .adapter = .{ .binding = try allocator.dupe(u8, binding) }, .consumer = consumer };
            return self;
        }

        pub fn producer(self: *Self) queue.Producer {
            return self.adapter.producer();
        }

        pub fn consume(self: *Self, bytes: []const u8) !void {
            if (bytes.len > 128 * 1024) return error.PayloadTooLarge;
            const HostDelivery = struct { body: events.Envelope(D.Payload), event_id: []const u8, attempt: u16 };
            var parsed = try std.json.parseFromSlice(HostDelivery, self.allocator, bytes, .{ .ignore_unknown_fields = true });
            defer parsed.deinit();
            const value = parsed.value.body;
            if (value.protocol_version != D.version) return error.UnsupportedVersion;
            if (!std.mem.eql(u8, value.event_type, D.name)) return error.UnknownEvent;
            const event_id = value.event_id orelse parsed.value.event_id;
            if (event_id.len == 0 or parsed.value.attempt == 0 or value.max_attempts == 0) return error.InvalidDelivery;
            // max_attempts is application metadata; Workers retry/dead-letter
            // enforcement is configured on the consumer deployment resource.
            try self.consumer.handler(value.payload, .{ .event_id = event_id, .correlation_id = value.correlation_id, .idempotency_key = value.idempotency_key, .attempt = parsed.value.attempt, .max_attempts = value.max_attempts });
        }

        /// Call only after application dispatch has stopped borrowing owner.
        pub fn deinit(self: *Self) void {
            const allocator = self.allocator;
            allocator.free(self.adapter.binding);
            allocator.destroy(self);
        }
    };
}

/// Install a raw queue consumer at application startup. Typed consumers can
/// decode the versioned envelope and delegate to `queue.Consumer(T)`.
pub fn setQueueConsumer(handler: @import("../runtime/workers.zig").QueueFn) void {
    @import("../runtime/workers.zig").setQueueDispatch(handler);
}

extern "akamata_r2" fn akamata_r2_put_begin([*]const u8, usize, [*]const u8, usize, [*]const u8, usize) i32;
extern "akamata_r2" fn akamata_r2_put_write(i32, [*]const u8, usize) i32;
extern "akamata_r2" fn akamata_r2_put_finish(i32) i32;
extern "akamata_r2" fn akamata_r2_put_abort(i32) void;
extern "akamata_r2" fn akamata_r2_get_begin([*]const u8, usize, [*]const u8, usize, u64, u64, i32, [*]const u8, usize) i32;
extern "akamata_r2" fn akamata_r2_get_size(i32) u64;
extern "akamata_r2" fn akamata_r2_get_etag(i32, [*]u8, usize) i32;
extern "akamata_r2" fn akamata_r2_get_content_type(i32, [*]u8, usize) i32;
extern "akamata_r2" fn akamata_r2_get_custom_metadata(i32, [*]u8, usize) i32;
extern "akamata_r2" fn akamata_r2_get_read(i32, [*]u8, usize) i32;
extern "akamata_r2" fn akamata_r2_get_close(i32) void;
extern "akamata_r2" fn akamata_r2_delete([*]const u8, usize, [*]const u8, usize) i32;
extern "akamata_r2" fn akamata_r2_head([*]const u8, usize, [*]const u8, usize) i64;
extern "akamata_r2" fn akamata_r2_list_begin([*]const u8, usize, [*]const u8, usize, [*]const u8, usize, usize) i32;
extern "akamata_r2" fn akamata_r2_list_page_begin([*]const u8, usize, [*]const u8, usize, [*]const u8, usize, usize) i32;
extern "akamata_r2" fn akamata_r2_list_len(i32) usize;
extern "akamata_r2" fn akamata_r2_list_copy(i32, [*]u8, usize) i32;
extern "akamata_r2" fn akamata_r2_list_close(i32) void;

/// R2-backed portable Store. Reads and writes are chunked through JSPI; the
/// complete object is never materialised in the Zig/WASM heap.
pub const R2Store = struct {
    allocator: std.mem.Allocator,
    binding: []const u8,

    pub fn init(allocator: std.mem.Allocator, binding: []const u8) R2Store {
        return .{ .allocator = allocator, .binding = binding };
    }
    pub fn store(self: *R2Store) storage.Store {
        return .{ .ptr = self, .vtable = &vtable };
    }

    const ReadState = struct {
        owner: *R2Store,
        handle: i32,
        metadata_buf: [4352]u8 = undefined,
        etag_len: usize = 0,
        content_type_len: usize = 0,
        custom_len: usize = 0,
        fn read(raw: *anyopaque, out: []u8) stream.Error!usize {
            const self: *ReadState = @ptrCast(@alignCast(raw));
            const n = akamata_r2_get_read(self.handle, out.ptr, out.len);
            if (n < 0) return error.BackendFailure;
            return @intCast(n);
        }
        fn close(raw: *anyopaque) void {
            const self: *ReadState = @ptrCast(@alignCast(raw));
            akamata_r2_get_close(self.handle);
            self.owner.allocator.destroy(self);
        }
    };

    fn put(raw: *anyopaque, key: []const u8, body: stream.Reader, options: storage.PutOptions) storage.Error!storage.Metadata {
        const self: *R2Store = @ptrCast(@alignCast(raw));
        try storage.validateKey(key);
        var option_buffer: [4096]u8 = undefined;
        var writer: std.Io.Writer = .fixed(&option_buffer);
        std.json.Stringify.value(options, .{}, &writer) catch return error.BackendFailure;
        const encoded = writer.buffered();
        const handle = akamata_r2_put_begin(self.binding.ptr, self.binding.len, key.ptr, key.len, encoded.ptr, encoded.len);
        if (handle < 0) return mapCode(handle);
        errdefer akamata_r2_put_abort(handle);
        defer body.close();
        var total: u64 = 0;
        var buffer: [64 * 1024]u8 = undefined;
        while (true) {
            const n = body.read(&buffer) catch return error.BackendFailure;
            if (n == 0) break;
            if (akamata_r2_put_write(handle, buffer[0..n].ptr, n) != 0) return error.BackendFailure;
            total += n;
        }
        const rc = akamata_r2_put_finish(handle);
        if (rc != 0) return mapCode(rc);
        return .{ .size = total, .content_type = options.content_type, .custom_json = options.metadata_json };
    }

    fn get(raw: *anyopaque, key: []const u8, options: storage.GetOptions) storage.Error!storage.Object {
        const self: *R2Store = @ptrCast(@alignCast(raw));
        try storage.validateKey(key);
        const state = self.allocator.create(ReadState) catch return error.Unavailable;
        errdefer self.allocator.destroy(state);
        state.* = .{ .owner = self, .handle = -1 };
        var option_buffer: [2048]u8 = undefined;
        var writer: std.Io.Writer = .fixed(&option_buffer);
        std.json.Stringify.value(options, .{}, &writer) catch return error.BackendFailure;
        const encoded = writer.buffered();
        const range: storage.Range = options.range orelse .{ .offset = 0, .length = null };
        state.handle = akamata_r2_get_begin(self.binding.ptr, self.binding.len, key.ptr, key.len, range.offset, range.length orelse 0, @intFromBool(options.range != null), encoded.ptr, encoded.len);
        if (state.handle < 0) return mapCode(state.handle);
        const etag_len = akamata_r2_get_etag(state.handle, state.metadata_buf[0..128].ptr, 128);
        const content_type_len = akamata_r2_get_content_type(state.handle, state.metadata_buf[128..256].ptr, 128);
        const custom_len = akamata_r2_get_custom_metadata(state.handle, state.metadata_buf[256..].ptr, state.metadata_buf.len - 256);
        if (etag_len < 0 or content_type_len < 0 or custom_len < 0) {
            akamata_r2_get_close(state.handle);
            return error.BackendFailure;
        }
        state.etag_len = @intCast(etag_len);
        state.content_type_len = @intCast(content_type_len);
        state.custom_len = @intCast(custom_len);
        return .{
            .metadata = .{
                .size = akamata_r2_get_size(state.handle),
                .etag = if (state.etag_len == 0) null else state.metadata_buf[0..state.etag_len],
                .content_type = if (state.content_type_len == 0) null else state.metadata_buf[128..][0..state.content_type_len],
                .custom_json = if (state.custom_len == 0) null else state.metadata_buf[256..][0..state.custom_len],
            },
            .body = .{ .ptr = state, .read_fn = ReadState.read, .close_fn = ReadState.close },
        };
    }

    fn delete(raw: *anyopaque, key: []const u8) storage.Error!void {
        const self: *R2Store = @ptrCast(@alignCast(raw));
        try storage.validateKey(key);
        const rc = akamata_r2_delete(self.binding.ptr, self.binding.len, key.ptr, key.len);
        if (rc != 0) return mapCode(rc);
    }
    fn head(raw: *anyopaque, key: []const u8) storage.Error!storage.Metadata {
        const self: *R2Store = @ptrCast(@alignCast(raw));
        try storage.validateKey(key);
        const size = akamata_r2_head(self.binding.ptr, self.binding.len, key.ptr, key.len);
        if (size < 0) return mapCode(@intCast(size));
        return .{ .size = @intCast(size) };
    }
    fn list(raw: *anyopaque, allocator: std.mem.Allocator, prefix: []const u8, cursor: ?[]const u8, limit: usize) storage.Error![]storage.ListEntry {
        const self: *R2Store = @ptrCast(@alignCast(raw));
        if (prefix.len > 1024 or std.mem.indexOf(u8, prefix, "..") != null or std.mem.indexOfScalar(u8, prefix, '\\') != null) return error.PermissionDenied;
        const after = cursor orelse "";
        const handle = akamata_r2_list_begin(self.binding.ptr, self.binding.len, prefix.ptr, prefix.len, after.ptr, after.len, @min(limit, 1000));
        if (handle < 0) return mapCode(handle);
        defer akamata_r2_list_close(handle);
        const bytes = allocator.alloc(u8, akamata_r2_list_len(handle)) catch return error.Unavailable;
        const copied = akamata_r2_list_copy(handle, bytes.ptr, bytes.len);
        if (copied < 0 or copied != bytes.len) return error.BackendFailure;
        const Wire = struct { key: []const u8, size: u64, etag: ?[]const u8 = null };
        const parsed = std.json.parseFromSliceLeaky([]Wire, allocator, bytes, .{ .ignore_unknown_fields = true }) catch return error.BackendFailure;
        const entries = allocator.alloc(storage.ListEntry, parsed.len) catch return error.Unavailable;
        for (parsed, entries) |item, *entry| entry.* = .{ .key = item.key, .metadata = .{ .size = item.size, .etag = item.etag } };
        return entries;
    }
    fn mapCode(code: i32) storage.Error {
        return switch (code) {
            -1 => error.NotFound,
            -3 => error.PreconditionFailed,
            -4 => error.PermissionDenied,
            -2 => error.Unavailable,
            else => error.BackendFailure,
        };
    }
    fn listPage(raw: *anyopaque, allocator: std.mem.Allocator, prefix: []const u8, cursor: ?[]const u8, limit: usize) storage.Error!storage.PageData {
        const self: *R2Store = @ptrCast(@alignCast(raw));
        if (prefix.len > 1024 or std.mem.indexOf(u8, prefix, "..") != null or std.mem.indexOfScalar(u8, prefix, '\\') != null) return error.PermissionDenied;
        const after = cursor orelse "";
        const handle = akamata_r2_list_page_begin(self.binding.ptr, self.binding.len, prefix.ptr, prefix.len, after.ptr, after.len, limit);
        if (handle == -6) return error.InvalidCursor;
        if (handle < 0) return mapCode(handle);
        defer akamata_r2_list_close(handle);
        const bytes = allocator.alloc(u8, akamata_r2_list_len(handle)) catch return error.Unavailable;
        const copied = akamata_r2_list_copy(handle, bytes.ptr, bytes.len);
        if (copied < 0 or copied != bytes.len) return error.BackendFailure;
        const Wire = struct {
            objects: []struct { key: []const u8, size: u64, etag: ?[]const u8 = null, content_type: ?[]const u8 = null, custom_json: ?[]const u8 = null },
            cursor: ?[]const u8 = null,
        };
        const page = std.json.parseFromSliceLeaky(Wire, allocator, bytes, .{ .ignore_unknown_fields = true }) catch return error.BackendFailure;
        const entries = allocator.alloc(storage.ListEntry, page.objects.len) catch return error.Unavailable;
        for (page.objects, entries) |item, *entry| entry.* = .{ .key = item.key, .metadata = .{ .size = item.size, .etag = item.etag, .content_type = item.content_type, .custom_json = item.custom_json } };
        return .{ .entries = entries, .cursor = page.cursor };
    }
    const vtable: storage.Store.VTable = .{ .put = put, .get = get, .delete = delete, .head = head, .list = list, .list_page = listPage };
};
