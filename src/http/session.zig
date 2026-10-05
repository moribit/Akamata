//! Incremental input/lifetime shared by blocking and event-driven drivers.
const std = @import("std");
const parser = @import("parser.zig");
const app_mod = @import("../app.zig");
const clock = @import("../observability/clock.zig");
pub const Parsed = @typeInfo(@typeInfo(@TypeOf(parser.parseRequest)).@"fn".return_type.?).error_union.payload;
pub const Issue = struct { code: u16, kind: []const u8 };
pub const Need = struct { maximum: usize, deadline_ns: u64, timeout_ms: u32, shutdown_if_idle: bool };
pub const Event = union(enum) { input: Need, request: Parsed, issue: Issue };
pub const Session = struct {
    gpa: std.mem.Allocator,
    arena: std.heap.ArenaAllocator,
    input: std.ArrayList(u8) = .empty,
    header_capacity: usize,
    max_buffer: usize,
    request_count: u32 = 0,
    request_start: u64,
    first_read: bool = true,
    body_phase: bool = false,
    pub fn init(gpa: std.mem.Allocator, opts: *const app_mod.ServeOptions) !Session {
        const headers = std.math.add(usize, opts.parse_limits.max_request_bytes, 4) catch return error.InvalidParseLimits;
        const maximum = std.math.add(usize, headers, opts.parse_limits.max_body_bytes) catch return error.InvalidParseLimits;
        var self: Session = .{ .gpa = gpa, .arena = .init(gpa), .header_capacity = headers, .max_buffer = maximum, .request_start = 0 };
        errdefer self.deinit();
        try self.input.ensureTotalCapacity(gpa, @min(headers, 16 * 1024));
        self.request_start = clock.monotonicNs();
        return self;
    }
    pub fn deinit(self: *Session) void {
        self.input.deinit(self.gpa);
        self.arena.deinit();
    }
    pub fn next(self: *Session, opts: *const app_mod.ServeOptions) !Event {
        const measured = @import("../runtime/cost.zig").begin();
        defer measured.end(.parse);
        if (!self.body_phase) {
            if (parser.headersEnd(self.input.items) == null) {
                if (self.input.items.len >= self.header_capacity) return .{ .issue = .{ .code = 431, .kind = "headers_too_large" } };
                return .{ .input = self.need(opts, self.header_capacity) };
            }
            self.body_phase = true;
        }
        _ = self.arena.reset(.retain_capacity);
        const parsed = parser.parseRequest(self.arena.allocator(), self.input.items, opts.parse_limits) catch |err| switch (err) {
            error.Incomplete => {
                if (self.input.items.len >= self.max_buffer) return .{ .issue = .{ .code = 413, .kind = "payload_too_large" } };
                return .{ .input = self.need(opts, self.max_buffer) };
            },
            error.OutOfMemory => return err,
            else => return .{ .issue = switch (err) {
                error.BodyTooLarge => .{ .code = 413, .kind = "payload_too_large" },
                error.HeadersTooLarge => .{ .code = 431, .kind = "headers_too_large" },
                error.UnsupportedTransferEncoding => .{ .code = 501, .kind = "unsupported_transfer_encoding" },
                else => .{ .code = 400, .kind = "bad_request" },
            } },
        };
        @import("../runtime/cost.zig").add(.request, 1);
        return .{ .request = parsed };
    }
    fn need(self: *Session, opts: *const app_mod.ServeOptions, maximum: usize) Need {
        const idle = !self.body_phase and self.first_read and self.request_count > 0;
        const phase = if (self.body_phase) opts.body_read_timeout_ms else if (idle) opts.keep_alive_idle_timeout_ms else opts.header_read_timeout_ms;
        const budget = @min(phase, opts.total_request_timeout_ms);
        const elapsed = clock.elapsedNs(self.request_start) / std.time.ns_per_ms;
        return .{ .maximum = maximum, .deadline_ns = self.request_start +| @as(u64, budget) * std.time.ns_per_ms, .timeout_ms = if (elapsed >= budget) 0 else @intCast(budget - elapsed), .shutdown_if_idle = self.first_read and self.input.items.len == 0 };
    }
    pub fn writable(self: *Session, maximum: usize) ![]u8 {
        const used = self.input.items.len;
        if (self.input.capacity <= used) {
            const next_capacity = @min(maximum, @max(used +| 1, self.input.capacity *| 2));
            if (next_capacity <= used) return error.PayloadTooLarge;
            try self.input.ensureTotalCapacity(self.gpa, next_capacity);
        }
        return self.input.allocatedSlice()[used..@min(self.input.capacity, maximum)];
    }
    pub fn received(self: *Session, n: usize) void {
        self.input.items.len += n;
        self.first_read = false;
    }
    pub fn finish(self: *Session, consumed: usize) void {
        const remaining = self.input.items.len - consumed;
        std.mem.copyForwards(u8, self.input.items[0..remaining], self.input.items[consumed..]);
        self.input.items.len = remaining;
        self.request_count += 1;
        self.request_start = clock.monotonicNs();
        self.first_read = remaining == 0;
        self.body_phase = false;
    }
};

fn failingIncrementalRequest(gpa: std.mem.Allocator) !void {
    const opts: app_mod.ServeOptions = .{ .parse_limits = .{ .max_request_bytes = 256, .max_headers = 8, .max_body_bytes = 32768 } };
    var session = try Session.init(gpa, &opts);
    defer session.deinit();
    const header = "POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: 20000\r\n\r\n";
    var raw: [header.len + 20000]u8 = undefined;
    @memcpy(raw[0..header.len], header);
    @memset(raw[header.len..], 'x');
    var consumed: usize = 0;
    while (true) switch (try session.next(&opts)) {
        .input => |need| {
            const writable_bytes = try session.writable(need.maximum);
            const n = @min(raw.len - consumed, @min(writable_bytes.len, 701));
            @memcpy(writable_bytes[0..n], raw[consumed..][0..n]);
            consumed += n;
            session.received(n);
        },
        .request => |parsed| {
            try std.testing.expectEqual(raw.len, parsed.consumed);
            try std.testing.expectEqualSlices(u8, raw[header.len..], parsed.request.body);
            return;
        },
        .issue => return error.UnexpectedProtocolIssue,
    };
}
test "incremental input growth and parser allocation failures clean up" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, failingIncrementalRequest, .{});
}
