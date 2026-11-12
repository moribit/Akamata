//! One black-box contract for Threaded, kqueue/epoll, sharded and Group.
//! Case names deliberately match the retired Python suite's coverage ledger.
const std = @import("std");
const builtin = @import("builtin");
const s = @import("support.zig");
pub const w = @import("wire.zig");
pub const Case = enum {
    partial_upgrade_budget_survives_external_broadcast,
    application_execution_capability_is_explicit,
    fragment_control_utf8_and_invalid_upgrade_cleanup,
    application_isolation_with_active_idle_upgrades_and_slow_streams,
    normal_request_and_disconnect,
    large_keep_alive_body_does_not_wait_for_next_request,
    malformed_and_transfer_encoding,
    header_and_body_limits,
    keep_alive_multiple_and_request_limit,
    pipeline_and_buffer_residue,
    partial_request_and_partial_next_header,
    chunked_request,
    idle_timeout,
    trickle_does_not_reset_header_deadline,
    shutdown_with_partial_request,
    header_body_and_total_timeout,
    stream_and_stream_error,
    upgrade_ownership,
    fixed_length_stream_and_truncation,
    peer_and_trusted_proxy,
    upgrade_preserves_coalesced_frame,
    max_connections_overload_and_recovery,
    backpressure_does_not_starve_other_connections,
    graceful_shutdown_and_idle_connections,
    shutdown_drains_inflight_response,
    absolute_write_deadline_slow_reader,
    stream_write_deadline_while_producer_pauses,
    zero_write_budget_permits_no_socket_output,
    upgrade_hub_snapshot_disconnect_ownership,
    forced_drain_slow_writer_and_repeated_signal,
    forced_drain_partial_request,
    forced_drain_upgraded_connection,
    upgraded_writer_forced_drain_and_disconnect,
    handler_and_stream_outlive_grace_without_preemption,
};
pub const Fixture = struct {
    server: w.Server,
    adapter: []const u8,
    pub fn start(h: s.H, binary: []const u8, adapter: []const u8, profile: []const u8, incremental: bool) !Fixture {
        return startLimited(h, binary, adapter, profile, incremental, null);
    }
    pub fn startLimited(h: s.H, binary: []const u8, adapter: []const u8, profile: []const u8, incremental: bool, fd_limit: ?u64) !Fixture {
        const port = try w.freePort();
        const options = [_][]const u8{ binary, adapter, try h.fmt("{d}", .{port}), if (incremental) try h.fmt("incremental-{s}", .{profile}) else profile };
        const argv: []const []const u8 = if (fd_limit) |limit| &.{ h.self, "limit-exec", try h.fmt("{d}", .{limit}), options[0], options[1], options[2], options[3] } else &options;
        var result: Fixture = .{ .adapter = adapter, .server = try w.Server.start(h, argv, null, null, port) };
        errdefer result.server.deinit();
        var ready = false;
        for (0..100) |_| {
            if (try result.server.poll()) {
                std.debug.print("startup: {s}\n", .{try h.read(result.server.log_path)});
                return error.FixtureStartup;
            }
            const c = result.server.connect() catch |err| {
                if (err != error.ConnectionRefused and err != error.Timeout) return err;
                h.sleep(20);
                continue;
            };
            try c.send(try w.request(h, "/hello", true, ""));
            if (!std.mem.eql(u8, profile, "write-zero")) _ = try status(c, 200);
            try c.eof();
            c.close();
            ready = true;
            break;
        }
        try s.check(ready, "fixture startup deadline");
        return result;
    }
    pub fn deinit(f: *Fixture) void {
        f.server.deinit();
    }
};
pub fn status(c: *w.Client, expected: u16) !w.Response {
    const r = try c.response();
    if (r.status != expected) std.debug.print("response: {s}\n{s}\n", .{ r.head, r.body });
    try s.check(r.status == expected, "HTTP status");
    return r;
}
pub fn bytes(c: *w.Client, expected: []const u8) !void {
    try s.eq(try c.take(expected.len), expected);
}
fn hello(server: *w.Server) !*w.Client {
    const c = try server.connect();
    try c.send(try w.request(server.h, "/hello", true, ""));
    try s.eq((try status(c, 200)).body, "hello");
    return c;
}
fn upgraded(server: *w.Server, path: []const u8) !*w.Client {
    const c = try server.connect();
    try c.send(try w.request(server.h, path, false, w.upgrade));
    _ = try status(c, 101);
    return c;
}
fn timed(h: s.H, start: i96, minimum_ms: u64, maximum_ms: u64) !void {
    const elapsed = h.now() - start;
    try s.check(elapsed >= @as(i96, minimum_ms) * std.time.ns_per_ms and elapsed < @as(i96, maximum_ms) * std.time.ns_per_ms, "monotonic contract deadline");
}
const partial = "POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: 5\r\n\r\nhe";

