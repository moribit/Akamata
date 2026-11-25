//! Loopback A/B validation; excludes DB/TLS and retains complete oha reports.
const std = @import("std");
const s = @import("support.zig");
const w = @import("wire.zig");
const evidence = @import("benchmark_evidence.zig");
extern "c" fn wait4(pid: std.c.pid_t, status: *c_int, options: c_int, usage: *std.c.rusage) std.c.pid_t;

fn finishProfile(server: *w.Server) !std.c.rusage {
    server.signal(.TERM);
    const deadline = server.h.now() + 4 * std.time.ns_per_s;
    var status: c_int = undefined;
    var usage: std.c.rusage = undefined;
    while (true) {
        const rc = wait4(server.child.id.?, &status, std.c.W.NOHANG, &usage);
        if (rc > 0) {
            server.status = status;
            server.child.id = null;
            try s.check(status == 0, "profiled fixture exits cleanly");
            return usage;
        }
        if (rc < 0 and std.posix.errno(rc) != .INTR) return error.Wait4;
        if (server.h.now() >= deadline) return error.ProcessDeadline;
        server.h.sleep(5);
    }
}

pub fn run(h: s.H, args: []const []const u8) !void {
    if (args.len != 5) return error.ExpectedBaselineFastCandidateFastBaselineSafeCandidateSafeDirectory;
    const directory = args[4];
    for ([_][]const u8{ "threaded", "reactor" }) |runtime| {
        try h.env.put("COMPETITIVE_RUNTIME", runtime);
        for (0..2) |optimization| {
            const mode = if (optimization == 0) "fast" else "safe";
            for ([_]usize{ 0, 4096 }) |header_length| {
                const header = try h.a.alloc(u8, header_length + "Cookie: ".len);
                @memcpy(header[0.."Cookie: ".len], "Cookie: ");
                @memset(header["Cookie: ".len..], 'x');
                for (0..10) |round| {
                    for (0..2) |position| {
                        const variant = (round + position) % 2;
                        const label = if (variant == 0) "baseline" else "candidate";
                        const output = try h.fmt("{s}/http-{s}-{s}-{d}-{d}-{s}.json", .{ directory, runtime, mode, header_length, round, label });
                        if (h.exists(output)) continue;
                        const binary = args[optimization * 2 + variant];
                        var server = try w.Server.start(h, &.{binary}, null, h.env, 8088);
                        defer server.deinit();
                        // Probe readiness and exact wire body outside timed runs.
                        const deadline = h.now() + 10 * std.time.ns_per_s;
                        while (true) {
                            var client = w.Client.connect(h, 8088) catch |err| {
                                if (h.now() >= deadline or try server.poll()) return err;
                                h.sleep(10);
                                continue;
                            };
                            defer client.close();
                            try client.send("GET /json HTTP/1.1\r\nHost: fixture\r\nConnection: close\r\n\r\n");
                            const response = try client.response();
                            try s.check(response.status == 200, "SIMD HTTP readiness status");
                            try s.eq(response.body, "{\"message\":\"Hello, World!\"}");
                            break;
                        }
                        const url = "http://127.0.0.1:8088/json";
                        const warmup = try h.run(&.{ "oha", "--no-tui", "--output-format", "json", "-z", "1s", "-w", "-c", "8", "-H", header, url }, null, h.env);
                        const result = try h.command(&.{ "oha", "--no-tui", "--output-format", "json", "-z", "5s", "-w", "-c", "8", "-H", header, url }, null, h.env);
                        try s.check(s.success(result.term), "SIMD HTTP load generator exit");
                        const data = try h.json(result.stdout);
                        const errors = try s.field(data, "errorDistribution");
                        try s.check(errors.object.count() == 0, "SIMD HTTP has no request errors");
                        const statuses = try s.field(data, "statusCodeDistribution");
                        try s.check(statuses.object.count() == 1 and statuses.object.contains("200"), "SIMD HTTP returns only 200");
                        // RSS is a post-load snapshot, not peak RSS.
                        const rss = try h.command(&.{ "ps", "-o", "rss=", "-p", try h.fmt("{d}", .{server.child.id.?}) }, null, h.env);
                        try h.write(try h.fmt("{s}.rss", .{output}), rss.stdout);
                        const usage = try finishProfile(&server);
                        const warm = try h.json(warmup);
                        const requests = 1 + try evidence.number(try s.field(try s.field(warm, "statusCodeDistribution"), "200")) + try evidence.number(try s.field(statuses, "200"));
                        const cpu_seconds = @as(f64, @floatFromInt(usage.utime.sec + usage.stime.sec)) + @as(f64, @floatFromInt(usage.utime.usec + usage.stime.usec)) / 1_000_000;
                        const peak_rss_kib = @as(f64, @floatFromInt(usage.maxrss)) / (if (@import("builtin").os.tag == .macos) @as(f64, 1024) else 1);
                        try h.write(try h.fmt("{s}.process.json", .{output}), try h.encode(.{ .peak_rss_kib = peak_rss_kib, .cpu_seconds = cpu_seconds, .requests_including_warmup_and_probe = requests, .cpu_ns_per_request = cpu_seconds * 1e9 / requests, .scope = "server lifetime including startup, 1s warmup, 5s load and shutdown; excludes oha CPU" }));
                        try h.write(try h.fmt("{s}.warmup.json", .{output}), warmup);
                        try h.write(output, result.stdout);
                        std.debug.print("SIMD HTTP {s} {s} header={d} pair={d}/10 {s} complete\n", .{ runtime, mode, header_length, round + 1, label });
                    }
                }
            }
        }
    }
}

