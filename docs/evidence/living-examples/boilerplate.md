# Repeated application code: decisions

Inspected baseline and final sources; this is not a proposal for a DI container.

| Pattern | Occurrences | Why repeated / current source | Could core own it? | Decision |
|---|---:|---|---|---|
| Workers stable isolate initialization | 4 examples | `worker.zig`: stable globals, checked acquire, errdefer, commit initialized after graph/consumer registration | A small lifecycle helper may be possible, but DB-only and queue/realtime owners have different cleanup and stable-address requirements | Later; preserve explicit lifetime, no examples-only helper |
| Provider acquisition bundle | 3 stateful/effects examples plus production reference | Db plus optional channel, filesystem, queue and realtime | A universal owner would obscure reverse cleanup and worker join | Do not abstract; owners remain in entrypoints |
| Typed graph reflection quota | 3 typed graphs | Large compile-time DTO/route metadata required caller quota | Compiler bookkeeping belongs in `App` and descriptor `For` | Implemented in separate core commit; no public API |
| Route registration / test setup | guestbook, tasks, chat | `setup.Application` built from one route tuple | Already owned by existing ordinary-function Application API | Reused; deleted duplicate test graph |
| Principal attachment | device production reference | Middleware verifies credential once; Context borrows copied request-local Principal | Existing Context and typed Principal already provide the mechanism | Reused; no auth framework |
| Migration startup | 4 examples, 3 dogfood apps | Tutorials initialize before admission; production requires explicit versioned migration | Automatic migration would hide policy and deployment errors | Do not abstract; document tutorial versus production |
| Queue thread ownership | tasks and device | `worker.run`, stop/join before owner cleanup; tests use finite tick | Threaded lifecycle is explicit and different from Workers dispatch | Later only with evidence of a reusable owner; no scheduler |
| Native realtime callback lifetime | chat and device | Gate protects broadcast callbacks against detach and Conn destruction; MessageArena reset per frame | Core could eventually provide transport leases/retirement | Later; current explicit gate is safe but slow peers serialize realtime sends |
| SQL schema deployment copy | chat | Canonical embedded schema also published to D1 template | Generation is possible | CI byte equality now; no independent second schema |
| Benchmark directory relocation | 2 fixtures | Existing build/scripts/historical evidence consume `examples/bench` paths | Not a framework concern | Later physical move; learning index and fixture READMEs separate roles now |

No new router, DB facade, queue engine, storage abstraction, realtime backend,
service locator, middleware preset or Workers lifecycle API was added.

## Read-only dogfood comparison

| App | Inspected commit | Relevant alignment / explicit difference |
|---|---|---|
| Ehagaki | `9962b4a12bda794b4ceaf7304ca02f02c2f47d23` | Shared setup/model, isolate owners. Its older deferred DDL is not adopted as production guidance. |
| mimoc_news | `24eb3e140f9e669ec62c842b4074d5ee63e548d4` | Explicit provider/storage state and development-only migration opt-in; examples likewise distinguish development convenience. |
| mobus-backend | `5ea286700c10cd5d8391add5dedcd14cb61ee8ec` | Entrypoint DB/files/realtime owners, per-message arenas, explicit platform gateway, versioned migrations. |

These are source comparisons, not live application certification. No external
repository was modified and no credentials or deployment configuration values
were inspected.
