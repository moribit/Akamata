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
        handler: *const fn (Event, Delivery) anyerror!void = noHandler,
        /// Borrowed explicit application owner, never a global service lookup.
        context: ?*anyopaque = null,
        handler_with_context: ?*const fn (*anyopaque, Event, Delivery) anyerror!void = null,

        pub fn validate(self: @This()) !void {
            if ((self.handler != noHandler) == (self.handler_with_context != null)) return error.InvalidConsumer;
            if (self.handler_with_context != null and self.context == null) return error.InvalidConsumer;
        }

        pub fn consumeValue(self: @This(), value: Event, delivery: Delivery) !void {
            try self.validate();
            if (self.handler_with_context) |callback| return callback(self.context.?, value, delivery);
            return self.handler(value, delivery);
        }

        fn noHandler(_: Event, _: Delivery) anyerror!void {
            return error.InvalidConsumer;
        }

        pub fn consume(self: @This(), allocator: std.mem.Allocator, bytes: []const u8, delivery: Delivery) !void {
            var parsed = try events.Descriptor(Event, .{}).decode(allocator, bytes);
            defer parsed.deinit();
            return self.consumeValue(parsed.value, delivery);
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

test "consumer admission rejects missing or ambiguous ownership and borrows explicit context" {
    const Event = struct { id: u64 };
    const Owner = struct {
        total: u64 = 0,
        fn consume(ptr: *anyopaque, event: Event, _: Delivery) !void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.total += event.id;
        }
        fn legacy(_: Event, _: Delivery) !void {}
    };
    const C = Consumer(Event);
    try std.testing.expectError(error.InvalidConsumer, (C{}).validate());
    try std.testing.expectError(error.InvalidConsumer, (C{ .handler_with_context = Owner.consume }).validate());
    var owner: Owner = .{};
    try std.testing.expectError(error.InvalidConsumer, (C{ .handler = Owner.legacy, .context = &owner, .handler_with_context = Owner.consume }).validate());
    const consumer: C = .{ .context = &owner, .handler_with_context = Owner.consume };
    try consumer.consumeValue(.{ .id = 7 }, .{ .event_id = "owned" });
    try std.testing.expectEqual(@as(u64, 7), owner.total);
    try (C{ .handler = Owner.legacy }).consumeValue(.{ .id = 1 }, .{ .event_id = "legacy" });
}
