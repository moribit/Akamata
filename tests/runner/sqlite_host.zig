//! Offline D1-shaped host for isolated living-example databases only.
//! This is a SQLite adapter fixture, not a Cloudflare D1 emulator.
const std = @import("std");
const c = @import("sqlite3");
pub fn main(init: std.process.Init) !void {
    const a = init.arena.allocator();
    const args = try init.minimal.args.toSlice(a);
    if (args.len != 2) return error.ExpectedIsolatedDatabasePath;
    var buffer: [4096]u8 = undefined;
    var reader = std.Io.File.stdin().readerStreaming(init.io, &buffer);
    const text = try reader.interface.allocRemaining(a, .limited(16 * 1024 * 1024));
    const request = (try std.json.parseFromSlice(std.json.Value, a, text, .{ .allocate = .alloc_always })).value;
    if (request != .object) return error.ExpectedRequestObject;
    const path = try a.dupeSentinel(u8, args[1], 0);
    var db: ?*c.sqlite3 = null;
    const opened = c.sqlite3_open_v2(path.ptr, &db, c.SQLITE_OPEN_READWRITE | c.SQLITE_OPEN_CREATE | c.SQLITE_OPEN_FULLMUTEX, null);
    defer if (db) |handle| {
        _ = c.sqlite3_close(handle);
    };
    if (opened != c.SQLITE_OK or db == null) return error.SqliteOpen;
    const handle = db.?;
    _ = c.sqlite3_busy_timeout(handle, 5000);
    var result: std.json.Value = .{ .object = .empty };
    if (request.object.get("schema")) |schema| {
        if (schema != .null) {
            if (schema != .string) return error.ExpectedSchemaString;
            if (c.sqlite3_exec(handle, (try a.dupeSentinel(u8, schema.string, 0)).ptr, null, null, null) != c.SQLITE_OK) return error.SqliteSchema;
            try std.Io.File.stdout().writeStreamingAll(init.io, "{}\n");
            return;
        }
    }
    const sql = request.object.get("sql") orelse return error.MissingSql;
    const parameters = request.object.get("args") orelse return error.MissingArgs;
    if (sql != .string or parameters != .array) return error.InvalidQuery;
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(handle, sql.string.ptr, @intCast(sql.string.len), &stmt, null) != c.SQLITE_OK or stmt == null) return error.SqlitePrepare;
    defer _ = c.sqlite3_finalize(stmt.?);
    if (c.sqlite3_bind_parameter_count(stmt.?) != parameters.array.items.len) return error.InvalidBindCount;
    for (parameters.array.items, 1..) |value, index| {
        const rc = switch (value) {
            .null => c.sqlite3_bind_null(stmt.?, @intCast(index)),
            .integer => |v| c.sqlite3_bind_int64(stmt.?, @intCast(index), v),
            .float => |v| c.sqlite3_bind_double(stmt.?, @intCast(index), v),
            .string => |v| c.sqlite3_bind_text(stmt.?, @intCast(index), v.ptr, @intCast(v.len), null),
            .bool => |v| c.sqlite3_bind_int(stmt.?, @intCast(index), @intFromBool(v)),
            else => return error.UnsupportedBinding,
        };
        if (rc != c.SQLITE_OK) return error.SqliteBind;
    }
    const before = c.sqlite3_total_changes64(handle);
    const count: usize = @intCast(c.sqlite3_column_count(stmt.?));
    var columns: std.json.Array = .init(a);
    for (0..count) |index| try columns.append(.{ .string = try a.dupe(u8, std.mem.span(c.sqlite3_column_name(stmt.?, @intCast(index)))) });
    var rows: std.json.Array = .init(a);
    while (true) {
        const rc = c.sqlite3_step(stmt.?);
        if (rc == c.SQLITE_DONE) break;
        if (rc != c.SQLITE_ROW) return error.SqliteStep;
        var row: std.json.ObjectMap = .empty;
        for (0..count) |index| {
            const column: c_int = @intCast(index);
            const value: std.json.Value = switch (c.sqlite3_column_type(stmt.?, column)) {
                c.SQLITE_NULL => .null,
                c.SQLITE_INTEGER => .{ .integer = c.sqlite3_column_int64(stmt.?, column) },
                c.SQLITE_FLOAT => .{ .float = c.sqlite3_column_double(stmt.?, column) },
                c.SQLITE_TEXT => blk: {
                    const data = c.sqlite3_column_text(stmt.?, column);
                    const len: usize = @intCast(c.sqlite3_column_bytes(stmt.?, column));
                    break :blk .{ .string = try a.dupe(u8, data[0..len]) };
                },
                else => return error.UnsupportedBlobInJsonHost,
            };
            try row.put(a, columns.items[index].string, value);
        }
        try rows.append(.{ .object = row });
    }
    var meta: std.json.ObjectMap = .empty;
    try meta.put(a, "changes", .{ .integer = c.sqlite3_total_changes64(handle) - before });
    try meta.put(a, "last_row_id", .{ .integer = c.sqlite3_last_insert_rowid(handle) });
    try result.object.put(a, "results", .{ .array = rows });
    try result.object.put(a, "columns", .{ .array = columns });
    try result.object.put(a, "meta", .{ .object = meta });
    try std.Io.File.stdout().writeStreamingAll(init.io, try std.json.Stringify.valueAlloc(a, result, .{}));
}
