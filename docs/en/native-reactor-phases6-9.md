# Native Reactor Phases 6–9: implementation, evidence and release decision

**Reactor Not Ready.** Threaded remains production default. Public `.runtime = .reactor` still returns `error.ExperimentalRuntimeDisabled`. Isolation now passes, but the substantial lightweight HTTP throughput deficit remains a release blocker. Implementation volume does not justify opening the gate.

Baseline: `75fcb26`. Phase 6: `cf2b6c0`; Phase 7: `82a7f73`; subsequent certification fixes: `26017bd` (partial-frame deadline) and `40ed7e4` (signal errno). See [complete Japanese report](../ja/native-reactor-phases6-9.md), [Phase 7 measurements](../../benchmark/results/runtime-phase7-2026-10-05/README.md), [Phase 8 raw data/reproduction/provenance](../../benchmark/results/runtime-phase8-2026-10-05/README.md) and historical [Phases 2–5](native-runtime-phases.md).

## Application execution and isolation

Previously synchronous stream/upgrade handlers waited on I/O while holding worker stacks. Four long-lived upgrades occupied four workers and delayed unrelated HTTP beyond 250 ms. Increasing worker count was not the fix.

```text
App → shared HTTP parser / lifecycle / response cursor
                     ↓
       finite initializer / producer / message / cleanup
                     ↓
       bounded application admission and completions
                     ↓
       event loop-owned sockets / input / output / timers
                     ├─ kqueue
                     └─ epoll
```

Following the user's selected compatibility policy, Reactor explicitly rejects synchronous stream/upgrade (`UnsupportedApplicationExecution`, default HTTP 501). Threaded retains these APIs. Native experimental `Response.streamSession()` and `am.ws.upgradeSession()` use `application_session.Definition.init(State, state, callback, mode)`. A callback handles opened/produce/message/closed and returns one finite step, at most 8 KiB output and input/produce/after/wait/done. No new Transport vtable or per-step task allocation is introduced; endpoint-style callbacks use a comptime adapter. HTTP semantics and serialization remain shared.

The loop owns socket readiness, read-ahead, WebSocket frame assembly, fragments/control/UTF-8/close validation and deadlines. Workers handle complete messages or one producer step. Idle WebSockets and backpressured streams consume no workers. Resumer is borrowed until closed returns; registries must unregister/join senders before returning. State must be arena/application-owned; Context/Conn/handler stack references must not escape. Closed may arrive without opened after setup failure, HEAD or cancellation. It is delivered once before arena destruction.

Streams produce one bounded quantum and park until output drains. Emit final data with another produce step, then return done separately; stream output plus done is rejected. Fixed-length mismatch and producer errors follow shared protocol behavior. Arbitrary synchronous stacks are not suspended. CPU/foreign blocking callbacks must cooperate and remain finite; unsafe preemption is not attempted.

Normal FIFO admission is bounded by `max_pending_application_tasks` (default connection capacity), with one queued/running borrow per connection. Overflow closes new work. A separate capacity-bounded cleanup FIFO cannot be rejected by ordinary saturation. Fixture broadcast mailboxes are bounded and close overflow recipients. Pending output is 16 KiB; response cursor quanta are 4 KiB, session emissions 8 KiB. Session header preludes fit a fixed approximately 8 KiB wire buffer; ordinary buffered response headers/bodies use the cursor. Default message limit is 64 KiB, checked before growth. Partial writes retain offsets; EAGAIN waits for readiness. Frame/notification quanta are 64/128. Mixed idle/active WebSocket plus slow-stream Contract and the former four-worker starvation regression now require HTTP success.

The loop alone closes sockets. Completion release/acquire transfers application borrows; workers do not dereference connections after publishing completion. Generation tokens reject stale events/fd reuse. Close joins existing work, runs closed cleanup, then destroys the arena. Group was not adopted; the previous performance/ownership decision remains valid.

## Deadline and shutdown corrections

