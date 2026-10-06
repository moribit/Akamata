# Portable production reference

The existing shared application now demonstrates checked DB, Storage, Queue and Realtime provider ownership. contracts.zig defines requirements and bindings; application.zig defines domain routes, typed event descriptors and queue effects. Native and Workers entry points acquire concrete owners explicitly.

| Service | Native | Workers |
|---|---|---|
| DB | SQLite checked factory | D1 checked factory (DB binding) |
| Storage | Filesystem; explicit directory/Io owner | R2 derived FILES binding |
| Queue | existing jobs.Queue provider; explicit worker stop/join | QueueOwner + explicit setQueueConsumer callback; EVENTS binding |
| Realtime | existing Native registry; transport owns sockets | RealtimeOwner; AKAMATA_REALTIME DO namespace |

POST /reports commits a report then enqueues ReportDescriptor version 1. The same consumeReport callback borrows ReportEffects.db and records delivery idempotently by event ID. GET /reports/:id/delivery allows application smoke to observe actual consumer dispatch. DB write and Queue send are not atomic; failed send after commit may leave a report without delivery. Idempotency metadata and an idempotent consumer do not imply exactly-once or automatically make client HTTP retries idempotent.

Native owns DB, root directory, registry, Queue provider and worker thread in explicit reverse cleanup order. Workers setup uses errdefer for DB, secret strings, Realtime/Queue owners and route initialization; initialized is set only after successful registration. Context borrows db()/storage()/queue()/realtime(). No resource provisioning occurs during checked acquisition. R2/Queue/DO binding names come from Provision.

```sh
zig build -Dexample=device_messaging -Doptimize=ReleaseSafe
zig build run -Dexample=device_messaging -- akamata-capabilities workers
zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe
zig build test
```

The root managed Workers glue exports AkamataRealtimeRoom and the named realtime application handler; keep it synchronized for the additive R2 page/Realtime ABI. Configure real D1/R2/Queue/DO test bindings explicitly before deployment. There is no automatic resource creation. Native default is Threaded; Reactor remains parked.

Record/report DELETE routes scope SQL to the authenticated principal and support exact live-test cleanup. Object keys use a shared authenticated reference namespace; production multi-tenant applications must add their own object ownership policy. Existing endpoints remain; create responses additionally return IDs, report creation now depends on Queue admission, and State provider fields use the current portable facade names. These are reference-application changes, not a new framework service interface.

See ../../docs/en/provider-lifecycle.md, queue-providers.md, realtime-providers.md, deployment-validation.md and live-provider-contract.md for lifecycle, differences and evidence levels. The Native integration test uses actual SQLite/Filesystem/jobs/Realtime owners; the shared WASM fixture remains host-simulated evidence. A Workers build alone is not semantic production parity proof.
