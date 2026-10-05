//! Level-triggered OS readiness. Tokens are generation-tagged, never pointers.
const std = @import("std");
const builtin = @import("builtin");
pub const Interests = struct { read: bool = false, write: bool = false };
pub const Event = struct { token: u64, read: bool, write: bool, failed: bool };
pub const Selector = if (builtin.os.tag == .linux) Epoll else Kqueue;
pub fn nonblocking(fd: c_int) !void {
    const flags = std.c.fcntl(fd, std.c.F.GETFL);
    const nonblock: c_int = @bitCast(std.c.O{ .NONBLOCK = true });
    if (flags < 0 or std.c.fcntl(fd, std.c.F.SETFL, flags | nonblock) < 0 or std.c.fcntl(fd, std.c.F.SETFD, @as(c_int, std.c.FD_CLOEXEC)) < 0) return error.SocketConfigurationFailed;
}
const Epoll = struct {
    fd: c_int,
    pub fn init() !Epoll {
        const fd = std.c.epoll_create1(std.os.linux.EPOLL.CLOEXEC);
        if (fd < 0) return error.SelectorInitFailed;
        return .{ .fd = fd };
    }
    pub fn deinit(self: *Epoll) void {
        _ = std.c.close(self.fd);
    }
    pub fn set(self: *Epoll, fd: c_int, token: u64, next: Interests, previous: *Interests) !void {
        const old_any = previous.read or previous.write;
        const new_any = next.read or next.write;
        if (!old_any and !new_any) return;
        var event: std.c.epoll_event = .{ .events = (if (next.read) @as(u32, std.os.linux.EPOLL.IN | std.os.linux.EPOLL.RDHUP) else 0) | (if (next.write) @as(u32, std.os.linux.EPOLL.OUT) else 0), .data = .{ .u64 = token } };
        const op: u32 = if (!new_any) std.os.linux.EPOLL.CTL_DEL else if (old_any) std.os.linux.EPOLL.CTL_MOD else std.os.linux.EPOLL.CTL_ADD;
        const rc = std.c.epoll_ctl(self.fd, @intCast(op), fd, &event);
        if (rc < 0) {
            const e = std.posix.errno(rc);
            if (new_any or (e != .NOENT and e != .BADF)) return error.SelectorUpdateFailed;
        }
        previous.* = next;
    }
    pub fn wait(self: *Epoll, output: []Event, timeout_ms: u32) !usize {
        var events: [128]std.c.epoll_event = undefined;
        const n = std.c.epoll_wait(self.fd, &events, @intCast(@min(events.len, output.len)), @intCast(timeout_ms));
        if (n < 0) {
            if (std.posix.errno(n) == .INTR) return 0;
            return error.SelectorWaitFailed;
        }
        for (events[0..@intCast(n)], 0..) |e, i| output[i] = .{ .token = e.data.u64, .read = e.events & (std.os.linux.EPOLL.IN | std.os.linux.EPOLL.RDHUP | std.os.linux.EPOLL.HUP) != 0, .write = e.events & std.os.linux.EPOLL.OUT != 0, .failed = e.events & (std.os.linux.EPOLL.ERR | std.os.linux.EPOLL.HUP) != 0 };
        return @intCast(n);
    }
};
const Kqueue = struct {
    fd: c_int,
    pub fn init() !Kqueue {
        const fd = std.c.kqueue();
        if (fd < 0) return error.SelectorInitFailed;
        errdefer _ = std.c.close(fd);
        if (std.c.fcntl(fd, std.c.F.SETFD, @as(c_int, std.c.FD_CLOEXEC)) < 0) return error.SelectorInitFailed;
        return .{ .fd = fd };
    }
    pub fn deinit(self: *Kqueue) void {
        _ = std.c.close(self.fd);
    }
    fn change(self: *Kqueue, fd: c_int, token: u64, filter: i16, enabled: bool) !void {
        var event: std.c.Kevent = .{ .ident = @intCast(fd), .filter = filter, .flags = if (enabled) std.c.EV.ADD | std.c.EV.ENABLE else std.c.EV.DELETE, .fflags = 0, .data = 0, .udata = @intCast(token) };
        var empty: [0]std.c.Kevent = .{};
        const rc = std.c.kevent(self.fd, @ptrCast(&event), 1, &empty, 0, null);
        if (rc < 0) {
            const e = std.posix.errno(rc);
            if (enabled or (e != .NOENT and e != .BADF)) return error.SelectorUpdateFailed;
        }
    }
    pub fn set(self: *Kqueue, fd: c_int, token: u64, next: Interests, previous: *Interests) !void {
        if (previous.read != next.read) try self.change(fd, token, std.c.EVFILT.READ, next.read);
        if (previous.write != next.write) try self.change(fd, token, std.c.EVFILT.WRITE, next.write);
        previous.* = next;
    }
    pub fn wait(self: *Kqueue, output: []Event, timeout_ms: u32) !usize {
        var events: [128]std.c.Kevent = undefined;
        const timeout: std.c.timespec = .{ .sec = @intCast(timeout_ms / 1000), .nsec = @intCast((timeout_ms % 1000) * std.time.ns_per_ms) };
        const n = std.c.kevent(self.fd, &.{}, 0, &events, @intCast(@min(events.len, output.len)), &timeout);
        if (n < 0) {
            if (std.posix.errno(n) == .INTR) return 0;
            return error.SelectorWaitFailed;
        }
        for (events[0..@intCast(n)], 0..) |e, i| output[i] = .{ .token = @intCast(e.udata), .read = e.filter == std.c.EVFILT.READ, .write = e.filter == std.c.EVFILT.WRITE, .failed = e.flags & std.c.EV.ERROR != 0 };
        return @intCast(n);
    }
};
