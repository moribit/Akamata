# Phase 5 runtime evaluation — 2026-10-05

Decision: **Reactor Not Ready**. Threaded remains default; App and both direct
Reactor serve entrypoints retain ExperimentalRuntimeDisabled. This completes
evaluation, not certification of all production conditions.

## Method and raw artifacts

Apple M2, macOS 27.0 arm64, installed Zig 0.17.0, oha 1.15.0. ReleaseFast,
eight Threaded acceptors versus one Reactor event loop/eight bounded workers,
same three application handlers and shared SQLite DB. matrix.json has 3 paired
3-second keep-alive rounds at 4/32/128 connections plus 64/256 idle cases.
short-lived.json has 2 paired 2-second rounds at the same connection settings,
paced at 500 requests/s to avoid exhausting local source ports; it measures
latency/resources at that load, **not short-lived throughput ceiling**.
Server order alternates. app.gpa counters are enabled in those matrices and
exclude libc, SQLite and OS stacks. Every final tracked live count is zero.
Sampling and compilation were separate from the saturated keep-alive matrix.

threaded-after.json is a separate uninstrumented 3×5-second/32-connection
regression check, matching the Phase 2 baseline protocol. Raw oha JSON, command,
binary SHA, CPU/RSS/fd/thread samples and shutdown timings are retained. CPU
is process CPU time/wall time (100% = one core). ps time has coarse resolution;
short fixture exchanges and idle CPU are qualitative, not precise CPU profiles.
P50/P95/P99 below are medians of per-run percentiles, not pooled percentiles.
FD counts in the saturated matrix are sampled after the client exits and show cleanup; idle FD counts are sampled while connections remain open. Only macOS has local performance data; Linux CI certifies tests, not these rates.

## Saturated keep-alive comparison

| Connections | Endpoint | Runtime | req/s | P50 µs | P95 µs | P99 µs | RSS MiB | CPU % | Threads | FDs at end |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 4 | hello | threaded | 82840 | 42.5 | 75.9 | 113.8 | 3.63 | 77 | 12 | 4 |
| 4 | hello | reactor | 56796 | 65.7 | 102.2 | 137.6 | 3.50 | 103 | 9 | 7 |
| 4 | echo | threaded | 80822 | 43.5 | 77.8 | 114.2 | 3.65 | 80 | 12 | 4 |
| 4 | echo | reactor | 55568 | 67.0 | 104.2 | 139.8 | 3.52 | 104 | 9 | 7 |
| 4 | db/1 | threaded | 63968 | 55.8 | 98.5 | 141.2 | 3.71 | 118 | 12 | 4 |
| 4 | db/1 | reactor | 48991 | 75.8 | 122.4 | 161.0 | 3.60 | 130 | 9 | 7 |
| 32 | hello | threaded | 164277 | 165.8 | 354.4 | 706.4 | 5.67 | 228 | 40 | 4 |
| 32 | hello | reactor | 89794 | 333.3 | 509.1 | 694.0 | 5.17 | 185 | 9 | 7 |
| 32 | echo | threaded | 163586 | 159.5 | 379.0 | 826.6 | 5.70 | 229 | 40 | 4 |
| 32 | echo | reactor | 86869 | 340.8 | 533.8 | 683.2 | 5.03 | 179 | 9 | 7 |
| 32 | db/1 | threaded | 85364 | 231.2 | 914.3 | 2543.4 | 6.19 | 431 | 40 | 4 |
| 32 | db/1 | reactor | 72370 | 427.0 | 663.0 | 872.0 | 5.14 | 285 | 9 | 7 |
| 128 | hello | threaded | 179718 | 593.0 | 1340.2 | 3870.5 | 11.95 | 256 | 136 | 4 |
| 128 | hello | reactor | 89787 | 1352.8 | 1839.3 | 2325.3 | 10.88 | 184 | 9 | 7 |
| 128 | echo | threaded | 179278 | 515.8 | 1414.2 | 4608.6 | 12.03 | 253 | 136 | 4 |
| 128 | echo | reactor | 88439 | 1372.3 | 1881.2 | 2382.9 | 10.25 | 179 | 9 | 7 |
| 128 | db/1 | threaded | 73735 | 532.3 | 5132.7 | 23533.8 | 13.47 | 494 | 136 | 4 |
| 128 | db/1 | reactor | 70155 | 1801.3 | 2433.4 | 3355.7 | 11.01 | 287 | 9 | 7 |

