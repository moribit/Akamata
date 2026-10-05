# Phase 5 runtime evaluation — 2026-10-05

Decision: **Reactor Not Ready**. Threaded remains default; App and both direct
Reactor serve entrypoints retain ExperimentalRuntimeDisabled. This completes
evaluation, not certification of all production conditions.

## Method and raw artifacts

Apple M2, macOS 27.0 arm64, installed Zig 0.17.0, oha 1.15.0. ReleaseFast,
eight Threaded acceptors versus one Reactor event loop/eight bounded workers,
same three application handlers and shared SQLite DB. matrix-final.json has 3 paired
3-second keep-alive rounds at 4/32/128 connections plus 64/256 idle cases.
short-lived.json has 2 paired 2-second rounds at the same connection settings,
paced at 500 requests/s to avoid exhausting local source ports; it measures
latency/resources at that load, **not short-lived throughput ceiling**.
matrix.json retains the earlier pre-syscall-deadline-check run. matrix-final.json repeats the full matrix after those checks; each records its binary SHA. short-lived.json and the hello profiles precede that extra deadline check. Server order alternates. app.gpa counters are enabled in those matrices and
exclude libc, SQLite and OS stacks. Every final tracked live count is zero.
Sampling and compilation were separate from the saturated keep-alive matrix.

threaded-after.json is a separate uninstrumented 3×5-second/32-connection
regression check, matching the Phase 2 baseline protocol. Raw oha JSON, command,
binary SHA, CPU/RSS/fd/thread samples and shutdown timings are retained. CPU
is process CPU time/wall time (100% = one core). ps time has coarse resolution;
short fixture exchanges and idle CPU are qualitative, not precise CPU profiles.
P50/P95/P99 below are medians of per-run percentiles, not pooled percentiles.
FD counts in the saturated matrix are sampled after client exit and show cleanup; idle FD counts are sampled while connections remain open. Only macOS has local performance data; Linux CI certifies tests, not these rates.

## Saturated keep-alive comparison

| Connections | Endpoint | Runtime | req/s | P50 µs | P95 µs | P99 µs | RSS MiB | CPU % | Threads | FDs at end |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 4 | hello | threaded | 83303 | 42.4 | 75.8 | 113.3 | 3.61 | 77 | 12 | 4 |
| 4 | hello | reactor | 56492 | 66.0 | 102.6 | 138.5 | 3.55 | 103 | 9 | 7 |
| 4 | echo | threaded | 81005 | 43.5 | 77.1 | 115.4 | 3.63 | 81 | 12 | 4 |
| 4 | echo | reactor | 55779 | 67.1 | 103.8 | 139.5 | 3.55 | 104 | 9 | 7 |
| 4 | db/1 | threaded | 64059 | 55.8 | 98.5 | 140.8 | 3.71 | 116 | 12 | 4 |
| 4 | db/1 | reactor | 48778 | 76.0 | 123.2 | 162.1 | 3.64 | 130 | 9 | 7 |
| 32 | hello | threaded | 164691 | 167.8 | 351.9 | 724.9 | 5.63 | 228 | 40 | 4 |
| 32 | hello | reactor | 89662 | 335.0 | 507.8 | 646.7 | 5.04 | 185 | 9 | 7 |
| 32 | echo | threaded | 164128 | 160.6 | 375.2 | 801.5 | 5.64 | 232 | 40 | 4 |
| 32 | echo | reactor | 87144 | 342.1 | 525.1 | 758.8 | 5.07 | 181 | 9 | 7 |
| 32 | db/1 | threaded | 85032 | 233.8 | 919.4 | 2637.2 | 6.19 | 437 | 40 | 4 |
| 32 | db/1 | reactor | 69081 | 447.7 | 680.5 | 921.5 | 5.19 | 279 | 9 | 7 |
| 128 | hello | threaded | 179031 | 565.7 | 1386.5 | 4007.4 | 11.94 | 257 | 136 | 4 |
| 128 | hello | reactor | 88493 | 1364.0 | 1941.4 | 2539.5 | 10.26 | 180 | 9 | 7 |
| 128 | echo | threaded | 178607 | 518.2 | 1475.0 | 4552.8 | 12.09 | 254 | 136 | 4 |
| 128 | echo | reactor | 87364 | 1378.9 | 1935.4 | 2405.0 | 10.29 | 178 | 9 | 7 |
| 128 | db/1 | threaded | 72946 | 517.3 | 5233.4 | 26241.5 | 13.53 | 505 | 136 | 4 |
| 128 | db/1 | reactor | 70612 | 1751.8 | 2526.3 | 3826.5 | 10.98 | 296 | 9 | 7 |

At 32 connections Reactor hello/echo throughput is approximately 46%/47% lower;
DB is 19% lower. At 128 connections hello/echo are about 50% lower; DB is only
3% lower, with lower CPU and bounded worker contention. These differences are
too large to attribute to measurement noise. Do not enable production on this
evidence, and do not weaken deadlines to improve the numbers.

## Idle resource comparison

| Idle clients | Runtime | RSS MiB | Threads | FDs at end | Shutdown ms |
|---:|---|---:|---:|---:|---:|
| 64 | threaded | 7.92 | 72 | 68 | 128.0 |
| 64 | reactor | 7.38 | 9 | 71 | 3.6 |
| 256 | threaded | 22.00 | 264 | 260 | 129.9 |
| 256 | reactor | 19.75 | 9 | 263 | 3.8 |

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

The final common Contract has 29 cases per adapter, including zero output
budget and concurrent Hub snapshot/disconnect ownership. Snapshot borrows are
joined by Conn.deinit; controlled upgrade recv cannot consume a recycled fd.
An explicit unit reproduces failure of pending output after worker completion
and requires immediate admission reclamation. These are final correctness
fixes; the matrix's success-path HTTP workload does not exercise these branches.

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
| threaded | 9543 | 0.347 / 0.587 / 1.109 | 10090 | 0.335 / 0.513 / 2.118 |
| kqueue | 10114 | 0.332 / 0.603 / 1.061 | 10522 | 0.317 / 0.583 / 1.216 |

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

## Final cross-platform CI

Implementation `ce5ef1f40732c8c8de132b71a847b2aa28e262fa` passed all 15 jobs in [CI run 37270065077](https://github.com/moribit/Akamata/actions/runs/37270065077). Each of Linux Threaded/epoll and macOS Threaded/kqueue passed the same 29-case Contract. The CI jobs also ran ReleaseSafe fault/unit tests, Group Contract and quick stress. Raw stress artifacts are in `ci-linux/` and `ci-macos/`; run provenance is in `ci-validation.json`. The expected worker-isolation failure is recorded as evidence for **Not Ready**, not converted into a weaker production Contract. These final evidence additions change only documentation/data.
