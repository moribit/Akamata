//! Loopback A/B validation; excludes DB/TLS and retains complete oha reports.
const std = @import("std");
const s = @import("support.zig");
const w = @import("wire.zig");

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
                        _ = try h.run(&.{ "oha", "--no-tui", "--output-format", "json", "-z", "1s", "-w", "-c", "8", "-H", header, url }, null, h.env);
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
                        server.signal(.TERM);
                        try server.wait(4000);
                        try h.write(output, result.stdout);
                        std.debug.print("SIMD HTTP {s} {s} header={d} pair={d}/10 {s} complete\n", .{ runtime, mode, header_length, round + 1, label });
                    }
                }
            }
        }
    }
}
