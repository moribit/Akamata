//! Six equivalent DB paths; no throughput thresholds in correctness CI.
const std = @import("std");
const s = @import("support.zig");
pub fn run(h: s.H, binary_path: []const u8) !void {
    const binary = try h.absolute(binary_path);
    var env = try h.env.clone(h.a);
    try env.put("DB_THREADS", "2");
    try env.put("DB_OPS", "500");
    try env.put("DB_SQL_LENGTH", "0");
    for (0..6) |index| {
        try env.put("DB_CASE", try h.fmt("{d}", .{index}));
        const result = try h.command(&.{binary}, null, &env);
        try s.check(s.success(result.term), result.stderr);
        var lines = std.mem.splitScalar(u8, result.stderr, '\n');
        var found = false;
        while (lines.next()) |line| {
            if (!std.mem.startsWith(u8, line, "DB_MICRO ")) continue;
            try s.check(!found, "single DB_MICRO diagnostic");
            found = true;
            const text = try h.a.dupe(u8, line[9..]);
            // Preserve compatibility with the fixture's Zig array formatting.
            for ([_][]const u8{ "\"stage_ns\":", "\"stage_calls\":" }) |key| {
                if (std.mem.indexOf(u8, text, key)) |at| {
                    const start = at + key.len;
                    if (text[start] == '{') {
                        const end = std.mem.indexOfScalarPos(u8, text, start, '}') orelse return error.InvalidStageArray;
                        text[start] = '[';
                        text[end] = ']';
                    }
                }
            }
            const row = try h.json(text);
            try s.check((try s.field(row, "errors")).integer == 0 and (try s.field(row, "operations")).integer == 1000, "DB operations and errors");
            try s.check((try s.field(row, "checksum")).integer == 2 * (500 + 100) * 534, "complete row checksum");
            const p50 = (try s.field(row, "p50_ns")).integer;
            const p95 = (try s.field(row, "p95_ns")).integer;
            const p99 = (try s.field(row, "p99_ns")).integer;
            try s.check(0 <= p50 and p50 <= p95 and p95 <= p99, "DB latency ordering");
        }
        try s.check(found, "DB_MICRO diagnostic present");
    }
    std.debug.print("DB microfixture: 6 paths preserve row data, error handling and latency ordering\n", .{});
}
