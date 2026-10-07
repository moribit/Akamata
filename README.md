# Akamata

![Akamata ASCII art hero](assets/branding/akamata-ascii-hero.png)

[日本語](README.ja.md) | English

A portable Zig backend framework for Native and Cloudflare Workers. Start with ordinary functions, then add typed JSON APIs, authentication, database, storage, queue and realtime through existing application contracts and explicit provider owners. Native production uses Threaded; Reactor remains parked. Workers host simulation is tested separately from opt-in live Cloudflare validation.

Latest release: **v0.2.0** · Requires **Zig 0.17.x** · [Release notes](CHANGELOG.md)

```zig
const std = @import("std");
const ak = @import("akamata");

fn hello() []const u8 {
    return "Hello, Akamata!";
}

pub const Application = ak.App(.{ .routes = .{ak.get("/", hello)} });

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    var app = try Application.init(gpa.allocator());
    defer app.deinit();
    try app.serve(.{ .port = 8080 });
}
```

The ordinary-function API below is available in v0.2.0; the explicit App(State) API remains supported. The [source](tests/docs/minimal.zig) is compiled and tested with `zig build documentation-test -Doptimize=ReleaseSafe`, including a Workers WASM application contract. Caller-owned initialization is explicit; no Context is needed for Hello World.

## Why Akamata?

- **Zig-native typed handlers** — ordinary functions, structs and error sets
  define typed inputs, validation, responses and HTTP error mappings.
- **One application, Native or Workers** — share application contracts with
  explicit platform entry points and owners. Containers run the Native path.
- **Portable backend services** — existing DB, Storage, Queue and Realtime
  contracts connect SQLite/filesystem/jobs to D1/R2/Queues/Durable Objects.
- **Types reach your tools** — endpoint metadata feeds OpenAPI, TypeScript
  clients and in-process tests, including Principal and provider effects.
- **Measured Native runtime** — Threaded remains the production default.
  See the [local benchmark and its conditions](docs/en/public-performance.md).

## Quick start

The CLI installer is included in the repository; clone it first:

```bash
git clone https://github.com/moribit/Akamata.git
cd Akamata
./scripts/install.sh

# Ensure $HOME/.local/bin is on PATH, then create an app anywhere.
cd ~/projects
akamata init myapp --target=both
cd myapp
akamata dev
```

In another terminal:

```bash
curl -sS http://127.0.0.1:8080/
```

The default project serves one Hello response without opening a database or
configuring providers. `--target=both` adds Workers and Container deployment files.
Choose `--template=notes` for the existing SQLite CRUD/validation/migration tutorial.
Current CLI scaffolds pin v0.2.0. If an older CLI generated a v0.1.5 project, run
`akamata update --to=v0.2.0` before using typed examples. See [Getting Started](docs/en/quickstart.md).

Developing the CLI itself? Build without installing:

```bash
zig build cli
./zig-out/bin/akamata help
```

## Requirements and compatibility

| Scope | Requirement |
|---|---|
| Core development | Zig 0.17.x, macOS or Linux, libc |
| Native database | Bundled SQLite amalgamation; no system SQLite install required |
| Workers | Node.js + Wrangler, a Cloudflare account; D1 is optional |
| Containers | Docker; Cloudflare Containers requires an eligible Cloudflare plan |
| Turso / HTTPS client | Zig standard-library TLS and the OS trust store |
| FCM RS256 signing only | Optional OpenSSL build flag (`-Dopenssl=true`) |

Windows native support is not documented or tested; use WSL2 for the supported
Linux workflow. SSE and native WebSocket connections are native-only today;
Workers WebSockets use the provided Workers/Durable Object integration pattern.

## Documentation

| Goal | English | 日本語 |
|---|---|---|
| Get running | [Quick Start](docs/en/quickstart.md) | [クイックスタート](docs/ja/quickstart.md) |
| Learn step by step | [Tutorial](docs/en/tutorial.md) | [チュートリアル](docs/ja/tutorial.md) |
| Tour the framework | [Handbook](docs/en/handbook.md) | [ハンドブック](docs/ja/handbook.md) |
| Upgrade from v0.0.1 | [Upgrade guide](docs/en/upgrading.md) | [アップグレードガイド](docs/ja/upgrading.md) |
| Find a topic | [Documentation home](docs/en/README.md) | [ドキュメントホーム](docs/ja/README.md) |
| Present Akamata | [Slides (PDF)](docs/en/slides.pdf) | [スライド (PDF)](docs/ja/slides.pdf) |

## Features

- Runtime route builder, path parameters, grouped routes, and middleware
- JSON, form, multipart, cookies, validation, and typed model repositories
- SQLite, D1 through JSPI, and Turso/libsql Hrana
- Native WebSocket, SSE, static files, compression, and security middleware
- JWT, bcrypt, sessions, CSRF, rate limiting, and bearer authentication
- Native/Workers outbound HTTP, MQTT QoS 0, and optional FCM support
- Request IDs, access logs, Prometheus metrics, lightweight spans, and
  `Server-Timing`
- OpenAPI generation, typed client generation, testing client, jobs, and cron
- Compile-time typed handler binding, lifecycle hooks, per-route resource
  budgets, route inspection, project doctor, and schema-aware API diff

Backend availability and API details are documented in the
[Handler API](docs/en/handler-api.md), [DB backends](docs/en/db-backends.md),
and [WebSocket guide](docs/en/websocket.md).

Begin with ordinary functions and `ak.App(.{ .routes = ... })`.
The explicit `App(State)`/`Context(State)` API remains available for advanced control.
See the [v0.2 Phase 1 changes](docs/en/v0.2-phase1.md) for removed APIs.

## Examples

[Follow the learning path](examples/README.md): canonical minimal scaffold →
guestbook (typed HTTP / validation / DB / OpenAPI) → tasks (queue effects /
testing) → chat (portable protocol / explicit transports) → device_messaging
(production providers / Principal / migration).

Benchmark fixtures remain under `examples/bench` and `examples/router_bench`
for historical scripts; they are measurements, not application architecture.

## License

MIT
