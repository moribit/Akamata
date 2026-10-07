# Tasks: effects, delivery and in-process testing

Read [guestbook](../../examples/guestbook/README.md) first for typed HTTP,
validation, repositories and generated schemas. Tasks adds queue effects and
explicit owner lifetimes; it is not an all-features starter template.

## Read the production code in this order

1. [contract.zig](../../examples/tasks/src/contract.zig): routes, queue event
   descriptor and Native/Workers provider/binding resolution.
2. [setup.zig](../../examples/tasks/src/setup.zig): **one Application graph**;
   only recover/request ID middleware and an explicitly named development migration.
3. [handlers.zig](../../examples/tasks/src/handlers.zig): typed request writes
   the task and publishes the event through `Context.queue()`.
4. [main.zig](../../examples/tasks/src/main.zig): checked DB and jobs.Provider,
   borrowed facades, explicit worker start, stop/join and reverse cleanup.
5. [worker.zig](../../examples/tasks/src/worker.zig): D1 and QueueOwner remain
   isolate-owned; consumer registration commits only after successful startup.
6. [integration_test.zig](../../examples/tasks/src/integration_test.zig): the
   same graph with QueueRecorder, real consumer/DB effects and Native jobs delivery.

## Run and test

From the repository root using Zig 0.17:

```sh
zig build -Dexample=tasks
./zig-out/bin/tasks
zig build tasks-test
zig build tasks-test -Doptimize=ReleaseSafe
zig build -Dexample=tasks -Dbackend=workers
```

The [example README](../../examples/tasks/README.md) contains request commands,
binding/schema setup, platform differences and lifecycle details. Native SSE is
a bounded lossy UI channel; Workers `/events` returns 501. Queue delivery is
portable and at-least-once. A DB write and external queue send are distinct
effects: queue admission failure does not roll back the task. Production needing
that guarantee uses an outbox/reconciliation policy.

QueueRecorder verifies publication metadata, not delivery durability. Consumer
and actual jobs-owner tests verify separate delivery behavior. No port or worker
thread is necessary in application tests; finite `worker.tick()` exercises the
real Native engine. A Workers build/host fixture is not a live Cloudflare claim.

Next: [chat](../../examples/chat/README.md) for long-lived transport ownership,
then [device messaging](../../examples/device_messaging/README.md) for production
providers, Principal and explicit versioned migration.
