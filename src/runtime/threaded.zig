// Production Native listener/lifecycle and socket transport.
const std = @import("std");
const app_mod = @import("../app.zig");
const is_native = @import("build_options").backend == .native;
const Io = std.Io;
const net = Io.net;

pub fn serve(comptime State: type, app: *app_mod.App(State), opts: app_mod.ServeOptions) !void {
    return serveWithReadiness(State, @import("readiness_poll.zig").Readiness, app, opts);
}

// Internal evaluation seam; never selected by App.serve(.reactor).
pub fn serveWithReadiness(comptime State: type, comptime Readiness: type, app: *app_mod.App(State), opts: app_mod.ServeOptions) !void {
    if (!is_native) return;
    app.trust_proxy_headers = opts.trust_proxy_headers;
    app.trusted_proxy_fn = opts.trusted_proxy_fn;
    try app.prepare();
    var io_impl: Io.Threaded = .init(app.gpa, .{});
    defer io_impl.deinit();
    const io = io_impl.io();

    const addr_str = opts.address orelse "0.0.0.0";
    var addr = net.IpAddress.parseIp4(addr_str, opts.port) catch {
        std.log.err("invalid bind address {s}: must be an IPv4 literal", .{addr_str});
        return error.InvalidAddress;
    };
    var listener = try net.IpAddress.listen(&addr, io, .{ .reuse_address = true });
    defer {
        app.listener_fd.store(-1, .seq_cst);
        listener.deinit(io);
    }

    app.listener_fd.store(listener.socket.handle, .seq_cst);
    // Put the listener in non-blocking mode. The accept loop uses libc
    // accept(2) directly (not std.Io), so EAGAIN is just an errno we loop on —
    // no thread ever blocks inside accept(), which is what made shutdown(2) /
    // Ctrl-C unable to stop the server before. Readiness is waited on via
    // poll(2) with a timeout that bounds shutdown latency.
    try setNonBlocking(listener.socket.handle);
    std.log.info("akamata listening on http://{s}:{d}/", .{ addr_str, opts.port });

    const n_threads = @max(opts.accept_thread_count, 1);
    var threads: std.ArrayList(std.Thread) = .empty;
    defer threads.deinit(app.gpa);
    try threads.ensureTotalCapacity(app.gpa, n_threads);

    const Ctx = LoopCtx(State, Readiness);
    var ctx: Ctx = .{ .app = app, .io = io, .listener = &listener, .opts = &opts, .connections = .{ .mutex = .init() } };
    defer ctx.connections.mutex.deinit();

    var signals = installSignalHandlers(State, app);
    defer signals.deinit();

    errdefer {
        app.requestShutdown();
        for (threads.items) |t| t.join();
        drain(State, Readiness, &ctx);
    }
    var i: usize = 1;
    while (i < n_threads) : (i += 1) {
        const t = try std.Thread.spawn(.{}, acceptLoopThread, .{ State, Readiness, &ctx });
        threads.appendAssumeCapacity(t);
    }
    acceptLoop(State, Readiness, &ctx);
    for (threads.items) |t| t.join();
    // Detached workers still borrow ctx/app/io. Drain before destroying them;
    // Io.Group replacement is evaluated separately, not mixed into production.
    drain(State, Readiness, &ctx);
}

fn drain(comptime State: type, comptime Readiness: type, ctx: *LoopCtx(State, Readiness)) void {
    const clock = @import("../observability/clock.zig");
    const recorded = ctx.app.shutdown_started_ns.load(.acquire);
    const started = if (recorded == 0) clock.monotonicNs() else recorded;
    var forced = false;
    while (ctx.active_connections.load(.acquire) != 0) {
        ctx.connections.expireWrites(clock.monotonicNs());
        if (!forced and clock.elapsedNs(started) / std.time.ns_per_ms >= ctx.opts.shutdown_drain_timeout_ms) {
            ctx.connections.force();
            forced = true;
        }
        Io.sleep(ctx.io, .fromMilliseconds(1), .awake) catch {};
    }
}

fn LoopCtx(comptime State: type, comptime Readiness: type) type {
    _ = Readiness;
    return struct {
        app: *app_mod.App(State),
        io: Io,
        listener: *net.Server,
        opts: *const app_mod.ServeOptions,
        active_connections: std.atomic.Value(usize) = .init(0),
        connections: @import("drain.zig").Registry,
    };
}

