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