pub fn run(h: s.H, args: []const []const u8) !void {
    if (args.len == 0) return error.MissingFixtureBinary;
    const binary = try h.absolute(args[0]);
    const gate = try h.commandFor(&.{ binary, "disabled", "0", "normal" }, null, null, 5);
    try s.check(s.success(gate.term), gate.stderr);
    const only_group = has(args, "--only-group");
    var adapters: std.ArrayList([]const u8) = .empty;
    if (!only_group) try adapters.appendSlice(h.a, &.{ "threaded", if (builtin.os.tag == .linux) "epoll" else "kqueue" });
    if (has(args, "--group") or only_group) try adapters.append(h.a, "group");
    if (has(args, "--sharded")) try adapters.append(h.a, "sharded");
    var count: usize = 0;
    for (adapters.items) |adapter| {
        for (std.enums.values(Case)) |case| {
            try runCase(h, binary, adapter, false, case);
            count += 1;
        }
    }
    if (!only_group) for (std.enums.values(Case)) |case| {
        try runCase(h, binary, "threaded", true, case);
        count += 1;
    };
    std.debug.print("Transport Contract: {d}/{d} cases passed (34 per adapter/mode)\n", .{ count, count });
}
pub fn has(args: []const []const u8, needle: []const u8) bool {
    for (args) |arg| if (std.mem.eql(u8, arg, needle)) return true;
    return false;
}
pub fn runCase(parent: s.H, binary: []const u8, adapter: []const u8, incremental: bool, case: Case) !void {
    return runCaseDiagnostic(parent, binary, adapter, incremental, case, null);
}
pub const Diagnostic = struct { fixture_log: ?[]const u8 = null, stats: ?[]const u8 = null, snapshot_error: ?[]const u8 = null };
fn snapshot(parent: s.H, f: *Fixture, diagnostic: ?*Diagnostic) void {
    const d = diagnostic orelse return;
    if (f.server.h.read(f.server.log_path)) |log| {
        d.fixture_log = parent.a.dupe(u8, log) catch null;
    } else |_| {}
    const response = blk: {
        const client = f.server.connect() catch |err| break :blk err;
        defer client.close();
        client.send(w.request(f.server.h, "/runtime-stats", true, "") catch |err| break :blk err) catch |err| break :blk err;
        break :blk client.response();
    };
    if (response) |r| {
        d.stats = parent.a.dupe(u8, r.body) catch null;
    } else |err| d.snapshot_error = @errorName(err);
}
pub fn runCaseDiagnostic(parent: s.H, binary: []const u8, adapter: []const u8, incremental: bool, case: Case, diagnostic: ?*Diagnostic) !void {
    const profiles: []const []const u8 = switch (case) {
        .peer_and_trusted_proxy => &.{ "normal", "proxy", "untrusted" },
        .header_body_and_total_timeout => &.{ "normal", "normal", "total" },
        .large_keep_alive_body_does_not_wait_for_next_request => &.{"certify"},
        .max_connections_overload_and_recovery => &.{"overload"},
        .application_isolation_with_active_idle_upgrades_and_slow_streams => &.{"stress"},
        .fragment_control_utf8_and_invalid_upgrade_cleanup, .upgrade_hub_snapshot_disconnect_ownership, .graceful_shutdown_and_idle_connections, .shutdown_drains_inflight_response => &.{"shutdown"},
        .absolute_write_deadline_slow_reader => &.{"write-slot"},
        .stream_write_deadline_while_producer_pauses => &.{"write"},
        .zero_write_budget_permits_no_socket_output => &.{"write-zero"},
        .forced_drain_slow_writer_and_repeated_signal, .forced_drain_partial_request, .forced_drain_upgraded_connection, .upgraded_writer_forced_drain_and_disconnect, .handler_and_stream_outlive_grace_without_preemption => &.{"drain"},
        else => &.{"normal"},
    };
    for (profiles, 0..) |profile, index| {
        var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
        defer arena.deinit();
        var h = parent;
        h.a = arena.allocator();
        var fixture = try Fixture.start(h, binary, adapter, profile, incremental);
        defer fixture.deinit();
        execute(&fixture, case, index) catch |err| {
            snapshot(parent, &fixture, diagnostic);
            std.debug.print("FAIL {s}{s} test_{s} profile={s}: {s}\n{s}\n", .{ adapter, if (incremental) "-incremental" else "", @tagName(case), profile, @errorName(err), try h.read(fixture.server.log_path) });
            return err;
        };
        fixture.server.finish() catch |err| {
            snapshot(parent, &fixture, diagnostic);
            return err;
        };
    }
    std.debug.print("PASS {s}{s} test_{s}\n", .{ adapter, if (incremental) "-incremental" else "", @tagName(case) });
}
fn execute(f: *Fixture, case: Case, index: usize) !void {
    const server = &f.server;
    const h = server.h;
    switch (case) {
        .normal_request_and_disconnect => {
            try (try hello(server)).eof();
            const abandoned = try server.connect();
            try abandoned.send("GET /hello HTTP/1.1\r\nHost:");
            abandoned.close();
            _ = try hello(server);
        },
        .large_keep_alive_body_does_not_wait_for_next_request => {
            const c = try server.connect();
            for (0..3) |_| for ([_]usize{ 16385, 65536, 65537, 131073 }) |size| {
                const body = try h.a.alloc(u8, size);
                @memset(body, 'x');
                try c.send(try h.fmt("POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: {d}\r\n\r\n{s}", .{ size, body }));
                try s.eq((try status(c, 200)).body, body);
            };
            c.close();
        },
        .malformed_and_transfer_encoding, .header_and_body_limits => {
            const rows: []const struct { []const u8, u16 } = if (case == .malformed_and_transfer_encoding) &.{
                .{ "GET / HTTP/2.0\r\nHost: a\r\n\r\n", 400 },
                .{ "POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: 0\r\nContent-Length: 0\r\n\r\n", 400 },
                .{ "POST /echo HTTP/1.1\r\nHost: a\r\nTransfer-Encoding: gzip, chunked\r\n\r\n", 501 },
            } else &.{
                .{ try w.request(h, "/hello", false, "X: " ++ @as([300]u8, @splat('a')) ++ "\r\n"), 431 },
                .{ try w.request(h, "/hello", false, &repeat("X: a\r\n", 9)), 431 },
                .{ "POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: 65\r\n\r\n", 413 },
                .{ "POST /echo HTTP/1.1\r\nHost: a\r\nTransfer-Encoding: chunked\r\n\r\n1000000\r\n", 413 },
            };
            for (rows) |row| {
                const c = try server.connect();
                try c.send(row[0]);
                _ = try status(c, row[1]);
                try c.eof();
            }
        },
        .keep_alive_multiple_and_request_limit => {
            const c = try server.connect();
            for (0..3) |i| {
                try c.send(try w.request(h, "/hello", false, ""));
                const r = try status(c, 200);
                try s.eq(r.body, "hello");
                if (i == 2) try s.contains(r.head, "connection: close");
            }
            try c.eof();
        },
        .pipeline_and_buffer_residue => {
            const c = try server.connect();
            const req = try w.request(h, "/hello", false, "");
            try c.send(try h.fmt("{s}{s}{s}{s}", .{ req, req, req, req }));
            for (0..3) |_| try s.eq((try status(c, 200)).body, "hello");
            try s.check(c.pending.items.len == 0, "request-buffer residue");
            try c.eof();
            const echo = try server.connect();
            try echo.send(try h.fmt("POST /echo HTTP/1.1\r\nHost: a\r\nContent-Length: 3\r\n\r\nabc{s}", .{try w.request(h, "/hello", true, "")}));
            try s.eq((try status(echo, 200)).body, "abc");
            try s.eq((try status(echo, 200)).body, "hello");
            try echo.eof();
        },
        .partial_request_and_partial_next_header => {
            const c = try server.connect();
            try c.send(try h.fmt("{s}POST /echo HTTP", .{try w.request(h, "/hello", false, "")}));
            try s.eq((try status(c, 200)).body, "hello");
            h.sleep(30);
            try c.send("/1.1\r\nHost: a\r\nContent-Length: 5\r\nConnection: close\r\n\r\nhe");
            h.sleep(30);
            try c.send("llo");
            try s.eq((try status(c, 200)).body, "hello");
            try c.eof();
        },
        .chunked_request => {
            const c = try server.connect();
            try c.send("POST /echo HTTP/1.1\r\nHost: a\r\nTransfer-Encoding: chunked\r\nConnection: close\r\n\r\n3\r\nabc\r\n0\r\n\r\n");
            try s.eq((try status(c, 200)).body, "abc");
            try c.eof();
        },
        .idle_timeout => {
            const c = try server.connect();
            try c.send(try w.request(h, "/hello", false, ""));
            _ = try status(c, 200);
            const started = h.now();
            try c.eof();
            try timed(h, started, 0, 1500);
        },
        .trickle_does_not_reset_header_deadline => {
            const c = try server.connect();
            const started = h.now();
            for ("GET /hello HTTP/1.1") |byte| {
                c.send(&.{byte}) catch break;
                h.sleep(60);
            }
            try c.eof();
            try timed(h, started, 0, 900);
        },
        .header_body_and_total_timeout => {
            const c = try server.connect();
            const started = h.now();
            try c.send(if (index == 0) "GET /hello HTTP/1.1\r\nHost:" else partial);
            try c.eof();
            try timed(h, started, 100, 1500);
        },
        .shutdown_with_partial_request, .forced_drain_partial_request => {
            const c = try server.connect();
            try c.send(partial);
            h.sleep(40);
            server.signal(.TERM);
            try c.eof();
            try server.wait(1500);
        },
        .stream_and_stream_error => {
            for ([_]struct { []const u8, []const u8 }{ .{ "/stream", "3\r\none\r\n3\r\ntwo\r\n" }, .{ "/stream-error", "7\r\npartial\r\n" } }) |row| {
                const c = try server.connect();
                try c.send(try w.request(h, row[0], false, ""));
                const raw = try c.collect();
                try s.check(std.mem.startsWith(u8, raw, "HTTP/1.1 200"), "stream status");
                try s.contains(raw, "transfer-encoding: chunked");
                try s.contains(raw, row[1]);
                try s.check(std.mem.endsWith(u8, raw, "0\r\n\r\n"), "stream terminator");
            }
        },
        .upgrade_ownership => {
            const c = try server.connect();
            try c.send(try w.request(h, "/upgrade", false, w.upgrade));
            const raw = try c.collect();
            try s.check(std.mem.startsWith(u8, raw, "HTTP/1.1 101"), "upgrade status");
            try s.contains(raw, "s3pPLMBiTxaQ9kYGzzhZRbK+xOo=");
            try s.contains(raw, "\x81\x08upgraded");
            try s.check(std.mem.count(u8, raw, "HTTP/1.1") == 1, "single response after handoff");
            _ = try hello(server);
        },
        .fixed_length_stream_and_truncation => {
            const c = try server.connect();
            try c.send(try w.request(h, "/fixed", false, ""));
            try s.eq((try status(c, 200)).body, "hello");
            try c.eof();
            const truncated = try server.connect();
            try truncated.send(try w.request(h, "/fixed-short", false, ""));
            const raw = try truncated.collect();
            try s.contains(raw, "content-length: 5");
            try s.check(std.mem.endsWith(u8, raw, "\r\n\r\nhe") and std.mem.count(u8, raw, "HTTP/1.1") == 1, "truncated fixed stream closes without second response");
        },
        .peer_and_trusted_proxy => {
            const c = try server.connect();
            try c.send(try w.request(h, "/ip", true, "X-Forwarded-For: 203.0.113.7\r\n"));
            try s.eq((try status(c, 200)).body, if (index == 1) "203.0.113.7" else "127.0.0.1");
        },
        .upgrade_preserves_coalesced_frame => {
            const c = try server.connect();
            try c.send(try h.fmt("{s}{s}", .{ try w.request(h, "/upgrade-echo", false, w.upgrade), try w.frame(h, 1, "hello", true) }));
            const raw = try c.collect();
            try s.check(std.mem.startsWith(u8, raw, "HTTP/1.1 101"), "coalesced upgrade");
            try s.contains(raw, "\x81\x05hello");
            try s.check(std.mem.count(u8, raw, "HTTP/1.1") == 1, "single upgrade response");
        },
        .max_connections_overload_and_recovery => {
            const first = try admit(server, false);
            _ = try admit(server, false);
            const excess = try server.connect();
            excess.send(try w.request(h, "/hello", false, "")) catch {};
            try excess.eof();
            first.close();
            try (try admit(server, true)).eof();
        },
        .backpressure_does_not_starve_other_connections => {
            const blocked = try server.connect();
            try blocked.receiveBuffer(4096);
            try blocked.send(try w.request(h, "/large", false, ""));
            h.sleep(80);
            _ = try hello(server);
            try blocked.reset();
        },
        .graceful_shutdown_and_idle_connections => {
            const never = try server.connect();
            const idle = try server.connect();
            try idle.send(try w.request(h, "/hello", false, ""));
            _ = try status(idle, 200);
            const started = h.now();
            server.signal(.TERM);
            try server.wait(1500);
            try timed(h, started, 0, 1500);
            try never.eof();
            try idle.eof();
        },
        .shutdown_drains_inflight_response, .handler_and_stream_outlive_grace_without_preemption => {
            const c = try server.connect();
            try c.send(try w.request(h, "/slow", true, ""));
            while (std.mem.indexOf(u8, c.pending.items, "\r\n\r\n") == null) try c.fill();
            server.signal(.TERM);
            const raw = try c.collect();
            if (case == .shutdown_drains_inflight_response) try s.contains(raw, "completed") else {
                try s.check(std.mem.indexOf(u8, raw, "completed") == null and std.mem.count(u8, raw, "HTTP/1.1") == 1, "expired drain cannot send a second response/body");
            }
            try server.wait(1500);
        },
        .absolute_write_deadline_slow_reader => {
            const c = try server.connect();
            try c.receiveBuffer(4096);
            try c.send(try w.request(h, "/large", false, ""));
            const started = h.now();
            var buffer: [4096]u8 = undefined;
            for (0..7) |_| {
                try s.check(try c.recv(&buffer) != 0, "slow reader progress");
                h.sleep(60);
            }
            _ = try hello(server);
            try timed(h, started, 0, 2000);
            c.close();
        },
        .stream_write_deadline_while_producer_pauses => {
            const c = try server.connect();
            try c.send(try w.request(h, "/paused-stream", false, ""));
            const started = h.now();
            const raw = try c.collect();
            try timed(h, started, 0, 800);
            try s.check(std.mem.indexOf(u8, raw, "completed") == null and std.mem.startsWith(u8, raw, "HTTP/1.1 200"), "paused stream respects write deadline");
        },
        .zero_write_budget_permits_no_socket_output => {
            for ([_][]const u8{ "/hello", "/stream", "/upgrade" }) |path| {
                const c = try server.connect();
                try c.send(try w.request(h, path, true, if (std.mem.eql(u8, path, "/upgrade")) w.upgrade else ""));
                try c.eof();
            }
        },
        .forced_drain_slow_writer_and_repeated_signal => {
            const c = try server.connect();
            try c.receiveBuffer(4096);
            try c.send(try w.request(h, "/large", false, ""));
            var byte: [1]u8 = undefined;
            try s.check(try c.recv(&byte) == 1, "writer started");
            const started = h.now();
            server.signal(.TERM);
            server.signal(.INT);
            try server.wait(1500);
            try timed(h, started, 0, 1500);
            c.close();
        },
        .forced_drain_upgraded_connection => {
            const c = try upgraded(server, "/upgrade-wait");
            server.signal(.TERM);
            try c.eof();
            try server.wait(1500);
        },
        .upgraded_writer_forced_drain_and_disconnect => {
            const c = try server.connect();
            try c.receiveBuffer(4096);
            try c.send(try w.request(h, "/upgrade-large", false, w.upgrade));
            _ = try status(c, 101);
            server.signal(.TERM);
            try c.reset();
            try server.wait(1500);
        },
        .application_execution_capability_is_explicit => {
            for ([_][]const u8{ "/sync-stream", "/sync-upgrade" }) |path| {
                const is_upgrade = std.mem.endsWith(u8, path, "upgrade");
                const c = try server.connect();
                try c.send(try w.request(h, path, true, if (is_upgrade) w.upgrade else ""));
                const raw = try c.collect();
                const reactor = std.mem.eql(u8, f.adapter, "kqueue") or std.mem.eql(u8, f.adapter, "epoll") or std.mem.eql(u8, f.adapter, "sharded");
                if (reactor) {
                    try s.check(std.mem.startsWith(u8, raw, "HTTP/1.1 501"), "sync execution rejected");
                    try s.contains(raw, "unsupported_application_execution");
                    try s.check(std.mem.count(u8, raw, "HTTP/1.1") == 1, "single unsupported response");
                } else try s.check(std.mem.startsWith(u8, raw, if (is_upgrade) "HTTP/1.1 101" else "HTTP/1.1 200"), "Threaded synchronous execution retained");
            }
        },
        .fragment_control_utf8_and_invalid_upgrade_cleanup => {
            const c = try server.connect();
            try c.send(try h.fmt("{s}{s}{s}{s}", .{ try w.request(h, "/upgrade-echo", false, w.upgrade), try w.frame(h, 1, "\xe2\x82", false), try w.frame(h, 9, "p", true), try w.frame(h, 0, "\xac", true) }));
            _ = try status(c, 101);
            try bytes(c, "\x8a\x01p\x81\x03\xe2\x82\xac");
            try c.eof();
            const empty = try server.connect();
            try empty.send(try h.fmt("{s}{s}", .{ try w.request(h, "/upgrade-echo", false, w.upgrade), try w.frame(h, 1, "", true) }));
            _ = try status(empty, 101);
            try bytes(empty, "\x81\x00");
            try empty.eof();
            for ([_][]const u8{ try w.frame(h, 1, "\xff", true), "\x81\x01x", try w.frame(h, 8, "\x00", true) }) |bad| {
                const invalid = try upgraded(server, "/upgrade-echo");
                try invalid.send(bad);
                try invalid.eof();
                _ = try hello(server);
            }
        },
        .application_isolation_with_active_idle_upgrades_and_slow_streams => {
            for (0..4) |_| _ = try upgraded(server, "/upgrade-wait");
            for (0..4) |_| {
                const c = try server.connect();
                try c.receiveBuffer(4096);
                try c.send(try w.request(h, "/large", false, ""));
                while (std.mem.indexOf(u8, c.pending.items, "\r\n\r\n") == null) try c.fill();
            }
            const active = [_]*w.Client{ try upgraded(server, "/upgrade-room"), try upgraded(server, "/upgrade-room") };
            for (active) |c| try bytes(c, "\x81\x05ready");
            for (0..8) |_| {
                try active[0].send(try w.frame(h, 1, "fair", true));
                for (active) |c| try bytes(c, "\x81\x04fair");
                const normal = try server.connect();
                normal.timeout_ms = 250;
                const started = h.now();
                try normal.send(try w.request(h, "/hello", true, ""));
                _ = try status(normal, 200);
                try timed(h, started, 0, 250);
                h.sleep(20);
            }
        },
        .upgrade_hub_snapshot_disconnect_ownership => {
            const payload = "borrowed-transport";
            const frame = try w.frame(h, 1, payload, true);
            const expected = "\x81\x12" ++ payload;
            for (0..8) |_| {
                const peers = [_]*w.Client{ try upgraded(server, "/upgrade-room"), try upgraded(server, "/upgrade-room"), try upgraded(server, "/upgrade-room") };
                for (peers) |c| try bytes(c, "\x81\x05ready");
                try peers[0].send(frame);
                try bytes(peers[0], expected);
                try peers[1].reset();
                try bytes(peers[2], expected);
                try peers[0].send(frame);
                try bytes(peers[0], expected);
                try bytes(peers[2], expected);
                peers[0].close();
                peers[2].close();
                h.sleep(20);
            }
        },
        .partial_upgrade_budget_survives_external_broadcast => try partialBudget(server),
    }
}
fn admit(server: *w.Server, close: bool) !*w.Client {
    const deadline = server.h.now() + std.time.ns_per_s;
    while (true) {
        const c = try server.connect();
        const outcome = blk: {
            c.send(try w.request(server.h, "/hello", close, "")) catch break :blk false;
            const r = c.response() catch break :blk false;
            break :blk r.status == 200;
        };
        if (outcome) return c;
        c.close();
        if (server.h.now() >= deadline) return error.AdmissionDeadline;
        server.h.sleep(10);
    }
}
fn partialBudget(server: *w.Server) !void {
    const h = server.h;
    const target = try upgraded(server, "/upgrade-budget");
    const peer = try upgraded(server, "/upgrade-live");
    try bytes(target, "\x81\x05ready");
    try bytes(peer, "\x81\x05ready");
    try target.send((try w.frame(h, 1, "neverend", true))[0..8]);
    const Producer = struct {
        client: *w.Client,
        frame: []const u8,
        stop: std.atomic.Value(bool) = .init(false),
        failed: std.atomic.Value(bool) = .init(false),
        fn work(p: *@This()) void {
            while (!p.stop.load(.acquire)) {
                p.client.send(p.frame) catch {
                    p.failed.store(true, .release);
                    return;
                };
                bytes(p.client, "\x81\x04tick") catch {
                    p.failed.store(true, .release);
                    return;
                };
                for (0..12) |_| {
                    if (p.stop.load(.acquire)) return;
                    p.client.h.sleep(10);
                }
            }
        }
    };
    var producer: Producer = .{ .client = peer, .frame = try w.frame(h, 1, "tick", true) };
    peer.timeout_ms = 500;
    const start = h.now();
    const thread = try std.Thread.spawn(.{}, Producer.work, .{&producer});
    var joined = false;
    defer if (!joined) {
        producer.stop.store(true, .release);
        thread.join();
    };
    var buffer: [65536]u8 = undefined;
    while (true) {
        const left = 650 * std.time.ns_per_ms - (h.now() - start);
        try s.check(left > 0, "external output cannot renew partial frame deadline");
        target.timeout_ms = @intCast(@max(1, @divTrunc(left, std.time.ns_per_ms)));
        if (try target.recv(&buffer) == 0) break;
    }
    try timed(h, start, 0, 650);
    producer.stop.store(true, .release);
    thread.join();
    joined = true;
    try s.check(!producer.failed.load(.acquire), "broadcast producer");
}

fn repeat(comptime text: []const u8, comptime count: usize) [text.len * count]u8 {
    var out: [text.len * count]u8 = undefined;
    for (0..count) |i| @memcpy(out[i * text.len ..][0..text.len], text);
    return out;
}
