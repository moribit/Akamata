// Internal HTTP/1 connection lifecycle. Transport is statically dispatched:
// read(vec, timeout_ms, shutdown_if_idle), writer(), bufferedInput(), close(),
// peerIp(arena), streamPtr(), ioPtr().
// Transport owns readiness/socket details; this module owns HTTP semantics.
const std = @import("std");
const app_mod = @import("../app.zig");
const res_mod = @import("response.zig");
const parser = @import("parser.zig");
const clock = @import("../observability/clock.zig");
const Io = std.Io;

pub fn run(comptime State: type, app: *app_mod.App(State), transport: anytype, opts: *const app_mod.ServeOptions) !void {
    var owns_stream = true;
    defer if (owns_stream) transport.close();
    var arena_state: std.heap.ArenaAllocator = .init(app.gpa);
    defer arena_state.deinit();

    var recv_buf: std.ArrayList(u8) = .empty;
    defer recv_buf.deinit(app.gpa);
    const header_capacity = std.math.add(usize, opts.parse_limits.max_request_bytes, 4) catch return error.InvalidParseLimits;
    const max_buffer = std.math.add(usize, header_capacity, opts.parse_limits.max_body_bytes) catch return error.InvalidParseLimits;
    try recv_buf.ensureTotalCapacity(app.gpa, @min(header_capacity, 16 * 1024));

    var pending_len: usize = 0;
    var request_count: u32 = 0;
    keep_alive: while (true) {
        if (app.shutdown_flag.load(.acquire)) return;
        transport.beginResponse(opts.write_timeout_ms);
        _ = arena_state.reset(.retain_capacity);
        const arena = arena_state.allocator();

        const request_start = clock.monotonicNs();
        var first_header_read = pending_len == 0;
        while (parser.headersEnd(recv_buf.items[0..pending_len]) == null) {
            if (pending_len >= header_capacity) {
                try writeProtocolError(arena, transport, 431, "headers_too_large");
                return;
            }
            try ensureReadCapacity(&recv_buf, app.gpa, pending_len, header_capacity);
            var vec: [1][]u8 = .{recv_buf.allocatedSlice()[pending_len..@min(recv_buf.capacity, header_capacity)]};
            const phase_ms = if (first_header_read and request_count > 0) opts.keep_alive_idle_timeout_ms else opts.header_read_timeout_ms;
            const n = try transport.read(&vec, boundedTimeout(phase_ms, opts.total_request_timeout_ms, request_start), first_header_read and pending_len == 0);
            first_header_read = false;
            pending_len += n;
            recv_buf.items.len = pending_len;
        }

        const parsed = blk: while (true) {
            // Incomplete parsing may allocate headers/chunk decoding. Discard
            // that attempt before retrying; fragmented bodies must not retain
            // one set of parser allocations per recv until the request ends.
            _ = arena_state.reset(.retain_capacity);
            const p = parser.parseRequest(arena, recv_buf.items[0..pending_len], opts.parse_limits) catch |e| switch (e) {
                parser.ParseError.Incomplete => {
                    if (pending_len >= max_buffer) {
                        try writeProtocolError(arena, transport, 413, "payload_too_large");
                        return;
                    }
                    try ensureReadCapacity(&recv_buf, app.gpa, pending_len, max_buffer);
                    var vec: [1][]u8 = .{recv_buf.allocatedSlice()[pending_len..@min(recv_buf.capacity, max_buffer)]};
                    const n = try transport.read(&vec, boundedTimeout(opts.body_read_timeout_ms, opts.total_request_timeout_ms, request_start), false);
                    pending_len += n;
                    recv_buf.items.len = pending_len;
                    continue;
                },
                else => {
                    const mapped: struct { u16, []const u8 } = switch (e) {
                        error.BodyTooLarge => .{ 413, "payload_too_large" },
                        error.HeadersTooLarge => .{ 431, "headers_too_large" },
                        error.UnsupportedTransferEncoding => .{ 501, "unsupported_transfer_encoding" },
                        else => .{ 400, "bad_request" },
                    };
                    try writeProtocolError(arena, transport, mapped[0], mapped[1]);
                    return;
                },
            };
            break :blk p;
        };

        var req_local = parsed.request;
        var res: res_mod.Response = .init(arena);
        res.native_control = transport.controlPtr();
        res.native_write_timeout_ms = opts.write_timeout_ms;
        res.keep_alive = req_local.keep_alive and request_count +| 1 < opts.max_requests_per_connection;
        if (req_local.header("upgrade") != null) {
            const tail = recv_buf.items[parsed.consumed..pending_len];
            const buffered = transport.bufferedInput();
            res.upgrade_input = if (buffered.len == 0) tail else try std.mem.concat(arena, u8, &.{ tail, buffered });
        }

        // Pre-create the socket writer so streaming handlers can grab it
        // via `res.startStream()`.
        const w = transport.writer();
        res.socket_writer = w;

        app.dispatchWithPeer(
            arena,
            &req_local,
            &res,
            transport.streamPtr(),
            transport.ioPtr(),
            try transport.peerIp(arena),
        ) catch |err| {
            // The middleware chain catches handler errors and turns them
            // into 5xx for *buffered* responses. Streaming responses are
            // different: headers + partial chunks have already left the
            // building, so finalize and flush what is valid, then close.
            // Short fixed-length streams remain visibly truncated.
            if (res.streaming != null or res.fixed_streaming != null) {
                std.log.warn("streaming handler returned error mid-stream: {t}", .{err});
                res.endStream() catch {};
                w.flush() catch {};
                return;
            }
            // Buffered: re-raise so the surrounding code path can pick
            // it up (mirrors the original `try` behavior).
            return err;
        };

        if (res.is_upgrade) {
            owns_stream = false;
            return;
        }

        // Streaming handlers already pushed headers/body to `w`. Finalize
        // chunked framing or validate fixed-length framing, then flush.
        if (res.streaming != null or res.fixed_streaming != null) {
            res.endStream() catch return;
            w.flush() catch return;
            return;
        }

        // Serialize into the fixed transport buffer. Response.body remains
        // application-owned; do not allocate a second full wire copy.
        // The connection will close after this response; advertise that rather
        // than inviting clients to reuse a socket at the request/shutdown cap.
        if (app.shutdown_flag.load(.acquire) or request_count +| 1 >= opts.max_requests_per_connection) res.keep_alive = false;
        res.writeTo(w) catch return;
        w.flush() catch return;

        if (!res.keep_alive) return;
        request_count += 1;
        if (request_count >= opts.max_requests_per_connection) return;

        const total = parsed.consumed;
        if (total < pending_len) {
            std.mem.copyForwards(u8, recv_buf.items[0 .. pending_len - total], recv_buf.items[total..pending_len]);
            pending_len -= total;
            recv_buf.items.len = pending_len;
        } else {
            pending_len = 0;
            recv_buf.items.len = 0;
        }
        continue :keep_alive;
    }
}

fn writeProtocolError(arena: std.mem.Allocator, transport: anytype, code: u16, kind: []const u8) !void {
    var res: res_mod.Response = .init(arena);
    res.setStatus(code);
    res.keep_alive = false;
    try res.json(.{ .error_kind = kind });
    const w = transport.writer();
    try res.writeTo(w);
    try w.flush();
}

fn ensureReadCapacity(buf: *std.ArrayList(u8), allocator: std.mem.Allocator, used: usize, maximum: usize) !void {
    if (buf.capacity > used) return;
    const next = @min(maximum, @max(used +| 1, buf.capacity *| 2));
    if (next <= used) return error.PayloadTooLarge;
    try buf.ensureTotalCapacity(allocator, next);
}

fn boundedTimeout(phase_ms: u32, total_ms: u32, started_ns: u64) u32 {
    const elapsed_ms = clock.elapsedNs(started_ns) / std.time.ns_per_ms;
    if (elapsed_ms >= total_ms or elapsed_ms >= phase_ms) return 0;
    return @min(@as(u32, @intCast(phase_ms - elapsed_ms)), @as(u32, @intCast(total_ms - elapsed_ms)));
}
