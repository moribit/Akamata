//! Explicit finite application steps. No socket/transport ownership or task
//! allocation per step. A single erased callback uses the existing endpoint
//! convention; transports and protocol dispatch remain compile-time selected.
const std = @import("std");
const frames = @import("../ws/frame.zig");
const messages = @import("../ws/message_state.zig");
pub const output_capacity = 8192;
pub const CloseReason = enum { completed, disconnected, timeout, shutdown, application_error };
/// Borrow valid until the closed callback returns. Application registries must
/// unregister/join senders during closed before the connection arena is freed.
pub const Resumer = struct {
    pending: *std.atomic.Value(bool),
    context: ?*anyopaque = null,
    token: u64 = 0,
    notify: ?*const fn (*anyopaque, u64) void = null,
    pub fn wake(self: Resumer) void {
        self.pending.store(true, .release);
        if (self.notify) |notify| notify(self.context.?, self.token);
    }
};

const TestState = struct {
    closed: usize = 0,
    fn step(self: *TestState, event: Event, out: []u8) !Action {
        return switch (event) {
            .closed => blk: {
                self.closed += 1;
                break :blk .{ .next = .done };
            },
            .opened => .{ .next = .input },
            .produce => .{ .next = .input },
            .message => |message| blk: {
                @memcpy(out[0..message.payload.len], message.payload);
                break :blk .{ .output = .{ .len = message.payload.len, .opcode = message.opcode, .next = .input } };
            },
        };
    }
};
fn allocationFailure(gpa: std.mem.Allocator) !void {
    var state: TestState = .{};
    const definition = Definition.init(TestState, &state, TestState.step, .{ .websocket = .{ .max_message_bytes = 4096 } });
    const bytes = "\x81\x84mask\x19\x04\x00\x1f";
    var session = try Session.init(gpa, definition, bytes);
    defer session.deinit();
    defer session.dispose(.completed);
    try session.step(.{ .opened = session.control() }, 1);
    const event = (try session.consumeInput()).?;
    try session.step(event, 1);
    _ = try session.receiveBuffer();
}
test "incremental frame task allocations roll back and session cleanup is once" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, allocationFailure, .{});
    var state: TestState = .{};
    var session = try Session.init(std.testing.allocator, Definition.init(TestState, &state, TestState.step, .{ .websocket = .{} }), "");
    defer session.deinit();
    session.dispose(.timeout);
    session.dispose(.shutdown);
    try std.testing.expectEqual(@as(usize, 1), state.closed);
}

test "producer error emits the shared chunk terminator and not another response" {
    const Producer = struct {
        fn step(_: *@This(), event: Event, _: []u8) !Action {
            if (event == .closed) return .{ .next = .done };
            return error.ProducerFailed;
        }
    };
    var state: Producer = .{};
    var session = try Session.init(std.testing.allocator, Definition.init(Producer, &state, Producer.step, .{ .stream = .{} }), "");
    defer session.deinit();
    defer session.dispose(.completed);
    try session.step(.produce, 1);
    try std.testing.expectEqualStrings("0\r\n\r\n", session.wire[0..session.wire_len]);
    try std.testing.expectEqual(CloseReason.application_error, session.closing_reason);
}

