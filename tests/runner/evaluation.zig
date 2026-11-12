//! Shared evidence and teardown for private runtime evaluations only.
const std = @import("std");
const builtin = @import("builtin");
const s = @import("support.zig");
const t = @import("transport.zig");
pub const Report = struct {
    h: s.H,
    path: []const u8,
    root: std.json.ObjectMap = .empty,
    runs: std.json.Array,
    pub fn init(h: s.H, path: []const u8, binary: []const u8, scope: []const u8) !Report {
        var r: Report = .{ .h = h, .path = path, .runs = .init(h.a) };
        try r.put("platform", @tagName(builtin.os.tag));
        const digest = try h.sha256(binary);
        try r.put("binary_sha256", digest[0..]);
        try r.put("scope", scope);
        return r;
    }
    pub fn put(r: *Report, key: []const u8, data: anytype) !void {
        try r.root.put(r.h.a, key, try r.h.json(try r.h.encode(data)));
    }
    pub fn save(r: *Report) !void {
        try r.root.put(r.h.a, "runs", .{ .array = r.runs });
        try r.h.write(r.path, try r.h.encode(std.json.Value{ .object = r.root }));
    }
};
pub const Entry = struct {
    f: t.Fixture,
    fields: std.json.ObjectMap = .empty,
    pub fn init(h: s.H, binary: []const u8, adapter: []const u8, name: []const u8, profile: []const u8) !Entry {
        return initLimited(h, binary, adapter, name, profile, null);
    }
    pub fn initLimited(h: s.H, binary: []const u8, adapter: []const u8, name: []const u8, profile: []const u8, fd_limit: ?u64) !Entry {
        var e: Entry = .{ .f = try t.Fixture.startLimited(h, binary, adapter, profile, false, fd_limit) };
        errdefer e.f.deinit();
        try e.put("adapter", adapter);
        try e.put("scenario", name);
        return e;
    }
    pub fn put(e: *Entry, key: []const u8, data: anytype) !void {
        const h = e.f.server.h;
        try e.fields.put(h.a, key, try h.json(try h.encode(data)));
    }
    /// Held clients stay open until drain completes, as in the original suite.
    pub fn finish(e: *Entry, timeout_ms: u32) !void {
        const server = &e.f.server;
        const h = server.h;
        const start = h.now();
        const requested = if (e.fields.get("shutdown_requested")) |flag| flag == .bool and flag.bool else false;
        if (server.child.id != null and !requested) server.signal(.TERM);
        server.wait(timeout_ms) catch |err| {
            server.signal(.KILL);
            server.wait(1000) catch {};
            return err;
        };
        if (!e.fields.contains("shutdown_ms")) try e.put("shutdown_ms", milliseconds(h.now() - start));
        for (server.clients.items) |client| client.close();
        const log = try h.read(server.log_path);
        try s.check(std.mem.indexOf(u8, log, "memory address") == null, "evaluation allocator leak");
        const allocator = try stats(h, log, "BENCH_STATS ");
        try s.check((try s.field(allocator, "live")).integer == 0, "no live framework allocations after shutdown");
        try e.fields.put(h.a, "allocator", allocator);
        const sessions = try stats(h, log, "SESSION_STATS ");
        try s.check((try s.field(sessions, "created")).integer == (try s.field(sessions, "closed")).integer, "all sessions reclaimed");
        try e.fields.put(h.a, "sessions", sessions);
    }
    pub fn save(e: *Entry, report: *Report, failure: ?anyerror) !void {
        try e.put("success", failure == null);
        if (failure) |err| {
            try e.put("error", @errorName(err));
            try e.put("fixture_log", try e.f.server.h.read(e.f.server.log_path));
        }
        try report.runs.append(.{ .object = e.fields });
        try report.save();
    }
    pub fn deinit(e: *Entry) void {
        e.f.deinit();
    }
};
pub fn milliseconds(ns: i96) f64 {
    return @as(f64, @floatFromInt(ns)) / std.time.ns_per_ms;
}
pub fn stats(h: s.H, log: []const u8, marker: []const u8) !std.json.Value {
    const start = (std.mem.indexOf(u8, log, marker) orelse return error.MissingRuntimeStatistics) + marker.len;
    const end = std.mem.indexOfScalarPos(u8, log, start, '\n') orelse log.len;
    return h.json(log[start..end]);
}
pub fn probe(server: *t.w.Server) !f64 {
    const h = server.h;
    const client = try server.connect();
    defer client.close();
    client.timeout_ms = 250;
    const start = h.now();
    try client.send(try t.w.request(h, "/hello", true, ""));
    _ = try t.status(client, 200);
    const elapsed = milliseconds(h.now() - start);
    try s.check(elapsed < 250, "unrelated HTTP completes within isolation budget");
    return elapsed;
}
