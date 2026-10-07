# Device messaging — portable production contract

## What you will learn

Acquire DB/Storage/Queue/Realtime providers against one Capability Contract,
retain explicit owners, verify a credential once into Principal, and trace a
report through a real queue consumer. This is a **production wiring reference**,
not a claim that the sample policy is suitable for every production application.

## Why this example exists

Begin with [guestbook](../guestbook/), [tasks](../tasks/) and [chat](../chat/).
Here the question is how several capabilities fit together: binding validation,
partial startup cleanup, owner lifetime, explicit migration and shutdown order.
Do not start a Hello World by copying this entire application.

## Run Native

From the repository root with Zig 0.17:

```sh
zig build -Dexample=device_messaging -Doptimize=ReleaseSafe
./zig-out/bin/device_messaging migrate-up
JWT_SECRET=local-test-jwt-secret LOGIN_SECRET=local-test-login-secret ./zig-out/bin/device_messaging
```

The displayed credentials are for local exploration only. Production supplies
strong secrets explicitly; missing secrets fail startup. `DATABASE_URL` defaults
to `file:device_messaging.db` and must match the selected provider. `migrate-up`
uses versioned SQL under `examples/device_messaging/migrations` and records
applied migrations. Run migrations from the repository root or pass a directory.
Only `--dev-init` opts into tutorial initial-schema creation. There is **no
first-request migration** and no migration inside queue delivery. Native
`jobs.Provider` initializes its own jobs-engine table during acquisition.

`POST /login` takes `{ "subject": "device-1", "credential": "..." }` and returns
a bounded-expiry bearer token. The middleware verifies it once, attaches
`Authenticated` via `Context.setPrincipal`, and handlers borrow it. `POST
/records` shows ordinary typed `Principal` + JSON DTO + created response.
The other routes use Context intentionally for storage streaming, manually
scoped SQL and explicit realtime control-plane behavior.

## Run / Build Workers

```sh
./zig-out/bin/device_messaging --print-schema > /tmp/device-messaging.sql
./zig-out/bin/device_messaging akamata-capabilities workers
zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe
```

Configure D1 `DB`, R2 `FILES`, Queue producer/consumer `EVENTS`, DO
`AKAMATA_REALTIME`, named service `AKAMATA_REALTIME_HANDLER`, and secrets
`JWT_SECRET` / `LOGIN_SECRET`. Use an isolated environment and explicit versioned
D1 migration **before deployment**. This example does not create remote resources.

The root `deploy/wrangler.toml` is the **chat** template, not this application's
config. Generate/maintain a separate deployment configuration with all providers;
keep its JS glue synchronized with the current managed template. `akamata
inspect capabilities` / `check --capabilities` validate declared/configured wiring,
not remote readiness. See [deployment validation](../../docs/en/deployment-validation.md).

## Test

```sh
zig build test
zig build test -Doptimize=ReleaseSafe
zig build portable-application-test -Dbackend=workers -Doptimize=ReleaseSafe
```

`src/integration_test.zig` uses actual SQLite, filesystem, Native realtime and
jobs owners with the production endpoint registration. It tests login → JWT
middleware → report queue → finite `worker.tick()` → observable delivery → scoped
cleanup, plus typed Principal injection and validation. `Client.as` uses the
request-local attachment path; it does not globally disable authentication.
The core fixture independently covers host-simulated Workers adapters and partial
provider failure. [Live tests](../../docs/en/live-provider-contract.md) are
explicit opt-in with dedicated test resources; no live Cloudflare certification
is implied by compilation or a WASM fixture.

## Architecture

```text
contracts.For(target) → checked acquisition → entrypoint/isolate owners
         │                                      │
    endpoints                          DB / Store / Producer / Service
         │                                      │
         └──────── application Context borrows ──┘
                          │
                credential → Principal → domain work
                          │
                 ReportDescriptor → Consumer → delivery row
```

| Capability | Native owner/provider | Workers owner/provider |
|---|---|---|
| database | entrypoint Db / SQLite | isolate Db / D1 `DB` |
| storage | directory + Io / filesystem | isolate StorageFactory / R2 `FILES` |
| queue | jobs.Provider + explicitly joined Worker | QueueOwner + explicit dispatch / `EVENTS` |
| realtime | Native registry + guarded socket transport | RealtimeOwner + DO / `AKAMATA_REALTIME` |

Context destroys no owner. Startup uses `try`/`errdefer`; successful acquisition
is followed by reverse cleanup. Native stops/joins the worker before App, queue,
transport gate, registry, DB and filesystem directory cleanup. Workers owners
keep stable addresses for the isolate; initialization commits only after all
route/consumer wiring succeeds, and failure unwinds acquired resources before
retry. Isolate-owned providers are not reinitialized or destroyed per request.

Queue delivery is at-least-once: descriptor version, event ID, correlation,
idempotency key, attempt and max attempts are preserved. DB INSERT and queue send
are **not atomic**. A publish failure can leave an undelivered report; production
requiring guaranteed paired effects needs an outbox/reconciliation policy.
An idempotent consumer does not make HTTP retries exactly-once.

Native WS has a per-message arena and a transport lifetime gate; a slow receiver
can delay other realtime sends. Workers DO owns transports, authorization derives
room/identity from verified JWT, and the named handler returns bounded effects.
Object keys use a shared authenticated reference namespace; multi-tenant apps
must add an object ownership policy. The login shared credential is a demo policy,
not a complete identity service. Native Threaded remains default; Reactor is parked.

### Compatibility note

Startup now requires explicit schema migration and credentials. `schema_ready`
was removed from example State; request/delivery DDL no longer occurs. Empty
record DTOs use typed validation (`422`) rather than manual `400`. Context-based
advanced routes remain. Framework provider APIs are unchanged.

## Next

Read [provider lifecycle](../../docs/en/provider-lifecycle.md),
[Queue providers](../../docs/en/queue-providers.md),
[Realtime providers](../../docs/en/realtime-providers.md), and
[Portable Production Contract](../../docs/en/portable-production-contract.md).
Apply environment validation and optional live evidence to your own deployment.
