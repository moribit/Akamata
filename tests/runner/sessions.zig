//! Incremental session, race, resource and bounded soak evaluation.
//! These timings validate isolation, not peak request throughput.
const std = @import("std");
const builtin = @import("builtin");
const s = @import("support.zig");
const t = @import("transport.zig");
const e = @import("evaluation.zig");
const resource = @import("resources.zig");
const Options = struct { binary: []const u8, output: []const u8, levels: []usize, adapters: []const []const u8, soak: u32 = 1200, mixed_idle: usize = 100, rounds: usize = 50 };
pub fn run(h: s.H, args: []const []const u8) !void {
    if (args.len < 1) return error.MissingFixtureBinary;
    var options: Options = .{ .binary = try h.absolute(args[0]), .output = "", .levels = &.{}, .adapters = &.{} };
    var levels: std.ArrayList(usize) = .empty;
    var adapters: std.ArrayList([]const u8) = .empty;
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const key = args[i];
        i += 1;
        if (i >= args.len) return error.MissingOptionValue;
        if (std.mem.eql(u8, key, "--idle-levels") or std.mem.eql(u8, key, "--adapters")) {
            const initial = i;
            while (i < args.len and !std.mem.startsWith(u8, args[i], "--")) : (i += 1) {
                if (std.mem.eql(u8, key, "--idle-levels")) {
                    const n = try std.fmt.parseInt(usize, args[i], 10);
                    if (n == 0 or n > 10000) return error.UnsafeIdleCount;
                    try levels.append(h.a, n);
                } else {
                    if (!std.mem.eql(u8, args[i], "threaded") and !std.mem.eql(u8, args[i], "kqueue") and !std.mem.eql(u8, args[i], "epoll") and !std.mem.eql(u8, args[i], "sharded")) return error.InvalidAdapter;
                    try adapters.append(h.a, args[i]);
                }
            }
            if (i == initial) return error.MissingOptionValue;
            i -= 1;
        } else if (std.mem.eql(u8, key, "--output")) options.output = args[i] else if (std.mem.eql(u8, key, "--soak-seconds")) options.soak = try std.fmt.parseInt(u32, args[i], 10) else if (std.mem.eql(u8, key, "--mixed-idle")) options.mixed_idle = try std.fmt.parseInt(usize, args[i], 10) else if (std.mem.eql(u8, key, "--session-rounds")) options.rounds = try std.fmt.parseInt(usize, args[i], 10) else return error.UnknownOption;
    }
    if (options.output.len == 0 or options.soak > 14400 or options.mixed_idle > 5000 or options.rounds < 1 or options.rounds > 1000) return error.UnsafeEvaluationOptions;
    if (levels.items.len == 0) try levels.appendSlice(h.a, &.{ 100, 1000 });
    if (adapters.items.len == 0) try adapters.appendSlice(h.a, &.{ "threaded", if (builtin.os.tag == .linux) "epoll" else "kqueue" });
    options.levels = levels.items;
    options.adapters = adapters.items;
    try resource.raiseFdCeiling(16384);
    const limit = try std.posix.getrlimit(.NOFILE);
    var report = try e.Report.init(h, options.output, options.binary, "incremental session and bounded soak evaluation; not peak throughput or production certification");
    try report.put("source_sha", std.mem.trim(u8, try h.run(&.{ "git", "rev-parse", "HEAD" }, null, h.env), "\r\n"));
    try report.put("working_tree_dirty", (try h.run(&.{ "git", "status", "--porcelain" }, null, h.env)).len != 0);
    try report.put("zig_version", std.mem.trim(u8, try h.run(&.{ h.env.get("ZIG") orelse "zig", "version" }, null, h.env), "\r\n"));
    try report.put("command", args);
    try report.put("rlimit_nofile", .{ limit.cur, limit.max });
    try report.put("close_reason_order", .{ "completed", "disconnected", "timeout", "shutdown", "application_error" });
    try report.put("thread_count_method", if (builtin.os.tag == .linux) "proc-task" else "ps-M-minus-header");
    try report.put("limitations", .{ "Zig test load generator is not a peak throughput benchmark", "allocator counters exclude libc/SQLite and thread stacks", "application callbacks remain cooperatively bounded" });
    var passed = true;
    var long_soak = options.soak >= 1200;
    for (options.adapters) |adapter| {
        const kinds = [_]Kind{ .performance, .fd_races, .shutdown_race, .idle, .mixed };
        for (kinds) |kind| {
            const counts: []const usize = if (kind == .idle) options.levels else &.{0};
            for (counts) |count| {
                if (kind == .idle and count + 128 > @min(limit.max, 16384)) {
                    try report.runs.append(try h.json(try h.encode(.{ .adapter = adapter, .scenario = "idle", .count = count, .skipped = "safe fd ceiling" })));
                    try report.save();
                    continue;
                }
                var entry = try e.Entry.init(h, options.binary, adapter, switch (kind) {
                    .performance => "session-performance",
                    .fd_races => "disconnect-fd-reuse-races",
                    .shutdown_race => "shutdown-disconnect-completion-race",
                    .idle => "idle",
                    .mixed => "mixed-soak-races",
                }, "incremental-certify");
                defer entry.deinit();
                var failure: ?anyerror = null;
                try entry.put("baseline", try resource.sample(h, entry.f.server.child.id.?));
                exercise(&entry, &report, options, kind, count) catch |err| {
                    failure = err;
                    const snapshot = sample(&entry, 0) catch |snapshot_error| blk: {
                        try entry.put("failure_snapshot_error", @errorName(snapshot_error));
                        break :blk std.json.Value.null;
                    };
                    try entry.fields.put(h.a, "failure_snapshot", snapshot);
                };
                entry.finish(5000) catch |err| {
                    failure = err;
                };
                try entry.put("clean", failure == null);
                const log = try h.read(entry.f.server.log_path);
                for ([_][]const u8{ "RUNTIME_MEMORY ", "APPLICATION_MEMORY " }, [_][]const u8{ "runtime_memory", "application_memory" }) |marker, key| {
                    if (std.mem.indexOf(u8, log, marker) != null) try entry.fields.put(h.a, key, try e.stats(h, log, marker));
                }
                if (entry.fields.get("allocator")) |v| try entry.fields.put(h.a, "allocator_final", v);
                if (entry.fields.get("sessions")) |v| try entry.fields.put(h.a, "sessions_final", v);
                try entry.put("exit_code", entry.f.server.status orelse -1);
                if (failure != null) {
                    passed = false;
                    if (kind == .mixed) long_soak = false;
                }
                try entry.save(&report, failure);
                // Match the original fatal race checks; other scenarios retain
                // evidence and continue, then fail the overall gate.
                if (failure != null and (kind == .fd_races or kind == .shutdown_race)) {
                    try report.put("passed", false);
                    try report.save();
                    return failure.?;
                }
            }
        }
    }
    try report.put("passed", passed);
    try report.put("long_soak_completed", long_soak);
    try report.save();
    try s.check(passed, "session evaluation unmet conditions; retain production gate");
}
const Kind = enum { performance, fd_races, shutdown_race, idle, mixed };
fn query(h: s.H, port: u16, path: []const u8) !struct { ms: f64, body: []const u8 } {
    var client = try t.w.Client.connect(h, port);
    defer client.close();
    const start = h.now();
    try client.send(try t.w.request(h, path, true, ""));
    const response = try t.status(&client, 200);
    return .{ .ms = e.milliseconds(h.now() - start), .body = response.body };
}
fn websocket(h: s.H, port: u16) !t.w.Client {
    var client = try t.w.Client.connect(h, port);
    errdefer client.close();
    try client.send(try t.w.request(h, "/upgrade-live", false, t.w.upgrade));
    _ = try t.status(&client, 101);
    try s.eq(try client.take(7), "\x81\x05ready");
    return client;
}
fn heldWebSocket(server: *t.w.Server) !*t.w.Client {
    const c = try server.h.a.create(t.w.Client);
    c.* = try websocket(server.h, server.port);
    errdefer c.close();
    try server.clients.append(server.h.a, c);
    return c;
}
fn broadcast(h: s.H, clients: []const *t.w.Client) !f64 {
    const start = h.now();
    try clients[0].send(try t.w.frame(h, 1, "tick", true));
    const expected = "\x81\x04tick";
    const fds = try h.a.alloc(std.c.pollfd, clients.len);
    for (clients, fds) |c, *fd| fd.* = .{ .fd = c.fd, .events = std.c.POLL.IN, .revents = 0 };
    var remaining = clients.len;
    const deadline = start + 5 * std.time.ns_per_s;
    while (remaining > 0) {
        for (clients, fds) |c, *fd| {
            if (fd.fd < 0) continue;
            if (c.pending.items.len >= expected.len) {
                try s.eq(try c.take(expected.len), expected);
                fd.fd = -1;
                remaining -= 1;
            }
        }
        if (remaining == 0) break;
        try s.check(h.now() < deadline, "broadcast deadline");
        const rc = std.c.poll(fds.ptr, @intCast(fds.len), 100);
        if (rc < 0) {
            if (std.posix.errno(rc) == .INTR) continue;
            return error.Poll;
        }
        if (rc == 0) continue;
        for (clients, fds) |c, fd| if (fd.fd >= 0 and fd.revents != 0) try c.fill();
    }
    return e.milliseconds(h.now() - start);
}
fn sample(entry: *e.Entry, elapsed: f64) !std.json.Value {
    const server = &entry.f.server;
    const h = server.h;
    var result = try h.json(try h.encode(try resource.sample(h, server.child.id orelse return error.FixtureExited)));
    try result.object.put(h.a, "elapsed_s", .{ .float = elapsed });
    try result.object.put(h.a, "allocator", try h.json((try query(h, server.port, "/runtime-stats")).body));
    return result;
}
fn percentile(h: s.H, input: []const f64) !struct { p50_ms: f64, p95_ms: f64, p99_ms: f64 } {
    const values = try h.a.dupe(f64, input);
    std.mem.sort(f64, values, {}, std.sort.asc(f64));
    const n = values.len;
    if (n == 0) return error.NoSamples;
    return .{ .p50_ms = if (n % 2 == 0) (values[n / 2 - 1] + values[n / 2]) / 2 else values[n / 2], .p95_ms = values[@min(n - 1, n * 95 / 100)], .p99_ms = values[@min(n - 1, n * 99 / 100)] };
}
fn workStarted(server: *t.w.Server) !void {
    for (0..100) |_| {
        if (std.mem.indexOf(u8, try server.h.read(server.log_path), "APPLICATION_WORK_ENTERED") != null) return;
        server.h.sleep(10);
    }
    return error.ApplicationStartBarrier;
}
const Task = enum { stream, race, http, close };
const Batch = struct {
    work: *Work,
    threads: std.ArrayList(std.Thread) = .empty,
    fn start(h: s.H, port: u16, task: Task, count: usize, concurrency: usize, clients: []const *t.w.Client) !Batch {
        const work = try h.a.create(Work);
        work.* = .{ .h = h, .port = port, .task = task, .values = try h.a.alloc(f64, count), .clients = clients };
        var batch: Batch = .{ .work = work };
        errdefer batch.join();
        try batch.threads.ensureTotalCapacity(h.a, concurrency);
        for (0..concurrency) |_| batch.threads.appendAssumeCapacity(try std.Thread.spawn(.{}, Work.worker, .{work}));
        return batch;
    }
    fn join(batch: *Batch) void {
        for (batch.threads.items) |thread| thread.join();
        batch.threads.clearRetainingCapacity();
    }
    fn finish(batch: *Batch) ![]f64 {
        batch.join();
        try s.check(!batch.work.failed.load(.acquire), "concurrent session work succeeded");
        return batch.work.values;
    }
};
const Work = struct {
    h: s.H,
    port: u16,
    task: Task,
    values: []f64,
    clients: []const *t.w.Client,
    next: std.atomic.Value(usize) = .init(0),
    failed: std.atomic.Value(bool) = .init(false),
    gate: std.atomic.Value(bool) = .init(false),
    fn worker(work: *Work) void {
        while (true) {
            const index = work.next.fetchAdd(1, .monotonic);
            if (index >= work.values.len) return;
            work.values[index] = work.exchange(index) catch |err| {
                std.debug.print("session task {s}: {s}\n", .{ @tagName(work.task), @errorName(err) });
                work.failed.store(true, .release);
                return;
            };
        }
    }
    fn exchange(work: *Work, index: usize) !f64 {
        var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
        defer arena.deinit();
        var h = work.h;
        h.a = arena.allocator();
        const start = h.now();
        if (work.task == .http) return (try query(h, work.port, if (index % 3 == 0) "/db/1" else "/hello")).ms;
        if (work.task == .close) {
            const deadline = h.now() + 2 * std.time.ns_per_s;
            while (!work.gate.load(.acquire) and h.now() < deadline) h.sleep(1);
            const client = work.clients[index];
            // Only this worker owns this client during the race.
            defer client.close();
            client.send(try t.w.frame(h, 9, "bye", true)) catch {};
            return 0;
        }
        if (work.task == .stream) {
            var client = try t.w.Client.connect(h, work.port);
            defer client.close();
            try client.send(try t.w.request(h, "/stream", true, ""));
            const raw = try client.collect();
            try s.check(std.mem.startsWith(u8, raw, "HTTP/1.1 200"), "small stream status");
            const body = (std.mem.indexOf(u8, raw, "\r\n\r\n") orelse return error.StreamHeader) + 4;
            try s.eq(raw[body..], "3\r\none\r\n3\r\ntwo\r\n0\r\n\r\n");
        } else {
            var client = if (index % 4 == 0) try t.w.Client.connect(h, work.port) else try websocket(h, work.port);
            defer client.close();
            switch (index % 4) {
                0 => try client.send(try t.w.request(h, "/db/1", true, "")),
                1 => try client.send((try t.w.frame(h, 1, "race", true))[0..7]),
                2 => try client.send(try t.w.frame(h, 9, "race", true)),
                3 => try client.send(try t.w.frame(h, 8, "\x03\xe8", true)),
                else => unreachable,
            }
            if (index % 2 == 0) try client.reset();
        }
        return e.milliseconds(h.now() - start);
    }
};
fn exercise(entry: *e.Entry, report: *e.Report, options: Options, kind: Kind, count: usize) !void {
    const server = &entry.f.server;
    const h = server.h;
    var samples: std.json.Array = .init(h.a);
    var clients: std.ArrayList(*t.w.Client) = .empty;
    // server owns the sockets; this list is only a borrowed selection.
    switch (kind) {
        .performance => {
            for (0..100) |_| try clients.append(h.a, try heldWebSocket(server));
            const times = try h.a.alloc(f64, options.rounds);
            var total: f64 = 0;
            for (times) |*time| {
                time.* = try broadcast(h, clients.items);
                total += time.*;
            }
            const p = try percentile(h, times);
            try entry.put("broadcast", .{ .p50_ms = p.p50_ms, .p95_ms = p.p95_ms, .p99_ms = p.p99_ms, .recipients = 100, .rounds = options.rounds, .observed_frames_per_second = @as(f64, @floatFromInt(100 * options.rounds)) / (total / 1000) });
            const start = h.now();
            var batch = try Batch.start(h, server.port, .stream, options.rounds * 32, 32, &.{});
            defer batch.join();
            const values = try batch.finish();
            const seconds = e.milliseconds(h.now() - start) / 1000;
            const stream = try percentile(h, values);
            try entry.put("stream", .{ .p50_ms = stream.p50_ms, .p95_ms = stream.p95_ms, .p99_ms = stream.p99_ms, .requests = values.len, .observed_requests_per_second = @as(f64, @floatFromInt(values.len)) / seconds });
            try samples.append(try sample(entry, 0));
        },
        .fd_races => {
            var batch = try Batch.start(h, server.port, .race, 256, 16, &.{});
            defer batch.join();
            _ = try batch.finish();
            const deadline = h.now() + 3 * std.time.ns_per_s;
            while (true) {
                const snapshot = try sample(entry, 0);
                const stats = try s.field(snapshot, "allocator");
                if ((try s.field(stats, "created")).integer == (try s.field(stats, "closed")).integer) {
                    try samples.append(snapshot);
                    break;
                }
                try s.check(h.now() < deadline, "race session cleanup deadline");
                h.sleep(10);
            }
            try entry.put("iterations", 256);
            try entry.put("recovered_http_ms", (try query(h, server.port, "/hello")).ms);
        },
        .shutdown_race => {
            for (0..64) |_| try clients.append(h.a, try heldWebSocket(server));
            var batch = try Batch.start(h, server.port, .close, 64, 16, clients.items);
            defer batch.join();
            const work = try server.connect();
            try work.send(try t.w.request(h, "/application-hold", false, ""));
            try workStarted(server);
            batch.work.gate.store(true, .release);
            try entry.put("shutdown_requested", true);
            server.signal(.TERM);
            if (!try server.poll()) server.signal(.INT);
            _ = try batch.finish();
            try entry.put("connections", 64);
        },
        .idle => {
            try entry.put("count", count);
            const start = h.now();
            for (0..count) |_| try clients.append(h.a, try heldWebSocket(server));
            try entry.put("establishment_ms", e.milliseconds(h.now() - start));
            try samples.append(try sample(entry, 0));
            try entry.put("broadcast_ms", try broadcast(h, clients.items));
            const ms = (try query(h, server.port, "/hello")).ms;
            try entry.put("http_probe_ms", ms);
            try s.check(ms < 250, "idle WebSocket HTTP isolation");
        },
        .mixed => {
            for (0..options.mixed_idle + 16) |_| try clients.append(h.a, try heldWebSocket(server));
            const start = h.now();
            const duration = @max(@as(u32, 1), options.soak);
            const deadline = start + @as(i96, duration) * std.time.ns_per_s;
            var iterations: usize = 0;
            var results: std.json.Array = .init(h.a);
            try entry.put("requested_soak_s", options.soak);
            while (h.now() < deadline) {
                for (clients.items) |client| try client.send(try t.w.frame(h, 9, "live", true));
                for (clients.items) |client| try s.eq(try client.take(6), "\x8a\x04live");
                std.mem.rotate(*t.w.Client, clients.items, 1);
                var slow: [4]*t.w.Client = undefined;
                var opened: usize = 0;
                defer for (slow[0..opened]) |client| client.close();
                for (&slow) |*client| {
                    client.* = try server.connect();
                    opened += 1;
                    try client.*.receiveBuffer(4096);
                    try client.*.send(try t.w.request(h, "/large", false, ""));
                    _ = try client.*.headers();
                }
                var batch = try Batch.start(h, server.port, .http, 32, 32, &.{});
                defer batch.join();
                const latency = try broadcast(h, clients.items);
                const values = try batch.finish();
                const p = try percentile(h, values);
                const maximum = std.mem.max(f64, values);
                try results.append(try h.json(try h.encode(.{ .http_p50_ms = p.p50_ms, .http_max_ms = maximum, .broadcast_ms = latency })));
                try entry.put("http_isolated", maximum < 250);
                try s.check(maximum < 250, "mixed HTTP isolation");
                for (slow[0..opened]) |client| client.close();
                opened = 0;
                for (0..4) |_| {
                    const client = try heldWebSocket(server);
                    try client.send(try t.w.frame(h, 8, "\x03\xe8", true));
                    client.close();
                }
                if (iterations % 3 == 0) {
                    try samples.append(try sample(entry, e.milliseconds(h.now() - start) / 1000));
                    try entry.fields.put(h.a, "samples", .{ .array = samples });
                    try entry.fields.put(h.a, "mixed_results", .{ .array = results });
                    // A snapshot of the current entry is written while it is
                    // still live, then removed before final append.
                    try report.runs.append(.{ .object = entry.fields });
                    try report.save();
                    report.runs.items.len -= 1;
                }
                iterations += 1;
                const left = deadline - h.now();
                if (left > 0) h.sleep(@intCast(@min(2000, @divTrunc(left, std.time.ns_per_ms))));
            }
            try entry.put("elapsed_s", e.milliseconds(h.now() - start) / 1000);
            try entry.put("iterations", iterations);
            try entry.fields.put(h.a, "mixed_results", .{ .array = results });
        },
    }
    try entry.fields.put(h.a, "samples", .{ .array = samples });
}
