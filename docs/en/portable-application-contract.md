# Portable Application Contract

Akamata keeps its existing App/Context, typed endpoints, Db/Stmt, Store,
Producer/Consumer, realtime.Service and events.Protocol. Native production
uses Threaded. Reactor remains parked behind its existing production gate.

## Inventory and boundaries

Routes already have runtime registration and a compile-time graph; no router
is added. Db selects SQLite/Turso on Native and D1/Turso on Workers. Store
adapts filesystem/R2; Workers downloads currently use a buffered HTTP ABI,
so semantic parity does not imply identical streaming resource behavior.
Queue provides typed delivery and callbacks, not automatic durable Native
queue provisioning. Realtime uses the existing typed rooms/backend facade.
OpenAPI and HTTP clients use endpoint schemas; realtime TS/C generators use
events.Protocol. Schema generation is not replaced with a universal AST.

Previously physical capability requirements, binding markers and State service
fields were independent. The new contract connects those existing metadata
sources and preserves manual State ownership.

## Declaration and resolution

`capability.Application` describes portable needs:
`database`, `object_storage`, `queue`, `realtime`, `outbound_http`, `crypto`.
`capability.Kind` remains the existing physical/platform source of truth:
filesystem, threads, sockets, sqlite, d1, durable_objects, outbound_http,
outbound_tcp, r2, queues, websocket, persistent_disk, persistent_storage,
crypto_random, web_crypto.

`capability.Contract(name, requirements, provisions)` requires explicit
`Provision` values. `defaultProvider` is a compile-time suggestion, never an
implicit service factory or global locator. Runtime ownership stays visible.

| Application need | Native / Container suggestion | Workers suggestion |
|---|---|---|
| database | sqlite | d1 (binding) |
| object_storage | filesystem | r2 (binding) |
| queue | native_queue, explicitly supplied Producer | workers_queue (binding) |
| realtime | native_realtime | durable_objects (binding) |
| outbound_http | native_http | workers_fetch |
| crypto | native_crypto | workers_crypto |

Turso is an explicit database alternative on all three targets. Declaring
sqlite does not prove a runtime URL points to SQLite; providers must wire
the declared adapter and configuration. Containers have Native capabilities,
not Workers binding access. Disk durability depends on deployment volumes.

`Contract.validate(target)` rejects missing/duplicate providers, incompatible
provider semantics and unsupported targets. `binding.validateContract(Env,
Contract, target)` validates resource names/kinds using D1/R2/Queue/DO markers.
It does not create remote resources or contain credentials/resource IDs.

## Runtime view and ownership

Opt-in State declares `pub const application_contract = ...`. App.init validates
target compatibility and the existing facade types in State: `db: Db`,
`store: Store`, `queue: Producer`, `realtime: Service`, as required.
Existing State without a contract is unchanged.

Context borrows `c.db()`, `c.storage()`, `c.queue()`, `c.realtime()` and retains
`c.state()`/`c.cfg()` as explicit escape hatches. Db/storage attach the existing
request trace. An observed facade must not escape request lifetime. Returned
storage readers still need close; storage spans time facade operations, not
the entire subsequent reader lifetime. Context never destroys service owners.
Copying a facade does not transfer ownership. Owners use existing App.own or
explicit lifecycle/defer; App does not implicitly close State resources.
Workers reference/scaffold setup cleans up App then DB if initialization fails;
successful owners live for the isolate lifetime.

## Endpoints and tooling

`capability.Uses(Endpoint, requirements)` adds portable route needs;
`Requires(Endpoint, physicalKinds)` remains a platform escape hatch. Typed
registration validates the State contract; runtime App.endpoint is unchanged.
Decorations preserve schema functions, errors, security and operation metadata.
OpenAPI exposes `x-akamata-capabilities` and
`x-akamata-platform-capabilities` from those same metadata values.

`Contract.writeManifest(target, writer, endpoints)` emits a versioned tooling
protocol without opening services. Applications expose it through the existing
runner convention `akamata-capabilities <target>`. The CLI uses
`akamata inspect capabilities --target=workers [--json] [--manifest=PATH]
[--config=PATH]`. A supplied manifest must be generated from the Zig contract,
not maintained as an independent schema. Unsupported old applications report
a missing tooling protocol instead of silently starting their HTTP server.

CLI statuses distinguish declared wiring from configured Workers bindings.
No status asserts remote readiness. Resource configuration remains managed by
the existing Cloudflare operation layer; inspection never rewrites user files.

Guestbook's shared `src/contract.zig` demonstrates route requirements and
SQLite/D1 resolution. Its metadata command executes before buildState,
preventing tooling from opening a DB or running migrations.

## Minimal explicit wiring

```zig
const C = am.capability.Contract("files", &.{ .database, .object_storage }, &.{
    .{ .capability = .database, .provider = .d1, .binding = "DB" },
    .{ .capability = .object_storage, .provider = .r2, .binding = "FILES" },
});
const Env = struct { db: am.binding.D1("DB"), files: am.binding.R2("FILES") };
comptime { am.binding.validateContract(Env, C, .workers); }
const State = struct {
    pub const application_contract = C;
    db: am.db.Db,
    store: am.storage.Store,
};
// A Workers entry point opens/owns Db and R2Store, then passes their facades
// into State. A Native entry point selects SQLite/FileStore and a Native C.
// The application handler uses c.db()/c.storage() in both cases.
```

Owners must outlive App and borrowed contexts. Destroy App first, then close
the database/store/queue/realtime owner; register lifecycle hooks with `App.own`
if needed. Native owners shared across request threads must be concurrency-safe.
The contract does not make an unsafe in-memory provider thread-safe.

