//! Portable object storage contract. Native filesystem and Workers R2 adapt
//! to this VTable; metadata and range semantics stay application-facing.
const std = @import("std");
const stream = @import("stream.zig");
const mime = @import("http/mime.zig");

pub const Error = error{ NotFound, InvalidRange, InvalidCursor, InvalidLimit, PreconditionFailed, PermissionDenied, Unavailable, BackendFailure };
pub const Range = struct { offset: u64, length: ?u64 = null };
pub const Metadata = struct {
    size: u64,
    etag: ?[]const u8 = null,
    content_type: ?[]const u8 = null,
    modified_at_ms: ?i64 = null,
    custom_json: ?[]const u8 = null,
};
pub const PutOptions = struct { content_type: ?[]const u8 = null, metadata_json: ?[]const u8 = null, if_match: ?[]const u8 = null };
pub const GetOptions = struct { range: ?Range = null, if_match: ?[]const u8 = null, if_none_match: ?[]const u8 = null };
pub const Object = struct { metadata: Metadata, body: stream.Reader };
pub const ListEntry = struct { key: []const u8, metadata: Metadata };

/// All slices, including metadata and the opaque continuation token, belong
/// to this result. They survive store mutation and destruction. Do not copy
/// an owning page or free its slices individually; call deinit exactly once.
pub const ListPage = struct {
    entries: []const ListEntry,
    cursor: ?[]const u8,
    arena: std.heap.ArenaAllocator,

    pub fn deinit(self: *ListPage) void {
        self.arena.deinit();
        self.* = undefined;
    }
};
pub const PageData = struct { entries: []ListEntry, cursor: ?[]const u8 = null };

fn ownOptional(allocator: std.mem.Allocator, value: ?[]const u8) Error!?[]const u8 {
    return if (value) |bytes| allocator.dupe(u8, bytes) catch error.Unavailable else null;
}

/// Object keys are portable relative paths, never filesystem paths or URLs.
/// Adapters must call this at their trust boundary before accessing a backend.
pub fn validateKey(key: []const u8) Error!void {
    if (key.len == 0 or key.len > 1024 or key[0] == '/' or key[key.len - 1] == '/') return error.PermissionDenied;
    if (std.mem.indexOfScalar(u8, key, 0) != null or std.mem.indexOfScalar(u8, key, '\\') != null) return error.PermissionDenied;
    var parts = std.mem.splitScalar(u8, key, '/');
    while (parts.next()) |part| {
        if (part.len == 0 or std.mem.eql(u8, part, ".") or std.mem.eql(u8, part, "..")) return error.PermissionDenied;
    }
}

