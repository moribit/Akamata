# Tasks — application effects and testing

## What you will learn

Follow a typed HTTP operation into a portable queue, a finite consumer, a DB
side effect and Native SSE. Use the **same Application graph** with real owners
or a bounded `QueueRecorder`, without sockets or a background test thread.

## Why this example exists

Start with [guestbook](../guestbook/) for DTOs, validation and DB basics. Tasks
adds effects and delivery semantics; it is not the default template for every app.

## Run Native

From the repository root, using Zig 0.17:

```sh
zig build -Dexample=tasks
./zig-out/bin/tasks
```

`DATABASE_URL` defaults to `file:tasks.db`; `PORT` defaults to `8080`.
Native tutorial startup applies the model schema. This development convenience
is **not a production migration strategy**. A production application applies
versioned migrations before admitting traffic.

```sh
curl -H 'content-type: application/json' -d '{"title":"buy milk"}' http://localhost:8080/tasks
curl -N http://localhost:8080/events
```

## Run / Build Workers

```sh
zig build -Dexample=tasks
./zig-out/bin/tasks --print-schema > /tmp/tasks.sql
zig build -Dexample=tasks -Dbackend=workers
```

The shared graph selects D1 `DB` and Workers Queue `EVENTS`. Apply the emitted
schema to the selected test/deployment D1 resource **before deployment**, and
configure producer **and consumer** bindings in your environment. Use the
[current managed Workers glue](../../docs/en/portable-production-contract.md),
including its queue dispatch exports; a WASM build alone does not create a queue
or prove a live deployment. `/events` explicitly returns `501` on Workers:
this example's local SSE channel is not a Durable Object subscription.

## Test

```sh
zig build tasks-test
zig build tasks-test -Doptimize=ReleaseSafe
```

Tests construct `setup.Application` with SQLite and `QueueRecorder`, exercise
validation/CRUD, assert `TaskCreatedDescriptor` publication, then invoke the
same `Consumer` twice to verify the DB's event-ID guard. The recorder proves
admission metadata, not durability, retry scheduling or live Workers behavior.

## Architecture

```text
contract.routes → setup.Application → Context borrows DB + Producer
                                      │
                                  TaskCreated
                                      │
                 Native jobs.Provider / Workers QueueOwner
                                      │
                            explicit Effects context
                                      │
                          task_deliveries + Native SSE
```

`main.zig` owns DB, channel and queue. It stops/joins the worker **before**
application/queue/channel/DB cleanup. Workers initializes stable isolate-owned
state once, unwinds partial startup failures, and explicitly registers its
consumer only after success. Context destroys none of these owners.

Delivery is **at-least-once**. The descriptor supplies name/version; event ID,
idempotency key, correlation ID, attempt and max attempts travel in the envelope.
Native retries use the jobs engine; Workers retry/dead-letter policy belongs to
deployment configuration. The DB primary key guards duplicate notification rows;
SSE may repeat and is intentionally a lossy UI hint, not durable delivery.

The task INSERT and queue publish are **not atomic across providers**. A publish
failure returns 500 after the task exists. Production requiring reliable paired
effects should use a transactional outbox and reconciliation; this example does
not claim exactly-once delivery. Tests preserve that failure boundary.

SSE snapshots copy bytes while locked, retain at most 64 × 4 KiB, reject oversized
notifications, and cap each connection to 60 seconds of monotonic elapsed time.
Slow/disconnected clients use the existing Threaded write/deadline contract.

Metadata is declared once in `contract.zig`. `/openapi.json` and `/client.ts`
use the same graph; offline `akamata-openapi`, `akamata-client` and
`akamata-capabilities native|workers` do not initialize DB/queue owners.

## Next

Continue to [chat](../chat/) for explicit realtime transport ownership, then
[device_messaging](../device_messaging/) for multiple production providers.
See [Testing](../../docs/en/guides/testing.md) and
[Background jobs / Queue](../../docs/en/handbook.md).