pub fn summarize(h: s.H, directory: []const u8) !void {
    var output: std.Io.Writer.Allocating = .init(h.a);
    const writer = &output.writer;
    try writer.writeAll("runtime,mode,header_bytes,pairs,baseline_rps,candidate_rps,paired_gain_median_percent,paired_gain_mean_ci95_low,paired_gain_mean_ci95_high,baseline_p50_ms,candidate_p50_ms,baseline_p95_ms,candidate_p95_ms,baseline_p99_ms,candidate_p99_ms,baseline_rss_snapshot_kib,candidate_rss_snapshot_kib,baseline_peak_rss_kib,candidate_peak_rss_kib,baseline_cpu_ns_request,candidate_cpu_ns_request\n");
    for ([_][]const u8{ "threaded", "reactor" }) |runtime| {
        for ([_][]const u8{ "fast", "safe" }) |mode| {
            for ([_]usize{ 0, 4096 }) |header_length| {
                var metrics: [2][4][10]f64 = undefined;
                var rss: [2][10]f64 = undefined;
                var peak: [2][10]f64 = undefined;
                var cpu: [2][10]f64 = undefined;
                var has_profile = true;
                var gain: [10]f64 = undefined;
                for (0..10) |round| {
                    for ([_][]const u8{ "baseline", "candidate" }, 0..) |label, variant| {
                        const path = try h.fmt("{s}/http-{s}-{s}-{d}-{d}-{s}.json", .{ directory, runtime, mode, header_length, round, label });
                        const data = try h.json(try h.read(path));
                        const summary = try s.field(data, "summary");
                        metrics[variant][0][round] = try evidence.number(try s.field(summary, "requestsPerSec"));
                        const latencies = try s.field(data, "latencyPercentiles");
                        for ([_][]const u8{ "p50", "p95", "p99" }, 1..) |key, index| metrics[variant][index][round] = 1000 * try evidence.number(try s.field(latencies, key));
                        rss[variant][round] = try std.fmt.parseFloat(f64, std.mem.trim(u8, try h.read(try h.fmt("{s}.rss", .{path})), " \r\n\t"));
                        const profile_path = try h.fmt("{s}.process.json", .{path});
                        if (h.exists(profile_path)) {
                            const profile = try h.json(try h.read(profile_path));
                            peak[variant][round] = try evidence.number(try s.field(profile, "peak_rss_kib"));
                            cpu[variant][round] = try evidence.number(try s.field(profile, "cpu_ns_per_request"));
                        } else has_profile = false;
                    }
                    gain[round] = 100 * (metrics[1][0][round] / metrics[0][0][round] - 1);
                }
                var mean: f64 = 0;
                for (gain) |value| mean += value / 10;
                var variance: f64 = 0;
                for (gain) |value| variance += (value - mean) * (value - mean) / 9;
                // Student t(9), two-sided 95%; descriptive, not a CI pass gate.
                const margin = 2.262157 * @sqrt(variance / 10);
                try writer.print("{s},{s},{d},10,{d:.3},{d:.3},{d:.3},{d:.3},{d:.3}", .{
                    runtime,                       mode,          header_length, try evidence.median(h, &metrics[0][0]), try evidence.median(h, &metrics[1][0]),
                    try evidence.median(h, &gain), mean - margin, mean + margin,
                });
                for (1..4) |index| try writer.print(",{d:.6},{d:.6}", .{ try evidence.median(h, &metrics[0][index]), try evidence.median(h, &metrics[1][index]) });
                try writer.print(",{d:.1},{d:.1}", .{ try evidence.median(h, &rss[0]), try evidence.median(h, &rss[1]) });
                if (has_profile) try writer.print(",{d:.1},{d:.1},{d:.3},{d:.3}\n", .{ try evidence.median(h, &peak[0]), try evidence.median(h, &peak[1]), try evidence.median(h, &cpu[0]), try evidence.median(h, &cpu[1]) }) else try writer.writeAll(",n/a,n/a,n/a,n/a\n");
            }
        }
    }
    try h.write(try h.fmt("{s}/http-summary.csv", .{directory}), output.written());
}