pub const Store = struct {
    ptr: *anyopaque,
    vtable: *const VTable,
    /// Borrowed request trace. Never retain an observed facade past dispatch.
    trace: ?*@import("observability/trace.zig").TraceContext = null,

    pub fn observed(self: Store, trace: *@import("observability/trace.zig").TraceContext) Store {
        var copy = self;
        copy.trace = trace;
        return copy;
    }
    pub const VTable = struct {
        put: *const fn (*anyopaque, []const u8, stream.Reader, PutOptions) Error!Metadata,
        get: *const fn (*anyopaque, []const u8, GetOptions) Error!Object,
        delete: *const fn (*anyopaque, []const u8) Error!void,
        head: *const fn (*anyopaque, []const u8) Error!Metadata,
        list: *const fn (*anyopaque, std.mem.Allocator, []const u8, ?[]const u8, usize) Error![]ListEntry,
        /// Optional for source compatibility with custom stores. Without this
        /// callback, list must implement sorted lexical key continuation.
        list_page: ?*const fn (*anyopaque, std.mem.Allocator, []const u8, ?[]const u8, usize) Error!PageData = null,
    };
    pub fn put(self: Store, key: []const u8, body: stream.Reader, options: PutOptions) Error!Metadata {
        var span = if (self.trace) |trace| trace.startSpan("storage.put") else null;
        defer if (span) |*s| s.end();
        return self.vtable.put(self.ptr, key, body, options);
    }
    pub fn get(self: Store, key: []const u8, options: GetOptions) Error!Object {
        var span = if (self.trace) |trace| trace.startSpan("storage.get") else null;
        defer if (span) |*s| s.end();
        return self.vtable.get(self.ptr, key, options);
    }
    pub fn delete(self: Store, key: []const u8) Error!void {
        var span = if (self.trace) |trace| trace.startSpan("storage.delete") else null;
        defer if (span) |*s| s.end();
        return self.vtable.delete(self.ptr, key);
    }
    pub fn head(self: Store, key: []const u8) Error!Metadata {
        var span = if (self.trace) |trace| trace.startSpan("storage.head") else null;
        defer if (span) |*s| s.end();
        return self.vtable.head(self.ptr, key);
    }
    pub fn list(self: Store, allocator: std.mem.Allocator, prefix: []const u8, cursor: ?[]const u8, limit: usize) Error![]ListEntry {
        var span = if (self.trace) |trace| trace.startSpan("storage.list") else null;
        defer if (span) |*s| s.end();
        return self.vtable.list(self.ptr, allocator, prefix, cursor, limit);
    }

    /// Preferred listing API. Cursor is opaque, scoped to this store/prefix,
    /// and not a snapshot: concurrent mutations may change subsequent pages.
    /// The caller's allocator owns the operation arena, including on failure.
    pub fn listPage(self: Store, allocator: std.mem.Allocator, prefix: []const u8, cursor: ?[]const u8, limit: usize) Error!ListPage {
        if (limit == 0 or limit > 1000) return error.InvalidLimit;
        if (prefix.len > 1024 or std.mem.indexOfScalar(u8, prefix, 0) != null or std.mem.indexOfScalar(u8, prefix, '\\') != null or std.mem.startsWith(u8, prefix, "/")) return error.PermissionDenied;
        var parts = std.mem.splitScalar(u8, prefix, '/');
        while (parts.next()) |part| if (std.mem.eql(u8, part, ".") or std.mem.eql(u8, part, "..")) return error.PermissionDenied;
        if (cursor) |token| if (token.len == 0 or token.len > 4096 or std.mem.indexOfScalar(u8, token, 0) != null) return error.InvalidCursor;
        var span = if (self.trace) |trace| trace.startSpan("storage.list") else null;
        defer if (span) |*s| s.end();
        var arena = std.heap.ArenaAllocator.init(allocator);
        errdefer arena.deinit();
        const gpa = arena.allocator();
        var data: PageData = undefined;
        if (self.vtable.list_page) |page| {
            data = try page(self.ptr, gpa, prefix, cursor, limit);
        } else {
            if (cursor) |token| validateKey(token) catch return error.InvalidCursor;
            const entries = try self.vtable.list(self.ptr, gpa, prefix, cursor, limit + 1);
            data = .{ .entries = entries[0..@min(entries.len, limit)], .cursor = if (entries.len > limit) entries[limit - 1].key else null };
        }
        if (data.entries.len > limit) return error.BackendFailure;
        // Legacy adapters may return store-owned metadata. Snapshot every
        // string before returning a uniformly owned result.
        for (data.entries) |*entry| {
            entry.key = gpa.dupe(u8, entry.key) catch return error.Unavailable;
            entry.metadata.etag = try ownOptional(gpa, entry.metadata.etag);
            entry.metadata.content_type = try ownOptional(gpa, entry.metadata.content_type);
            entry.metadata.custom_json = try ownOptional(gpa, entry.metadata.custom_json);
        }
        const next = try ownOptional(gpa, data.cursor);
        return .{ .entries = data.entries, .cursor = next, .arena = arena };
    }
};

pub const Conditional = enum { send, not_modified, precondition_failed };
pub fn evaluate(etag: ?[]const u8, if_none_match: ?[]const u8, if_match: ?[]const u8) Conditional {
    if (if_match) |expected| if (etag == null or !std.mem.eql(u8, etag.?, expected)) return .precondition_failed;
    if (if_none_match) |expected| if (etag != null and std.mem.eql(u8, etag.?, expected)) return .not_modified;
    return .send;
}

pub fn parseRange(value: []const u8, size: u64) !Range {
    // An empty representation has no satisfiable byte range, including a
    // suffix range. Reject it before arithmetic used by Content-Range.
    if (size == 0) return error.InvalidRange;
    if (!std.mem.startsWith(u8, value, "bytes=")) return error.InvalidRange;
    const raw = value[6..];
    const dash = std.mem.indexOfScalar(u8, raw, '-') orelse return error.InvalidRange;
    if (dash == 0) {
        const suffix = try std.fmt.parseInt(u64, raw[1..], 10);
        if (suffix == 0) return error.InvalidRange;
        const length = @min(suffix, size);
        return .{ .offset = size - length, .length = length };
    }
    const start = try std.fmt.parseInt(u64, raw[0..dash], 10);
    if (start >= size) return error.InvalidRange;
    if (dash + 1 == raw.len) return .{ .offset = start, .length = size - start };
    const end = try std.fmt.parseInt(u64, raw[dash + 1 ..], 10);
    if (end < start) return error.InvalidRange;
    return .{ .offset = start, .length = @min(end, size - 1) - start + 1 };
}

