//! Private SIMD evidence collection using the existing Zig process harness.
const std = @import("std");
const s = @import("support.zig");
const evidence = @import("benchmark_evidence.zig");
const Group = struct {
    kind: []const u8,
    mode: []const u8,
    size: usize,
    values: std.ArrayList(f64) = .empty,
    checksum_per_operation: i64,
};

pub fn run(h: s.H, args: []const []const u8) !void {
    if (args.len != 3 and args.len != 4) return error.ExpectedFastBinarySafeBinaryOutputDirectory;
    const expected_cases = if (args.len == 4) try std.fmt.parseInt(usize, args[3], 10) else 800;
    // Each process performs its own warmup, then one retained sample per case.
    // Existing complete files allow safe resumption after an interrupted run.
    for (0..10) |index| {
        for (0..2) |position| {
            const mode = (index + position) % 2;
            const name = if (mode == 0) "fast" else "safe";
            const path = try h.fmt("{s}/{s}-{d}.jsonl", .{ args[2], name, index });
            if (h.exists(path)) continue;
            const result = try h.commandFor(&.{ args[mode], "2", try h.fmt("{d}", .{index}) }, null, h.env, 600);
            if (!s.success(result.term)) {
                try h.write(try h.fmt("{s}.failed", .{path}), result.stderr);
                return error.CandidateBenchmarkFailed;
            }
            try h.write(path, result.stderr);
            std.debug.print("SIMD independent process {s} {d}/10 completed\n", .{ name, index + 1 });
        }
    }
    for ([_][]const u8{ "fast", "safe" }) |name| try summarize(h, args[2], name, expected_cases);
}

fn summarize(h: s.H, directory: []const u8, name: []const u8, expected_cases: usize) !void {
    var groups: std.ArrayList(Group) = .empty;
    for (0..10) |index| {
        const bytes = try h.read(try h.fmt("{s}/{s}-{d}.jsonl", .{ directory, name, index }));
        var lines = std.mem.tokenizeScalar(u8, bytes, '\n');
        var retained: usize = 0;
        while (lines.next()) |line| {
            if (!std.mem.startsWith(u8, line, "SIMD ")) continue;
            const row = try h.json(line[5..]);
            const round = (try s.field(row, "round")).integer;
            if (round == 0) continue;
            if (round != 1) return error.UnexpectedSampleRound;
            const kind = (try s.field(row, "kind")).string;
            const mode = (try s.field(row, "mode")).string;
            const size: usize = @intCast((try s.field(row, "size")).integer);
            const iterations = (try s.field(row, "iterations")).integer;
            const elapsed = (try s.field(row, "elapsed_ns")).integer;
            if (iterations <= 0 or elapsed < 10_000_000) return error.InsufficientMeasurement;
            const checksum = (try s.field(row, "checksum")).integer;
            if (@mod(checksum, iterations) != 0) return error.InvalidChecksum;
            const per_op = @divTrunc(checksum, iterations);
            var found: ?usize = null;
            for (groups.items, 0..) |group, i| {
                if (group.size == size and std.mem.eql(u8, group.kind, kind)) {
                    if (group.checksum_per_operation != per_op) return error.DifferentialChecksumMismatch;
                    if (std.mem.eql(u8, group.mode, mode)) found = i;
                }
            }
            if (found == null) {
                found = groups.items.len;
                try groups.append(h.a, .{ .kind = kind, .mode = mode, .size = size, .checksum_per_operation = per_op });
            }
            try groups.items[found.?].values.append(h.a, @as(f64, @floatFromInt(elapsed)) / @as(f64, @floatFromInt(iterations)));
            retained += 1;
        }
        if (retained != expected_cases) return error.IncompleteProcessResults;
    }
    var output: std.Io.Writer.Allocating = .init(h.a);
    const w = &output.writer;
    try w.writeAll("kind,mode,size,processes,median_ns_op,min_ns_op,max_ns_op,mb_s,time_reduction_percent\n");
    for (groups.items) |group| {
        if (group.values.items.len != 10) return error.MissingIndependentSamples;
        const median = try evidence.median(h, group.values.items);
        const baseline_mode: []const u8 = if (std.mem.startsWith(u8, group.kind, "mask-") or std.mem.startsWith(u8, group.kind, "form-")) "byte" else "scalar";
        var baseline: ?f64 = null;
        for (groups.items) |other| {
            if (other.size == group.size and std.mem.eql(u8, group.kind, other.kind) and std.mem.eql(u8, baseline_mode, other.mode)) baseline = try evidence.median(h, other.values.items);
        }
        const base = baseline orelse return error.MissingBaseline;
        try w.print("{s},{s},{d},10,{d:.3},{d:.3},{d:.3},{d:.3},{d:.2}\n", .{
            group.kind,                           group.mode,                           group.size,                                          median,
            std.mem.min(f64, group.values.items), std.mem.max(f64, group.values.items), @as(f64, @floatFromInt(group.size)) * 1000 / median, 100 * (1 - median / base),
        });
    }
    try h.write(try h.fmt("{s}/summary-{s}.csv", .{ directory, name }), output.written());
}