At 32 connections Reactor hello/echo throughput is approximately 45%/47% lower;
DB is 15% lower. At 128 connections hello/echo are about 50% lower; DB is only
5% lower, with lower CPU and bounded worker contention. These differences are
too large to attribute to measurement noise. Do not enable production on this
evidence, and do not weaken deadlines to improve the numbers.

## Idle resource comparison

| Idle clients | Runtime | RSS MiB | Threads | FDs at end | Shutdown ms |
|---:|---|---:|---:|---:|---:|
| 64 | threaded | 7.92 | 72 | 68 | 127.5 |
| 64 | reactor | 7.34 | 9 | 71 | 3.9 |
| 256 | threaded | 22.00 | 264 | 260 | 130.1 |
| 256 | reactor | 19.73 | 9 | 263 | 3.8 |

Reactor's fixed eight workers plus event loop use nine threads. Threaded uses
one thread per live client plus acceptors. At 256 idle connections Reactor RSS
falls roughly 10%; allocation peak is higher because its connection/input/output
storage is heap-owned while Threaded's transport storage is on worker stacks.
Do not infer total allocation savings from app.gpa alone. Three additional FDs
are the selector and wakeup pipe. These return on runtime teardown.

## Threaded regression check against 946f021

| Endpoint | Before req/s | After req/s | Change | Before/after P50 µs | Before/after P99 µs | Before/after RSS MiB |
|---|---:|---:|---:|---|---|---|
| hello | 165782 | 164877 | -0.5% | 167.7 / 162.6 | 678.5 / 738.8 | 6.36 / 6.33 |
| echo | 165054 | 164431 | -0.4% | 159.5 / 160.1 | 810.9 / 802.6 | 6.38 / 6.38 |
| db | 84436 | 88771 | +5.1% | 235.2 / 221.2 | 2755.8 / 2702.6 | 6.53 / 6.62 |

No major broad Threaded regression. Hello P99 is about 9% higher and is retained
as a tail variation, not erased by the throughput result. Echo and DB P99 fall.

## Stress, faults and ownership

stress.json is a tracked ReleaseSafe fixture with two acceptors/four Reactor
workers, separate from the ReleaseFast throughput matrix. Both runtimes pass:
64/256 idle clients, 1,024 connections in 64-wide burst/churn waves, three-request
pipelines and abortive resets, 32 partial-header slowloris clients, fragmented
512KiB request/response, chunked/fixed streams, stream/fixed-length error paths,
upgrade frames, four 16MiB slow-reader streams, repeated signals and forced drain.
FD counts return to baseline after churn/reset/body/stream/upgrade waves; final
tracked live bytes are zero and DebugAllocator deinit asserts no leak. This is
bounded-run evidence, not proof of no leaks under every possible workload.

| Runtime | Stream req/s | Stream P50/P95/P99 ms | Upgrade req/s | Upgrade P50/P95/P99 ms |
|---|---:|---|---:|---|
| threaded | 10809 | 0.324 / 0.455 / 1.490 | 11217 | 0.306 / 0.412 / 1.735 |
| kqueue | 9917 | 0.333 / 0.660 / 1.399 | 10443 | 0.331 / 0.584 / 1.127 |

These are 200 complete short-lived exchanges at concurrency four, including
client connect, stream framing or WebSocket handshake plus a frame and close.
They are short smoke measurements; Python client overhead is material. They do
not describe high-throughput sustained streaming or long-lived WebSocket traffic.
Raw CPU, RSS, allocation and shutdown observations are in stress.json.