/// Stream an object into an Akamata Context with HTTP Range/conditional
/// semantics. The fixed buffer bounds application memory for firmware-sized
/// and larger downloads on both Native and Workers adapters.
pub fn serveDownload(c: anytype, store: Store, key: []const u8) !void {
    // Open once without a range so metadata slices can be owned by the object
    // reader state. This avoids unsafe adapter-global scratch buffers.
    var probe = try store.get(key, .{});
    defer probe.body.close();
    const full = probe.metadata;
    const requested_range = if (c.req.header("range")) |value| parseRange(value, full.size) catch {
        c.status(416);
        try c.header("content-range", try std.fmt.allocPrint(c.arena, "bytes */{d}", .{full.size}));
        return;
    } else null;
    const conditional = evaluate(full.etag, c.req.header("if-none-match"), c.req.header("if-match"));
    if (conditional == .not_modified) {
        c.status(304);
        return;
    }
    if (conditional == .precondition_failed) {
        c.status(412);
        return;
    }
    const length = if (requested_range) |range| range.length orelse (full.size - range.offset) else full.size;
    c.status(if (requested_range != null) 206 else 200);
    try c.header("accept-ranges", "bytes");
    try c.header("content-length", try std.fmt.allocPrint(c.arena, "{d}", .{length}));
    try c.header("content-type", full.content_type orelse mime.fromExt(key));
    if (full.etag) |etag| try c.header("etag", etag);
    if (requested_range) |range| try c.header("content-range", try std.fmt.allocPrint(c.arena, "bytes {d}-{d}/{d}", .{ range.offset, range.offset + length - 1, full.size }));
    if (std.ascii.eqlIgnoreCase(c.req.method(), "HEAD")) return;
    if (requested_range) |range| {
        var ranged = try store.get(key, .{ .range = range });
        defer ranged.body.close();
        return streamDownloadBody(c, ranged.body, length);
    }
    return streamDownloadBody(c, probe.body, length);
}

fn streamDownloadBody(c: anytype, body: stream.Reader, length: u64) !void {
    const writer = c.startStream(.{ .content_length = length }) catch |err| switch (err) {
        // The current Workers ABI returns one complete HTTP response buffer;
        // it has no socket writer to flush incrementally. Preserve portable
        // semantics with bounded object reads until that ABI becomes streaming.
        error.UnsupportedOnTarget => {
            var fallback_buffer: [64 * 1024]u8 = undefined;
            var remaining = length;
            while (remaining > 0) {
                const want: usize = @intCast(@min(remaining, fallback_buffer.len));
                const n = try body.read(fallback_buffer[0..want]);
                if (n == 0) break;
                try c.body(fallback_buffer[0..n]);
                remaining -= n;
            }
            return;
        },
        else => return err,
    };
    var buffer: [64 * 1024]u8 = undefined;
    while (true) {
        const n = try body.read(&buffer);
        if (n == 0) break;
        try writer.writeAll(buffer[0..n]);
        try writer.flush();
    }
}

test "HTTP range and conditionals" {
    try std.testing.expectEqual(Range{ .offset = 10, .length = 10 }, try parseRange("bytes=10-19", 100));
    try std.testing.expectEqual(Range{ .offset = 90, .length = 10 }, try parseRange("bytes=-10", 100));
    try std.testing.expectError(error.InvalidRange, parseRange("bytes=0-0", 0));
    try std.testing.expectError(error.InvalidRange, parseRange("bytes=0-", 0));
    try std.testing.expectError(error.InvalidRange, parseRange("bytes=-1", 0));
    try std.testing.expectEqual(Conditional.not_modified, evaluate("v1", "v1", null));
}

test "portable object keys reject traversal" {
    try validateKey("objects/a.bin");
    try std.testing.expectError(error.PermissionDenied, validateKey("../secret"));
    try std.testing.expectError(error.PermissionDenied, validateKey("objects//a"));
    try std.testing.expectError(error.PermissionDenied, validateKey("/absolute"));
    try std.testing.expectError(error.PermissionDenied, validateKey("objects\\a"));
}

pub const filesystem = @import("storage/filesystem.zig");

test {
    _ = filesystem;
}