Workers DB URLs now honor `d1:NAME`; the provider owns a copy of NAME. `d1:DB`
and `openD1(allocator)` retain their existing default behavior. Upgrading the
Zig dependency requires syncing managed JS glue: new private named-D1 imports
must match the WASM binary. Old binaries still use the retained default imports.
No remote resource is automatically created by the contract.

The R2 private bridge also provides write abort cleanup and returns the existing
PreconditionFailed error when a conditional put fails. Sync that bridge together
with the dependency. Reader/write failures no longer retain pending host chunks.

## Events, queue delivery and schema

`Protocol.descriptor(.event_tag)` derives the payload, event name and version
from the existing tagged union. `Producer.dispatchDescriptor` and
`Consumer(Event).consumeEnvelope` share that descriptor. They preserve event ID,
correlation ID, attempt, idempotency key and maximum attempts; the consumer
rejects an unexpected name/version before invoking the application handler.
An idempotency key is metadata, not a promise of exactly-once delivery.
Retries, deduplication and dead-letter policy remain backend-owned.

`protocol_gen.generateProtocol(Protocol, allocator, options)` uses that same
union/version for TS/C generation. Existing `generate`/`dispatch`/`consume`
entry points remain supported. HTTP clients still reuse OpenAPI's existing
schema collector; no new schema tree or client naming scheme is introduced.
Portable endpoint extensions are additive and preserve errors/security/input/
output. Wrapping with `Uses` and `Requires` keeps both kinds of requirement.

## Testing and evidence boundaries

`testing.MemoryStore` (16 objects, 4 KiB each) and `testing.QueueRecorder`
(64 entries, 64 KiB payload each, bounded metadata) are explicit test owners.
They expose the existing Store/Producer, have predictable overflow errors and
perform no external I/O. MemoryStore supports the tested range/ETag/conditional
subset; arbitrary custom metadata is explicitly unsupported. They are not
production adapters or durable queue implementations.

The identical fixture runs through `testing.Client` on Native and Workers WASM:
typed input, validation, 201/400/404/503 error semantics, DB effects, storage,
queue delivery, realtime broadcast/event schema, provider/route resolution,
OpenAPI and generated clients. Native's testing allocator checks leaks; the
Workers runner repeats ten times and checks that WASM pages plateau after
warmup. This does not prove all host memory is leak-free.

Adapter checks additionally execute real D1/R2/Queue Zig adapters with injected
host bindings. D1 named/default selection, statement cleanup, R2 range/read/
conditional/list/delete and Queue envelope delivery are checked. The managed
D1 JavaScript source is executed with a D1 test binding to check async behavior
and resource selection. Existing SQLite/Turso, Durable Object, serialized WASM
dispatch and transport suites remain separate. These offline tests do not
claim live D1/R2/DO integration or Cloudflare retry behavior.

Malformed typed JSON uses an explicit application `onError` policy in the
fixture. The existing default unhandled-error behavior is preserved.

```bash
zig build test
zig build test -Doptimize=ReleaseSafe
zig build portable-application-test -Dbackend=workers -Doptimize=ReleaseSafe
zig build compile-fail-test cli-capabilities-test cli-operations-test
zig build scaffold-local-test scaffold-test project-update-test workers-capability-sync-test
```

CI executes Native application tests as part of existing `test` jobs and a
separate Workers WASM contract job. Compile-fail diagnostics and capability CLI
checks run in the existing CLI smoke job.

## Deployment validation and remaining platform differences

Run `akamata check --quick --capabilities --target=workers --config=PATH`
before deployment (or omit `--quick` to also run project tests). Optional
`--manifest=PATH` supports repository examples/custom build runners. Existing
`check`, `inspect`, `doctor`, `config`, deployment and update behavior is retained
unless capability validation is explicitly requested. `routes explain` prints
portable/physical requirements from OpenAPI when the application exposes it;
source-only route discovery cannot infer requirements from imported handlers.

CLI binding inspection supports the repository's TOML array sections, exact
resource kinds/names and quoted strings. JSONC, environment overrides, resource
IDs, DO class/migration validity and live provisioning are not validated here.
Statuses are `declared`, `binding_configured` and `missing_binding`; missing
bindings fail the command. User configuration is not rewritten. Generated JS
uses existing named adapter operations; metadata does not replace custom glue.

Native jobs already provide a persistent SQLite job queue. Portable Producer
and Consumer still require explicit callback wiring to a queue owner; no new
automatic queue backend or scheduler is added. Workers QueueProducer uses the
selected binding. Workers realtime uses the existing DO/HTTP action control
plane; a general automatic DO-backed `Service` factory does not exist. Explicit
Service providers/platform escape hatches remain necessary. Declaring a provider
checks facility/wiring metadata, not arbitrary opaque vtable implementation.

R2 list cursors remain platform tokens while filesystem cursors are lexical
keys. R2 list metadata uses the caller allocator's operation lifetime (use an
operation arena); the current Store list API lacks a portable next-cursor
result. R2 head metadata is less complete than get metadata. Workers HTTP
downloads and bounded R2 uploads still have host-side buffering limits. These
are documented adapter differences, not erased by capability declarations.
Queue acknowledgement/redelivery and DO connection ownership remain platform
specific. Effects across DB/storage/queue/realtime are not one atomic transaction.

The next DX work should add adapter ownership helpers for existing jobs/DO
operations, strengthen list-page ownership/cursor semantics, then extend
environment-specific deployment validation. It should reuse these existing
facades rather than introduce a new framework. Reactor remains parked.
