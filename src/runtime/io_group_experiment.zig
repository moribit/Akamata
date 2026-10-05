// Isolated structured-concurrency experiment. Never selected by App.serve.
// Cancellation of Io.Threaded blocking accept/read is exercised by its tests.
const std = @import("std");
const app_mod = @import("../app.zig");
const Transport = @import("socket_transport.zig").Transport(@import("readiness_poll.zig").Readiness);

pub fn serve(comptime State: type, app: *app_mod.App(State), opts: app_mod.ServeOptions) !void {
    app.trust_proxy_headers = opts.trust_proxy_headers;
    app.trusted_proxy_fn = opts.trusted_proxy_fn;
    try app.prepare();
    // One guaranteed-concurrent accept task plus at most max_connections
    // connection tasks. ConcurrencyUnavailable provides admission backpressure.
    var impl: std.Io.Threaded = .init(app.gpa, .{
        .concurrent_limit = .limited(opts.max_connections + 1),
    });
    defer impl.deinit();
    const io = impl.io();
    var address = try std.Io.net.IpAddress.parseIp4(opts.address orelse "0.0.0.0", opts.port);
    var listener = try address.listen(io, .{ .reuse_address = true });
    defer {
        app.listener_fd.store(-1, .seq_cst);
        listener.deinit(io);
    }
    app.listener_fd.store(listener.socket.handle, .seq_cst);
    var signals = @import("threaded.zig").installSignalHandlers(State, app);
    defer signals.deinit();
    var connections: std.Io.Group = .init;
    defer connections.cancel(io);
    var acceptors: std.Io.Group = .init;
    defer acceptors.cancel(io);
    try acceptors.concurrent(io, Tasks(State).accept, .{ app, io, &listener, &connections, &opts });
    while (!app.shutdown_flag.load(.acquire)) try std.Io.sleep(io, .fromMilliseconds(10), .awake);
    // No Thread.spawn/detach, active counter, or spin/join loop. Stop new
    // admissions first, then await already admitted requests. Cancel remains
    // available for a future explicit forced-shutdown deadline.
    acceptors.cancel(io);
    try connections.await(io);
}

fn Tasks(comptime State: type) type {
    return struct {
        fn accept(app: *app_mod.App(State), io: std.Io, listener: *std.Io.net.Server, group: *std.Io.Group, opts: *const app_mod.ServeOptions) std.Io.Cancelable!void {
            while (!app.shutdown_flag.load(.acquire)) {
                const stream = listener.accept(io) catch |err| switch (err) {
                    error.Canceled => return error.Canceled,
                    else => {
                        app.requestShutdown();
                        return;
                    },
                };
                @import("threaded.zig").applyTcpNoDelay(stream) catch {};
                group.concurrent(io, connection, .{ app, io, stream, opts }) catch {
                    stream.close(io);
                };
            }
        }

        fn connection(app: *app_mod.App(State), io: std.Io, stream: std.Io.net.Stream, opts: *const app_mod.ServeOptions) std.Io.Cancelable!void {
            var transport = Transport.init(io, stream, &app.shutdown_flag) catch {
                stream.close(io);
                return;
            };
            defer transport.deinit();
            @import("../http/connection.zig").run(State, app, &transport, opts) catch |err| switch (err) {
                error.Canceled => return error.Canceled,
                else => {},
            };
        }
    };
}

fn finite(io: std.Io, done: *std.atomic.Value(u32)) std.Io.Cancelable!void {
    try std.Io.sleep(io, .fromMilliseconds(1), .awake);
    _ = done.fetchAdd(1, .monotonic);
}

test "Group.async owns finite tasks through await" {
    var impl: std.Io.Threaded = .init(std.testing.allocator, .{ .async_limit = .limited(2) });
    defer impl.deinit();
    const io = impl.io();
    var group: std.Io.Group = .init;
    defer group.cancel(io);
    var done: std.atomic.Value(u32) = .init(0);
    for (0..8) |_| group.async(io, finite, .{ io, &done });
    try group.await(io);
    try std.testing.expectEqual(@as(u32, 8), done.load(.acquire));
}