fn acceptLoopThread(comptime State: type, comptime Readiness: type, ctx: *LoopCtx(State, Readiness)) void {
    acceptLoop(State, Readiness, ctx);
}

fn acceptLoop(comptime State: type, comptime Readiness: type, ctx: *LoopCtx(State, Readiness)) void {
    // Exponential backoff for transient accept failures (EMFILE, ENFILE,
    // ENOBUFS, etc.). Doubles from 100us up to 5s, resets on a successful
    // accept. Without this a server out of fds spins at 100% CPU spamming
    // the log.
    var backoff_us: u64 = 0;
    const max_backoff_us: u64 = 5_000_000;
    const Lib = struct {
        extern "c" fn usleep(usecs: c_uint) c_int;
    };

    // Zig 0.17 netAcceptPosix still treats EAGAIN as errnoBug. Multiple
    // accept workers can race after readiness, so a nonblocking listener
    // cannot safely use that API. The cancelable blocking standard accept
    // belongs in an Io.Group lifecycle (tested in io_group_experiment.zig),
    // not detached std.Thread workers without a cancellation scope.
    // We poll the listener fd with a timeout and,
    // once readable, call libc accept(2) directly, wrapping the raw fd into a
    // net.Stream. poll's timeout guarantees every thread re-checks the
    // shutdown flag promptly, so requestShutdown() / Ctrl-C always stops them.
    //
    // accept_poll_ms bounds how long a parked thread can ignore shutdown_flag.
    const accept_poll_ms: c_int = 100;

    while (!ctx.app.shutdown_flag.load(.seq_cst)) {
        ctx.connections.expireWrites(@import("../observability/clock.zig").monotonicNs());
        const fd = ctx.app.listener_fd.load(.seq_cst);
        if (fd < 0) return;
        if (!waitAcceptReady(fd, accept_poll_ms)) continue; // timeout/EINTR → re-check flag
        if (ctx.app.shutdown_flag.load(.seq_cst)) return;

        const accepted = rawAccept(fd);
        if (accepted.fd < 0) {
            // EAGAIN/EWOULDBLOCK: another thread took it, or a spurious wakeup.
            // EINVAL/EBADF: listener was shut down. Either way, loop and let the
            // flag check / next poll handle it. Brief backoff on hard errors.
            const e = errnoVal();
            if (e == EAGAIN or e == EWOULDBLOCK or e == ECONNABORTED or e == EINTR) continue;
            if (ctx.app.shutdown_flag.load(.seq_cst)) return;
            std.log.warn("accept failed: errno {d} (backoff {d}us)", .{ e, backoff_us });
            var remaining_us = backoff_us;
            while (remaining_us > 0 and !ctx.app.shutdown_flag.load(.acquire)) {
                const slice = @min(remaining_us, 100_000);
                _ = Lib.usleep(@intCast(slice));
                remaining_us -= slice;
            }
            backoff_us = if (backoff_us == 0) 100 else @min(backoff_us * 2, max_backoff_us);
            continue;
        }
        backoff_us = 0;
        // The connection fd may inherit O_NONBLOCK from the listener; std.Io's
        // read/write path requires blocking fds, so force it back.
        setBlocking(accepted.fd) catch {
            _ = std.c.close(accepted.fd);
            continue;
        };
        const stream: net.Stream = .{ .socket = .{ .handle = accepted.fd, .address = accepted.address } };
        applyTcpNoDelay(stream) catch {};
        const previous = ctx.active_connections.fetchAdd(1, .acq_rel);
        if (previous >= ctx.opts.max_connections) {
            _ = ctx.active_connections.fetchSub(1, .acq_rel);
            stream.close(ctx.io);
            continue;
        }
        const thread = std.Thread.spawn(.{}, connectionThread, .{ State, Readiness, ctx, stream }) catch {
            _ = ctx.active_connections.fetchSub(1, .acq_rel);
            stream.close(ctx.io);
            continue;
        };
        thread.detach();
    }
}

