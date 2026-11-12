const std = @import("std");
const builtin = @import("builtin");
const s = @import("support.zig");
const t = @import("transport.zig");
const e = @import("evaluation.zig");
const Scenario = enum { four_idle_upgrades, four_slow_streams, mixed_upgrade_stream, application_queue_overflow_recovery };
pub fn run(h: s.H, args: []const []const u8) !void {
    if (args.len == 0) return error.MissingFixtureBinary;
    const binary = try h.absolute(args[0]);
    var output: ?[]const u8 = null;
    var sharded = false;
    var record = false;
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--sharded")) sharded = true else if (std.mem.eql(u8, args[i], "--record-blockers")) record = true else if (std.mem.eql(u8, args[i], "--output")) {
            i += 1;
            if (i >= args.len) return error.MissingOutput;
            output = args[i];
        } else return error.UnknownOption;
    }
    var report = try e.Report.init(h, output orelse return error.MissingOutput, binary, "application isolation/admission gate; not full production certification");
    try report.put("zig_version", std.mem.trim(u8, try h.run(&.{ h.env.get("ZIG") orelse "zig", "version" }, null, h.env), "\r\n"));
    try report.put("command", args);
    var passed = true;
    const adapters: []const []const u8 = if (sharded) &.{ "threaded", if (builtin.os.tag == .linux) "epoll" else "kqueue", "sharded" } else &.{ "threaded", if (builtin.os.tag == .linux) "epoll" else "kqueue" };
    for (adapters) |adapter| for (std.enums.values(Scenario)) |scenario| {
        var entry = try e.Entry.init(h, binary, adapter, @tagName(scenario), if (scenario == .application_queue_overflow_recovery) "admission" else "stress");
        defer entry.deinit();
        var failure: ?anyerror = null;
        exercise(&entry, scenario) catch |err| {
            failure = err;
        };
        entry.finish(3000) catch |err| {
            failure = err;
        };
        try entry.save(&report, failure);
        if (failure) |err| {
            passed = false;
            try report.put("isolation_passed", false);
            try report.save();
            if (!record or scenario == .application_queue_overflow_recovery) return err;
        }
    };
    try report.put("isolation_passed", passed);
    try report.put("note", "Incremental isolation gate; full certification additionally requires lifecycle/ownership and fairness Contract parity.");
    try report.save();
    std.debug.print("application isolation evidence saved; isolation_passed={any}\n", .{passed});
}
fn exercise(entry: *e.Entry, scenario: Scenario) !void {
    const server = &entry.f.server;
    const h = server.h;
    if (scenario == .application_queue_overflow_recovery) {
        const owner = try server.connect();
        try owner.send(try t.w.request(h, "/application-hold", false, ""));
        var entered = false;
        for (0..100) |_| {
            if (std.mem.indexOf(u8, try h.read(server.log_path), "APPLICATION_WORK_ENTERED") != null) {
                entered = true;
                break;
            }
            h.sleep(10);
        }
        try s.check(entered, "finite-work start barrier");
        const queued = try server.connect();
        try queued.send(try t.w.request(h, "/hello", true, ""));
        h.sleep(50);
        const rejected = try server.connect();
        try rejected.send(try t.w.request(h, "/hello", true, ""));
        if (!std.mem.eql(u8, entry.f.adapter, "threaded")) {
            try rejected.eof();
            try entry.put("overflow_closed_without_response", true);
        } else {
            _ = try t.status(rejected, 200);
            try entry.put("threaded_option_ignored", true);
        }
        owner.close();
        _ = try t.status(queued, 200);
        _ = try e.probe(server);
        try entry.put("admission_recovered", true);
        return;
    }
    for (0..4) |index| {
        const upgrade = scenario == .four_idle_upgrades or (scenario == .mixed_upgrade_stream and index < 2);
        const c = try server.connect();
        try c.receiveBuffer(4096);
        try c.send(try t.w.request(h, if (upgrade) "/upgrade-wait" else "/large", false, if (upgrade) t.w.upgrade else ""));
        // Read only the headers. Never drain the 16 MiB response.
        const head = try c.headers();
        try s.check(std.mem.startsWith(u8, head, if (upgrade) "HTTP/1.1 101" else "HTTP/1.1 200"), "held connection handoff status");
    }
    h.sleep(30);
    const ms = e.probe(server) catch |err| {
        try entry.put("http_isolated", false);
        return err;
    };
    try entry.put("http_isolated", true);
    try entry.put("probe_ms", ms);
}