fn blockedRead(io: std.Io, stream: std.Io.net.Stream, started: *std.atomic.Value(bool), cleaned: *std.atomic.Value(bool)) std.Io.Cancelable!void {
    defer {
        stream.close(io);
        cleaned.store(true, .release);
    }
    var buf: [32]u8 = undefined;
    var reader = stream.reader(io, &buf);
    var dest: [1]u8 = undefined;
    started.store(true, .release);
    _ = reader.interface.readSliceShort(&dest) catch {
        if (reader.err) |e| if (e == error.Canceled) return error.Canceled;
        return;
    };
}

test "Group.cancel wakes blocked socket reader and releases ownership" {
    var impl: std.Io.Threaded = .init(std.testing.allocator, .{ .concurrent_limit = .limited(1) });
    defer impl.deinit();
    const io = impl.io();
    var fds: [2]c_int = undefined;
    try std.testing.expectEqual(@as(c_int, 0), std.c.socketpair(std.c.AF.UNIX, std.c.SOCK.STREAM, 0, &fds));
    defer _ = std.c.close(fds[1]);
    const stream: std.Io.net.Stream = .{ .socket = .{ .handle = fds[0], .address = .{ .ip4 = .loopback(0) } } };
    var started: std.atomic.Value(bool) = .init(false);
    var cleaned: std.atomic.Value(bool) = .init(false);
    var group: std.Io.Group = .init;
    defer group.cancel(io);
    try group.concurrent(io, blockedRead, .{ io, stream, &started, &cleaned });
    while (!started.load(.acquire)) try std.Io.sleep(io, .fromMilliseconds(1), .awake);
    group.cancel(io);
    try std.testing.expect(cleaned.load(.acquire));
    var byte: [1]u8 = undefined;
    try std.testing.expectEqual(@as(isize, 0), std.c.read(fds[1], &byte, 1));
}

fn gatedRead(io: std.Io, stream: std.Io.net.Stream, started: *std.atomic.Value(bool), cleaned: *std.atomic.Value(bool)) std.Io.Cancelable!void {
    var shutdown: std.atomic.Value(bool) = .init(false);
    var transport = Transport.init(io, stream, &shutdown) catch {
        stream.close(io);
        cleaned.store(true, .release);
        return;
    };
    defer {
        transport.close();
        transport.deinit();
        cleaned.store(true, .release);
    }
    var buf: [32]u8 = undefined;
    var vec = [_][]u8{&buf};
    started.store(true, .release);
    _ = transport.read(&vec, 5000, false) catch |err| {
        if (err == error.Canceled) return error.Canceled;
        return;
    };
}

test "Group.cancel is bounded through the shared raw readiness gate" {
    var impl: std.Io.Threaded = .init(std.testing.allocator, .{ .concurrent_limit = .limited(1) });
    defer impl.deinit();
    const io = impl.io();
    var fds: [2]c_int = undefined;
    try std.testing.expectEqual(@as(c_int, 0), std.c.socketpair(std.c.AF.UNIX, std.c.SOCK.STREAM, 0, &fds));
    defer _ = std.c.close(fds[1]);
    const stream: std.Io.net.Stream = .{ .socket = .{ .handle = fds[0], .address = .{ .ip4 = .loopback(0) } } };
    var started: std.atomic.Value(bool) = .init(false);
    var cleaned: std.atomic.Value(bool) = .init(false);
    var group: std.Io.Group = .init;
    defer group.cancel(io);
    try group.concurrent(io, gatedRead, .{ io, stream, &started, &cleaned });
    while (!started.load(.acquire)) try std.Io.sleep(io, .fromMilliseconds(1), .awake);
    try std.Io.sleep(io, .fromMilliseconds(20), .awake);
    const clock = @import("../observability/clock.zig");
    const before = clock.monotonicNs();
    group.cancel(io);
    const elapsed = clock.elapsedNs(before);
    std.debug.print("Group shared-readiness cancel: {d} ms\n", .{elapsed / std.time.ns_per_ms});
    try std.testing.expect(elapsed < 1500 * std.time.ns_per_ms);
    try std.testing.expect(cleaned.load(.acquire));
}
