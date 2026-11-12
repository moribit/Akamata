//! Evidence failure paths; never start a benchmark load generator.
const std = @import("std");
const s = @import("support.zig");
const b = @import("benchmark_evidence.zig");
const w = @import("wire.zig");
fn clone(h: s.H, v: std.json.Value) !std.json.Value {
    return h.json(try h.encode(v));
}
fn reject(expected: anyerror, result: anytype) !void {
    if (result) |_| return error.ExpectedRejection else |err| try s.check(err == expected, @errorName(expected));
}
fn micro(h: s.H) !std.json.Value {
    var runs: std.json.Array = .init(h.a);
    for (1..4) |round| for ("ABCDEF") |case| for ([_]usize{ 1, 8, 32, 128 }) |threads| for ("AB") |variant| for (0..2) |_| {
        try runs.append(try h.json(try h.encode(.{ .round = round, .case = try h.a.dupe(u8, &.{case}), .threads = threads, .variant = try h.a.dupe(u8, &.{variant}), .errors = 0, .operations = 1000, .checksum = (1000 + 100 * threads) * 534 })));
    };
    return h.json(try h.encode(.{ .runs = runs.items }));
}
fn http(h: s.H) !std.json.Value {
    var runs: std.json.Array = .init(h.a);
    for (1..3) |cycle| for ([_][]const u8{ "db", "plaintext", "json", "echo-1024" }) |workload| for (b.connections) |connection| for (0..4) |position| {
        try runs.append(try h.json(try h.encode(.{ .cycle = cycle, .workload = workload, .connections = connection, .position = position, .variant = "ABBA"[position .. position + 1], .wire_checks = @as([7]?u8, @splat(null)) })));
    };
    return h.json(try h.encode(.{ .runs = runs.items }));
}
fn matrix(h: s.H, frameworks: []const []const u8) !std.json.Value {
    var runs: std.json.Array = .init(h.a);
    var binaries: std.json.ObjectMap = .empty;
    for (frameworks) |framework| {
        try binaries.put(h.a, framework, .null);
        for (b.workloads) |workload| for (b.connections) |connection| for (1..6) |round| {
            try runs.append(try h.json(try h.encode(.{ .framework = framework, .workload = workload, .connections = connection, .round = round, .wire_checks = @as([7]?u8, @splat(null)), .cpu_percent = 100, .rss_mean_kib = 1000, .threads_peak = 8, .oha = .{ .summary = .{ .total = 30 }, .statusCodeDistribution = .{ .@"200" = 3000, .@"503" = 1 }, .errorDistribution = .{ .timeout = 2 }, .latencyPercentiles = .{ .p50 = 0.001, .p95 = 0.001, .p99 = 0.001, .@"p99.9" = 0.001 } } })));
        };
    }
    return h.json(try h.encode(.{ .warmup_seconds = 10, .duration_seconds = 30, .rounds = 5, .os = "fixture", .cpu_count = 8, .oha = "fixture", .binaries = std.json.Value{ .object = binaries }, .runs = runs.items }));
}
pub fn run(h: s.H) !void {
    for ([_][]const u8{ "build.zig", ".github/workflows/ci.yml", ".github/workflows/runtime-sanitizer.yml" }) |path|
        try s.check(std.mem.indexOf(u8, try h.read(path), "python3") == null, "CI test entrypoints must use the Zig runner");
    const full_micro = try micro(h);
    try b.validateMicro(full_micro, true);
    var d = try clone(h, full_micro);
    d.object.getPtr("runs").?.array.items.len -= 1;
    try reject(error.MissingOrDuplicateMicro, b.validateMicro(d, true));
    d = try clone(h, full_micro);
    try d.object.getPtr("runs").?.array.append((try b.rows(d))[0]);
    try reject(error.MissingOrDuplicateMicro, b.validateMicro(d, true));
    d = try clone(h, full_micro);
    try (try b.rows(d))[0].object.put(h.a, "errors", .{ .integer = 1 });
    try reject(error.MicroErrors, b.validateMicro(d, true));
    d = try clone(h, full_micro);
    try (try b.rows(d))[0].object.put(h.a, "checksum", .{ .integer = 0 });
    try reject(error.LostRowData, b.validateMicro(d, true));
    const full_http = try http(h);
    try s.check((try b.validateHttp(h, full_http)).completed.len == 192, "complete HTTP evidence");
    d = try clone(h, full_http);
    d.object.getPtr("runs").?.array.items.len -= 1;
    try reject(error.IncompleteHttp, b.validateHttp(h, d));
    d = try clone(h, full_http);
    try d.object.getPtr("runs").?.array.append((try b.rows(d))[0]);
    try reject(error.DuplicateHttp, b.validateHttp(h, d));
    d = try clone(h, full_http);
    try (try b.rows(d))[0].object.put(h.a, "variant", .{ .string = "B" });
    try reject(error.WrongAbbaOrder, b.validateHttp(h, d));
    d = try clone(h, full_http);
    var failed = try clone(h, (try b.rows(d))[0]);
    try failed.object.put(h.a, "failure", .{ .string = "recorded setup failure" });
    try d.object.getPtr("runs").?.array.append(failed);
    const retained = try b.validateHttp(h, d);
    try s.check(retained.completed.len == 192 and retained.failures.len == 1, "failed HTTP attempt retained");
    const before = try matrix(h, &b.baseline);
    const after = try matrix(h, &b.after);
    const comparison = try b.compare(h, before, after);
    try s.check((try s.field(comparison, "baseline_cases")).integer == 1260 and (try s.field(comparison, "after_cases")).integer == 630, "full matrix size");
    const first = (try s.field(comparison, "comparisons")).array.items[0];
    const current = try s.field(first, "after");
    try s.check(try b.number(try s.field(current, "http_200_per_second")) == 100 and try b.number(try s.field(current, "client_errors")) == 10 and try b.number(try s.field(current, "non_200")) == 5 and try b.number(try s.field(first, "throughput_change_percent")) == 0, "matrix retains errors separately from completed responses");
    d = try clone(h, before);
    d.object.getPtr("runs").?.array.items.len -= 1;
    try reject(error.IncompleteMatrix, b.validateMatrix(h, d, &b.baseline));
    d = try clone(h, before);
    try d.object.getPtr("runs").?.array.append((try b.rows(d))[0]);
    try reject(error.DuplicateCompletedCase, b.validateMatrix(h, d, &b.baseline));
    d = try clone(h, after);
    try d.object.put(h.a, "os", .{ .string = "other" });
    try reject(error.EnvironmentDrift, b.compare(h, before, d));
    try reject(error.InsufficientDiskReserve, b.diskReserve(.{ 500, 1000 }, 1000));
    try reject(error.InsufficientDiskReserve, b.diskReserve(.{ 1000, 500 }, 1000));
    try b.diskReserve(.{ 1000, 1000 }, 1000);
    try b.calibrationConnections(2);
    try b.calibrationConnections(1024);
    try reject(error.CalibrationConnectionsMustBeEven, b.calibrationConnections(1026));
    const reports = try b.diagnostics(h, "info: started\nRUNTIME_COST {\"future_counter\":{\"count\":7}}\nBENCH_STATS {\"live\":0}\n");
    try s.check((try s.field(try s.field(try s.field(reports, "runtime_cost"), "future_counter"), "count")).integer == 7 and (try s.field(try s.field(reports, "allocator"), "live")).integer == 0, "future counters preserved");
    try reject(error.DuplicateDiagnostic, b.diagnostics(h, "RUNTIME_COST {}\nRUNTIME_COST {}\n"));
    try summary(h);
    try cleanup(h);
    try ownership(h);
    const calibration = try h.command(&.{ h.self, "evidence", "calibration-connections", "31" }, null, h.env);
    try s.check(calibration.term == .exited and calibration.term.exited == 2, "calibration rejects unequal split before load");
    try s.contains(calibration.stderr, "must be even");
    const idle = try h.command(&.{ h.self, "evidence", "idle-connections", "1025" }, null, h.env);
    try s.check(idle.term == .exited and idle.term.exited == 2, "idle rejects unsafe count before load");
    try s.contains(idle.stderr, "safe connection range");
    std.debug.print("benchmark evidence: DB (10) and competitive (9) original failure-path contracts, plus CI driver guard passed\n", .{});
}
fn summary(h: s.H) !void {
    var runs: std.json.Array = .init(h.a);
    for ([_]usize{ 100, 300, 2000 }, 1..) |rate, errors| {
        try runs.append(try h.json(try h.encode(.{ .framework = "fixture", .workload = "plaintext", .connections = 32, .round = 1, .cpu_percent = 100, .rss_mean_kib = 1000, .threads_peak = 8, .oha = .{ .summary = .{ .requestsPerSec = rate + errors + 2, .total = 1 }, .latencyPercentiles = .{ .p50 = 0.001, .p95 = 0.001, .p99 = 0.001, .@"p99.9" = 0.001 }, .errorDistribution = .{ .timeout = errors }, .statusCodeDistribution = .{ .@"200" = rate, .@"503" = 2 } } })));
    }
    try runs.append(try h.json("{\"framework\":\"fixture\",\"workload\":\"plaintext\",\"connections\":32,\"round\":4,\"failure\":\"spawn failed\"}"));
    const text = try b.summarize(h, try h.json(try h.encode(.{ .classification = "exploratory", .runs = runs.items })));
    for ([_][]const u8{ "| 3 | 300 | 304 |", "| 6 | 6 | 0.4975 |", "Failed cases: 1", "spawn failed", "not pooled percentiles" }) |fragment| try s.contains(text, fragment);
}
fn cleanup(h: s.H) !void {
    const temp = try h.temp();
    defer temp.deinit();
    const full = try h.a.alloc(u8, 65536);
    @memset(full, 'x');
    for ([_][]const u8{ "facil_io_tmpfile_full", "unrelated" }) |name| try h.write(try temp.file(name), full);
    try h.write(try temp.file("facil_io_tmpfile_partial"), full[0..40769]);
    try h.write(try temp.file("facil_io_tmpfile_other"), "not benchmark data");
    const old = try temp.file("facil_io_tmpfile_old");
    try h.write(old, "x");
    const now = std.Io.Clock.real.now(h.io).toNanoseconds();
    const f = try std.Io.Dir.cwd().openFile(h.io, old, .{ .mode = .read_write });
    defer f.close(h.io);
    try f.setTimestamps(h.io, .{ .modify_timestamp = .{ .new = .fromNanoseconds(now - 11 * std.time.ns_per_s) } });
    try std.Io.Dir.cwd().symLink(h.io, try temp.file("unrelated"), try temp.file("facil_io_tmpfile_symlink"), .{});
    try std.Io.Dir.cwd().hardLink(try temp.file("unrelated"), .cwd(), try temp.file("facil_io_tmpfile_hardlink"), h.io, .{});
    const seconds = @as(f64, @floatFromInt(now)) / std.time.ns_per_s;
    const report = try @import("benchmark_cleanup.zig").cleanup(h, temp.path, seconds - 1, seconds + 1);
    try s.check(report.removed_files == 2, "only benchmark payloads in the owner window removed");
    for ([_][]const u8{ "facil_io_tmpfile_other", "facil_io_tmpfile_old", "unrelated", "facil_io_tmpfile_symlink", "facil_io_tmpfile_hardlink" }) |name| try s.check(h.exists(try temp.file(name)), "unowned/linked data preserved");
    try s.check(!h.exists(try temp.file("facil_io_tmpfile_full")) and !h.exists(try temp.file("facil_io_tmpfile_partial")), "owned spill files removed");
}
fn ownership(h: s.H) !void {
    const temp = try h.temp();
    defer temp.deinit();
    const executable = try temp.file("watch_app");
    try std.Io.Dir.cwd().symLink(h.io, h.self, executable, .{});
    var env = try h.env.clone(h.a);
    const log = try temp.file("mock.jsonl");
    try h.write(log, "");
    try env.put("MOCK_LOG", log);
    var server = try w.Server.start(h, &.{executable}, temp.path, &env, 0);
    const pid = server.child.id.?;
    h.sleep(50);
    server.deinit();
    try s.check(std.c.kill(pid, .CONT) != 0 and std.posix.errno(-1) == .SRCH, "interrupted owner reaps only its child");
}
