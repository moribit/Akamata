const std = @import("std");
const zap = @import("zap");
extern "c" fn competitive_db_init() c_int;
const Row = extern struct { id: i64, name: [64]u8, weight: f64 };
extern "c" fn competitive_db_lookup(*Row) c_int;
extern "c" fn competitive_db_close() void;
fn handle(r: zap.Request) !void {
    const path = r.path orelse "/";
    var buffer: [128]u8 = undefined;
    if (r.methodAsEnum() == .GET and std.mem.eql(u8, path, "/plaintext")) {
        try r.setHeader("content-type", "text/plain; charset=utf-8");
        return r.sendBody("Hello, World!");
    }
    if (r.methodAsEnum() == .POST and std.mem.eql(u8, path, "/echo")) {
        try r.setHeader("content-type", "application/octet-stream");
        return r.sendBody(r.body orelse "");
    }
    try r.setHeader("content-type", "application/json");
    if (r.methodAsEnum() == .GET and std.mem.eql(u8, path, "/json")) {
        return r.sendBody(try zap.util.stringifyBuf(&buffer, .{ .message = @as([]const u8, "Hello, World!") }, .{}));
    }
    if (r.methodAsEnum() == .GET and std.mem.eql(u8, path, "/db/1")) {
        var row: Row = undefined;
        if (competitive_db_lookup(&row) < 0) {
            r.setStatusNumeric(500);
            return r.sendBody("{}");
        }
        return r.sendBody(try zap.util.stringifyBuf(&buffer, .{ .id = row.id, .name = std.mem.sliceTo(&row.name, 0), .weight = row.weight }, .{}));
    }
    // zap's built-in Router is exact-path only. Explicit extraction is reported
    // separately from typed/generic route matching; it is not a router win claim.
    if (r.methodAsEnum() == .GET and std.mem.startsWith(u8, path, "/users/")) {
        var parts = std.mem.splitScalar(u8, path[7..], '/');
        const user = try std.fmt.parseInt(u64, parts.next() orelse return, 10);
        if (!std.mem.eql(u8, parts.next() orelse return, "posts")) return;
        const post = try std.fmt.parseInt(u64, parts.next() orelse return, 10);
        if (parts.next() != null) return;
        return r.sendBody(try zap.util.stringifyBuf(&buffer, .{ .user = user, .post = post }, .{}));
    }
    r.setStatusNumeric(404);
    try r.sendBody("{}");
}
pub fn main() !void {
    if (competitive_db_init() != 0) return error.DatabaseInitFailed;
    defer competitive_db_close();
    var listener = zap.HttpListener.init(.{ .port = 8088, .interface = "127.0.0.1", .on_request = handle, .log = false, .max_clients = 4096, .max_body_size = 1024 * 1024, .timeout = 60 });
    try listener.listen();
    zap.start(.{ .threads = 8, .workers = 1 });
}