Under child-only RLIMIT_NOFILE=64, both runtimes hit verified EMFILE, remain
responsive to shutdown, recover after held clients close and return to baseline
FD counts. Sampled exhausted CPU is near zero (coarse process-time resolution).
Unit faults exercise every setup/input-growth/parser allocation failure, verify
setup FD rollback, constrained socketpair partial sends and EAGAIN, broken-peer
EPIPE, preserved bytes, failed producer writes, stale generations, bounded wakeup
overflow and 10,000 indexed timer updates against a reference. Common Contract
adds disconnect/ECONNRESET, read/write/total timeouts, handler/stream errors and
shutdown during partial input, idle, writing, streaming and upgraded states.
There is no unsafe thread preemption or claim of arbitrary task-stack recovery.

## Production blocker reproduced

Four /upgrade-wait handlers occupy four workers. Threaded answers an unrelated
HTTP request within the 250ms probe; Reactor does not. Forced drain still reclaims
all four upgrades and the queued request. Slow synchronous stream producers can
similarly occupy workers. HTTP sockets are truly multiplexed, but synchronous
application upgrade/stream execution is not independently suspendable.
This test records the expected gap and keeps the public gate disabled; it is
not presented as passing production isolation parity.

## Profile and decision

The hello profiles in *.sample.txt.gz are separate untracked 5-second, 1ms
samples during a 10-second/32-connection load. Reactor stacks show worker
condition signals/waits, shared queue mutex contention, pipe wakeups and selector
changes around the event-loop/worker handoff. Threaded instead reads/writes
directly. Wait sample counts are wall-time observations, not CPU attribution.
They identify handoff/syscall costs worth profiling further, but do not isolate
one causal percentage. No speculative lock-free rewrite was applied.

Gate decision: **Not Ready**, based on reproduced worker starvation and major
hello/echo throughput regression. OS Contract parity, bounded output/deadlines
and bounded local fault cleanup are necessary evidence, not sufficient evidence.
Linux performance/resource measurements, longer soak runs, broader allocator/OS
fault coverage and race/sanitizer analysis remain before a future certification.

Next design work: give long-lived stream/upgrade execution an explicit bounded
admission/ownership model that preserves normal HTTP isolation, or add incremental
frame/producer tasks with a portable cooperative API. std.Io.Group on the current
Threaded task backend does not remove the synchronous worker occupancy shown in
Phase 3. Profile batching/wakeup/selector costs before changing the transport.
Retain shared HTTP semantics and rerun the complete OS matrix after any redesign.

## Reproduction

```sh
zig build -Dexample=bench -Doptimize=ReleaseFast
zig build runtime-reactor-bench runtime-group-bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_matrix.py threaded=zig-out/bin/bench reactor=zig-out/bin/runtime-reactor-bench --output /tmp/runtime-matrix.json --connections 4 32 128 --rounds 3 --duration 3s --modes keep_alive --stats
python3 tools/bench/runtime_matrix.py threaded=zig-out/bin/bench reactor=zig-out/bin/runtime-reactor-bench --output /tmp/runtime-short.json --connections 4 32 128 --rounds 2 --duration 2s --modes short_lived --skip-idle --stats
python3 tools/bench/runtime_compare.py zig-out/bin/bench /tmp/threaded-after.json --rounds 3 --duration 5s
python3 tools/bench/runtime_profile.py threaded=zig-out/bin/bench reactor=zig-out/bin/runtime-reactor-bench --endpoint hello --output-dir /tmp/runtime-profile
zig build transport-contract-test runtime-contract-unit runtime-poc-test -Doptimize=ReleaseSafe
zig build runtime-stress-test -Doptimize=ReleaseSafe
zig build runtime-stress-full -Doptimize=ReleaseSafe
```

The stress commands write .zig-cache/runtime-stress*.json. Long local stress is
separate from normal CI; the quick matrix runs on both macOS and Linux in CI.
All runners own only their children. localhost port 8080 must be free for the
benchmark matrix; the stress/Contract fixtures use OS-selected free ports.
Baseline binaries must be rebuilt from 946f021 to reproduce before results.
The recorded SHA identifies the preserved original baseline binary.
