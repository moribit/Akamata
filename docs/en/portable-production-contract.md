# Portable Production Contract

The existing Application Contract, Provision, binding declarations and Context facades remain the application model. Checked acquisition connects these declarations to concrete adapters and explicit owners. No universal Provider interface, automatic provisioning, service locator or new router is introduced. Native/Container production remains Threaded; Reactor is parked and fail-closed.

## Traceable wiring

Application / endpoint requirements → Contract Provision → binding validation → checked owner factory → existing adapter → environment resource configuration → optional live contract.

Compile-time checks establish target compatibility, required services and binding names/kinds. Checked factories establish database URL/provider consistency and derive binding names from Provision. CLI inspection establishes local deployment configuration consistency. None of these alone proves that a remote resource exists or an arbitrary manually supplied facade is the declared adapter.

Context borrows Db, Store, Producer and Service. App/State or the entry point retains explicit owners. Context never closes resources. Providers must remain stable until HTTP dispatch, consumer callbacks and socket callbacks have stopped. Acquisition uses errdefer; shutdown stops admission, joins borrowers and then destroys owners in reverse order. Workers isolate termination does not guarantee application destructors and never implies remote deletion.

## Provider / owner / evidence matrix

| Capability | Native / Container | Workers | Lifetime and evidence | Known limits |
|---|---|---|---|---|
| database | Db SQLite / Turso, caller-owned | Db D1 / Turso, caller-owned | openForContract → close; existing backend tests, actual SQLite integration, D1 WASM/managed bridge | URL checked before acquisition; secrets/remote existence are not proven offline |
| object_storage | StorageFactory filesystem, directory/Io borrowed | StorageFactory R2, Contract binding borrowed | owner adapter → Store borrow; Memory/FS/R2 page contract and host simulation | listPage owned; legacy list unchanged; Workers HTTP download/upload buffering differs |
| queue | jobs.Provider(Descriptor), existing jobs.Queue, Db borrowed | QueueOwner(Descriptor), copied binding, typed Consumer | stop worker → join → deinit; SQLite retry/attempt and Workers host wrapper tests | at-least-once; no exactly-once, no DB/enqueue transaction; Native descriptor-specific dispatch registry |
| realtime | realtime.Native owns registry; transport owns sockets | RealtimeOwner owns local Service adapter; DO owns sockets/attachments | drain socket callbacks → deinit; Native tests, WASM + managed DO/control bridge | zero presence cannot certify readiness; use presenceChecked; old attachments need reconnect for portable IDs |
| outbound_http | existing native HTTP client, caller-owned Io | existing Workers fetch adapter | request-scoped calls and existing adapter tests | platform transport limits differ; not a provisioned resource owner |
| crypto | existing native crypto helpers | existing Web Crypto host bridge | operation-scoped and existing tests | platform-specific algorithms remain explicit extensions |

Container mappings use the Native providers. SQLite/filesystem durability requires explicitly mounted persistent volumes. There is no automatic Container service provisioning.

## Deployment and evidence levels

[Deployment validation](deployment-validation.md) defines named-environment strict preflight and drift checks. Existing configured/missing-binding statuses remain compatible; added readiness is declared, configured or validated. Validated means local target/provider/binding/resource configuration consistency. It does not prove consumer callback registration, DO migration application, glue version or remote availability.

An application cannot infer queue-consumer registration from a Producer capability: producer-only applications are valid. The reference explicitly installs its typed consumer using the existing Workers dispatch hook. Custom glue remains responsible for this connection; adapter/managed-glue tests cover the repository implementation. Local inspection does not attest arbitrary source or generated WASM exports.

Evidence levels are Unit, Adapter Contract, WASM Host Simulation, Live Provider Contract and Production Observed. Reachable requires an actual safe probe; ready requires an application smoke contract. Offline CLI never emits either. [Live provider runner](live-provider-contract.md) is explicit opt-in, requires dedicated test resources and guarded credentials, and does not create resources. Infrastructure cleanup/expiry remains operator-owned. No live Cloudflare success is claimed without a recorded run.

## Storage and delivery contracts

[Owned storage pagination](storage-pagination.md) defines all result strings and cursors as page-owned, released by ListPage.deinit. Cursors are opaque to applications, backend-specific and not interchangeable. Limits are 1–1000; invalid syntax/non-advancing host cursors fail closed. Memory, filesystem and simulated R2 share tests for continuation, ownership, repeated listing and cleanup; native allocation-failure testing checks operation cleanup.

[Queue providers](queue-providers.md) document event version/ID, correlation, idempotency metadata, attempts, payload bounds and backend retry differences. Consumer work uses existing application event descriptors; HTTP/OpenAPI/client and realtime TS/C schemas remain sourced from the existing endpoint/types and events.Protocol. No schema AST is added.

[Realtime providers](realtime-providers.md) document room → DO namespace identity, UUID compatibility, portable lossless u64 identities, authorization and explicit platform extensions. Custom bindings require AKAMATA_REALTIME_BINDING to match Provision.

## Reference and compatibility

[Device messaging](../../examples/device_messaging/README.md) shares domain/application code across checked SQLite/filesystem/jobs/native realtime and D1/R2/Queues/DO owners. Guestbook remains the smaller database/typed endpoint reference. The in-process device test exercises real SQLite, filesystem ownership, queued report delivery and cleanup without sockets. CI compiles both device entry points.

Existing Db, Store.list, Producer/Consumer handler callbacks, Service and manual factories remain. Store Error adds InvalidCursor/InvalidLimit: exhaustive downstream switches need to handle them. listPage is additive and recommended for new code. The reference State/extra response fields changed internally and adds cleanup/delivery endpoints. Deploy now refuses implicit placeholder D1 creation; explicitly provision resources separately. Named-environment migration is rejected until it can safely select its adapter/resource. No remote resource is created because a capability is declared.

Further DX work should verify consumer/glue export metadata at the artifact boundary, add full JSONC/TOML parsing and safe named-environment migration routing, and run the isolated live workflow with operator-provided resources. These are explicit limitations rather than local readiness claims.
