const std = @import("std");
const frame = @import("frame.zig");
const handshake = @import("handshake.zig");
const res_mod = @import("../http/response.zig");

const Io = std.Io;
const net = std.Io.net;

pub const UpgradeOptions = struct {
    max_message_bytes: usize = 64 * 1024,
    read_buffer_bytes: usize = 8 * 1024,
    read_timeout_ms: u32 = 60_000,
    /// Exact browser Origin allowlist. Empty preserves non-browser clients.
    allowed_origins: []const []const u8 = &.{},
};

pub const Message = struct {
    opcode: frame.Opcode,
    payload: []u8,
};

pub const ReadError = error{
    ClosedByPeer,
    InvalidFrame,
    PayloadTooLarge,
    ReadFailed,
    OutOfMemory,
    UnsupportedReservedBits,
    BufferTooSmall,
    WriteFailed,
    Timeout,
};

/// Single WebSocket connection. Holds an owned read buffer and reuses the
/// underlying TCP stream. Synchronization on the send path is a tiny atomic
/// spinlock — works because the broadcast path takes a snapshot under the
/// hub's own lock and writes are short.
pub const Conn = struct {
    gpa: std.mem.Allocator,
    stream: net.Stream,
    io: Io,
    write_mutex: @import("../sync.zig").Mutex = .{},
    recv_buf: std.ArrayList(u8) = .empty,
    max_payload: usize = 64 * 1024,
    read_timeout_ms: u32 = 60_000,
    closed: std.atomic.Value(bool) = .init(false),
    native_control: ?*@import("../runtime/drain.zig").Node = null,
    write_timeout_ms: u32 = 30_000,
    native_writer: ?*Io.Writer = null,

    fn closeSocket(self: *Conn) void {
        if (self.native_control) |node| node.close() else self.stream.close(self.io);
    }

    pub fn init(gpa: std.mem.Allocator, stream: net.Stream, io: Io, max_payload: usize) Conn {
        return .{
            .gpa = gpa,
            .stream = stream,
            .io = io,
            .max_payload = max_payload,
            .write_mutex = @import("../sync.zig").Mutex.init(),
        };
    }

    pub fn deinit(self: *Conn) void {
        self.lockWrite();
        self.recv_buf.deinit(self.gpa);
        if (!self.closed.swap(true, .seq_cst)) {
            self.closeSocket();
        }
        self.unlockWrite();
        self.write_mutex.deinit();
    }

    pub fn isClosed(self: *Conn) bool {
        return self.closed.load(.seq_cst);
    }

    fn lockWrite(self: *Conn) void {
        self.write_mutex.lock();
    }
    fn unlockWrite(self: *Conn) void {
        self.write_mutex.unlock();
    }

    pub fn sendText(self: *Conn, payload: []const u8) !void {
        return self.send(.text, payload);
    }

    pub fn sendBinary(self: *Conn, payload: []const u8) !void {
        return self.send(.binary, payload);
    }

    pub fn close(self: *Conn, code: u16, reason: []const u8) void {
        var buf: [128]u8 = undefined;
        const blen = @min(reason.len, buf.len - 2);
        std.mem.writeInt(u16, buf[0..2], code, .big);
        @memcpy(buf[2 .. 2 + blen], reason[0..blen]);
        self.send(.close, buf[0 .. 2 + blen]) catch {};
        self.lockWrite();
        defer self.unlockWrite();
        if (!self.closed.swap(true, .seq_cst)) self.closeSocket();
    }

    fn send(self: *Conn, op: frame.Opcode, payload: []const u8) !void {
        if (self.closed.load(.seq_cst)) return ReadError.ClosedByPeer;
        var h_buf: [14]u8 = undefined;
        var pos: usize = 0;
        h_buf[0] = 0x80 | @as(u8, @backingInt(op));
        pos = 1;
        if (payload.len < 126) {
            h_buf[1] = @intCast(payload.len);
            pos = 2;
        } else if (payload.len <= 0xFFFF) {
            h_buf[1] = 126;
            std.mem.writeInt(u16, h_buf[2..4], @intCast(payload.len), .big);
            pos = 4;
        } else {
            h_buf[1] = 127;
            std.mem.writeInt(u64, h_buf[2..10], @intCast(payload.len), .big);
            pos = 10;
        }

        self.lockWrite();
        defer self.unlockWrite();
        if (self.closed.load(.seq_cst)) return ReadError.ClosedByPeer;
        defer if (self.native_control) |node| node.clearWriteDeadline();
        errdefer if (!self.closed.swap(true, .seq_cst)) self.closeSocket();

        var w_buf: [256]u8 = undefined;
        var sw = @import("../runtime/bounded_writer.zig").Writer.init(self.stream.socket.handle, self.io, &w_buf, self.write_timeout_ms);
        sw.control = self.native_control;
        const w: *Io.Writer = self.native_writer orelse &sw.interface;
        w.writeAll(h_buf[0..pos]) catch return ReadError.WriteFailed;
        if (payload.len > 0) w.writeAll(payload) catch return ReadError.WriteFailed;
        w.flush() catch return ReadError.WriteFailed;
    }

    pub fn readMessage(self: *Conn, arena: std.mem.Allocator) ReadError!Message {
        var assembled: std.ArrayList(u8) = .empty;
        defer assembled.deinit(self.gpa);
        var first_opcode: ?frame.Opcode = null;

        outer: while (true) {
            const fr = (try self.readFrame(arena)) orelse return ReadError.ClosedByPeer;

            if (fr.opcode.isControl()) {
                switch (fr.opcode) {
                    .close => {
                        if (fr.payload.len == 1) return ReadError.InvalidFrame;
                        if (fr.payload.len >= 2 and !validClosePayload(fr.payload)) return ReadError.InvalidFrame;
                        self.lockWrite();
                        defer self.unlockWrite();
                        if (!self.closed.swap(true, .seq_cst)) self.closeSocket();
                        return ReadError.ClosedByPeer;
                    },
                    .ping => {
                        self.send(.pong, fr.payload) catch {};
                        continue :outer;
                    },
                    .pong => continue :outer,
                    else => return ReadError.InvalidFrame,
                }
            }

            if (first_opcode == null) {
                if (fr.opcode == .cont) return ReadError.InvalidFrame;
                first_opcode = fr.opcode;
            } else if (fr.opcode != .cont) return ReadError.InvalidFrame;
            try assembled.appendSlice(self.gpa, fr.payload);
            if (assembled.items.len > self.max_payload) return ReadError.PayloadTooLarge;
            if (fr.fin) {
                if (first_opcode.? == .text and !std.unicode.utf8ValidateSlice(assembled.items)) return ReadError.InvalidFrame;
                const out = try arena.alloc(u8, assembled.items.len);
                @memcpy(out, assembled.items);
                return .{ .opcode = first_opcode.?, .payload = out };
            }
        }
    }

    fn readFrame(self: *Conn, arena: std.mem.Allocator) ReadError!?frame.Frame {
        const clock = @import("../observability/clock.zig");
        const started = clock.monotonicNs();
        while (true) {
            if (self.recv_buf.items.len > 0) {
                const r = frame.decodeClient(arena, self.recv_buf.items, self.max_payload) catch |e| switch (e) {
                    frame.FrameError.Incomplete => null,
                    frame.FrameError.InvalidFrame => return ReadError.InvalidFrame,
                    frame.FrameError.UnsupportedReservedBits => return ReadError.UnsupportedReservedBits,
                    frame.FrameError.PayloadTooLarge => return ReadError.PayloadTooLarge,
                    frame.FrameError.OutOfMemory => return ReadError.OutOfMemory,
                };
                if (r) |dec| {
                    const remaining = self.recv_buf.items.len - dec.consumed;
                    if (remaining > 0) {
                        std.mem.copyForwards(u8, self.recv_buf.items[0..remaining], self.recv_buf.items[dec.consumed..]);
                    }
                    self.recv_buf.shrinkRetainingCapacity(remaining);
                    return dec.frame;
                }
            }
            var tmp: [4096]u8 = undefined;
            self.io.checkCancel() catch return ReadError.ReadFailed;
            const elapsed = clock.elapsedNs(started) / std.time.ns_per_ms;
            if (elapsed >= self.read_timeout_ms) return ReadError.Timeout;
            if (!waitReadable(self.stream.socket.handle, @intCast(@min(self.read_timeout_ms - elapsed, 100)))) continue;
            const raw_n = std.c.recv(self.stream.socket.handle, &tmp, tmp.len, std.c.MSG.DONTWAIT);
            if (raw_n < 0) switch (std.posix.errno(raw_n)) {
                .AGAIN, .INTR => continue,
                else => return ReadError.ReadFailed,
            };
            const n: usize = @intCast(raw_n);
            if (n == 0) return null;
            self.recv_buf.appendSlice(self.gpa, tmp[0..n]) catch return ReadError.OutOfMemory;
            if (self.recv_buf.items.len > self.max_payload + 14) return ReadError.PayloadTooLarge;
        }
    }
};

