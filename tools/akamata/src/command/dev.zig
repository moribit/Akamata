const Timespec = @import("../native.zig").Timespec;
const std = @import("std");
const builtin = @import("builtin");
const DT_DIR = @import("../native.zig").DT_DIR;
const DT_REG = @import("../native.zig").DT_REG;
const closedir = @import("../native.zig").closedir;
const countSqlMigrations = @import("../project/files.zig").countSqlMigrations;
const opendir = @import("../native.zig").opendir;
const readZonName = @import("../project/manifest.zig").readZonName;
const readdir = @import("../native.zig").readdir;
const runChild = @import("../process.zig").runChild;
const stat = @import("../native.zig").stat;

// `struct stat` is OS-specific; we only read st_mtim(espec). These layouts
// match darwin (_DARWIN_FEATURE_64_BIT_INODE, the default) and linux x86_64.
const stat_t = @import("../native.zig").stat_t;

// ---- dev (hot reload) ----
//
// `akamata dev` builds the app, runs the native binary, and watches the source
// tree. On any change it rebuilds and restarts the binary. A `--no-watch` flag
// falls back to the old one-shot `zig build run`.
//
// Restart model: we run the built binary directly (not `zig build run`) so we
// own the PID and SIGTERM reaches the app — Akamata's serve() installs a
// SIGTERM handler that shuts the listener down cleanly, freeing the port for
// the next spawn. Change detection is mtime polling (portable, no inotify/
// kqueue); the poll interval is short enough to feel instant.
pub const dev_poll_ms = 400;

pub fn cmdDev(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    var watch = true;
    for (args) |raw| {
        const a = std.mem.sliceTo(raw, 0);
        if (std.mem.eql(u8, a, "--no-watch")) watch = false;
    }
    if (!watch) {
        try runChild(alloc, &.{ "zig", "build", "run" }, null);
        return;
    }

    const bin = (try readZonName(alloc)) orelse {
        std.debug.print("dev: couldn't read .name from build.zig.zon; falling back to `zig build run`.\n", .{});
        try runChild(alloc, &.{ "zig", "build", "run" }, null);
        return;
    };
    defer alloc.free(bin);
    const bin_path = try std.fmt.allocPrint(alloc, "zig-out/bin/{s}", .{bin});
    defer alloc.free(bin_path);
    const bin_path_z = try alloc.dupeSentinel(u8, bin_path, 0);
    defer alloc.free(bin_path_z);

    std.debug.print("==> akamata dev: watching ./src, ./migrations, build files, and .env ({d} migration(s)). Ctrl-C to stop.\n", .{countSqlMigrations("migrations")});
    dev_install_sigint();

    // The app runs in its own process group; `child` is the leader pid (-1 when
    // none). The loop is single-threaded and the signal handler only flips
    // dev_running, so a plain local is safe. `defer` guarantees teardown even on
    // Ctrl-C mid-build.
    var child: c_int = -1;
    defer stopChild(child);

    var sig = watchSignature(alloc);
    var first = true;

    while (dev_running.load(.seq_cst)) {
        if (first or watchSignature(alloc) != sig) {
            first = false;
            sig = watchSignature(alloc);

            if (child > 0) {
                std.debug.print("==> akamata dev: change detected — restarting\n", .{});
                stopChild(child);
                child = -1;
            }

            std.debug.print("==> akamata dev: building\n", .{});
            if (runChild(alloc, &.{ "zig", "build" }, null)) |_| {
                // A build can be interrupted by Ctrl-C; bail before spawning.
                if (!dev_running.load(.seq_cst)) break;
                // Re-read the signature AFTER the build: the build can touch
                // files (and takes time), so we don't want its own writes to
                // immediately re-trigger. Then spawn the freshly built binary.
                sig = watchSignature(alloc);
                child = spawnBinary(bin_path_z.ptr);
                if (child <= 0) std.debug.print("dev: failed to spawn {s}\n", .{bin_path});
            } else |_| {
                if (!dev_running.load(.seq_cst)) break;
                std.debug.print("==> akamata dev: build failed — fix and save to retry\n", .{});
            }
        }

        // Reap an app that exited on its own (e.g. crash) so we don't leave a
        // zombie; report it but keep watching so the next save restarts it.
        if (child > 0) {
            var status: c_int = 0;
            if (waitpid(child, &status, WNOHANG) == child) {
                std.debug.print("==> akamata dev: app exited (status {d}) — waiting for next change\n", .{status});
                child = -1;
            }
        }

        sleepMs(dev_poll_ms);
    }

    std.debug.print("\n==> akamata dev: stopping\n", .{});
}