fn connectionThread(comptime State: type, comptime Readiness: type, ctx: *LoopCtx(State, Readiness), stream: net.Stream) void {
    defer _ = ctx.active_connections.fetchSub(1, .acq_rel);
    var node: @import("drain.zig").Node = undefined;
    ctx.connections.attach(&node, stream.socket.handle);
    defer node.detach();
    var transport = @import("socket_transport.zig").Transport(Readiness).init(ctx.io, stream, &ctx.app.shutdown_flag) catch {
        return;
    };
    transport.control = &node;
    defer transport.deinit();
    @import("../http/connection.zig").run(State, ctx.app, &transport, ctx.opts) catch |err| switch (err) {
        error.Timeout, error.EndOfStream => {},
        error.OutOfMemory => std.log.err("conn aborted: OOM", .{}),
        else => std.log.warn("conn rejected: {t}", .{err}),
    };
}

// === Socket configuration ===
// std.Io.Threaded expects blocking connection descriptors; SO_RCVTIMEO and
// SO_SNDTIMEO can produce EAGAIN that its socket reader treats as a programmer
// error. Request read deadlines use poll readiness before blocking reads;
// Bounded output uses MSG_DONTWAIT and an absolute budget, independently of
// the blocking std.Io reader. No SO_SNDTIMEO/EAGAIN enters the stdlib writer.
const builtin = @import("builtin");

extern "c" fn setsockopt(sockfd: c_int, level: c_int, optname: c_int, optval: *const anyopaque, optlen: u32) c_int;

// === Shutdown-aware accept ===
//
// The Zig 0.17 standard blocking accept can be canceled by Io.Group, as the
// PoC verifies. The production listener is nonblocking and shared among raw
// accept threads; std netAcceptPosix does not expose EAGAIN as a recoverable
// error, so readiness races still require raw accept here.
//
// So we bypass std.Io for accept entirely: the listener is non-blocking, each
// thread waits for readability with poll(2) (timeout bounds shutdown latency),
// then calls libc accept(2) directly — where EAGAIN is an ordinary errno we
// loop on, and shutdown(2) surfaces as EBADF/EINVAL so the loop exits. The
// accepted connection fd is switched back to blocking before being handed to
// std.Io.Threaded's read/write path (which itself asserts on EAGAIN).
extern "c" fn accept(sockfd: c_int, addr: ?*anyopaque, addrlen: ?*u32) c_int;
extern "c" fn __error() *c_int; // macOS/BSD errno location
extern "c" fn __errno_location() *c_int; // Linux errno location
extern "c" fn fcntl(fd: c_int, cmd: c_int, ...) c_int;

const F_GETFL = std.c.F.GETFL;
const F_SETFL = std.c.F.SETFL;
const O_NONBLOCK: c_int = @bitCast(std.c.O{ .NONBLOCK = true });

/// Fail closed if the listener cannot be made non-blocking: multiple accept
/// workers otherwise race into a blocking accept without a shutdown deadline.
fn setNonBlocking(fd: c_int) !void {
    const flags = fcntl(fd, F_GETFL);
    if (flags < 0 or fcntl(fd, F_SETFL, flags | O_NONBLOCK) < 0) return error.SocketConfigurationFailed;
}

/// Clear O_NONBLOCK so the fd is blocking again. Accepted
/// connection fds must be blocking: std.Io.Threaded's read/write path treats
/// EAGAIN as a programmer bug and panics in debug builds.
fn setBlocking(fd: c_int) !void {
    const flags = fcntl(fd, F_GETFL);
    if (flags < 0 or fcntl(fd, F_SETFL, flags & ~O_NONBLOCK) < 0) return error.SocketConfigurationFailed;
}

const EINTR: c_int = 4;
const EAGAIN: c_int = if (builtin.os.tag == .linux) 11 else 35;
const EWOULDBLOCK: c_int = EAGAIN;
const ECONNABORTED: c_int = if (builtin.os.tag == .linux) 103 else 53;

fn errnoVal() c_int {
    return switch (builtin.os.tag) {
        .linux => __errno_location().*,
        else => __error().*,
    };
}

/// Block up to `timeout_ms` waiting for the listener to have an incoming
/// connection. Returns true if a connection is (probably) ready to accept,
/// false on timeout/EINTR/error so the caller re-checks `shutdown_flag`.
fn waitAcceptReady(fd: c_int, timeout_ms: c_int) bool {
    var pfd = [_]std.posix.pollfd{.{ .fd = fd, .events = std.posix.POLL.IN, .revents = 0 }};
    return (std.posix.poll(&pfd, timeout_ms) catch return false) > 0;
}

/// libc accept(2) on the raw listener fd. Returns the connection fd, or a
/// negative value on error (inspect errnoVal()).
const Accepted = struct { fd: c_int, address: net.IpAddress };