HTTP read budgets are absolute header/body/total budgets. WebSocket read budgets apply per frame; partial input does not renew them. Certification exposed producer/broadcast output incorrectly renewing a partial frame budget. `26017bd` preserves it across output/producer work, snapshots it before worker admission and keeps the timer active while workers/output are pending. The shared regression sends a partial frame under a 400 ms budget while broadcasting every 120 ms. Before-fix Threaded/kqueue failures and after-fix success are retained.

Buffered response/stream write budgets start with first output and include producer waits. WebSocket budgets apply to each handshake/frame. Partial writes do not renew them; zero permits no output. Threaded incremental WebSocket output also respects remaining partial-input budget.

Shutdown stops admission, drains within grace, force-shuts I/O at deadline, joins application borrows and cleans up exactly once. Repeated signals do not extend the budget. Bounded I/O drain is not bounded process exit for arbitrary handlers. TSan found signal-handler errno corruption; `40ed7e4` saves/restores `std.c._errno()` and adds a unit regression. Both OS instrumented reruns passed without suppressions.

## Profile and performance decision

macOS all-thread wall-stack sampling observed handoff condition/mutex, event-loop, send/read and wake writes; sleeping stacks are not a CPU percentage breakdown. Linux perf was denied by `perf_event_paranoid=4`; no Linux exclusive CPU profile is claimed. Allocation/dispatch/selector exclusive costs remain incomplete.

Only empty-to-nonempty completion wake batching was retained. Remaining notifications after the 128-item quantum trigger zero-time polling, without an artificial latency timer. Sample wake-write observations at 32 connections fell 79→39; the after sample at 128 had five. Paired before/after echo throughput improved approximately 6.7% at 32 and 9.2% at 128; hello32 was −0.4%, db128 −1.1%. This is workload-specific evidence, not universal improvement. No speculative lock-free queue, selector rewrite or event-loop-safe handler fast path was adopted.

Deadline-fixed cross-platform cohort `26017bd`, keep-alive 32 connections, arithmetic means of two three-second runs. The first cohort remains in raw data; different CI hosts/times prevent interpreting cohort differences as an optimization effect:

| Platform / endpoint | Threaded req/s | Reactor req/s | Delta |
|---|---:|---:|---:|
| Linux hello | 83,297 | 35,109 | −57.9% |
| Linux echo | 81,464 | 34,608 | −57.5% |
| Linux db | 49,628 | 36,153 | −27.2% |
| macOS hello | 56,547 | 40,382 | −28.6% |
| macOS echo | 53,666 | 32,421 | −39.6% |
| macOS db | 36,341 | 30,418 | −16.3% |

Final deadline-fixed cohort results are retained in `summary.json`. The matrix includes 4/32/128/256 connections, keep-alive and paced short-lived, P50/P95/P99, CPU/RSS/threads/allocation/shutdown. Reactor's benchmark uses eight workers plus its loop; session fixtures use four plus loop. Costs attributable to handoff remain a hypothesis until measured exclusively.

Stream/WebSocket performance uses identical incremental callbacks on both adapters. Threaded's new incremental external-wake bridge polls at up to approximately 100 ms; broadcast comparisons include this limitation, not a claim about existing synchronous Threaded WebSocket/Hub performance. Python fixture load is not a peak req/s benchmark.

## Certification and limitations

The same 33 cases run legacy Threaded, incremental Threaded and the host Reactor: 99 per OS. Linux epoll/macOS kqueue passed. Both use standard OS ABI selectors, shared HTTP, level-triggered readiness, indexed timers and identical worker ownership. General BSD certification was not performed.

Final runtime `40ed7e4` normal CI passed all 15 jobs: Native Debug/ReleaseSafe/OpenSSL/integration, Workers, CLI/generated projects and Docker. Quick session testing includes 256 disconnect/partial frame/reset/fd-reuse scenarios and 64 shutdown-close-completion races. A runner signal race was fixed with an application-start barrier and no signal resend after shutdown. Allocation failure, EAGAIN/partial write/EPIPE/reset, accept failure, stale token, overflow, timeout versus producer/completion/shutdown and error cleanup are covered by unit/Contract/stress. Both OS TSan Contract/isolation/session races passed; this does not prove every race absent.

