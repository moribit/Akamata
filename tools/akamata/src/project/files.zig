const std = @import("std");
const closedir = @import("../native.zig").closedir;
const opendir = @import("../native.zig").opendir;
const readdir = @import("../native.zig").readdir;

pub fn makeDirRecursive(path: []const u8) !void {
    // libc mkdir, multi-segment.
    const Lib = struct {
        extern "c" fn mkdir(p: [*:0]const u8, mode: u32) c_int;
    };
    var alloc_state: std.heap.ArenaAllocator = .init(std.heap.smp_allocator);
    defer alloc_state.deinit();
    const a = alloc_state.allocator();

    var cur: std.ArrayList(u8) = .empty;
    var it = std.mem.splitScalar(u8, path, '/');
    while (it.next()) |seg| {
        if (seg.len == 0) continue;
        if (cur.items.len > 0) try cur.append(a, '/');
        try cur.appendSlice(a, seg);
        const z = try a.dupeSentinel(u8, cur.items, 0);
        _ = Lib.mkdir(z.ptr, 0o755);
    }
}

/// Directory portion of a path (everything before the last '/'), or "." if the
/// path has no separator.
pub fn dirName(path: []const u8) []const u8 {
    if (std.mem.lastIndexOfScalar(u8, path, '/')) |i| return path[0..i];
    return ".";
}

pub fn fileExists(path: []const u8) bool {
    var buf: [1024]u8 = undefined;
    if (path.len >= buf.len) return false;
    @memcpy(buf[0..path.len], path);
    buf[path.len] = 0;
    const FILE = opaque {};
    const Lib = struct {
        extern "c" fn fopen(p: [*:0]const u8, m: [*:0]const u8) ?*FILE;
        extern "c" fn fclose(s: *FILE) c_int;
    };
    const f = Lib.fopen(@ptrCast(&buf), "rb") orelse return false;
    _ = Lib.fclose(f);
    return true;
}

pub fn readFileAlloc(alloc: std.mem.Allocator, path: []const u8, max_bytes: usize) ![]u8 {
    const path_z = try alloc.dupeSentinel(u8, path, 0);
    defer alloc.free(path_z);
    const FILE = opaque {};
    const Lib = struct {
        extern "c" fn fopen(p: [*:0]const u8, m: [*:0]const u8) ?*FILE;
        extern "c" fn fread(ptr: [*]u8, size: usize, n: usize, s: *FILE) usize;
        extern "c" fn fclose(s: *FILE) c_int;
        extern "c" fn fseek(s: *FILE, off: c_long, whence: c_int) c_int;
        extern "c" fn ftell(s: *FILE) c_long;
    };
    const f = Lib.fopen(path_z.ptr, "rb") orelse return error.FileNotFound;
    defer _ = Lib.fclose(f);
    _ = Lib.fseek(f, 0, 2); // SEEK_END
    const sz_signed = Lib.ftell(f);
    if (sz_signed < 0) return error.FileNotFound;
    const sz: usize = @intCast(sz_signed);
    if (sz > max_bytes) return error.FileTooLarge;
    _ = Lib.fseek(f, 0, 0);
    const buf = try alloc.alloc(u8, sz);
    const got = Lib.fread(buf.ptr, 1, sz, f);
    return buf[0..got];
}

pub fn writeFileBytes(path: []const u8, bytes: []const u8) !void {
    var path_buf: [4096]u8 = undefined;
    if (path.len >= path_buf.len) return error.PathTooLong;
    @memcpy(path_buf[0..path.len], path);
    path_buf[path.len] = 0;
    const FILE = opaque {};
    const Lib = struct {
        extern "c" fn fopen(p: [*:0]const u8, m: [*:0]const u8) ?*FILE;
        extern "c" fn fwrite(ptr: [*]const u8, size: usize, n: usize, s: *FILE) usize;
        extern "c" fn fclose(s: *FILE) c_int;
    };
    const f = Lib.fopen(@ptrCast(&path_buf), "wb") orelse return error.WriteFailed;
    defer _ = Lib.fclose(f);
    _ = Lib.fwrite(bytes.ptr, 1, bytes.len, f);
}

pub fn deleteFile(path: []const u8) !void {
    const z = try std.heap.smp_allocator.dupeSentinel(u8, path, 0);
    defer std.heap.smp_allocator.free(z);
    const Lib = struct {
        extern "c" fn unlink(p: [*:0]const u8) c_int;
    };
    if (Lib.unlink(z.ptr) != 0) return error.DeleteFailed;
}

pub fn countSqlMigrations(path: []const u8) usize {
    var path_buf: [4096]u8 = undefined;
    if (path.len >= path_buf.len) return 0;
    @memcpy(path_buf[0..path.len], path);
    path_buf[path.len] = 0;
    const dir = opendir(@ptrCast(&path_buf)) orelse return 0;
    defer _ = closedir(dir);
    var count: usize = 0;
    while (readdir(dir)) |entry| {
        const name = std.mem.sliceTo(@as([*:0]const u8, @ptrCast(&entry.name)), 0);
        if (std.mem.endsWith(u8, name, ".sql")) count += 1;
    }
    return count;
}

pub fn removeFileIfExists(alloc: std.mem.Allocator, path: []const u8) !void {
    if (!fileExists(path)) return;
    const z = try alloc.dupeSentinel(u8, path, 0);
    defer alloc.free(z);
    if (unlink(z.ptr) != 0) return error.RemoveFailed;
}

pub extern "c" fn unlink(path: [*:0]const u8) c_int;

pub fn directoryExists(path: []const u8) bool {
    var buf: [4096]u8 = undefined;
    if (path.len >= buf.len) return false;
    @memcpy(buf[0..path.len], path);
    buf[path.len] = 0;
    const dir = opendir(@ptrCast(&buf)) orelse return false;
    _ = closedir(dir);
    return true;
}