/// Spawn `path` as a child process, returning its pid (or -1 on failure).
/// Spawn `path` in its OWN process group (the child calls setpgid(0,0), so its
/// pgid == its pid). Two reasons:
///   1. A terminal Ctrl-C delivers SIGINT to the foreground *process group* —
///      i.e. to `akamata dev`. We do NOT want it delivered straight to the app
///      too (that races with our managed shutdown and can orphan the app if dev
///      exits first). Putting the app in its own group isolates it; dev is the
///      sole owner of the app's lifecycle.
///   2. Killing the group (`killpg`) takes down the app AND anything it spawned.
/// Returns the child pid (== its pgid), or -1 on fork failure.
pub fn spawnBinary(path: [*:0]const u8) c_int {
    const pid = fork();
    if (pid == 0) {
        _ = setpgid(0, 0); // become leader of a new process group
        const argv = [_:null]?[*:0]const u8{path};
        _ = execvp(path, &argv);
        _exit(127); // execvp only returns on failure
    }
    if (pid > 0) _ = setpgid(pid, pid); // also set from parent to avoid the race
    return pid;
}

/// Stop the app process group: SIGTERM (graceful — Akamata's serve() catches it
/// and drains the accept loop), then a short grace period, then SIGKILL if it's
/// still alive. `pid` is the group leader (== pgid). Reaps the leader.
pub fn stopChild(pid: c_int) void {
    if (pid <= 0) return;
    _ = killpg(pid, SIGTERM);
    // Wait up to ~2s for graceful exit, polling so we don't hang on a wedged app.
    var waited_ms: u64 = 0;
    while (waited_ms < 2000) {
        var status: c_int = 0;
        if (waitpid(pid, &status, WNOHANG) == pid) return; // reaped
        sleepMs(50);
        waited_ms += 50;
    }
    _ = killpg(pid, SIGKILL);
    _ = waitpid(pid, null, 0);
}

/// A coarse change signature over the watched files: every regular file under
/// ./src plus a few top-level files. We fold each file's mtime (sec, nsec) into
/// a running hash; any add/remove/modify changes the result. Missing files are
/// skipped. O(files) per poll, which is fine for a source tree.
pub fn watchSignature(alloc: std.mem.Allocator) u64 {
    var h: u64 = 1469598103934665603; // FNV-1a offset basis
    walkMtimes("src", &h);
    walkMtimes("migrations", &h);
    for ([_][]const u8{ "build.zig", "build.zig.zon", ".env" }) |f| {
        var st: stat_t = undefined;
        const fz = alloc.dupeSentinel(u8, f, 0) catch continue;
        defer alloc.free(fz);
        if (stat(fz.ptr, &st) == 0) foldMtime(&h, st.mtim);
    }
    return h;
}

pub fn foldMtime(h: *u64, ts: Timespec) void {
    const v: u64 = (@as(u64, @bitCast(@as(i64, ts.sec))) *% 1_000_000_000) +% @as(u64, @bitCast(@as(i64, ts.nsec)));
    h.* = (h.* ^ v) *% 1099511628211; // FNV-1a prime
}

