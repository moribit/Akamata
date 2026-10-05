// Static transport boundary. The standard Reader/Writer are the existing
// streaming interface, not a new transport vtable or allocation.
const std = @import("std");
const Io = std.Io;
const net = Io.net;
const clock = @import("../observability/clock.zig");
pub fn Transport(comptime Readiness: type) type {
    return struct {
        const Self = @This();
        readiness: Readiness,
        io: Io,
        stream: net.Stream,
        shutdown: *std.atomic.Value(bool),
        reader_buf: [4096]u8 = undefined,
        writer_buf: [4096]u8 = undefined,
        reader_state: ?net.Stream.Reader = null,
        writer_state: ?net.Stream.Writer = null,

        pub fn init(io: Io, stream: net.Stream, shutdown: *std.atomic.Value(bool)) !Self {
            return .{ .io = io, .stream = stream, .shutdown = shutdown, .readiness = try Readiness.init(stream.socket.handle) };
        }
        pub fn read(self: *Self, vec: [][]u8, timeout_ms: u32, shutdown_if_idle: bool) !usize {
            if (self.reader_state == null) self.reader_state = self.stream.reader(self.io, &self.reader_buf);
            const reader = &self.reader_state.?.interface;
            if (timeout_ms == 0) return error.Timeout;
            // std.Io.Reader can retain bytes from an earlier read. Read those before
            // waiting for new kernel readiness (pipelining/partial next request).
            if (reader.buffered().len == 0) {
                const started = clock.monotonicNs();
                while (true) {
                    try self.io.checkCancel();
                    if (shutdown_if_idle and self.shutdown.load(.acquire)) return error.EndOfStream;
                    const elapsed = clock.elapsedNs(started) / std.time.ns_per_ms;
                    if (elapsed >= timeout_ms) return error.Timeout;
                    const remaining: u32 = @intCast(timeout_ms - elapsed);
                    // The raw readiness call is not an Io cancellation point.
                    // Bound it so the experimental Group scope can observe
                    // cancellation too, without canceling in-flight HTTP on
                    // an ordinary graceful shutdown flag.
                    const slice = @min(remaining, 100);
                    if (try self.readiness.wait(self.stream.socket.handle, slice)) break;
                }
            }
            const n = reader.readVec(vec) catch {
                if (self.reader_state.?.err) |err| if (err == error.Canceled) return error.Canceled;
                return error.EndOfStream;
            };
            if (n == 0) return error.EndOfStream;
            return n;
        }
        pub fn writer(self: *Self) *Io.Writer {
            if (self.writer_state == null) self.writer_state = self.stream.writer(self.io, &self.writer_buf);
            return &self.writer_state.?.interface;
        }
        pub fn bufferedInput(self: *Self) []const u8 {
            if (self.reader_state) |*reader| return reader.interface.buffered();
            return "";
        }
        pub fn deinit(self: *Self) void {
            self.readiness.deinit();
        }
        pub fn close(self: *Self) void {
            self.stream.close(self.io);
        }
        pub fn streamPtr(self: *Self) *anyopaque {
            return @ptrCast(&self.stream);
        }
        pub fn ioPtr(self: *Self) *anyopaque {
            return @ptrCast(&self.io);
        }
        pub fn peerIp(self: *Self, arena: std.mem.Allocator) ![]const u8 {
            return formatPeerIp(arena, self.stream.socket.address);
        }
    };
}
fn formatPeerIp(arena: std.mem.Allocator, address: net.IpAddress) ![]const u8 {
    var writer: Io.Writer.Allocating = .init(arena);
    switch (address) {
        .ip4 => |ip| try writer.writer.print("{d}.{d}.{d}.{d}", .{ ip.bytes[0], ip.bytes[1], ip.bytes[2], ip.bytes[3] }),
        .ip6 => |ip| try ip.format(&writer.writer),
    }
    return writer.writer.buffered();
}
