//! Offline cost experiments, not network throughput or competitive ranking.
const std = @import("std");
const ak = @import("akamata");
const clock = ak.observability.clock;
const Message = struct { message: []const u8 };
const Nested = struct { user: struct { id: u64, name: []const u8 }, enabled: bool, optional: ?u32 };
const Numbers = struct { items: []const u64 };

fn report(name: []const u8, implementation: []const u8, round: usize, count: usize, started: u64, checksum: usize) void {
    const ns = clock.elapsedNs(started);
    std.debug.print("MICRO {{\"workload\":\"{s}\",\"implementation\":\"{s}\",\"round\":{d},\"iterations\":{d},\"elapsed_ns\":{d},\"ns_per_operation\":{d},\"checksum\":{d}}}\n", .{ name, implementation, round, count, ns, ns / count, checksum });
}

fn jsonRound(comptime T: type, name: []const u8, value: T, count: usize, round: usize, comptime fast: bool) !void {
    var bytes: [131072]u8 = undefined;
    var checksum: usize = 0;
    const started = clock.monotonicNs();
    for (0..count) |_| {
        var writer = std.Io.Writer.fixed(&bytes);
        if (fast) try ak.json.stringify(value, &writer) else try std.json.Stringify.value(value, .{}, &writer);
        std.mem.doNotOptimizeAway(writer.buffered());
        checksum +%= writer.end;
    }
    report(name, if (fast) "akamata" else "std.json", round, count, started, checksum);
}

fn jsonCase(name: []const u8, value: anytype, count: usize) !void {
    // Byte equality is checked outside timed regions. This fixture deliberately
    // uses the same options and supported type shapes on both implementations.
    var fast: std.Io.Writer.Allocating = .init(std.heap.smp_allocator);
    defer fast.deinit();
    var standard: std.Io.Writer.Allocating = .init(std.heap.smp_allocator);
    defer standard.deinit();
    try ak.json.stringify(value, &fast.writer);
    try std.json.Stringify.value(value, .{}, &standard.writer);
    if (!std.mem.eql(u8, fast.written(), standard.written())) return error.JsonWireMismatch;
    for (1..6) |round| {
        if (round % 2 == 0) {
            try jsonRound(@TypeOf(value), name, value, count, round, false);
            try jsonRound(@TypeOf(value), name, value, count, round, true);
        } else {
            try jsonRound(@TypeOf(value), name, value, count, round, true);
            try jsonRound(@TypeOf(value), name, value, count, round, false);
        }
    }
    for (1..6) |round| {
        var arena: std.heap.ArenaAllocator = .init(std.heap.smp_allocator);
        defer arena.deinit();
        var checksum: usize = 0;
        const started = clock.monotonicNs();
        for (0..count) |_| {
            const parsed = try ak.json.parseLeaky(@TypeOf(value), arena.allocator(), standard.written());
            std.mem.doNotOptimizeAway(&parsed);
            checksum +%= standard.written().len;
            _ = arena.reset(.retain_capacity);
        }
        // Akamata decoding delegates to this exact standard-library parser.
        report(name, "deserialize.std.json.via.akamata", round, count, started, checksum);
    }
}

fn parserCase(name: []const u8, bytes: []const u8, count: usize) !void {
    var arena: std.heap.ArenaAllocator = .init(std.heap.smp_allocator);
    defer arena.deinit();
    _ = try ak.http.parser.parseRequest(arena.allocator(), bytes, .{});
    _ = arena.reset(.retain_capacity);
    for (1..6) |round| {
        var checksum: usize = 0;
        const started = clock.monotonicNs();
        for (0..count) |_| {
            const parsed = try ak.http.parser.parseRequest(arena.allocator(), bytes, .{});
            std.mem.doNotOptimizeAway(&parsed);
            checksum +%= parsed.request.path.len + parsed.request.headers.len;
            _ = arena.reset(.retain_capacity);
        }
        report(name, "http.parser", round, count, started, checksum);
    }
}

const Kind = enum { literal, parameter, wildcard };
fn routeTypes(comptime count: usize, comptime kind: Kind) [count]type {
    @setEvalBranchQuota(2_000_000);
    var result: [count]type = undefined;
    for (0..count) |index| {
        result[index] = struct {
            pub const http_method: ak.Method = .GET;
            pub const route_path = switch (kind) {
                .literal => std.fmt.comptimePrint("/r/{d}", .{index}),
                .parameter => std.fmt.comptimePrint("/r/{d}/:id", .{index}),
                .wildcard => std.fmt.comptimePrint("/r/{d}/*rest", .{index}),
            };
        };
    }
    return result;
}
fn routingCase(comptime count: usize, comptime kind: Kind) !void {
    const Graph = ak.static_router.Graph(comptime routeTypes(count, kind));
    var path_buffer: [64]u8 = undefined;
    // Alternate first/middle/last/missing at runtime, so this is not a constant
    // folded lookup or a misleading single best-case route.
    const iterations = 100_000;
    for (1..6) |round| {
        var checksum: usize = 0;
        const started = clock.monotonicNs();
        for (0..iterations) |index| {
            const route = ([_]usize{ 0, count / 2, count - 1, count })[index % 4];
            const path = try std.fmt.bufPrint(&path_buffer, switch (kind) {
                .literal => "/r/{d}",
                .parameter => "/r/{d}/42",
                .wildcard => "/r/{d}/rest/of/path",
            }, .{route});
            std.mem.doNotOptimizeAway(path);
            if (Graph.match(.GET, path)) |matched| {
                checksum +%= matched.index + matched.params.len;
                std.mem.doNotOptimizeAway(&matched);
            }
        }
        report(std.fmt.comptimePrint("routes-{d}-{s}", .{ count, @tagName(kind) }), "matcher-plus-path-format", round, iterations, started, checksum);
    }
}

pub fn main() !void {
    try parserCase("http-small", "GET /plaintext HTTP/1.1\r\nHost: fixture\r\n\r\n", 200_000);
    try parserCase("http-headers", "POST /echo?a=b HTTP/1.1\r\nHost: fixture\r\nContent-Length: 3\r\nContent-Type: application/octet-stream\r\nAccept: */*\r\nConnection: keep-alive\r\nX-Request-Id: test\r\nX-Forwarded-For: 127.0.0.1\r\nUser-Agent: fixture\r\n\r\nabc", 200_000);
    try jsonCase("json-small", Message{ .message = "Hello, World!" }, 200_000);
    var medium: [1024]u8 = @splat('x');
    try jsonCase("json-medium", Message{ .message = &medium }, 20_000);
    var large: [65536]u8 = @splat('x');
    try jsonCase("json-large", Message{ .message = &large }, 1_000);
    try jsonCase("json-nested", Nested{ .user = .{ .id = 42, .name = "Alice\n東京" }, .enabled = true, .optional = null }, 100_000);
    var numbers: [512]u64 = undefined;
    for (&numbers, 0..) |*number, index| number.* = index;
    try jsonCase("json-array", Numbers{ .items = &numbers }, 5_000);
    inline for (.{ 10, 100, 1000 }) |count| {
        inline for (.{ Kind.literal, Kind.parameter, Kind.wildcard }) |kind| try routingCase(count, kind);
    }
}