Local kqueue held 5,000 idle sessions with five actual threads, 474,336 KiB RSS, 5,007 fds and 425,792,676 framework live bytes. Establishment/broadcast/shutdown were 554/56.7/231 ms. These are ReleaseSafe/debug-allocator fixture values, not a production memory floor. A 30-second 5,000-idle mixed workload passed; 10,000 was not certified.

Twenty-minute mixed runs combine 100 idle plus 16 rotating active WebSockets, 32 HTTP/DB clients, broadcast/heartbeat/reconnect and four slow streams held during each probe. Initial Linux Threaded/epoll maximum HTTP latency was 7.56/6.37 ms; macOS Threaded/kqueue 17.32/14.47 ms. Deadline-fixed local kqueue completed 1,200 seconds: HTTP max6.77 ms, fds123→123, live11,669,054→11,669,514 bytes, all4,852 sessions closed, final allocator live0.

An earlier local soak was interrupted by a recorded 66-second host sleep exceeding its 60-second read deadline; it remains failed raw evidence, not a completed soak. Historical macOS session thread counts include one ps header line (six means five); originals remain intact and the collector is corrected. Passing trials have created=closed, GPA cleanup, final live0 and exit0. RSS includes OS/allocator retention; in-flight work can affect the last fd/arena sample. Counters exclude libc/SQLite/thread stacks. Queue/task capacity is fixed, but queue high-water marks are not measured. No known leak was observed within these trials; multi-hour/high-concurrency validation remains warranted.

Final CI soak (`26017bd`) HTTP maxima were Linux Threaded/epoll6.72/9.79 ms and macOS Threaded/kqueue22.11/25.48 ms. Both Reactors stayed at five threads and fds123→123, shutting down in approximately164/159 ms. Epoll RSS15,196→15,448 KiB/live11,666,246→11,666,706 bytes; kqueue RSS16,592→17,104 KiB/live11,669,054→11,669,514 bytes. Final live0 and created=closed. Threaded mixed samples had approximately118–121 threads. These are low-rate soak values, not peak throughput.

Hello32 P50/P95/P99: Linux Threaded0.344/0.632/1.084 ms, epoll0.878/1.210/1.531 ms; macOS Threaded0.340/1.305/4.827 ms, kqueue0.634/1.721/2.866 ms. Reactor P99 is not universally worse. Linux hello CPU was approximately154% Threaded versus128% epoll, but lower req/s prevents interpreting this directly as better CPU efficiency.

[Final normal CI](https://github.com/moribit/Akamata/actions/runs/37308545796), [TSan](https://github.com/moribit/Akamata/actions/runs/37308578211) and [long certification](https://github.com/moribit/Akamata/actions/runs/37307456569) all passed. Normal/instrumented validation used errno-fixed `40ed7e4`; long/performance validation used its predecessor `26017bd`, with only signal errno save/restore separating their runtime behavior.

The release blocker is the substantial unexplained lightweight HTTP deficit despite isolation and bounded-thread benefits. Public gate and Threaded default are unchanged. Known limitations: Reactor synchronous APIs unsupported, finite/cooperative callback and Resumer lifetime requirements, session header/output/message bounds, per-connection memory cost, Threaded incremental wake polling, experimental Native session API and explicit unsupported Workers incremental adapter. Existing Workers APIs remain intact.

Next: obtain dedicated Linux/macOS CPU/syscall/queue-wait profiles, measure handoff/selector/serialization/allocation exclusive costs, retain only demonstrated improvements, reduce/observe per-connection budgets, run larger multi-hour mixed soak, and separately evaluate Threaded incremental wake and portable Workers event adapters. Do not weaken Contract semantics or invent lock-free/scheduling complexity without evidence.