/// Recursively fold mtimes of regular files under `dir` into `h`. Uses a fixed
/// path buffer; paths longer than the buffer are skipped (won't happen for a
/// normal source tree).
pub fn walkMtimes(dir: []const u8, h: *u64) void {
    var dir_buf: [4096]u8 = undefined;
    if (dir.len + 1 > dir_buf.len) return;
    @memcpy(dir_buf[0..dir.len], dir);
    dir_buf[dir.len] = 0;
    const d = opendir(@ptrCast(&dir_buf)) orelse return;
    defer _ = closedir(d);
    while (readdir(d)) |ent| {
        const name = std.mem.sliceTo(@as([*:0]const u8, @ptrCast(&ent.name)), 0);
        if (name.len == 0 or name[0] == '.') continue; // skip ., .., dotfiles
        var path_buf: [4096]u8 = undefined;
        const path = std.fmt.bufPrintSentinel(&path_buf, "{s}/{s}", .{ dir, name }, 0) catch continue;
        if (ent.type == DT_DIR) {
            walkMtimes(path, h);
        } else if (ent.type == DT_REG) {
            var st: stat_t = undefined;
            if (stat(path.ptr, &st) == 0) foldMtime(h, st.mtim);
        }
    }
}

// === dev hot-reload primitives (POSIX libc) ===
pub extern "c" fn fork() c_int;

pub extern "c" fn execvp(file: [*:0]const u8, argv: [*:null]const ?[*:0]const u8) c_int;

pub extern "c" fn kill(pid: c_int, sig: c_int) c_int;

pub extern "c" fn killpg(pgrp: c_int, sig: c_int) c_int;

pub extern "c" fn setpgid(pid: c_int, pgid: c_int) c_int;

pub extern "c" fn waitpid(pid: c_int, status: ?*c_int, options: c_int) c_int;

pub extern "c" fn _exit(code: c_int) noreturn;

pub extern "c" fn nanosleep(req: *const Timespec, rem: ?*Timespec) c_int;

pub extern "c" fn sigaction(sig: c_int, act: *const Sigaction, oact: ?*Sigaction) c_int;

pub const SIGINT = 2;

pub const SIGKILL = 9;

pub const SIGTERM = 15;

pub const WNOHANG = 1;

// Ctrl-C handling for the dev loop. The handler runs in async-signal context,
// so it does ONLY signal-safe work: flip an atomic flag. The main loop (and its
// `defer`) owns process teardown via stopChild — we do not kill from the
// handler, which keeps the spawn/record sequence race-free (the child is in its
// own process group, isolated from the terminal's Ctrl-C; dev is its sole
// killer). `dev_running` is atomic so the loop re-reads it after the handler
// fires (a plain `var` could be cached in a register under optimization).
pub var dev_running: std.atomic.Value(bool) = .init(true);

pub fn devSigintHandler(_: c_int) callconv(.c) void {
    dev_running.store(false, .seq_cst);
}

pub fn dev_install_sigint() void {
    // flags defaults to 0 — deliberately NO SA_RESTART, so nanosleep returns
    // EINTR on signal and the loop checks dev_running promptly.
    const act = Sigaction{ .handler = devSigintHandler };
    _ = sigaction(SIGINT, &act, null);
    _ = sigaction(SIGTERM, &act, null); // also stop cleanly on `kill`
}

pub fn sleepMs(ms: u64) void {
    const ts = Timespec{ .sec = @intCast(ms / 1000), .nsec = @intCast((ms % 1000) * 1_000_000) };
    _ = nanosleep(&ts, null);
}

// `struct sigaction`. We only set sa_handler + sa_flags (no SA_RESTART, so a
// signal interrupts nanosleep and the loop checks the flag promptly). Layouts
// differ per-OS; sa_handler is the first field on both darwin and linux.
pub const Sigaction = switch (builtin.os.tag) {
    .macos => extern struct {
        handler: *const fn (c_int) callconv(.c) void,
        mask: u32 = 0,
        flags: c_int = 0,
    },
    else => extern struct {
        handler: *const fn (c_int) callconv(.c) void,
        mask: [16]c_ulong = @as([16]c_ulong, @splat(0)), // sigset_t (over-sized; zeroed)
        flags: c_int = 0,
        restorer: ?*const fn () callconv(.c) void = null,
    },
};
