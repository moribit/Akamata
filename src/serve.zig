// `app.serve()` implementation: dispatches to a native HTTP server or to the
// Workers WASM bridge based on `build_options.backend`.

const std = @import("std");
const build_options = @import("build_options");
const app_mod = @import("app.zig");
const res_mod = @import("http/response.zig");
const parser = @import("http/parser.zig");

const is_native = build_options.backend == .native;
const Io = std.Io;

pub fn serve(comptime State: type, app: *app_mod.App(State), opts: app_mod.ServeOptions) !void {
    if (is_native) {
        switch (opts.runtime) {
            .threaded => return @import("runtime/threaded.zig").serve(State, app, opts),
            // The reactor implementations do not yet enforce the production
            // parser, deadline, connection, peer-IP, and backpressure
            // contracts of the threaded runtime. Fail closed until parity is
            // proven by the shared integration suite.
            .reactor => return error.ExperimentalRuntimeDisabled,
        }
    }
    return serveWorkers(State, app, opts);
}

// =========================================================================
// Workers: register the dispatch with the WASM runtime
// =========================================================================

const runtime_workers = if (build_options.backend == .workers) @import("runtime/workers.zig") else struct {};

fn serveWorkers(comptime State: type, app: *app_mod.App(State), opts: app_mod.ServeOptions) !void {
    if (is_native) return;
    app.trust_proxy_headers = opts.trust_proxy_headers;
    app.trusted_proxy_fn = opts.trusted_proxy_fn;
    try app.prepare();
    const Wrap = struct {
        var app_ref: *app_mod.App(State) = undefined;
        var parse_limits: parser.Limits = .{};
        fn dispatch(request_bytes: []const u8, out: *std.ArrayList(u8)) anyerror!void {
            const gpa = std.heap.wasm_allocator;
            var arena_state: std.heap.ArenaAllocator = .init(gpa);
            defer arena_state.deinit();
            const arena = arena_state.allocator();

            const parsed = try parser.parseRequest(arena, request_bytes, parse_limits);
            var req_local = parsed.request;
            var res: res_mod.Response = .init(arena);
            res.keep_alive = false;

            try app_ref.dispatchWithPeer(arena, &req_local, &res, null, null, null);

            var aw: Io.Writer.Allocating = .fromArrayList(gpa, out);
            defer out.* = aw.toArrayList();
            try res.writeTo(&aw.writer);
        }
    };
    Wrap.app_ref = app;
    Wrap.parse_limits = opts.parse_limits;
    runtime_workers.setDispatch(Wrap.dispatch);
    // Hand control back; the JS host invokes `handle_fetch` per request.
}