test "protocol work quantum yields after bounded fragmented input progress" {
    var state: TestState = .{};
    var session = try Session.init(std.testing.allocator, Definition.init(TestState, &state, TestState.step, .{ .websocket = .{ .max_message_bytes = 4096 } }), "");
    defer session.deinit();
    defer session.dispose(.completed);
    try session.input.appendSlice(std.testing.allocator, "\x01\x80mask");
    for (0..128) |_| try session.input.appendSlice(std.testing.allocator, "\x00\x80mask");
    try std.testing.expect((try session.consumeInput()) == null);
    try std.testing.expect(session.protocol_yielded);
    try std.testing.expectEqual(@as(usize, 65 * 6), session.input.items.len);
}
pub const Event = union(enum) { opened: Resumer, produce, message: messages.Message, closed: CloseReason };
pub const Next = union(enum) { input, produce, after_ms: u32, wait, done };
pub const Emission = struct {
    len: usize,
    opcode: frames.Opcode = .binary,
    fin: bool = true,
    next: Next = .produce,
};
pub const Action = union(enum) { output: Emission, next: Next };
pub const Mode = union(enum) {
    stream: struct { content_length: ?u64 = null, content_type: ?[]const u8 = null },
    websocket: struct { max_message_bytes: usize = 64 * 1024, read_timeout_ms: u32 = 60_000 },
};
pub const Definition = struct {
    state: *anyopaque,
    callback: *const fn (*anyopaque, Event, []u8) anyerror!Action,
    mode: Mode,

    /// state must outlive the session (usually allocated in the request arena).
    /// callback must finish one finite step, never await socket I/O. closed is
    /// delivered once on a worker before state/arena destruction; ignore output.
    pub fn init(comptime State: type, state: *State, comptime callback: fn (*State, Event, []u8) anyerror!Action, mode: Mode) Definition {
        return .{ .state = state, .mode = mode, .callback = struct {
            fn invoke(ptr: *anyopaque, event: Event, output: []u8) anyerror!Action {
                return callback(@ptrCast(@alignCast(ptr)), event, output);
            }
        }.invoke };
    }
};

