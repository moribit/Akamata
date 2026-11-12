//! Canonical offline evidence guards, shared by the CLI and its Zig contracts.
const std = @import("std");
const s = @import("support.zig");
pub const workloads = [_][]const u8{ "plaintext", "json", "routing", "db", "echo-64", "echo-1024", "echo-65536" };
pub const connections = [_]i64{ 1, 8, 32, 128, 512, 1024 };
pub const baseline = [_][]const u8{ "akamata-threaded", "akamata-reactor", "actix", "axum", "go", "zap" };
pub const after = [_][]const u8{ "akamata-threaded-after", "akamata-reactor-single-after", "akamata-reactor-sharded-after" };
pub fn number(v: std.json.Value) !f64 {
    return switch (v) {
        .integer => |n| @floatFromInt(n),
        .float => |n| n,
        else => error.ExpectedNumber,
    };
}
fn integer(v: std.json.Value) !i64 {
    if (v != .integer) return error.ExpectedInteger;
    return v.integer;
}
fn string(v: std.json.Value) ![]const u8 {
    if (v != .string) return error.ExpectedString;
    return v.string;
}
pub fn rows(v: std.json.Value) ![]std.json.Value {
    const value = try s.field(v, "runs");
    if (value != .array) return error.ExpectedRuns;
    return value.array.items;
}
fn nameIndex(names: []const []const u8, value: []const u8) !usize {
    for (names, 0..) |name, i| if (std.mem.eql(u8, name, value)) return i;
    return error.UnexpectedCase;
}
fn connectionIndex(value: i64) !usize {
    for (connections, 0..) |n, i| if (n == value) return i;
    return error.UnexpectedCase;
}
pub fn validateMicro(data: std.json.Value, paired: bool) !void {
    var counts: [144]u8 = @splat(0);
    const width: usize = if (paired) 2 else 1;
    for (try rows(data)) |row| {
        const round = try integer(try s.field(row, "round"));
        const case = try string(try s.field(row, "case"));
        const threads = try integer(try s.field(row, "threads"));
        if (round < 1 or round > 3 or case.len != 1 or case[0] < 'A' or case[0] > 'F') return error.UnexpectedCase;
        const thread: usize = switch (threads) {
            1 => 0,
            8 => 1,
            32 => 2,
            128 => 3,
            else => return error.UnexpectedCase,
        };
        const variant = if (row.object.get("variant")) |v| try string(v) else "A";
        const v: usize = if (std.mem.eql(u8, variant, "A")) 0 else if (paired and std.mem.eql(u8, variant, "B")) 1 else return error.UnexpectedCase;
        if (try integer(try s.field(row, "errors")) != 0) return error.MicroErrors;
        const operations = try integer(try s.field(row, "operations"));
        if (operations < 0) return error.InvalidOperations;
        const sum = std.math.add(i64, operations, 100 * threads) catch return error.InvalidOperations;
        const expected = std.math.mul(i64, sum, 534) catch return error.InvalidOperations;
        if (try integer(try s.field(row, "checksum")) != expected) return error.LostRowData;
        const key = (((@as(usize, @intCast(round - 1)) * 6 + case[0] - 'A') * 4 + thread) * width) + v;
        counts[key] = std.math.add(u8, counts[key], 1) catch return error.DuplicateMicro;
    }
    for (counts[0 .. 3 * 6 * 4 * width]) |count| if (count != (if (paired) @as(u8, 2) else 1)) return error.MissingOrDuplicateMicro;
}
pub const Validated = struct { completed: []std.json.Value, failures: []std.json.Value };
pub fn validateHttp(h: s.H, data: std.json.Value) !Validated {
    const names = [_][]const u8{ "db", "plaintext", "json", "echo-1024" };
    var complete: [192]?std.json.Value = @splat(null);
    var failures: std.ArrayList(std.json.Value) = .empty;
    for (try rows(data)) |row| {
        const cycle = try integer(try s.field(row, "cycle"));
        const position = try integer(try s.field(row, "position"));
        if (cycle < 1 or cycle > 2 or position < 0 or position > 3) return error.UnexpectedCase;
        const workload = try nameIndex(&names, try string(try s.field(row, "workload")));
        const connection = try connectionIndex(try integer(try s.field(row, "connections")));
        const key = (((@as(usize, @intCast(cycle - 1)) * 4 + workload) * 6 + connection) * 4) + @as(usize, @intCast(position));
        if (row.object.contains("failure")) {
            try failures.append(h.a, row);
            continue;
        }
        if (complete[key] != null) return error.DuplicateHttp;
        const variant = try string(try s.field(row, "variant"));
        if (variant.len != 1 or variant[0] != "ABBA"[@intCast(position)]) return error.WrongAbbaOrder;
        if ((try s.field(row, "wire_checks")).array.items.len != 7) return error.MissingWireConformance;
        complete[key] = row;
    }
    const result = try h.a.alloc(std.json.Value, complete.len);
    for (complete, result) |value, *slot| slot.* = value orelse return error.IncompleteHttp;
    return .{ .completed = result, .failures = failures.items };
}
pub fn validateMatrix(h: s.H, data: std.json.Value, frameworks: []const []const u8) !Validated {
    for ([_][]const u8{ "warmup_seconds", "duration_seconds", "rounds" }, [_]i64{ 10, 30, 5 }) |key, expected| if (try integer(try s.field(data, key)) != expected) return error.MatrixParameters;
    const binaries = try s.field(data, "binaries");
    if (binaries != .object or binaries.object.count() != frameworks.len) return error.FrozenFrameworkSet;
    for (frameworks) |framework| if (!binaries.object.contains(framework)) return error.FrozenFrameworkSet;
    const complete = try h.a.alloc(?std.json.Value, frameworks.len * 7 * 6 * 5);
    @memset(complete, null);
    var failures: std.ArrayList(std.json.Value) = .empty;
    for (try rows(data)) |row| {
        const framework = try nameIndex(frameworks, try string(try s.field(row, "framework")));
        const workload = try nameIndex(&workloads, try string(try s.field(row, "workload")));
        const connection = try connectionIndex(try integer(try s.field(row, "connections")));
        const round = try integer(try s.field(row, "round"));
        if (round < 1 or round > 5) return error.UnexpectedCase;
        const key = (((framework * 7 + workload) * 6 + connection) * 5) + @as(usize, @intCast(round - 1));
        if (row.object.contains("failure") or !row.object.contains("oha")) {
            try failures.append(h.a, row);
            continue;
        }
        if (complete[key] != null) return error.DuplicateCompletedCase;
        if ((try s.field(row, "wire_checks")).array.items.len != 7) return error.MissingWireConformance;
        complete[key] = row;
    }
    const result = try h.a.alloc(std.json.Value, complete.len);
    for (complete, result) |value, *slot| slot.* = value orelse return error.IncompleteMatrix;
    return .{ .completed = result, .failures = failures.items };
}
pub fn median(h: s.H, input: []const f64) !f64 {
    if (input.len == 0) return error.NoRounds;
    const values = try h.a.dupe(f64, input);
    std.mem.sort(f64, values, {}, std.sort.asc(f64));
    const n = values.len;
    return if (n % 2 == 0) (values[n / 2 - 1] + values[n / 2]) / 2 else values[n / 2];
}
fn sumObject(v: std.json.Value) !f64 {
    if (v != .object) return error.ExpectedDistribution;
    var total: f64 = 0;
    for (v.object.values()) |n| total += try number(n);
    return total;
}
pub fn metrics(h: s.H, input: []const std.json.Value) !std.json.Value {
    const keys = [_][]const u8{ "http_200_per_second", "p50_ms", "p95_ms", "p99_ms", "p99.9_ms", "cpu_percent", "rss_kib", "threads", "attempts_per_second" };
    var values: [keys.len]std.ArrayList(f64) = @splat(.empty);
    var errors: f64 = 0;
    var non200: f64 = 0;
    var attempts: f64 = 0;
    var forced: usize = 0;
    var exits: std.json.Array = .init(h.a);
    for (input) |row| {
        const oha = try s.field(row, "oha");
        const summary = try s.field(oha, "summary");
        const status = try s.field(oha, "statusCodeDistribution");
        const failure = try sumObject(try s.field(oha, "errorDistribution"));
        const total = try sumObject(status);
        const ok = if (status.object.get("200")) |n| try number(n) else 0;
        const seconds = try number(try s.field(summary, "total"));
        if (seconds <= 0) return error.InvalidDuration;
        errors += failure;
        non200 += total - ok;
        attempts += failure + total;
        try values[0].append(h.a, ok / seconds);
        for ([_][]const u8{ "p50", "p95", "p99", "p99.9" }, 1..) |key, index| try values[index].append(h.a, 1000 * try number(try s.field(try s.field(oha, "latencyPercentiles"), key)));
        try values[5].append(h.a, try number(try s.field(row, "cpu_percent")));
        try values[6].append(h.a, try number(try s.field(row, "rss_mean_kib")));
        try values[7].append(h.a, try number(try s.field(row, "threads_peak")));
        try values[8].append(h.a, if (summary.object.get("requestsPerSec")) |n| try number(n) else (failure + total) / seconds);
        if (row.object.get("forced_runner_cleanup")) |v| {
            if (v == .bool and v.bool) forced += 1;
        }
        try exits.append(row.object.get("server_exit") orelse .null);
    }
    var result: std.json.ObjectMap = .empty;
    for (keys, values) |key, list| try result.put(h.a, key, .{ .float = try median(h, list.items) });
    try result.put(h.a, "client_errors", .{ .integer = @intFromFloat(errors) });
    try result.put(h.a, "non_200", .{ .integer = @intFromFloat(non200) });
    try result.put(h.a, "error_percent", .{ .float = if (attempts > 0) 100 * (errors + non200) / attempts else 0 });
    try result.put(h.a, "forced_cleanup", .{ .integer = @intCast(forced) });
    try result.put(h.a, "server_exits", .{ .array = exits });
    return .{ .object = result };
}
pub fn compare(h: s.H, left: std.json.Value, right: std.json.Value) !std.json.Value {
    const before = try validateMatrix(h, left, &baseline);
    const current = try validateMatrix(h, right, &after);
    for ([_][]const u8{ "os", "cpu_count", "oha", "warmup_seconds", "duration_seconds", "rounds" }) |key| {
        if (!std.mem.eql(u8, try h.encode(try s.field(left, key)), try h.encode(try s.field(right, key)))) return error.EnvironmentDrift;
    }
    var comparisons: std.json.Array = .init(h.a);
    for (workloads, 0..) |workload, wi| for (connections, 0..) |connection, ci| {
        const b = try metrics(h, before.completed[(wi * 6 + ci) * 5 ..][0..5]);
        for (after, 0..) |framework, fi| {
            const a = try metrics(h, current.completed[((fi * 7 + wi) * 6 + ci) * 5 ..][0..5]);
            const rate = try number(try s.field(b, "http_200_per_second"));
            if (rate <= 0) return error.InvalidBaselineRate;
            try comparisons.append(try h.json(try h.encode(.{ .workload = workload, .connections = connection, .framework = framework, .before_threaded = b, .after = a, .throughput_change_percent = 100 * ((try number(try s.field(a, "http_200_per_second"))) / rate - 1) })));
        }
    };
    return h.json(try h.encode(.{ .complete = true, .baseline_cases = before.completed.len, .after_cases = current.completed.len, .failed_attempts = .{ .baseline = before.failures, .after = current.failures }, .excluded_prior_runs = .{ .baseline = left.object.get("excluded_runs") orelse std.json.Value{ .array = .init(h.a) }, .after = right.object.get("excluded_runs") orelse std.json.Value{ .array = .init(h.a) } }, .comparisons = comparisons.items }));
}
pub fn diagnostics(h: s.H, log: []const u8) !std.json.Value {
    var result: std.json.ObjectMap = .empty;
    var lines = std.mem.splitScalar(u8, log, '\n');
    while (lines.next()) |line| for ([_][]const u8{ "RUNTIME_COST ", "BENCH_STATS ", "RUNTIME_MEMORY " }, [_][]const u8{ "runtime_cost", "allocator", "runtime_memory" }) |marker, key| {
        if (std.mem.startsWith(u8, line, marker)) {
            if (result.contains(key)) return error.DuplicateDiagnostic;
            try result.put(h.a, key, try h.json(line[marker.len..]));
        }
    };
    return .{ .object = result };
}
pub fn diskReserve(free: [2]u64, reserve: u64) !void {
    for (free) |bytes| if (bytes < reserve) return error.InsufficientDiskReserve;
}
pub fn calibrationConnections(n: usize) !void {
    if (n < 2 or n > 1024 or n % 2 != 0) return error.CalibrationConnectionsMustBeEven;
}
pub fn idleConnections(n: usize) !void {
    if (n < 1 or n > 1024) return error.UnsafeConnectionRange;
}
pub fn summarize(h: s.H, data: std.json.Value) ![]const u8 {
    const Group = struct { workload: []const u8, connections: i64, framework: []const u8, items: std.ArrayList(std.json.Value) = .empty };
    var groups: std.ArrayList(Group) = .empty;
    var failed: std.ArrayList(std.json.Value) = .empty;
    for (try rows(data)) |row| {
        if (row.object.contains("failure") or !row.object.contains("oha")) {
            try failed.append(h.a, row);
            continue;
        }
        const workload = try string(try s.field(row, "workload"));
        const framework = try string(try s.field(row, "framework"));
        const connection = try integer(try s.field(row, "connections"));
        var found: ?usize = null;
        for (groups.items, 0..) |group, index| if (std.mem.eql(u8, workload, group.workload) and std.mem.eql(u8, framework, group.framework) and connection == group.connections) {
            found = index;
            break;
        };
        const index = found orelse blk: {
            try groups.append(h.a, .{ .workload = workload, .connections = connection, .framework = framework });
            break :blk groups.items.len - 1;
        };
        try groups.items[index].items.append(h.a, row);
    }
    const Order = struct {
        fn less(_: void, a: Group, b: Group) bool {
            const order = std.mem.order(u8, a.workload, b.workload);
            if (order != .eq) return order == .lt;
            if (a.connections != b.connections) return a.connections < b.connections;
            return std.mem.lessThan(u8, a.framework, b.framework);
        }
    };
    std.mem.sort(Group, groups.items, {}, Order.less);
    var out: std.Io.Writer.Allocating = .init(h.a);
    const w = &out.writer;
    try w.print("classification: {s}\n\nMedians of all completed rounds; not pooled percentiles. CPU: one core = 100%; errors are summed, never removed.\n\n", .{try string(try s.field(data, "classification"))});
    try w.writeAll("| Workload | Connections | Framework | Rounds | HTTP 200/s | Attempts/s | P50 ms | P95 ms | P99 ms | P99.9 ms | CPU % | RSS KiB | Threads | Non-200 | Client errors | Error % |\n|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n");
    for (groups.items) |group| {
        const m = try metrics(h, group.items.items);
        try w.print("| {s} | {d} | {s} | {d} | {d:.0} | {d:.0} |", .{ group.workload, group.connections, group.framework, group.items.items.len, try number(try s.field(m, "http_200_per_second")), try number(try s.field(m, "attempts_per_second")) });
        for ([_][]const u8{ "p50_ms", "p95_ms", "p99_ms", "p99.9_ms" }) |key| try w.print(" {d:.3} |", .{try number(try s.field(m, key))});
        try w.print(" {d:.1} | {d:.0} | {d:.0} | {d:.0} | {d:.0} | {d:.4} |\n", .{ try number(try s.field(m, "cpu_percent")), try number(try s.field(m, "rss_kib")), try number(try s.field(m, "threads")), try number(try s.field(m, "non_200")), try number(try s.field(m, "client_errors")), try number(try s.field(m, "error_percent")) });
    }
    try w.print("\nFailed cases: {d}. Full requested matrix completion is not implied by a subset table.\n", .{failed.items.len});
    const excluded = if (data.object.get("excluded_runs")) |v| v.array.items.len else 0;
    try w.print("Excluded prior cases retained in raw evidence: {d}.\n", .{excluded});
    for (failed.items) |row| try w.print("- {s} / {s} / {d} / round {d}: {s}\n", .{ try string(try s.field(row, "framework")), try string(try s.field(row, "workload")), try integer(try s.field(row, "connections")), try integer(try s.field(row, "round")), if (row.object.get("failure")) |v| try string(v) else "incomplete" });
    return out.toOwnedSlice();
}
pub fn cli(h: s.H, args: []const []const u8) !void {
    if (args.len == 0) return error.MissingEvidenceOperation;
    const mode = args[0];
    var result: ?std.json.Value = null;
    if (std.mem.eql(u8, mode, "micro")) {
        if (args.len < 2 or args.len > 3) return error.InvalidArguments;
        try validateMicro(try h.json(try h.read(args[1])), args.len == 3 and std.mem.eql(u8, args[2], "--paired"));
        try std.Io.File.stdout().writeStreamingAll(h.io, "{}\n");
        return;
    } else if (std.mem.eql(u8, mode, "http")) {
        if (args.len != 2) return error.InvalidArguments;
        const v = try validateHttp(h, try h.json(try h.read(args[1])));
        result = try h.json(try h.encode(.{ .completed = v.completed.len, .failures = v.failures }));
    } else if (std.mem.eql(u8, mode, "matrix")) {
        if (args.len < 3) return error.InvalidArguments;
        const data = try h.json(try h.read(args[1]));
        const frameworks: []const []const u8 = if (std.mem.eql(u8, args[2], "--frameworks") and args.len > 3) args[3..] else if (args.len != 3) return error.InvalidArguments else if (std.mem.eql(u8, args[2], "baseline")) &baseline else if (std.mem.eql(u8, args[2], "after")) &after else return error.InvalidMatrixVariant;
        const v = try validateMatrix(h, data, frameworks);
        result = try h.json(try h.encode(.{ .completed = v.completed.len, .failures = v.failures }));
    } else if (std.mem.eql(u8, mode, "compare")) {
        if (args.len != 3) return error.InvalidArguments;
        result = try compare(h, try h.json(try h.read(args[1])), try h.json(try h.read(args[2])));
    } else if (std.mem.eql(u8, mode, "metrics")) {
        if (args.len != 2) return error.InvalidArguments;
        result = try metrics(h, try rows(try h.json(try h.read(args[1]))));
    } else if (std.mem.eql(u8, mode, "diagnostics")) {
        if (args.len != 2) return error.InvalidArguments;
        result = try diagnostics(h, try h.read(args[1]));
    } else if (std.mem.eql(u8, mode, "summarize")) {
        if (args.len != 2) return error.InvalidArguments;
        try std.Io.File.stdout().writeStreamingAll(h.io, try summarize(h, try h.json(try h.read(args[1]))));
        return;
    } else if (std.mem.eql(u8, mode, "calibration-connections") or std.mem.eql(u8, mode, "idle-connections")) {
        if (args.len != 2) return error.InvalidArguments;
        const n = try std.fmt.parseInt(usize, args[1], 10);
        if (std.mem.eql(u8, mode, "calibration-connections")) {
            calibrationConnections(n) catch {
                std.debug.print("connections must be even\n", .{});
                std.process.exit(2);
            };
        } else idleConnections(n) catch {
            std.debug.print("safe connection range is 1..1024\n", .{});
            std.process.exit(2);
        };
        return;
    } else if (std.mem.eql(u8, mode, "zap-cleanup")) {
        if (args.len != 4) return error.InvalidArguments;
        const report = try @import("benchmark_cleanup.zig").cleanup(h, args[1], try std.fmt.parseFloat(f64, args[2]), try std.fmt.parseFloat(f64, args[3]));
        result = try h.json(try h.encode(report));
    } else if (std.mem.eql(u8, mode, "disk-reserve")) {
        if (args.len != 3) return error.InvalidArguments;
        const reserve = try std.fmt.parseInt(u64, args[2], 10);
        var free: [2]u64 = undefined;
        for ([_][]const u8{ args[1], h.env.get("TMPDIR") orelse "/tmp" }, &free) |directory, *bytes| {
            const output = try h.run(&.{ "df", "-Pk", directory }, null, h.env);
            var lines = std.mem.tokenizeScalar(u8, output, '\n');
            _ = lines.next() orelse return error.DiskProbe;
            const line = lines.next() orelse return error.DiskProbe;
            var fields = std.mem.tokenizeAny(u8, line, " \t");
            for (0..3) |_| _ = fields.next() orelse return error.DiskProbe;
            bytes.* = std.math.mul(u64, try std.fmt.parseInt(u64, fields.next() orelse return error.DiskProbe, 10), 1024) catch return error.DiskProbe;
        }
        diskReserve(free, reserve) catch |err| {
            std.debug.print("insufficient disk reserve; checkpoint retained, no case started\n", .{});
            return err;
        };
        result = try h.json("{}");
    } else return error.UnknownEvidenceOperation;
    try std.Io.File.stdout().writeStreamingAll(h.io, try h.encode(result.?));
}
