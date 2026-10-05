# Akamata architecture

Akamata runs the same Zig application on Native/VPS/Containers and Cloudflare Workers. Its application-facing HTTP path is `App → Context → endpoint/middleware → runtime`.

## Application and adapters

- `src/app.zig` owns route registration, middleware chains, lifecycle hooks, and dispatch. `src/context.zig` provides request data, responses, application state, and portable services. Handlers receive `*am.Context(State)`; middleware receives that Context and `am.Next(State)`.
- `src/static_router.zig`, `static_middleware.zig`, and `contract.zig` provide compile-time registration/binding into the same App dispatch. They are not a separate HTTP server API.
- `src/serve.zig` selects the backend. Native listener/admission/lifecycle lives in `runtime/threaded.zig`; `http/connection.zig` owns shared HTTP semantics, using a statically dispatched `runtime/socket_transport.zig`. Threaded drives the shared incremental Session synchronously; private kqueue/epoll evaluation multiplexes sockets with a bounded handler pool. Public Reactor selection stays fail-closed. See [current lifecycle and Transport Contract](runtime-transport.md).
- Workers uses `src/runtime/workers.zig` and the JavaScript WASM bridge under `deploy/worker/`. HTTP requests enter the same App dispatch. JSPI serializes a complete WASM request while asynchronous host operations suspend. Bridge details stay outside application handlers.
- Database, storage, queue, and realtime abstractions expose portable interfaces with platform adapters. SQLite/Turso and Workers D1 use `am.db.Db`; filesystem and Workers R2 use the storage boundary. Platform-specific capabilities are explicit.

```zig
const State = struct { hits: u32 = 0 };
fn hello(c: *am.Context(State)) !void {
    c.state().hits += 1;
    try c.text("hello");
}
// During application initialization:
// var app = am.App(State).init(allocator, .{});
// defer app.deinit();
// _ = try app.get("/hello", hello);
// try app.serve(.{ .port = 8080 });
```

Shared mutable state must be synchronized when serving concurrent Native requests.

## Native request flow

1. Accept connections under configured limits and record peer addresses.
2. Parse headers/body with size limits and header/body/idle/total deadlines; reject ambiguous framing.
3. Dispatch through App route matching, Context construction, middleware, and endpoint.
4. Write the response or chunked stream; retain the connection only within keep-alive limits.
5. A Native WebSocket upgrade transfers the connection to `am.ws.Conn`; that upgraded connection owns its lifetime. Workers realtime uses its platform bridge.

## Build and C bindings

| Backend | Target | Use |
|---|---|---|
| Native | Host default | Local development/VPS |
| Native | `x86_64-linux-musl` | Static container binary |
| Workers | Automatic `wasm32-freestanding` | Workers WASM |

Native compiles the vendored SQLite amalgamation. `build.zig` imports its headers as module `sqlite3` using the official external translate-c package, pinned to its Zig 0.17 branch commit. Optional `-Dopenssl=true` translates `src/crypto/openssl.h` with system `ssl`/`crypto` include/link discovery for RS256 signing. Workers does not instantiate this lazy Native dependency. There is no source-level C import. [Binding tradeoffs](v0.2-phase1.md#c-bindings) describe this choice.

## CLI architecture

`tools/akamata/src/main.zig` handles arguments, help, exit behavior, and command dispatch. `command/` orchestrates commands; `project/` owns manifests, scaffolding, managed-file hashes, and update protection. `process.zig` owns subprocess transport and `native.zig` shares POSIX filesystem ABI definitions with the dev watcher.

Cloudflare operations follow `command → cloudflare/operations.zig → cloudflare/wrangler.zig → process`. The operation layer exposes deploy and D1 create/list/execute/provision, with an injectable runner for offline contract tests. Provider arguments and output parsing stay in `cloudflare/`; configuration rendering is in `cloudflare/config.zig`. Wrangler remains the sole default provider. `--containers` currently builds a Linux binary and Docker image; it does not provision or publish Cloudflare Containers.

## Operational boundaries

- Terminate inbound TLS at Cloudflare/nginx/Caddy. Native outbound HTTPS uses `std.crypto.tls.Client` with OS certificate roots; Workers uses host fetch. Optional OpenSSL is used for signing, not outbound transport.
- HTTP parsing rejects duplicate CL/Host, ambiguous framing, obs-fold, invalid chunking, and unsupported versions. Response headers reject injection. Native parsing deadlines and connection/request limits are configurable with `ServeOptions`.
- Metrics, tracing, request IDs, and timing use existing middleware and request-scoped observability structures; platform clocks/transport are adapters. Phase 2 will evaluate consistent App configuration rather than create another framework.
- Workers D1 requires the asynchronous JSPI bridge and fails closed if the bridge is unavailable. Native-only job queues and MQTT remain capability-specific; portable scheduled events are Phase 2 work.

See [v0.2 Phase 1](v0.2-phase1.md) for breaking API removals, validation, and the next design review.

Native Reactor separates finite application steps from connection ownership. Threaded preserves synchronous stream/upgrade; Reactor requires incremental sessions. Shared HTTP, bounded queues/output, static Transport and the unchanged release gate are documented in [Phases 6–9](native-reactor-phases6-9.md).
