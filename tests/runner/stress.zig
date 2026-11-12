//! Bounded stress/fault scenarios; this does not enable a production runtime.
const std = @import("std");
const builtin = @import("builtin");
const s = @import("support.zig");
const t = @import("transport.zig");
const e = @import("evaluation.zig");
const resource = @import("resources.zig");
const Kind = enum { idle, churn, partial, slow_reader, stream_latency, upgrade_latency, isolation, exhaustion };
pub fn run(h: s.H, args: []const []const u8) !void {
    if (args.len < 1) return error.MissingFixtureBinary;
    const binary = try h.absolute(args[0]);
    var output: ?[]const u8 = null;
    var quick = false;
    var sharded = false;
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--quick")) quick = true else if (std.mem.eql(u8, args[i], "--sharded")) sharded = true else if (std.mem.eql(u8, args[i], "--output")) {
            i += 1;
            if (i >= args.len) return error.MissingOutput;
            output = args[i];
        } else return error.UnknownOption;
    }
    try resource.raiseFdCeiling(2048);
    var report = try e.Report.init(h, output orelse return error.MissingOutput, binary, "bounded stress/fault evaluation; production gate remains disabled");
    try report.put("quick", quick);
    const adapters: []const []const u8 = if (sharded) &.{ "threaded", if (builtin.os.tag == .linux) "epoll" else "kqueue", "sharded" } else &.{ "threaded", if (builtin.os.tag == .linux) "epoll" else "kqueue" };
    for (adapters) |adapter| for (std.enums.values(Kind)) |kind| {
        const counts: []const usize = if (kind != .idle) &.{0} else if (quick) &.{32} else &.{ 64, 256 };
        for (counts) |count| {
            const name = if (kind == .idle) try h.fmt("idle-{d}", .{count}) else switch (kind) {
                .churn => "burst-churn-pipeline-reset",
                .partial => "partial-read-large-body-stream-upgrade-errors",
                .slow_reader => "slow-reader-load-forced-drain",
                .stream_latency => "stream-latency-4",
                .upgrade_latency => "upgrade-latency-4",
                .isolation => "upgrade-worker-isolation-gate",
                .exhaustion => "accept-fd-exhaustion-recovery",
                .idle => unreachable,
            };
            var entry = try e.Entry.initLimited(h, binary, adapter, name, "stress", if (kind == .exhaustion) 64 else null);
            defer entry.deinit();
            var failure: ?anyerror = null;
            exercise(&entry, kind, count, quick) catch |err| {
                failure = err;
            };
            entry.finish(8000) catch |err| {
                failure = err;
            };
            if (kind == .exhaustion) {
                const log = try h.read(entry.f.server.log_path);
                const observed = std.mem.indexOf(u8, log, "MFILE") != null or std.mem.indexOf(u8, log, "errno 24") != null;
                try entry.put("accept_exhaustion_observed", observed);
                if (!observed) failure = error.AcceptExhaustionNotObserved;
            }
            try entry.save(&report, failure);
            if (failure) |err| return err;
            std.debug.print("{s} {s} ok\n", .{ adapter, name });
        }
    };
    std.debug.print("stress/fault evaluation complete; production gate remains disabled\n", .{});
}
fn hello(server: *t.w.Server) !void {
    const client = try server.connect();
    defer client.close();
    try client.send(try t.w.request(server.h, "/hello", true, ""));
    try s.eq((try t.status(client, 200)).body, "hello");
}
fn shutdown(entry: *e.Entry, repeat: bool) !void {
    const server = &entry.f.server;
    const start = server.h.now();
    server.signal(.TERM);
    if (repeat) server.signal(.TERM);
    try server.wait(3000);
    const ms = e.milliseconds(server.h.now() - start);
    try entry.put("shutdown_ms", ms);
    if (repeat) try s.check(ms < 1500, "forced drain budget");
}
fn exercise(entry: *e.Entry, kind: Kind, count: usize, quick: bool) !void {
    const server = &entry.f.server;
    const h = server.h;
    h.sleep(50);
    const before = try resource.sample(h, server.child.id.?);
    try entry.put("before", before);
    switch (kind) {
        .idle => {
            for (0..count) |_| {
                const client = try server.connect();
                try client.send(try t.w.request(h, "/hello", false, ""));
                _ = try t.status(client, 200);
            }
            const first = try resource.sample(h, server.child.id.?);
            const start = h.now();
            h.sleep(500);
            const loaded = try resource.sample(h, server.child.id.?);
            try entry.put("loaded", loaded);
            try entry.put("idle_cpu_percent", 100 * (loaded.cpu_seconds - first.cpu_seconds) / (e.milliseconds(h.now() - start) / 1000));
            try hello(server);
            try shutdown(entry, false);
        },
        .churn => {
            const concurrency: usize = if (quick) 16 else 64;
            const operations: usize = concurrency * (if (quick) @as(usize, 4) else 16);
            const start = h.now();
            _ = try parallel(h, server.port, .churn, operations, concurrency);
            try entry.put("connections", operations);
            try entry.put("elapsed_ms", e.milliseconds(h.now() - start));
            h.sleep(200);
            const after = try resource.sample(h, server.child.id.?);
            try entry.put("after", after);
            try s.check(after.fds <= before.fds + 1, "churn fd recovery");
            try hello(server);
        },
        .partial => {
            var slow: std.ArrayList(*t.w.Client) = .empty;
            for (0..if (quick) @as(usize, 8) else 32) |_| {
                const c = try server.connect();
                try slow.append(h.a, c);
                try c.send("GET /hello HTTP/1.1\r\nHost:");
            }
            h.sleep(350);
            for (slow.items) |c| {
                try c.eof();
                c.close();
            }
            const body = try h.a.alloc(u8, 512 * 1024);
            @memset(body, 'x');
            const client = try server.connect();
            const head = try h.fmt("POST /echo HTTP/1.1\r\nHost: a\r\nConnection: close\r\nContent-Length: {d}\r\n\r\n", .{body.len});
            for (head) |byte| try client.send(&.{byte});
            var offset: usize = 0;
            while (offset < body.len) {
                const end = @min(body.len, offset + 3071);
                try client.send(body[offset..end]);
                offset = end;
            }
            try s.eq((try client.response()).body, body);
            client.close();
            for ([_][]const u8{ "/stream", "/stream-error", "/fixed", "/fixed-short", "/upgrade" }) |path| {
                const c = try server.connect();
                try c.send(try t.w.request(h, path, true, if (std.mem.eql(u8, path, "/upgrade")) t.w.upgrade else ""));
                try s.check(std.mem.count(u8, try c.collect(), "HTTP/1.1") == 1, "single response on stream/error/upgrade");
                c.close();
            }
            h.sleep(100);
            const after = try resource.sample(h, server.child.id.?);
            try entry.put("after", after);
            try s.check(after.fds <= before.fds + 1, "partial/error fd recovery");
        },
        .slow_reader => {
            for (0..4) |_| {
                const c = try server.connect();
                try c.receiveBuffer(4096);
                try c.send(try t.w.request(h, "/large", false, ""));
            }
            h.sleep(100);
            try entry.put("loaded", try resource.sample(h, server.child.id.?));
            try shutdown(entry, true);
        },
        .stream_latency, .upgrade_latency => {
            const requests: usize = if (quick) 40 else 200;
            const start = h.now();
            const latencies = try parallel(h, server.port, if (kind == .stream_latency) .stream else .upgrade, requests, 4);
            const seconds = e.milliseconds(h.now() - start) / 1000;
            try entry.put("requests", requests);
            try entry.put("throughput", @as(f64, @floatFromInt(requests)) / seconds);
            try entry.put("latency_ms", .{ .@"50" = latencies[requests * 50 / 100], .@"95" = latencies[requests * 95 / 100], .@"99" = latencies[@min(requests - 1, requests * 99 / 100)] });
            const loaded = try resource.sample(h, server.child.id.?);
            try entry.put("loaded", loaded);
            try entry.put("cpu_percent", 100 * (loaded.cpu_seconds - before.cpu_seconds) / seconds);
        },
        .isolation => {
            for (0..4) |_| {
                const c = try server.connect();
                try c.send(try t.w.request(h, "/upgrade-wait", false, t.w.upgrade));
                _ = try t.status(c, 101);
            }
            try entry.put("probe_ms", try e.probe(server));
            try entry.put("unrelated_request_isolated", true);
            try entry.put("loaded", try resource.sample(h, server.child.id.?));
            try shutdown(entry, false);
        },
        .exhaustion => {
            var held: std.ArrayList(*t.w.Client) = .empty;
            for (0..80) |_| {
                const c = try server.connect();
                try held.append(h.a, c);
                c.timeout_ms = 300;
                c.send(try t.w.request(h, "/hello", false, "")) catch break;
                _ = t.status(c, 200) catch break;
            }
            const first = try resource.sample(h, server.child.id.?);
            const start = h.now();
            h.sleep(300);
            const last = try resource.sample(h, server.child.id.?);
            try entry.put("admitted", held.items.len -| 1);
            try entry.put("exhausted_cpu_percent", 100 * (last.cpu_seconds - first.cpu_seconds) / (e.milliseconds(h.now() - start) / 1000));
            for (held.items) |c| c.close();
            h.sleep(500);
            try hello(server);
            h.sleep(100);
            const after = try resource.sample(h, server.child.id.?);
            try entry.put("after", after);
            try s.check(after.fds <= before.fds + 1, "fd exhaustion recovery");
        },
    }
}
const WorkKind = enum { churn, stream, upgrade };
const Work = struct {
    h: s.H,
    port: u16,
    kind: WorkKind,
    next: std.atomic.Value(usize) = .init(0),
    failed: std.atomic.Value(bool) = .init(false),
    latencies: []f64,
    fn worker(work: *Work) void {
        while (true) {
            const index = work.next.fetchAdd(1, .monotonic);
            if (index >= work.latencies.len) return;
            const elapsed = work.exchange() catch |err| {
                std.debug.print("parallel exchange: {s}\n", .{@errorName(err)});
                work.failed.store(true, .release);
                return;
            };
            work.latencies[index] = elapsed;
        }
    }
    // Each worker must keep its measured duration local; no shared scratch.
    fn exchange(work: *Work) !f64 {
        var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
        defer arena.deinit();
        var h = work.h;
        h.a = arena.allocator();
        const start = h.now();
        var c = try t.w.Client.connect(h, work.port);
        defer c.close();
        if (work.kind == .churn) {
            const request = try t.w.request(h, "/hello", false, "");
            try c.send(try h.fmt("{s}{s}{s}", .{ request, request, request }));
            for (0..3) |_| try s.eq((try c.response()).body, "hello");
            try c.reset();
        } else {
            const upgrade = work.kind == .upgrade;
            try c.send(try t.w.request(h, if (upgrade) "/upgrade" else "/stream", true, if (upgrade) t.w.upgrade else ""));
            const raw = try c.collect();
            try s.check(std.mem.count(u8, raw, "HTTP/1.1") == 1, "parallel single HTTP response");
            try s.contains(raw, if (upgrade) "upgraded" else "one");
        }
        return e.milliseconds(h.now() - start);
    }
};
fn parallel(h: s.H, port: u16, kind: WorkKind, count: usize, concurrency: usize) ![]f64 {
    const latencies = try h.a.alloc(f64, count);
    var work: Work = .{ .h = h, .port = port, .kind = kind, .latencies = latencies };
    var threads: std.ArrayList(std.Thread) = .empty;
    try threads.ensureTotalCapacity(h.a, concurrency);
    defer for (threads.items) |thread| thread.join();
    for (0..concurrency) |_| threads.appendAssumeCapacity(try std.Thread.spawn(.{}, Work.worker, .{&work}));
    // Join before inspecting failures and output. Clear after explicit join.
    for (threads.items) |thread| thread.join();
    threads.clearRetainingCapacity();
    try s.check(!work.failed.load(.acquire), "all concurrent exchanges succeeded");
    std.mem.sort(f64, latencies, {}, std.sort.asc(f64));
    return latencies;
}
