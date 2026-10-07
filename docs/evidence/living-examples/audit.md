# Living reference audit

Baseline: main `c69bbd8190e0e53e612f25448a6a6c86f83b70ef`, matching origin/main.
Zig 0.17.0. This is an application/example change, not a runtime redesign.

## Initial inventory

| Example | Learning purpose before refresh | API / older pattern | Duplication | Platform code | Ownership / lifecycle issue | README drift | Initial CI | Native / Workers | Role overlap |
|---|---|---|---|---|---|---|---|---|---|
| guestbook | Model-backed portable CRUD | Explicit Context, runtime Endpoint; example DatabaseEndpoint helper | Route descriptions repeated in index output | Two entrypoints, D1/SQLite URL | Deferred Workers migration swallowed errors; Native migration skipped failure | Contract reference stronger than ordinary-function teaching | Workers build, indirect CLI migration | Both compile; no own shared behavior test | tasks CRUD |
| tasks | CRUD, jobs, SSE, tooling | Manual binding, direct jobs.Queue | Production/test independently register five routes | Native-only events/jobs, no Workers entry | URL/DB partial startup leaks; App cleanup before DB differs in test; SSE borrowed bytes escape lock | Suggests obsolete Workers alternatives / Zig 0.16 rationale | tasks-test | Native only | guestbook HTTP teaching |
| chat | Rooms, SQL, WebSocket | App.get/post, openSqlite/openD1, ws.Hub | Native/Workers repeat route registration | Native socket; older ChatRoom DO | Hub copied into State; DB row/transport lifetime implicit; unbounded per-connection arena accumulation | Explicitly old hub reference | Native/Workers build | Both compile, no example semantic contract | device realtime |
| device_messaging | Multiple portable providers | Contract/Provision, Context facades, jobs.Provider, Workers owners | Credential verification repeated in handlers | Filesystem/R2, queue worker/dispatch, socket/DO | Schema in first HTTP/consumer path; mutable readiness flag; development secret defaults | Production example still includes development migration convenience | Native/Workers + integration + host fixtures | Strong offline evidence | chat realtime details |
| bench | HTTP performance fixture | Deliberately specialized runtime handlers | Companion languages intentional | Native benchmark | Measurement-owned process/DB | Must not imply canonical app architecture | adversarial/integration builds | Native only | none |
| router_bench | Static matcher measurement | Specialized comptime route graph | Matrix intentional | Native | Fixture lifetime | Missing example/fixture separation | benchmark targets/scripts | Native only | none |

## Existing APIs to reuse

`am.App(.{ .State, .routes, .configure })`, `am.endpoint`, explicit Path/Query/
Json/Principal wrappers, Result/created, mapped errors with explicit fallback,
DTO `__schema.validates`, Application.Metadata, existing App/Context escape hatch,
Contract/Provision, db.openForContract, StorageFactory, jobs.Provider,
Workers QueueOwner/RealtimeOwner, realtime.Service/Protocol/MessageArena and
testing.Client. No new router/provider engine/service locator is needed.

## Learning path and migration policy

Minimal is the existing scaffold and compiled documentation source. Guestbook
teaches typed HTTP; tasks teaches effects/testing; chat teaches realtime/domain
versus transport; device_messaging teaches production ownership. Benchmark paths
stay intact because build/CI/scripts/historical evidence consume them.

Native tutorials may explicitly initialize development schemas before serving.
Workers and production references use out-of-band schemas/versioned migrations;
request handlers and queue consumers must not silently perform DDL. Configuration
and migrations are validation/explicit operations, never automatic provisioning.

## Dogfooding comparison (read-only)

Local Ehagaki, mimoc_news and mobus-backend sources were inspected. Ehagaki
demonstrates shared setup/model code and isolate-lifetime App state, but still
contains a deferred migration pattern. mimoc_news gates request migration behind
an explicit development-only flag and fails 503 rather than swallowing failure.
mobus-backend keeps DB/files/RealtimeOwner in entrypoints and uses bounded
per-message arenas and explicit platform gateway handlers. References adopt
those ownership and production-migration boundaries, not their complete domain
APIs. No external application was modified, no secrets/config values were read,
and no live deployment evidence is claimed.

Further lifecycle/boilerplate decisions and final commands/results are recorded
as each example is updated. Native Threaded and parked Reactor remain unchanged.
