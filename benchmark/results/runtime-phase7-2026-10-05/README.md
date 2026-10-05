# Phase 7: evidence-driven wakeup batching

Phase 6 isolation and cross-platform Contract were passed before these measurements. macOS 27 / Apple M2 / Zig 0.17.0 / oha 1.15.0. ReleaseFast binaries; raw JSON contains binary SHA, complete oha output, CPU/RSS/threads/fd/shutdown and framework allocator counters. Two paired rounds alternate adapter order; 3-second samples are local measurements, not universal performance claims. Threaded remained unchanged between trials.

The all-thread wall sampling shows worker handoff mutex/condition operations, wake pipe write/read, selector calls, socket recv/send and parser/dispatch work. For Reactor c32 before: leaf samples include condition wait 10,471 (sleeping), kevent 725 (includes waiting), mutex wait 432, recv 208, send 145, condition signal 101, wake write 79, wake read 27. These are NOT CPU percentages. Inlining and the five-sample reporting threshold prevent reliable separate parser/dispatch/serialization/allocation percentages. No lock-free queue or implicit event-loop handler fast-path is justified by this evidence.

The only optimization wakes on notification FIFO empty-to-nonempty transition. Duplicate and already-pending notifications need no additional pipe write. A nonempty queue after the 128-token fairness quantum forces a zero-time selector poll; this preserves readiness fairness without losing the batch remainder. After batching, c32 wake-write leaf samples fell from 79 to 39; c128 to five (sampling threshold applies). This is corroborating wall-sample evidence, not a syscall-rate or CPU-percentage claim.

No timer-delay batching or extra buffer/task allocation was added. Unit tests cover generation replacement, overflow, deduplication and a 256-token batch across fairness quanta; 96 Contract cases and the isolation gate pass.

| Connections | Endpoint | Reactor change | Threaded req/s | Reactor req/s | Reactor P99 ms |
|---:|---|---:|---:|---:|---:|
| 4 | hello | +0.3% | 79964 | 57402 | 0.136 |
| 4 | echo | +0.8% | 79417 | 56723 | 0.139 |
| 4 | db/1 | +0.4% | 64234 | 49501 | 0.160 |
| 32 | hello | -0.4% | 165128 | 92938 | 0.727 |
| 32 | echo | +6.7% | 163324 | 91125 | 0.686 |
| 32 | db/1 | +4.5% | 86299 | 72028 | 0.952 |
| 128 | hello | +5.5% | 179214 | 92193 | 2.705 |
| 128 | echo | +9.2% | 177787 | 91120 | 2.579 |
| 128 | db/1 | -1.1% | 74668 | 72470 | 3.728 |
| 256 | hello | +2.8% | 179759 | 94329 | 4.779 |
| 256 | echo | +3.1% | 177617 | 92767 | 5.421 |
| 256 | db/1 | +1.1% | 58765 | 71711 | 7.250 |

Decision: retain this small change for the measured echo improvements at 32/128 connections (+6.7%/+9.2%) and reduced redundant wake work. Some workloads remain within noise or slightly regress (c32 hello −0.4%, c128 DB −1.1%); P99 changes are recorded rather than hidden. This does not solve the large lightweight HTTP gap. The production gate remains closed. Fixed workers bound thread count but add handoff/selector overhead; finite callbacks may block only workers, never the event loop.

Reproduce:
```sh
zig build -Dexample=bench -Doptimize=ReleaseFast
zig build runtime-reactor-bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_matrix.py threaded=zig-out/bin/bench reactor=zig-out/bin/runtime-reactor-bench --output matrix.json --connections 4 32 128 256 --rounds 2 --duration 3s --stats --modes keep_alive --skip-idle
python3 tools/bench/runtime_profile.py threaded=zig-out/bin/bench reactor=zig-out/bin/runtime-reactor-bench --output-dir profile --endpoint hello --connections 4 32 128 256
```

Linux profiling uses perf when installed/permitted; unavailable tooling is explicitly recorded. Cross-platform performance and long session workloads are Phase 8 evidence, separate from this local optimization decision.