fn waitReadable(fd: c_int, timeout_ms: u32) bool {
    if (timeout_ms == 0) return true;
    var pfd = [_]std.c.pollfd{.{ .fd = fd, .events = std.c.POLL.IN, .revents = 0 }};
    return std.c.poll(&pfd, 1, @intCast(@min(timeout_ms, std.math.maxInt(c_int)))) > 0;
}

fn validClosePayload(payload: []const u8) bool {
    const code = std.mem.readInt(u16, payload[0..2], .big);
    if (code < 1000 or code >= 5000 or code == 1004 or code == 1005 or code == 1006 or code == 1015) return false;
    return std.unicode.utf8ValidateSlice(payload[2..]);
}

/// Perform a WebSocket upgrade from Context(State). Socket ownership passes
/// to the returned Conn; the shared HTTP driver must not close it again.
pub fn upgrade(comptime CtxT: type, ctx: *CtxT, opts: UpgradeOptions) !Conn {
    const upg = ctx.req.header("upgrade");
    const conn_h = ctx.req.header("connection");
    const ver = ctx.req.header("sec-websocket-version");
    const key = ctx.req.header("sec-websocket-key");

    if (opts.allowed_origins.len > 0) {
        const origin = ctx.req.header("origin") orelse {
            ctx.res.setStatus(403);
            try ctx.res.text("websocket origin rejected");
            return error.ForbiddenOrigin;
        };
        var allowed = false;
        for (opts.allowed_origins) |candidate| {
            if (std.mem.eql(u8, origin, candidate)) {
                allowed = true;
                break;
            }
        }
        if (!allowed) {
            ctx.res.setStatus(403);
            try ctx.res.text("websocket origin rejected");
            return error.ForbiddenOrigin;
        }
    }

    if (!handshake.isUpgradeRequest(upg, conn_h, ver)) {
        ctx.res.setStatus(400);
        try ctx.res.text("invalid websocket upgrade");
        return error.NotUpgrade;
    }
    const client_key = key orelse {
        ctx.res.setStatus(400);
        try ctx.res.text("missing sec-websocket-key");
        return error.MissingKey;
    };

    var accept_buf: [64]u8 = undefined;
    const accept_len = try handshake.acceptKey(client_key, &accept_buf);
    const accept_value = try ctx.arena.dupe(u8, accept_buf[0..accept_len]);

    const stream_ptr: *net.Stream = @ptrCast(@alignCast(ctx.stream_ptr.?));
    const io_ptr: *Io = @ptrCast(@alignCast(ctx.io_ptr.?));
    var conn = Conn.init(ctx.arena, stream_ptr.*, io_ptr.*, opts.max_message_bytes);
    errdefer {
        conn.recv_buf.deinit(ctx.arena);
        conn.write_mutex.deinit();
    }
    // Copy read-ahead before committing the upgrade: allocation failure must
    // leave socket ownership with the HTTP driver.
    try conn.recv_buf.appendSlice(ctx.arena, ctx.res.upgrade_input);
    conn.read_timeout_ms = opts.read_timeout_ms;
    conn.native_control = ctx.res.native_control;
    conn.write_timeout_ms = ctx.res.native_write_timeout_ms;
    conn.native_writer = ctx.res.socket_writer;

    ctx.res.setStatus(101);
    if (conn.native_control) |node| node.synchronous_output.store(true, .release);
    ctx.res.is_upgrade = true;
    ctx.res.keep_alive = false;
    try ctx.res.header("upgrade", "websocket");
    try ctx.res.header("connection", "Upgrade");
    try ctx.res.header("sec-websocket-accept", accept_value);

    // Send the 101 handshake response immediately so the caller can start
    // reading/writing WebSocket frames on the same socket. The HTTP server
    // sees `is_upgrade` and skips its own response write/flush, which would
    // otherwise race with the ws.Conn lifecycle and risk writing to an fd
    // already closed by Conn.deinit.
    var sw_buf: [1024]u8 = undefined;
    var sw = @import("../runtime/bounded_writer.zig").Writer.init(stream_ptr.socket.handle, io_ptr.*, &sw_buf, conn.write_timeout_ms);
    sw.control = conn.native_control;
    const w: *std.Io.Writer = conn.native_writer orelse &sw.interface;
    try ctx.res.writeTo(w);
    try w.flush();
    if (conn.native_control) |node| node.clearWriteDeadline();
    ctx.res.finalized = true;

    return conn;
}