/// Shared lifecycle/framing used by Threaded and multiplexed Reactor.
pub const Session = struct {
    definition: Definition,
    gpa: std.mem.Allocator,
    input: std.ArrayList(u8) = .empty,
    scratch: std.heap.ArenaAllocator,
    message: messages.State,
    outgoing_message: messages.State,
    application_output: [output_capacity]u8 = undefined,
    wire: [output_capacity + 64]u8 = undefined,
    wire_len: usize = 0,
    next: Next = .produce,
    wake_ns: u64 = 0,
    read_deadline_ns: u64 = 0,
    written: u64 = 0,
    disposed: bool = false,
    closing_reason: CloseReason = .completed,
    started: bool = false,
    external_wake: std.atomic.Value(bool) = .init(false),
    resumer: ?Resumer = null,
    protocol_yielded: bool = false,

    pub fn init(gpa: std.mem.Allocator, definition: Definition, read_ahead: []const u8) !Session {
        const maximum = if (definition.mode == .websocket) definition.mode.websocket.max_message_bytes else 0;
        if (definition.mode == .websocket and (maximum > std.math.maxInt(usize) - 14 or read_ahead.len > maximum + 14)) return error.PayloadTooLarge;
        var self: Session = .{ .definition = definition, .gpa = gpa, .scratch = .init(gpa), .message = .{ .max_payload = maximum }, .outgoing_message = .{ .max_payload = maximum } };
        errdefer self.deinit();
        if (definition.mode == .websocket) try self.input.appendSlice(gpa, read_ahead);
        return self;
    }
    pub fn deinit(self: *Session) void {
        self.input.deinit(self.gpa);
        self.message.deinit(self.gpa);
        self.outgoing_message.deinit(self.gpa);
        self.scratch.deinit();
    }
    pub fn dispose(self: *Session, reason: CloseReason) void {
        if (self.disposed) return;
        self.disposed = true;
        _ = self.definition.callback(self.definition.state, .{ .closed = reason }, &.{}) catch {};
    }
    pub fn control(self: *Session) Resumer {
        return self.resumer orelse .{ .pending = &self.external_wake };
    }
    pub fn setNext(self: *Session, next: Next, now: u64) void {
        self.next = next;
        self.wake_ns = if (next == .after_ms) now +| @as(u64, next.after_ms) * std.time.ns_per_ms else 0;
        self.read_deadline_ns = 0;
    }
    /// Worker-owned: one callback, at most one bounded output quantum.
    pub fn step(self: *Session, event: Event, now: u64) !void {
        self.wire_len = 0;
        const action = self.definition.callback(self.definition.state, event, &self.application_output) catch |err| blk: {
            self.closing_reason = .application_error;
            // Match synchronous endStream(): a committed chunked stream ends
            // with the terminator on producer error, never a second response.
            if (self.definition.mode == .stream and (self.definition.mode.stream.content_length == null or self.definition.mode.stream.content_length.? == self.written))
                break :blk Action{ .next = .done };
            return err;
        };
        switch (action) {
            .next => |next| {
                if (next == .input and self.definition.mode != .websocket) return error.InvalidSessionAction;
                self.setNext(next, now);
                if (next == .done) try self.terminate();
            },
            .output => |out| {
                if (out.len > self.application_output.len or (out.len == 0 and self.definition.mode != .websocket)) return error.InvalidSessionOutput;
                const payload = self.application_output[0..out.len];
                if (self.definition.mode == .websocket) {
                    _ = try self.outgoing_message.accept(self.gpa, .{ .opcode = out.opcode, .fin = out.fin, .payload = self.application_output[0..out.len] });
                    if (!out.fin and out.next == .done) return error.InvalidSessionOutput;
                    if (out.opcode == .close and out.next != .done) return error.InvalidSessionAction;
                    self.wire_len = (try frames.encode(&self.wire, out.opcode, out.fin, payload)).len;
                } else if (self.definition.mode.stream.content_length) |limit| {
                    if (out.len > limit -| self.written) return error.ContentLengthExceeded;
                    @memcpy(self.wire[0..out.len], payload);
                    self.wire_len = out.len;
                } else {
                    var writer: std.Io.Writer = .fixed(&self.wire);
                    try writer.print("{x}\r\n", .{out.len});
                    try writer.writeAll(payload);
                    try writer.writeAll("\r\n");
                    self.wire_len = writer.end;
                }
                self.written +|= out.len;
                if (out.next == .input and self.definition.mode != .websocket) return error.InvalidSessionAction;
                // Stream termination is a separate quantum after the last data
                // drains, so a chunk terminator can never overwrite payload.
                if (out.next == .done and self.definition.mode == .stream) return error.InvalidSessionAction;
                self.setNext(out.next, now);
            },
        }
    }
    fn terminate(self: *Session) !void {
        if (self.definition.mode != .stream) return;
        if (self.definition.mode.stream.content_length) |length| {
            if (self.written != length) return error.ContentLengthMismatch;
        } else {
            @memcpy(self.wire[0..5], "0\r\n\r\n");
            self.wire_len = 5;
        }
    }
    /// Event-loop-owned protocol work. A control reply is emitted without an
    /// application callback; message storage remains borrowed until task join.
    pub fn consumeInput(self: *Session) !?Event {
        self.protocol_yielded = false;
        for (0..64) |_| {
            _ = self.scratch.reset(.retain_capacity);
            const decoded = try frames.decodeClient(self.scratch.allocator(), self.input.items, self.message.max_payload) orelse return null;
            const action = try self.message.accept(self.gpa, decoded.frame);
            self.read_deadline_ns = 0;
            const consumed = decoded.consumed;
            const remaining = self.input.items.len - consumed;
            switch (action) {
                .pong => |payload| {
                    self.wire_len = (try frames.encode(&self.wire, .pong, true, payload)).len;
                },
                else => {},
            }
            std.mem.copyForwards(u8, self.input.items[0..remaining], self.input.items[consumed..]);
            self.input.shrinkRetainingCapacity(remaining);
            switch (action) {
                .message => |message| return .{ .message = message },
                .closed => return error.ClosedByPeer,
                .pong => return null,
                .more => {},
            }
        }
        self.protocol_yielded = self.input.items.len != 0;
        return null;
    }
    pub fn receiveBuffer(self: *Session) ![]u8 {
        const limit = self.message.max_payload + 14;
        const n = @min(4096, limit -| self.input.items.len);
        if (n == 0) return error.PayloadTooLarge;
        try self.input.ensureTotalCapacityPrecise(self.gpa, self.input.items.len + n);
        return self.input.unusedCapacitySlice()[0..n];
    }
    pub fn received(self: *Session, n: usize) void {
        self.input.items.len += n;
    }
};
