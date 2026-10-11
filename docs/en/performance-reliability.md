# v0.2.1 performance and reliability

Native production uses Threaded. Reactor remains parked and fail-closed. This
work does not publish a release or change the default runtime.

Start with [DB Pool deadlines and metrics](db-pool.md). Pool acquisition uses
Zig 0.17 std.Io mutex/condition waits and absolute monotonic deadlines. `close`
stops admission; `deinit` waits for borrowers and already-entered acquisitions.
Handle ownership transfers only after successful initialization.

Runtime metrics borrow the existing Prometheus Counters owner explicitly through
ServeOptions. Application phase metrics also work through `App.metrics`. Existing
DB spans, Server-Timing, request IDs and backend labels remain the query-timing
source. Socket waits measure elapsed time, not CPU time. See the metric table and
overlap/stream limitations in the Pool guide.

## Native / Workers capability status

This is a semantic support matrix, not proof that every adapter behaves identically.

| Feature | Native Threaded | Workers managed host |
|---|---|---|
| Buffered HTTP | supported | supported; WASM transaction serialized per instance |
| HTTP streaming / SSE | supported with bounded write/drain | synchronous Response streaming unsupported; fail-closed |
| WebSocket / realtime | native socket owner and Service | explicit DO gateway/control owner; different transport lifecycle |
| DB | SQLite / Turso facade; native Pool deadlines | D1 / Turso facade; no native Pool |
| Storage | filesystem Store, bounded readers, caller-owned pages | R2 Store bridge, caller-owned opaque pages |
| Queue | jobs.Queue provider, cooperative stop/join | explicit producer binding and consumer dispatch |

[Cloudflare Streams](https://developers.cloudflare.com/workers/runtime-apis/streams/)
supports streaming HTTP responses, but this does not make Akamata's synchronous
socket producer portable. Current managed glue copies a completed WASM response
and serializes its ABI transaction around shared allocator/response registries.
A safe bridge needs a separate producer lifetime, bounded pull admission, abort
cleanup, terminal error propagation and fixed-length validation. Returning a
ReadableStream around that completed buffer would not satisfy this contract.
No buffering shim or unbounded queue is introduced. `UnsupportedOnTarget` remains
the explicit synchronous streaming outcome without a socket writer.

DB acquisition timeout is distinct from query timeout. Acquiring a pool lease
does not cancel SQLite/Turso/D1 work. Backend query limits and cancellation differ;
no automatic query retry or exactly-once effect is implied. Queue delivery remains
at-least-once; event ID, version, attempt, correlation and idempotency metadata are
preserved, while retry/dead-letter policy is provider-specific. Storage cancellation
and conditional errors remain in the existing Store/bridge contract.

## Typed wire contracts

Mapped errors retain HTTP status and the `error_kind` discriminator through actual
in-process responses, OpenAPI and generated TypeScript. Enum schemas retain literal
types. Tagged-union responses use Zig's JSON object-with-active-tag representation;
void payloads are empty objects. See [handler API](handler-api.md). Optional/null
and default/omission are separate semantics. Custom serializers require explicit
metadata; their schema is not inferred.

## Allocation and optimization decisions

`zig build http-allocation-profile -Doptimize=ReleaseSafe` distinguishes logical
arena requests from backing heap allocations. The small fixture observes one
parse allocation, one header allocation, one static-body copy allocation and two
JSON header/body allocations. Cursor/write adds zero heap allocations; 1,000 warmed
JSON iterations with retained arena capacity add zero backing heap allocations.
This is fixture evidence, not a universal allocation-free claim.

Borrowed responses, inline self-referential buffers and global buffer pools are
not adopted: the measured warm heap cost does not justify their ownership and
maintenance complexity. Existing arenas, body ownership and static dispatch remain.
The transport initialization error path now closes the accepted socket through
its existing drain owner. Required DTO fields are checked before lifting; an
unreachable zero-initialization fallback was removed so tagged unions are safe.

## Reproduction and evidence

Raw measurements are in [benchmark-results/v0.2.1](../../benchmark-results/v0.2.1/README.md).
They include binary SHA, oha output, CPU/RSS/thread samples, errors and shutdown.
Keep instrumentation runs separate from throughput comparisons. Use the same
binary build mode, allocator, connection lifetime, input and sampling interval.
The HTTP fixture defaults to 100 requests per connection, so backing allocations
include connection renewal and startup; they are not per-request logical counts.

```sh
zig build -Dexample=bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_matrix.py after=zig-out/bin/bench --output /tmp/after.json --connections 32 128 512 1024 --rounds 3 --duration 3s --modes keep_alive
python3 tools/bench/runtime_matrix.py after=zig-out/bin/bench --output /tmp/metrics.json --connections 32 --idle 32 --rounds 3 --duration 3s --observability metrics
python3 tools/bench/runtime_matrix.py after=zig-out/bin/bench --output /tmp/large-json.json --connections 32 --idle 32 --rounds 3 --duration 3s --endpoints echo --echo-bytes 65536 --stats
zig build test db-pool-test transport-contract-test runtime-contract-unit -Doptimize=ReleaseSafe
zig build portable-application-test documentation-test -Dbackend=workers -Doptimize=ReleaseSafe
zig build db-pool-test -Druntime-tsan=true -Doptimize=ReleaseSafe
```

Pool and socket contract tests include deadlines, exhaustion, disconnect, idle
connections, overload, slow readers, streaming/upgrades and cooperative shutdown.
TSan is opt-in in the existing Linux/macOS sanitizer workflow. Offline adapter
contracts and WASM host simulation do not certify live Cloudflare resources.
Live validation requires explicitly isolated resources and credentials; normal
CI never provisions resources automatically.

The prepared static route + empty handler and the same route with a passthrough middleware both make zero logical arena allocation requests in the diagnostic fixture. This excludes route registration/preparation and response payload generation.
