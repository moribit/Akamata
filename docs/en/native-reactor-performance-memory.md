# Native Reactor CPU and memory investigation — 2026-10-05

Baseline: main at/after `8bbe7d4`. **Stop / Park Reactor development as an experimental research runtime.** Retain its foundations and revisit only with realistic realtime demand and additional profiles. Threaded stays the production default. Public Reactor selection still fails closed with `ExperimentalRuntimeDisabled`.

The [full investigation](../ja/native-reactor-performance-memory.md) contains cost, syscall, benchmark, memory and validation tables. [Raw evidence and reproduction](../../benchmark/results/runtime-investigation-2026-10-05/README.md) retain binary hashes, commands, environments, failed runs and derivation scripts.

## Attribution

Compile-time `-Druntime-cost=true` counts/times read, parsing, task admission, worker acquire/wait/work, dispatch, serialization, completion, selector operations, pipe wakes, sends and Akamata pthread wrappers. It uses wall and thread CPU clocks; production builds disable it. Instrumented throughput is not performance evidence. Spans are inclusive and overlap: do not sum mutex/enqueue/worker/dispatch or infer an exclusive percentage of the throughput gap. Threaded read includes poll wait; Reactor recv excludes selector wait. Queue/completion wait is wall time only.

Linux perf was unavailable (`perf_event_paranoid=4`); settings were not changed. Separate strace summaries cover 10,000 requests, including startup/shutdown. Ptrace changes scheduling and futex counts. macOS sample reports wall stacks, not CPU percentages. Exclusive gap attribution and exact context-switch counts remain unknown.

Lightweight requests perform one enqueue, dispatch, completion and notification. Existing empty-to-nonempty wake batching already reduces wake writes to a fraction of requests. Parsing/dispatch are comparable; additional handoff, synchronization and event-loop work remain. Roughly 15 Akamata mutex acquisitions/request versus 2 for Threaded do not justify an unprofiled lock-free scheduler rewrite.

## Retained changes

1. **Eager bounded nonblocking send:** send the response cursor's 4 KiB quantum before registering writable readiness; at most 16 KiB per turn. EAGAIN preserves pending bytes and waits for readiness. This removes small-response writable registration/round trips. Linux epoll_ctl drops from about 3.017 to 2.007/request, but most lightweight throughput difference remains.
2. **Borrowed finite output:** borrow stable connection/session storage until drained. Only protocol-error synchronous Writer output allocates the bounded 16 KiB fallback. No producer step, buffer reuse or destruction occurs while bytes remain borrowed. Normal-response copying disappears, without claiming it was the CPU bottleneck.
3. **Separate internal Session allocation:** runtime owns/destroys the internal incremental Session outside the request arena; application callback state and escaped HTTP data retain their arena lifetime. This avoids geometric arena slack without changing six idle-fixture allocations/connection.

No queue rewrite, global pool, Group adoption, unconditional event-loop application execution, worker increase or relaxed deadline was introduced. Borrow-only throughput varied around noise and was retained for memory, not speed.

## Memory

ReleaseSafe/DebugAllocator idle WebSocket fixture live memory slope falls from **84,915 B (82.93 KiB) to 38,299 B (37.40 KiB)/connection**, about 55%. At 5,000 connections, local live memory falls from 406.18 to 183.88 MiB; RSS from 463.17 to 351.41 MiB, about 24%. DebugAllocator size classes/retention make the independent Session allocation use more RSS than borrowed-output-only, despite less live memory. These quantities are not interchangeable.

Connection shrinks 21,368→5,024 B, including a 4 KiB writer; Output shrinks 16,592→248 B. HTTP input is eagerly allocated on accept: 518 B under the fixture's small parser limits, versus 24,704 B capacity for the default initial 16 KiB request. The 37.4 KiB fixture budget is not a production-default guarantee. Smaller/lazy input needs a separate Shared HTTP/Threaded churn measurement. Arena capacity shrinks 62,952→15,936 B; the separate Session is 16,768 B (8 KiB application output plus wire storage/metadata). The application's 8 KiB mailbox is inside arena capacity. Do not count Session/mailbox/Output twice. Shared fixed queues/slots/timers cost approximately 80 B per configured capacity slot. Incoming WebSocket message storage already grows lazily within limits.

The 5,000-idle fixture holds five threads and approximately 5,007 fds. HTTP benchmark workers differ (eight workers plus loop). Realtime and mixed-workload evidence remains valuable; general lightweight HTTP still has a substantial Linux throughput deficit.

## Correctness and decision

An initial TSan run exposed a functional upgrade EOF, also reproducible with the baseline runtime. There was no TSan data-race warning or mailbox overflow. Multiple `done` loads within `refresh` could observe completion only in a later ordinary-HTTP branch and close a newly published incremental session. `5815bbc` uses one acquire snapshot per refresh. Local TSan 50 repetitions pass; both OS sanitizer workflows now include that repetition. Failed evidence is retained. Attribution probes also preserve syscall errno (`44eeb29`).

Final Contract, isolation, stress, fault, TSan, session race and resource evidence is listed in the linked report/raw manifest. A short soak is identified by its actual duration and is not claimed as new long-duration certification. No production gate change follows from measurements alone.

Next work should be a low-overhead dedicated-host Linux scheduler/CPU profile, realistic realtime mixed workload, production-allocator RSS/churn and longer post-change soak. Continue only bounded realtime research that can demonstrate application value; do not spend scheduler complexity merely to chase Threaded HTTP req/s.

Both local 30-minute soak attempts were interrupted by host sleep (idle sleep, then lid sleep despite `caffeinate -i`). Their failure data and narrow power-log evidence are preserved; final allocator live bytes were zero, but neither is continuous-soak certification. Both OS CI mixed runs passed for 240 seconds. Longer post-change soak remains unverified. Normal benchmark builds disable CPU probes but retain identical fixture allocator statistics across compared labels.
