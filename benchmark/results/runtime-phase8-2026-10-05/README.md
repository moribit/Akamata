# Phase 8 certification evidence — 2026-10-05

Threaded remains default; public Reactor is **Not Ready**. Functional isolation now passes, but lightweight HTTP still has a substantial throughput deficit. See the [final decision](../../../docs/en/native-reactor-phases6-9.md). Preserve failed trials as evidence, not as successful certification.

## Provenance

| Evidence | Source / scope |
|---|---|
| `ci-linux/`, `ci-macos/` | `6ec6724`, [first certification](https://github.com/moribit/Akamata/actions/runs/37292754729), both adapters, 20 minutes each |
| `ci-*-after-deadline-fix/` | `26017bd`, [second certification](https://github.com/moribit/Akamata/actions/runs/37307456569), fixes partial frame budget during producer work |
| `ci-sanitizer-*/` | Initial cold-cache option failure at `d9ac5cc`; preserved setup diagnostics |
| `ci-sanitizer-*-after-fix/` | `26017bd`, TSan found signal-handler errno corruption; not a passing run |
| `ci-sanitizer-*-final/` | `40ed7e4`, [passing TSan](https://github.com/moribit/Akamata/actions/runs/37308578211), Linux and macOS, no suppressions |
| `macos-kqueue-after-deadline-fix.json` | `26017bd`, completed local 1200-second mixed soak, all sessions reclaimed |
| `macos-final-session-validation.json` | `40ed7e4` binary, five-second collector validation; not a long soak |
| `macos-kqueue-certification.json` | Earlier local 5,000-idle test passed; its mixed soak was interrupted by host sleep, overall `passed=false` |
| `host-suspend.json` | Relevant host sleep/wake transitions; 66-second sleep exceeded the fixture's 60-second read deadline |
| `macos-mixed-5000.json` | 5,000 idle plus rotating active WebSocket, HTTP/DB and slow streams; **30 seconds**, not long certification |
| `frame-budget-before.log` | Failing Threaded/kqueue partial-frame regression before `26017bd`; after-fix Contract passes |

Every matrix records binary SHA-256, platform, exact oha invocation, allocator/resource samples and latency percentiles. Session files record binary hash, source SHA, dirty status and command. CI artifacts additionally contain environment and checked-out source SHA. A dirty status may include fixture or documentation changes; identify the recorded binary, not an implied pristine build. The final runtime change `40ed7e4` preserves errno in the signal handler; HTTP/queue/performance paths are unchanged from `26017bd`.

`summary.json` is derived by `python3 benchmark/results/runtime-phase8-2026-10-05/summarize.py`. Paired entries are arithmetic means of two alternating three-second runs; they are not confidence intervals. Both keep-alive and paced short-lived modes, 4/32/128/256 connections and hello/echo/db are retained. The paced short-lived workload must not be interpreted as peak connection churn.

## Resource interpretation

Historical macOS **session collector** `threads` includes one `ps -M` header line: subtract one (reported 6 means 5 actual threads: loop plus four workers). Original JSON is unchanged. The final collector records `thread_count_method=ps-M-minus-header`. Matrix thread counts and Linux `/proc/.../task` counts need no correction.

The local 5,000-idle kqueue trial used 474,336 KiB RSS, 425,792,676 framework live bytes, 5,007 fds and five actual threads. Establishment was 554 ms, broadcast 56.7 ms and shutdown 231 ms. This is a ReleaseSafe/debug-allocator fixture, not a production memory floor; per-connection input/session/mailbox capacity is substantial. 10,000 was not certified. Scaling memory and process fd budgets need explicit capacity planning.

Final allocator live bytes are zero, created equals closed, debug allocator cleanup passes and processes exit successfully for passing scenarios. During traffic, a final sample may include in-flight sockets/arenas; inspect created-minus-closed and resource ranges rather than treating one nonbaseline sample as a leak. Counters exclude libc/SQLite allocations and thread stacks. RSS includes allocator/OS retention; warm-up growth alone does not prove a leak. No known leak was observed within these trials, which do not prove indefinite leak/race absence.

The soak mixes 100 idle plus 16 rotating active WebSockets, 32 HTTP clients including DB, broadcasts/heartbeats/reconnects and four slow-reader streams held during each HTTP probe. It is not four uninterrupted 20-minute stream producers. Stronger continuous stream isolation is covered by the Contract and application isolation suite. Queue sizes are fixed by construction; this runner does not measure queue high-water marks.

Sampling on macOS is all-thread wall-stack sampling, **not CPU percentages**. Linux `perf` was denied by runner `perf_event_paranoid=4`; the failure is retained. No security settings were relaxed. Do not claim a Linux CPU cost breakdown from those samples.

## Reproduction

```sh
zig version # 0.17.0
zig build transport-contract-test runtime-contract-unit runtime-isolation-test runtime-stress-test runtime-session-test -Doptimize=ReleaseSafe
zig build -Dexample=bench -Doptimize=ReleaseFast
zig build runtime-reactor-bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_matrix.py threaded=zig-out/bin/bench reactor=zig-out/bin/runtime-reactor-bench --output matrix.json --connections 4 32 128 256 --rounds 2 --duration 3s --stats --idle 100 1000 --modes keep_alive short_lived
python3 tools/bench/runtime_profile.py threaded=zig-out/bin/bench reactor=zig-out/bin/runtime-reactor-bench --output-dir profile --endpoint hello --connections 32 128
zig build runtime-certify-fixture -Doptimize=ReleaseSafe
python3 tools/bench/runtime_certify.py zig-out/bin/runtime-contract-server --output sessions.json --idle-levels 100 1000 --mixed-idle 100 --soak-seconds 1200
python3 tools/bench/runtime_certify.py zig-out/bin/runtime-contract-server --output scale-5000.json --adapters kqueue --idle-levels 100 1000 5000 --mixed-idle 5000 --soak-seconds 30
zig build transport-contract-test runtime-isolation-test runtime-session-test -Druntime-tsan=true -Doptimize=ReleaseSafe
```

Replace kqueue with epoll on Linux. Keep the host awake during deadline/soak comparisons; do not disable runtime deadlines to hide a host suspension. macOS `mach_absolute_time`, used by Python's monotonic clock, excludes sleep ([Apple documentation](https://developer.apple.com/documentation/kernel/1462446-mach_absolute_time?language=objc)); runtime `CLOCK_MONOTONIC` includes it according to the installed macOS man page. The interrupted trial is consistent with the recorded sleep exceeding its idle budget, not evidence of a completed soak.

Long and instrumented runs are separate workflows (`runtime-certification.yml`, `runtime-sanitizer.yml`); normal Linux/macOS CI includes the shared Contract, isolation, quick stress and session races. `ci-validation.json` records the final tested runtime SHA and job conclusions.
