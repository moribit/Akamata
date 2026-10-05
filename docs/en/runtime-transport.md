# Native HTTP runtime and Transport Contract (Zig 0.17)

Threaded remains the production default. Public Reactor entrypoints fail closed before opening sockets. See [application execution](reactor-application-execution.md), [Phase 7 evidence](../../benchmark/results/runtime-phase7-2026-10-05/README.md) and historical [Phases 2–5](native-runtime-phases.md).

```text
App → Shared HTTP (session / connection / response cursor)
                   ↓
       Finite application steps / static Transport
                   ├─ Threaded: production
                   └─ Reactor: private multiplexed evaluation
                              ├─ kqueue (macOS/BSD)
                              └─ epoll (Linux)
```

```sh
zig build transport-contract-test runtime-contract-unit runtime-isolation-test runtime-stress-test -Doptimize=ReleaseSafe
zig build runtime-certify-fixture -Doptimize=ReleaseSafe
python3 tools/bench/runtime_certify.py zig-out/bin/runtime-contract-server --output certification.json --idle-levels 100 1000 --mixed-idle 100 --soak-seconds 1200
```

`http/session.zig` owns incremental input/framing, absolute read budgets, limits and pipeline residue. `http/connection.zig` dispatches shared requests and errors. `http/response_cursor.zig` is the single serializer, including HEAD and upgrade framing. WebSocket fragments/control/UTF-8/close validation live in shared `ws/message_state.zig`. Selectors never implement HTTP semantics.

Transport uses static `anytype` dispatch, with no new transport vtable or per-step task allocation. Finite callbacks use a comptime adapter to the existing endpoint-style callback ABI. Threaded retains synchronous APIs; Reactor explicitly rejects synchronous stream/upgrade (default HTTP 501) and requires owned incremental sessions. Idle/readiness/timer/output waits do not own workers. The event loop owns socket I/O; workers perform one finite initializer/producer/message/cleanup step.

There is one queued/running application borrow per connection. Ordinary admission and reserved cleanup FIFOs are bounded. Output is a 16 KiB pending slot, a 4 KiB response cursor quantum or an 8 KiB session emission. EAGAIN retains the offset and waits for readiness. Input/message limits are checked before buffer growth. Cleanup joins senders and worker borrows, delivers closed once, then destroys the arena; only the socket owner closes the fd.

Read budgets are absolute: partial progress never renews HTTP header/body/total input deadlines. Total request timeout does not preempt handlers. WebSocket read budgets apply per frame, including fragmented/control frame progress. `write_timeout_ms` bounds a buffered response/stream from first output, including producer waits; WebSocket budgets apply separately to handshake/each frame. Partial writes never renew them; zero permits no output. Shutdown stops admission, drains within grace, then force-shuts I/O. Arbitrary CPU/foreign blocking callbacks still require cooperative completion; bounded I/O drain does not promise bounded process exit or unsafe preemption.

The same 33 cases run legacy Threaded, incremental Threaded and the host Reactor (99): framing/limits/timeouts, keep-alive/pipeline/read-ahead, disconnect, peer/proxy, stream/upgrade semantics, backpressure/admission and graceful/forced shutdown. Mixed active/idle upgrade plus slow-stream isolation requires unrelated HTTP below 250 ms. Allocation faults, stale tokens and exact session cleanup are separately checked. Long certification runs in manual CI; a passing Contract does not release the production gate.

Zig 0.17.0 installed stdlib remains the reference. libc accept/poll preserve required operation deadlines, shutdown readiness and errno handling; pthread mutex/condition protect synchronous ownership. Signal handlers publish shutdown state; runtime cleanup owns descriptor close. Threaded connection threads and atomic drain remain because the prior Group performance/cancellation evaluation did not justify adoption. Group belongs to task ownership, never protocol semantics. Reactor uses standard OS ABI definitions and an indexed deadline heap.

Private `-Druntime-tsan=true` instruments the Contract fixture on supported targets. Instrumented success constrains observed failures; it does not prove all races absent. Allocation counters exclude SQLite/libc malloc and thread stacks. Native incremental callbacks are experimental; Workers event adapters are currently explicit unsupported.

Current certification and release decision: [Phases 6–9 report](native-reactor-phases6-9.md).