pub fn rawAccept(fd: c_int) Accepted {
    var address: std.posix.sockaddr.in = undefined;
    var len: u32 = @sizeOf(std.posix.sockaddr.in);
    const accepted_fd = accept(fd, &address, &len);
    if (accepted_fd < 0) return .{ .fd = accepted_fd, .address = undefined };
    return .{ .fd = accepted_fd, .address = .{ .ip4 = .{
        .port = std.mem.bigToNative(u16, address.port),
        .bytes = @bitCast(address.addr),
    } } };
}

// Zig 0.17 exposes a portable SIG enum and Sigaction.handler_fn. No libc
// signal(3), synthetic SIG_IGN pointer, or 0.16-specific handler casts remain.
// Signal registrations are process-wide: one serving App owns INT/TERM.
// std.Io.Threaded itself handles SIGPIPE while its instance is alive.
const ShutdownRegistry = struct {
    var slot: ?*anyopaque = null;
    var trigger: ?*const fn (*anyopaque) void = null;
};
fn shutdownTrampoline(_: std.posix.SIG) callconv(.c) void {
    // requestShutdown() may call clock_gettime/shutdown (including repeated
    // listener shutdown). Preserve the interrupted syscall's errno even when
    // those signal-safe calls fail; Zig 0.17 exposes the libc TLS accessor.
    const errno_ptr = std.c._errno();
    const saved_errno = errno_ptr.*;
    defer errno_ptr.* = saved_errno;
    if (ShutdownRegistry.slot) |s| {
        if (ShutdownRegistry.trigger) |t| t(s);
    }
}

test "shutdown signal preserves the interrupted syscall errno" {
    const saved_slot = ShutdownRegistry.slot;
    const saved_trigger = ShutdownRegistry.trigger;
    const errno_ptr = std.c._errno();
    const saved_errno = errno_ptr.*;
    defer {
        ShutdownRegistry.slot = saved_slot;
        ShutdownRegistry.trigger = saved_trigger;
        errno_ptr.* = saved_errno;
    }
    var called = false;
    ShutdownRegistry.slot = &called;
    ShutdownRegistry.trigger = struct {
        fn invoke(ptr: *anyopaque) void {
            const flag: *bool = @ptrCast(@alignCast(ptr));
            flag.* = true;
            std.c._errno().* = 99;
        }
    }.invoke;
    errno_ptr.* = 42;
    shutdownTrampoline(.TERM);
    try std.testing.expect(called);
    try std.testing.expectEqual(@as(c_int, 42), errno_ptr.*);
}
pub const SignalScope = struct {
    old_int: std.posix.Sigaction,
    old_term: std.posix.Sigaction,
    pub fn deinit(self: *SignalScope) void {
        std.posix.sigaction(.INT, &self.old_int, null);
        std.posix.sigaction(.TERM, &self.old_term, null);
        ShutdownRegistry.slot = null;
        ShutdownRegistry.trigger = null;
    }
};
pub fn installSignalHandlers(comptime State: type, app: *app_mod.App(State)) SignalScope {
    const Wrap = struct {
        fn trigger(opaque_app: *anyopaque) void {
            const a: *app_mod.App(State) = @ptrCast(@alignCast(opaque_app));
            a.requestShutdown();
        }
    };
    ShutdownRegistry.slot = @ptrCast(app);
    ShutdownRegistry.trigger = Wrap.trigger;
    const action: std.posix.Sigaction = .{
        .handler = .{ .handler = shutdownTrampoline },
        .mask = std.posix.sigemptyset(),
        .flags = 0,
    };
    var scope: SignalScope = undefined;
    std.posix.sigaction(.INT, &action, &scope.old_int);
    std.posix.sigaction(.TERM, &action, &scope.old_term);
    return scope;
}

/// Disable Nagle's algorithm so small responses go out immediately. HTTP/1.1
/// keep-alive workloads dominated by 100-byte requests/responses see noticeably
/// lower P99 latency once this is on.
pub fn applyTcpNoDelay(stream: net.Stream) !void {
    if (!is_native) return;
    if (builtin.os.tag == .windows) return;
    const IPPROTO_TCP: c_int = 6;
    const TCP_NODELAY: c_int = 1;
    const fd: c_int = stream.socket.handle;
    const on: c_int = 1;
    _ = setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, @ptrCast(&on), @sizeOf(c_int));
}
