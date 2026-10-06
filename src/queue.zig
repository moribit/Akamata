//! Typed at-least-once queue contract shared by native jobs and Workers Queues.
const std = @import("std");
const events = @import("events.zig");

pub const Delivery = struct {
    event_id: []const u8,
    correlation_id: ?[]const u8 = null,
    idempotency_key: ?[]const u8 = null,
    attempt: u16 = 1,
    max_attempts: u16 = 5,
    failure: ?Failure = null,
    pub const Failure = struct { code: []const u8, message: []const u8 };
};

pub const DeadLetterStrategy = union(enum) { discard, retain, queue: []const u8 };
pub const Error = error{ Unavailable, Rejected, PayloadTooLarge, BackendFailure };

/// Portable producer admission limits, independent of backend retry policy.
pub fn validateEnvelope(meta: events.EnvelopeMeta, payload: []const u8) Error!void {
    if (payload.len > 64 * 1024) return error.PayloadTooLarge;
    const id = meta.event_id orelse return error.Rejected;
    if (id.len == 0 or meta.event_type.len == 0 or meta.attempt == 0 or meta.max_attempts == 0) return error.Rejected;
    for ([_]?[]const u8{ id, meta.event_type, meta.correlation_id, meta.idempotency_key }) |value| {
        if (value) |text| if (text.len > 256) return error.PayloadTooLarge;
    }
}

pub const Producer = struct {
    ptr: *anyopaque,
    enqueue_fn: *const fn (*anyopaque, events.EnvelopeMeta, []const u8) Error!void,

    pub fn dispatch(self: Producer, allocator: std.mem.Allocator, comptime Event: type, value: Event, delivery: Delivery) !void {
        const D = events.Descriptor(Event, .{});
        return self.dispatchDescriptor(allocator, D, value, delivery);
    }

    /// Queue and realtime can reuse the same named/versioned event descriptor.
    pub fn dispatchDescriptor(self: Producer, allocator: std.mem.Allocator, comptime D: type, value: D.Payload, delivery: Delivery) !void {
        const bytes = try D.encode(allocator, value);
        defer allocator.free(bytes);
        return self.enqueue_fn(self.ptr, .{
            .protocol_version = D.version,
            .event_type = D.name,
            .event_id = delivery.event_id,
            .correlation_id = delivery.correlation_id,
            .attempt = delivery.attempt,
            .idempotency_key = delivery.idempotency_key,
            .max_attempts = delivery.max_attempts,
        }, bytes);
    }
};

pub fn Consumer(comptime Event: type) type {
    events.validateEventType(Event);
    return struct {
        handler: *const fn (Event, Delivery) anyerror!void,

        pub fn consume(self: @This(), allocator: std.mem.Allocator, bytes: []const u8, delivery: Delivery) !void {
            var parsed = try events.Descriptor(Event, .{}).decode(allocator, bytes);
            defer parsed.deinit();
            return self.handler(parsed.value, delivery);
        }

        /// Validate a named/versioned descriptor before invoking the existing
        /// typed consumer. Retry/dead-letter policy remains backend-owned.
        pub fn consumeEnvelope(self: @This(), allocator: std.mem.Allocator, comptime D: type, meta: events.EnvelopeMeta, bytes: []const u8) !void {
            if (D.Payload != Event) @compileError("queue consumer descriptor payload does not match Event");
            if (meta.protocol_version != D.version) return error.UnsupportedVersion;
            if (!std.mem.eql(u8, meta.event_type, D.name)) return error.UnknownEvent;
            const event_id = meta.event_id orelse return error.InvalidDelivery;
            if (meta.attempt == 0 or meta.max_attempts == 0) return error.InvalidDelivery;
            return self.consume(allocator, bytes, .{
                .event_id = event_id,
                .correlation_id = meta.correlation_id,
                .idempotency_key = meta.idempotency_key,
                .attempt = meta.attempt,
                .max_attempts = meta.max_attempts,
            });
        }
    };
}

test "typed producer preserves delivery metadata" {
    const Created = struct { id: u64 };
    const Sink = struct {
        calls: usize = 0,
        fn enqueue(ptr: *anyopaque, meta: events.EnvelopeMeta, bytes: []const u8) Error!void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.calls += 1;
            if (!std.mem.eql(u8, meta.event_id.?, "evt-1") or bytes.len == 0) return error.BackendFailure;
            if (!std.mem.eql(u8, meta.idempotency_key.?, "record:1") or meta.max_attempts != 5) return error.BackendFailure;
        }
    };
    var sink: Sink = .{};
    const producer: Producer = .{ .ptr = &sink, .enqueue_fn = Sink.enqueue };
    try producer.dispatch(std.testing.allocator, Created, .{ .id = 1 }, .{ .event_id = "evt-1", .idempotency_key = "record:1" });
    try std.testing.expectEqual(@as(usize, 1), sink.calls);
}
