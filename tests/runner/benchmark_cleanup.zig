//! Reclaim only pinned facil.io spill payloads in an owned, stopped-server window.
const std = @import("std");
const builtin = @import("builtin");
const s = @import("support.zig");
const Info = struct { dev: u128, ino: u64, mode: u32, uid: u32, nlink: u64, size: i128, blocks: u64, modified_ns: i128 };
fn stat(fd: c_int, path: ?[*:0]const u8) !Info {
    if (builtin.os.tag == .linux) {
        const linux = std.os.linux;
        const requested: linux.STATX = .{ .TYPE = true, .UID = true, .NLINK = true, .MTIME = true, .INO = true, .SIZE = true, .BLOCKS = true };
        var raw: linux.Statx = undefined;
        while (true) {
            switch (linux.errno(linux.statx(fd, path orelse "", linux.AT.SYMLINK_NOFOLLOW | (if (path == null) @as(u32, linux.AT.EMPTY_PATH) else 0), requested, &raw))) {
                .SUCCESS => break,
                .INTR => continue,
                .NOENT => return error.FileNotFound,
                else => return error.StatSpillFile,
            }
        }
        const mask: u32 = @bitCast(requested);
        if (@as(u32, @bitCast(raw.mask)) & mask != mask) return error.IncompleteFileMetadata;
        return .{ .dev = (@as(u128, raw.dev_major) << 32) | raw.dev_minor, .ino = raw.ino, .mode = raw.mode, .uid = raw.uid, .nlink = raw.nlink, .size = raw.size, .blocks = raw.blocks, .modified_ns = @as(i128, raw.mtime.sec) * std.time.ns_per_s + raw.mtime.nsec };
    }
    var raw: std.c.Stat = undefined;
    const rc = if (path) |name| std.c.fstatat(fd, name, &raw, std.c.AT.SYMLINK_NOFOLLOW) else std.c.fstat(fd, &raw);
    if (rc != 0) {
        if (std.posix.errno(rc) == .NOENT) return error.FileNotFound;
        return error.StatSpillFile;
    }
    const modified = raw.mtime();
    const Device = @Int(.unsigned, @bitSizeOf(@TypeOf(raw.dev)));
    return .{ .dev = @as(Device, @bitCast(raw.dev)), .ino = @intCast(raw.ino), .mode = raw.mode, .uid = raw.uid, .nlink = raw.nlink, .size = raw.size, .blocks = @intCast(raw.blocks), .modified_ns = @as(i128, modified.sec) * std.time.ns_per_s + modified.nsec };
}
pub const Result = struct { directory: []const u8, since: f64, until: f64, removed_files: usize = 0, removed_allocated_bytes: u64 = 0, preserved_files: usize = 0 };
pub fn cleanup(h: s.H, directory: []const u8, since: f64, until: f64) !Result {
    if (!std.math.isFinite(since) or !std.math.isFinite(until) or until < since) return error.InvalidOwnershipWindow;
    var report: Result = .{ .directory = directory, .since = since, .until = until };
    var dir = try std.Io.Dir.cwd().openDir(h.io, directory, .{ .iterate = true });
    defer dir.close(h.io);
    var iterator = dir.iterate();
    while (try iterator.next(h.io)) |entry| {
        if (!std.mem.startsWith(u8, entry.name, "facil_io_tmpfile_")) continue;
        const name = try h.a.dupeSentinel(u8, entry.name, 0);
        const flags: std.c.O = .{ .NOFOLLOW = true, .NONBLOCK = true, .CLOEXEC = true };
        const fd = std.c.openat(dir.handle, name.ptr, flags);
        if (fd < 0) {
            switch (std.posix.errno(fd)) {
                .NOENT, .LOOP, .ISDIR => {
                    report.preserved_files += 1;
                    continue;
                },
                else => return error.OpenSpillFile,
            }
        }
        defer _ = std.c.close(fd);
        const info = try stat(fd, null);
        const seconds = @as(f64, @floatFromInt(info.modified_ns)) / std.time.ns_per_s;
        if (info.mode & std.c.S.IFMT != std.c.S.IFREG or info.uid != std.c.getuid() or info.nlink != 1 or info.size <= 0 or info.size > 65536 or seconds < since or seconds > until) {
            report.preserved_files += 1;
            continue;
        }
        var buffer: [65537]u8 = undefined;
        var count: usize = 0;
        while (count < buffer.len) {
            const n = std.c.read(fd, buffer[count..].ptr, buffer.len - count);
            if (n < 0) {
                if (std.posix.errno(n) == .INTR) continue;
                return error.ReadSpillFile;
            }
            if (n == 0) break;
            count += @intCast(n);
        }
        if (count != info.size or !std.mem.allEqual(u8, buffer[0..count], 'x')) {
            report.preserved_files += 1;
            continue;
        }
        const current = stat(dir.handle, name.ptr) catch |err| {
            if (err == error.FileNotFound) {
                report.preserved_files += 1;
                continue;
            }
            return err;
        };
        if (current.dev != info.dev or current.ino != info.ino or current.size != info.size or current.modified_ns != info.modified_ns) {
            report.preserved_files += 1;
            continue;
        }
        try dir.deleteFile(h.io, entry.name);
        report.removed_files += 1;
        report.removed_allocated_bytes += @as(u64, @intCast(info.blocks)) * 512;
    }
    return report;
}
