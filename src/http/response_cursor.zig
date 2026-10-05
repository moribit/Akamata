//! Shared incremental response serialization. Slices borrow response storage;
//! partial transport progress never advances beyond bytes already copied.
const std = @import("std");
const response = @import("response.zig");
const status = @import("status.zig");
pub const Cursor = struct {
    headers: []const response.Header,
    body: []const u8,
    status_line: [96]u8 = undefined,
    status_len: usize,
    length_line: [64]u8 = undefined,
    length_len: usize = 0,
    connection: []const u8,
    phase: u8 = 0,
    header_index: usize = 0,
    header_part: u8 = 0,
    current: []const u8 = "",
    pub fn init(res: *const response.Response) !Cursor {
        var self: Cursor = .{ .headers = res.headers.items, .body = if (res.suppress_body) "" else res.body.items, .status_len = 0, .connection = "" };
        const wire_status: u16 = if (res.status_code >= 100 and res.status_code <= 599) res.status_code else 500;
        const code: status.Code = @fromBackingInt(wire_status);
        self.status_len = (try std.fmt.bufPrint(&self.status_line, "HTTP/1.1 {d} {s}\r\n", .{ wire_status, code.phrase() })).len;
        var saw_length = false;
        var saw_connection = false;
        for (res.headers.items) |h| {
            if (std.ascii.eqlIgnoreCase(h.name, "content-length")) saw_length = true;
            if (std.ascii.eqlIgnoreCase(h.name, "connection")) saw_connection = true;
        }
        if (!res.is_upgrade) {
            if (!saw_length) self.length_len = (try std.fmt.bufPrint(&self.length_line, "content-length: {d}\r\n", .{res.body.items.len})).len;
            if (!saw_connection) self.connection = if (res.keep_alive) "connection: keep-alive\r\n" else "connection: close\r\n";
        }
        return self;
    }
    pub fn nextSlice(self: *Cursor) ?[]const u8 {
        while (self.current.len == 0) {
            switch (self.phase) {
                0 => {
                    self.phase = 1;
                    self.current = self.status_line[0..self.status_len];
                },
                1 => {
                    if (self.header_index == self.headers.len) {
                        self.phase = 2;
                        continue;
                    }
                    const h = self.headers[self.header_index];
                    self.current = switch (self.header_part) {
                        0 => h.name,
                        1 => ": ",
                        2 => h.value,
                        3 => "\r\n",
                        else => unreachable,
                    };
                    self.header_part += 1;
                    if (self.header_part == 4) {
                        self.header_part = 0;
                        self.header_index += 1;
                    }
                },
                2 => {
                    self.phase = 3;
                    self.current = self.length_line[0..self.length_len];
                },
                3 => {
                    self.phase = 4;
                    self.current = self.connection;
                },
                4 => {
                    self.phase = 5;
                    self.current = "\r\n";
                },
                5 => {
                    self.phase = 6;
                    self.current = self.body;
                },
                else => return null,
            }
        }
        return self.current;
    }
    pub fn consume(self: *Cursor, n: usize) void {
        self.current = self.current[n..];
    }
    pub fn fill(self: *Cursor, buffer: []u8) usize {
        var count: usize = 0;
        while (count < buffer.len) {
            const bytes = self.nextSlice() orelse break;
            const n = @min(bytes.len, buffer.len - count);
            @memcpy(buffer[count..][0..n], bytes[0..n]);
            self.consume(n);
            count += n;
        }
        return count;
    }
};

test "cursor one-byte output preserves framing, large headers and HEAD length" {
    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();
    var res: response.Response = .init(arena.allocator());
    try res.header("x-empty", "");
    try res.text("hello");
    res.suppress_body = true;
    var cursor = try Cursor.init(&res);
    var output: std.Io.Writer.Allocating = .init(std.testing.allocator);
    defer output.deinit();
    var byte: [1]u8 = undefined;
    while (cursor.fill(&byte) != 0) try output.writer.writeAll(&byte);
    try std.testing.expectEqualStrings("HTTP/1.1 200 OK\r\nx-empty: \r\ncontent-type: text/plain; charset=utf-8\r\ncontent-length: 5\r\nconnection: keep-alive\r\n\r\n", output.written());
}
