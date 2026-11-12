//! POSIX loopback driver for black-box tests, never a framework transport.
//! Standard ABI definitions, nonblocking sockets and absolute test deadlines.
const std = @import("std");
const builtin = @import("builtin");
const s = @import("support.zig");
pub const upgrade = "Upgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n";

fn address(port: u16) std.c.sockaddr.in {
    return .{ .port = std.mem.nativeToBig(u16, port), .addr = std.mem.nativeToBig(u32, 0x7f000001) };
}
fn socket() !c_int {
    const fd = std.c.socket(std.c.AF.INET, std.c.SOCK.STREAM, 0);
    if (fd < 0) return error.Socket;
    errdefer _ = std.c.close(fd);
    if (std.c.fcntl(fd, std.c.F.SETFD, @as(c_int, std.c.FD_CLOEXEC)) < 0) return error.CloseOnExec;
    if (builtin.os.tag == .macos) {
        const yes: c_int = 1;
        if (std.c.setsockopt(fd, std.c.SOL.SOCKET, std.c.SO.NOSIGPIPE, &yes, @sizeOf(c_int)) != 0) return error.SocketOption;
    }
    return fd;
}
pub fn freePort() !u16 {
    const fd = try socket();
    defer _ = std.c.close(fd);
    var addr = address(0);
    if (std.c.bind(fd, @ptrCast(&addr), @sizeOf(@TypeOf(addr))) != 0) return error.Bind;
    var len: std.c.socklen_t = @sizeOf(@TypeOf(addr));
    if (std.c.getsockname(fd, @ptrCast(&addr), &len) != 0) return error.Address;
    return std.mem.bigToNative(u16, addr.port);
}
pub const Response = struct { status: u16, head: []const u8, body: []const u8 };
pub const Client = struct {
    h: s.H,
    fd: c_int,
    pending: std.ArrayList(u8) = .empty,
    timeout_ms: u32 = 3000,
    pub fn connect(h: s.H, port: u16) !Client {
        const fd = try socket();
        errdefer _ = std.c.close(fd);
        const old = std.c.fcntl(fd, std.c.F.GETFL);
        const nonblock: c_int = @bitCast(std.c.O{ .NONBLOCK = true });
        if (old < 0 or std.c.fcntl(fd, std.c.F.SETFL, old | nonblock) < 0) return error.Nonblocking;
        var result: Client = .{ .h = h, .fd = fd };
        var addr = address(port);
        const rc = std.c.connect(fd, @ptrCast(&addr), @sizeOf(@TypeOf(addr)));
        if (rc != 0) {
            const err = std.posix.errno(rc);
            if (err != .INPROGRESS) return error.ConnectionRefused;
            try result.ready(std.c.POLL.OUT, h.now() + 3 * std.time.ns_per_s);
            var code: c_int = 0;
            var size: std.c.socklen_t = @sizeOf(c_int);
            if (std.c.getsockopt(fd, std.c.SOL.SOCKET, std.c.SO.ERROR, @ptrCast(&code), &size) != 0 or code != 0) return error.ConnectionRefused;
        }
        return result;
    }
    fn ready(c: *Client, event: i16, deadline: i96) !void {
        while (true) {
            const left = deadline - c.h.now();
            if (left <= 0) return error.Timeout;
            var fds = [_]std.c.pollfd{.{ .fd = c.fd, .events = event, .revents = 0 }};
            const rc = std.c.poll(&fds, 1, @intCast(@max(1, @min(@divTrunc(left, std.time.ns_per_ms), std.math.maxInt(c_int)))));
            if (rc > 0) return;
            if (rc < 0 and std.posix.errno(rc) != .INTR) return error.Poll;
        }
    }
    pub fn send(c: *Client, data: []const u8) !void {
        const deadline = c.h.now() + @as(i96, c.timeout_ms) * std.time.ns_per_ms;
        var offset: usize = 0;
        while (offset < data.len) {
            try c.ready(std.c.POLL.OUT, deadline);
            const n = std.c.send(c.fd, data[offset..].ptr, data.len - offset, if (builtin.os.tag == .linux) std.c.MSG.NOSIGNAL else 0);
            if (n > 0) {
                offset += @intCast(n);
                continue;
            }
            if (n < 0 and (std.posix.errno(n) == .INTR or std.posix.errno(n) == .AGAIN)) continue;
            return error.Disconnected;
        }
    }
    pub fn recv(c: *Client, buffer: []u8) !usize {
        const deadline = c.h.now() + @as(i96, c.timeout_ms) * std.time.ns_per_ms;
        while (true) {
            try c.ready(std.c.POLL.IN, deadline);
            const n = std.c.recv(c.fd, buffer.ptr, buffer.len, 0);
            if (n >= 0) return @intCast(n);
            const err = std.posix.errno(n);
            if (err == .CONNRESET) return 0;
            if (err != .INTR and err != .AGAIN) return error.Read;
        }
    }
    pub fn fill(c: *Client) !void {
        var data: [65536]u8 = undefined;
        const n = try c.recv(&data);
        if (n == 0) return error.UnexpectedEof;
        if (c.pending.items.len + n > 32 * 1024 * 1024) return error.ResponseLimit;
        try c.pending.appendSlice(c.h.a, data[0..n]);
    }
    pub fn take(c: *Client, n: usize) ![]const u8 {
        while (c.pending.items.len < n) try c.fill();
        const result = try c.h.a.dupe(u8, c.pending.items[0..n]);
        std.mem.copyForwards(u8, c.pending.items, c.pending.items[n..]);
        c.pending.items.len -= n;
        return result;
    }
    pub fn response(c: *Client) !Response {
        const head = try c.headers();
        var words = std.mem.tokenizeScalar(u8, head, ' ');
        _ = words.next();
        const status = try std.fmt.parseInt(u16, words.next() orelse return error.Status, 10);
        var length: usize = 0;
        var header_lines = std.mem.splitSequence(u8, head, "\r\n");
        while (header_lines.next()) |line| if (std.mem.indexOfScalar(u8, line, ':')) |colon| {
            if (std.ascii.eqlIgnoreCase(line[0..colon], "content-length")) length = try std.fmt.parseInt(usize, std.mem.trim(u8, line[colon + 1 ..], " \t"), 10);
        };
        if (length > 32 * 1024 * 1024) return error.ResponseLimit;
        return .{ .status = status, .head = head, .body = try c.take(length) };
    }
    pub fn headers(c: *Client) ![]const u8 {
        while (std.mem.indexOf(u8, c.pending.items, "\r\n\r\n") == null) try c.fill();
        const end = std.mem.indexOf(u8, c.pending.items, "\r\n\r\n").?;
        if (end > 65536) return error.HeaderLimit;
        return c.take(end + 4);
    }
    pub fn collect(c: *Client) ![]const u8 {
        var out: std.ArrayList(u8) = .empty;
        try out.appendSlice(c.h.a, c.pending.items);
        c.pending.clearRetainingCapacity();
        var buffer: [65536]u8 = undefined;
        while (true) {
            const n = try c.recv(&buffer);
            if (n == 0) break;
            if (out.items.len + n > 32 * 1024 * 1024) return error.ResponseLimit;
            try out.appendSlice(c.h.a, buffer[0..n]);
        }
        return out.toOwnedSlice(c.h.a);
    }
    pub fn eof(c: *Client) !void {
        var byte: [1]u8 = undefined;
        try s.check(try c.recv(&byte) == 0, "expected socket EOF");
    }
    pub fn receiveBuffer(c: *Client, bytes: c_int) !void {
        if (std.c.setsockopt(c.fd, std.c.SOL.SOCKET, std.c.SO.RCVBUF, &bytes, @sizeOf(c_int)) != 0) return error.SocketOption;
    }
    pub fn reset(c: *Client) !void {
        const linger = std.c.linger{ .onoff = 1, .linger = 0 };
        if (std.c.setsockopt(c.fd, std.c.SOL.SOCKET, std.c.SO.LINGER, &linger, @sizeOf(@TypeOf(linger))) != 0) return error.SocketOption;
        c.close();
    }
    pub fn close(c: *Client) void {
        if (c.fd >= 0) _ = std.c.close(c.fd);
        c.fd = -1;
    }
};
pub fn request(h: s.H, path: []const u8, close: bool, extra: []const u8) ![]const u8 {
    return h.fmt("GET {s} HTTP/1.1\r\nHost: localhost\r\n{s}{s}\r\n", .{ path, extra, if (close) "Connection: close\r\n" else "" });
}
pub fn frame(h: s.H, opcode: u8, data: []const u8, fin: bool) ![]const u8 {
    if (data.len > 65535) return error.FrameLimit;
    const prefix: usize = if (data.len < 126) 2 else 4;
    const result = try h.a.alloc(u8, prefix + 4 + data.len);
    result[0] = (if (fin) @as(u8, 0x80) else 0) | opcode;
    result[1] = 0x80 | (if (prefix == 2) @as(u8, @intCast(data.len)) else 126);
    if (prefix == 4) std.mem.writeInt(u16, result[2..4], @intCast(data.len), .big);
    @memcpy(result[prefix..][0..4], "mask");
    for (data, 0..) |byte, index| result[prefix + 4 + index] = byte ^ "mask"[index % 4];
    return result;
}
pub const Server = struct {
    h: s.H,
    temp: s.Temp,
    child: std.process.Child,
    log: std.Io.File,
    log_path: []const u8,
    port: u16,
    clients: std.ArrayList(*Client) = .empty,
    status: ?c_int = null,
    pub fn start(h: s.H, argv: []const []const u8, cwd: ?[]const u8, env: ?*const std.process.Environ.Map, port: u16) !Server {
        const temp = try h.temp();
        errdefer temp.deinit();
        const path = try temp.file("fixture.log");
        const log = try std.Io.Dir.cwd().createFile(h.io, path, .{ .read = true });
        errdefer log.close(h.io);
        const child = try std.process.spawn(h.io, .{ .argv = argv, .cwd = if (cwd) |p| .{ .path = p } else .inherit, .environ_map = env, .stdin = .ignore, .stdout = .{ .file = log }, .stderr = .{ .file = log } });
        return .{ .h = h, .temp = temp, .child = child, .log = log, .log_path = path, .port = port };
    }
    pub fn connect(server: *Server) !*Client {
        const c = try server.h.a.create(Client);
        c.* = try Client.connect(server.h, server.port);
        errdefer c.close();
        try server.clients.append(server.h.a, c);
        return c;
    }
    pub fn signal(server: *Server, sig: std.c.SIG) void {
        if (server.child.id) |pid| _ = std.c.kill(pid, sig);
    }
    pub fn poll(server: *Server) !bool {
        if (server.status != null) return true;
        var status: c_int = undefined;
        const rc = std.c.waitpid(server.child.id.?, &status, std.c.W.NOHANG);
        if (rc == 0) return false;
        if (rc < 0) return error.Wait;
        server.status = status;
        server.child.id = null;
        return true;
    }
    pub fn wait(server: *Server, ms: u32) !void {
        const deadline = server.h.now() + @as(i96, ms) * std.time.ns_per_ms;
        while (!try server.poll()) {
            if (server.h.now() >= deadline) return error.ProcessDeadline;
            server.h.sleep(5);
        }
        if (server.status.? != 0) {
            std.debug.print("fixture exited {d}: {s}\n", .{ server.status.?, try server.h.read(server.log_path) });
            return error.FixtureExit;
        }
    }
    pub fn finish(server: *Server) !void {
        for (server.clients.items) |c| c.close();
        server.signal(.TERM);
        try server.wait(4000);
        const log = try server.h.read(server.log_path);
        try s.check(std.mem.indexOf(u8, log, "memory address") == null, "fixture allocator leak");
    }
    pub fn deinit(server: *Server) void {
        for (server.clients.items) |c| c.close();
        if (server.child.id != null) {
            server.signal(.TERM);
            server.wait(4000) catch {
                server.signal(.KILL);
                server.wait(1000) catch {};
            };
        }
        server.log.close(server.h.io);
        server.temp.deinit();
    }
};
