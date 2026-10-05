//! Incremental WebSocket message semantics, independent of sockets/scheduling.
//! accept() consumes one decoded frame and never waits for I/O. Events borrow
//! their payload until the next accept() or deinit(); consumers must finish it.
const std = @import("std");
const frame = @import("frame.zig");
pub const Message = struct { opcode: frame.Opcode, payload: []u8 };
pub const Event = union(enum) { more, message: Message, pong: []const u8, closed };
pub const Error = error{ InvalidFrame, PayloadTooLarge, OutOfMemory };

pub const State = struct {
    bytes: std.ArrayList(u8) = .empty,
    first_opcode: ?frame.Opcode = null,
    max_payload: usize,

    pub fn deinit(self: *State, gpa: std.mem.Allocator) void {
        self.bytes.deinit(gpa);
    }
    pub fn accept(self: *State, gpa: std.mem.Allocator, fr: frame.Frame) Error!Event {
        if (fr.opcode.isControl()) {
            if (!fr.fin or fr.payload.len > 125) return error.InvalidFrame;
            return switch (fr.opcode) {
                .close => blk: {
                    if (fr.payload.len == 1 or (fr.payload.len >= 2 and !validClosePayload(fr.payload))) return error.InvalidFrame;
                    break :blk .closed;
                },
                .ping => .{ .pong = fr.payload },
                .pong => .more,
                else => error.InvalidFrame,
            };
        }
        if (self.first_opcode == null) {
            if (fr.opcode != .text and fr.opcode != .binary) return error.InvalidFrame;
            self.bytes.clearRetainingCapacity();
            self.first_opcode = fr.opcode;
        } else if (fr.opcode != .cont) return error.InvalidFrame;
        // Enforce the aggregate limit before allocation/copy, not after an
        // oversized fragment has already expanded the buffer.
        if (fr.payload.len > self.max_payload -| self.bytes.items.len) return error.PayloadTooLarge;
        try self.bytes.ensureTotalCapacityPrecise(gpa, self.bytes.items.len + fr.payload.len);
        self.bytes.appendSliceAssumeCapacity(fr.payload);
        if (!fr.fin) return .more;
        const opcode = self.first_opcode.?;
        if (opcode == .text and !std.unicode.utf8ValidateSlice(self.bytes.items)) return error.InvalidFrame;
        self.first_opcode = null;
        return .{ .message = .{ .opcode = opcode, .payload = self.bytes.items } };
    }
};

fn validClosePayload(payload: []const u8) bool {
    const code = std.mem.readInt(u16, payload[0..2], .big);
    if (code < 1000 or code >= 5000 or code == 1004 or code == 1005 or code == 1006 or code == 1015) return false;
    return std.unicode.utf8ValidateSlice(payload[2..]);
}

test "fragmented message survives interleaved control frames and reuses bounded state" {
    var state: State = .{ .max_payload = 8 };
    defer state.deinit(std.testing.allocator);
    var first = [_]u8{ 0xe2, 0x82 };
    var last = [_]u8{0xac};
    var ping = [_]u8{'p'};
    try std.testing.expect((try state.accept(std.testing.allocator, .{ .opcode = .text, .fin = false, .payload = &first })) == .more);
    const control = try state.accept(std.testing.allocator, .{ .opcode = .ping, .fin = true, .payload = &ping });
    try std.testing.expectEqualStrings("p", control.pong);
    const message = try state.accept(std.testing.allocator, .{ .opcode = .cont, .fin = true, .payload = &last });
    try std.testing.expectEqualSlices(u8, &.{ 0xe2, 0x82, 0xac }, message.message.payload);
    const second = try state.accept(std.testing.allocator, .{ .opcode = .binary, .fin = true, .payload = &ping });
    try std.testing.expectEqualStrings("p", second.message.payload);
    try std.testing.expect(state.bytes.capacity <= state.max_payload);
}

test "aggregate limit is checked before allocation and continuation requires an open message" {
    var state: State = .{ .max_payload = 2 };
    defer state.deinit(std.testing.allocator);
    var bytes = [_]u8{ 'a', 'b' };
    try std.testing.expectError(error.InvalidFrame, state.accept(std.testing.allocator, .{ .opcode = .cont, .fin = true, .payload = &bytes }));
    _ = try state.accept(std.testing.allocator, .{ .opcode = .binary, .fin = false, .payload = &bytes });
    const capacity = state.bytes.capacity;
    try std.testing.expectError(error.PayloadTooLarge, state.accept(std.testing.allocator, .{ .opcode = .cont, .fin = true, .payload = &bytes }));
    try std.testing.expectEqual(capacity, state.bytes.capacity);
    try std.testing.expectEqual(@as(usize, 2), state.bytes.items.len);
}

test "invalid UTF8 and close/control frames fail before delivery" {
    var state: State = .{ .max_payload = 16 };
    defer state.deinit(std.testing.allocator);
    var invalid = [_]u8{0xff};
    try std.testing.expectError(error.InvalidFrame, state.accept(std.testing.allocator, .{ .opcode = .text, .fin = true, .payload = &invalid }));
    try std.testing.expectError(error.InvalidFrame, state.accept(std.testing.allocator, .{ .opcode = .close, .fin = true, .payload = &invalid }));
    try std.testing.expectError(error.InvalidFrame, state.accept(std.testing.allocator, .{ .opcode = .ping, .fin = false, .payload = &invalid }));
    var valid_close = [_]u8{ 0x03, 0xe8 };
    try std.testing.expect((try state.accept(std.testing.allocator, .{ .opcode = .close, .fin = true, .payload = &valid_close })) == .closed);
}

fn allocationFailure(gpa: std.mem.Allocator) !void {
    var state: State = .{ .max_payload = 8 };
    defer state.deinit(gpa);
    var bytes = [_]u8{ 'a', 'b', 'c', 'd' };
    _ = try state.accept(gpa, .{ .opcode = .binary, .fin = false, .payload = &bytes });
    _ = try state.accept(gpa, .{ .opcode = .cont, .fin = true, .payload = &bytes });
}
test "incremental message ownership rolls back allocation failure" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, allocationFailure, .{});
}
