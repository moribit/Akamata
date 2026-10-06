# Native Reactor CPU / memory evidence — 2026-10-05

Read [the Japanese decision report](../../../docs/ja/native-reactor-performance-memory.md) or [English report](../../../docs/en/native-reactor-performance-memory.md). **Stop / Park Reactor development as an experimental research runtime. Threaded remains default; public Reactor remains fail-closed.** Revisit only with real realtime demand and additional profiles.

## Provenance

The starting application/runtime was main `8bbe7d4`. Attribution-only commit `97f04ac53b6a2d998f7af9e26da13a5b19b8a5a7` is the unchanged runtime baseline used for paired comparison. The standalone test module needed its build options import fixed (`9c168c9`); that failure did not invalidate the benchmark modules.

| Commit | Change |
|---|---|
| `97f04ac` | Compile-time disabled-by-default CPU/counter probes, collectors/workflow |
| `0cc0b72` | Bounded eager response send before writable registration |
| `9c168c9` | Standalone test-root build options |
| `f9546e8` | Borrow finite output, lazy protocol-error copy buffer, separate internal Session ownership |
| `5815bbc` | One worker completion snapshot/refresh, failure diagnostics and TSan repeat regression |
| `44eeb29` | Preserve syscall errno in enabled attribution probes |

Every matrix records binary SHA-256, platform, oha version and per-run command. CI directories include source SHA/environment. Source/binary identities differ between local stages; do not infer a stage from its basename alone. Source SHA may identify a working-tree overlay in local memory trials; `working_tree_dirty` and binary hash preserve this distinction. No binaries or sqlite database files are committed here.

| Directory / file | Meaning |
|---|---|
| `ci-linux-before`, `ci-macos-before` | Initial attribution/benchmark/profile at `97f04ac`, CI `37316584513` |
| `macos-targeted.json` | Same-host alternating c32 Threaded/before/eager/borrow comparison, 3 rounds |
| `macos-memory-http-tradeoff.json` | Same-host eager/borrow/separate-Session HTTP tradeoff |
| `macos-memory-before`, `macos-memory-borrow`, `macos-memory-separated` JSON | Local 1000/5000 idle allocation/layout stages; debug allocator |
| `ci-linux-final`, `ci-macos-final` | Paired before/candidate matrix, counters, profile/syscalls, session/stress prerequisites at `f9546e8`, CI `37320200686` |
| `ci-first-candidate` | Normal all-15-job CI artifacts at `f9546e8`, run `37320145339` |
| `tsan-linux-first-candidate`, `tsan-macos-first-candidate` | TSan run `37320202277`; Linux functional upgrade EOF failed, macOS passed |
| `macos-room-*` | Targeted repeated Contract failure diagnostics and fixed-run proof |
| `macos-final-soak.json` | Post-fix ReleaseSafe fixture, 1000/5000 idle + attempted 1800-second mixed kqueue soak; interrupted by lid sleep, failed |
| `macos-soak-interrupted-by-host-sleep.json`, `macos-soak-host-sleep.json` | Failed first long-soak attempt: host Idle Sleep 378 seconds; all 1016 active frame budgets expired on wake; cleanup/live0 succeeded; not a soak pass |
| `threaded-regression-investigation.json` | Native/shared source comparison, disabled-probe symbol checks and limits of macOS before/after inference |
| `ci-linux-postfix`, `ci-macos-postfix` | Final paired/profiling/session matrix at `44eeb29`, run `37324577434` |
| `tsan-postfix` | Post-fix Linux/macOS TSan + 50 upgrade repeats, run `37324583960` |
| `ci-postfix` | Normal post-fix CI at `44eeb29`, run `37324533705` |
| `ci-runs.json` | Final CI outcomes, job status and source SHA |
| `analysis.json`, `analyze.py` | Derived normalized values; raw JSON untouched |
| `report-tables.md`, `report_tables.py` | Reproducible human-readable final tables |

`macos-uninstrumented-before.json` overlapped early builds/Contract; `macos-cost-after.json` and late c128/c256 portions of `macos-final-paired.json` overlapped local TSan diagnosis/builds. Keep them as raw exploratory evidence, **not primary causal comparison**. Final CI matrices compare all labels on the same host, sequentially; hosted-runner contention remains possible.

Room baseline TSan reproduction used runtime source `97f04ac` in an isolated worktree with only fixture `mailbox_overflows` diagnostics added. It failed on the same EOF with zero mailbox overflow and zero final allocator live bytes. Diagnostic candidate runs temporarily logged close origin/stack; those logs were removed before `5815bbc`. One failed local attempt encountered sandbox socket permission and is not runtime evidence. Successful execution is identified by fixture/requests data.

## Measurement limitations

- Instrumented spans use wall and thread CPU clocks, with shared atomic counters. Nested/inclusive spans are **not additive**, and instrumented req/s is not used as optimization evidence.
- "Uninstrumented" means CPU attribution disabled. Matched `BENCH_STATS` allocator counters remain enabled for both runtimes/stages. These fixtures use DebugAllocator; do not silently equate results with another production allocator.
- Queue/completion wait is wall time; Threaded read includes poll; Reactor recv does not include selector wait. Wall stack samples are not CPU percentages.
- Linux perf was denied by `perf_event_paranoid=4`; no security setting was changed. Empty perf files are failure evidence, not valid profiles.
- Linux strace summaries include startup/shutdown and perturb scheduling; futex counts are traced observations, not normal-run context switches. macOS syscall trace and exact context-switch counts remain unknown.
- Framework allocation counters cover `app.gpa` only: SQLite/libc/stacks/kernel memory are excluded. RSS includes allocator size classes and retained pages. A live-memory reduction is not the same RSS reduction.
- Short-lived matrix is deliberately paced at 500 qps to bound descriptor/ephemeral-port churn; it measures latency/resources, not saturation throughput. `ps time` is coarse and may report 0% at this load.
- Before/after hosted matrices are 2 rounds × 3 seconds; performance percentages do not constitute confidence intervals. Exclusive percentage of the CPU gap explained remains **unknown**. `observed_gap_closed_percent` measures throughput intervention effect only.
- Gap-closure percentages with a baseline gap smaller than 5% are omitted as unstable denominators; this is a reporting guard, not a claim of statistical confidence.
- Fixture parser limits and application mailbox cost differ from production defaults. Fixed queue cost depends on configured maximum capacity, not solely active connections.
- CI mixed soak is 240 seconds, not long-duration certification. Both separate macOS 1800-second attempts failed after host sleep; neither completed continuous soak. `macos-soak-interrupted-by-lid-sleep.json` and `macos-soak-lid-sleep.json` preserve the second attempt and narrow sleep evidence. No new 30-minute Linux result is claimed.

## Reproduce

Pinned Zig 0.17.0, SQLite fetched by `third_party/sqlite/fetch.sh`, oha 1.15.0. CI pins oha release asset hashes and uses `.github/workflows/runtime-investigation.yml`. Native task execution does not require Workers/Wrangler.

```sh
rtk proxy zig build -Dexample=bench -Doptimize=ReleaseFast --prefix candidate
rtk proxy zig build runtime-reactor-bench -Doptimize=ReleaseFast --prefix candidate
rtk proxy python3 tools/bench/runtime_matrix.py threaded=candidate/bin/bench reactor=candidate/bin/runtime-reactor-bench --output /tmp/runtime-uninstrumented.json --connections 4 32 128 256 --rounds 2 --duration 3s --stats --skip-idle
rtk proxy zig build -Dexample=bench -Doptimize=ReleaseFast -Druntime-cost=true --prefix measured
rtk proxy zig build runtime-reactor-bench -Doptimize=ReleaseFast -Druntime-cost=true --prefix measured
rtk proxy python3 tools/bench/runtime_matrix.py threaded=measured/bin/bench reactor=measured/bin/runtime-reactor-bench --output /tmp/runtime-cost.json --connections 4 32 128 256 --rounds 1 --duration 2s --stats --skip-idle
rtk proxy python3 tools/bench/runtime_profile.py threaded=candidate/bin/bench reactor=candidate/bin/runtime-reactor-bench --output-dir /tmp/runtime-profile --endpoint hello --connections 32 128
rtk proxy python3 tools/bench/runtime_syscalls.py candidate/bin/runtime-reactor-bench --endpoint hello --output-dir /tmp/runtime-syscalls
rtk proxy zig build transport-contract-test runtime-contract-unit runtime-isolation-test runtime-session-test runtime-stress-test -Doptimize=ReleaseSafe
rtk proxy zig build runtime-certify-fixture -Doptimize=ReleaseSafe
rtk proxy python3 tools/bench/runtime_certify.py zig-out/bin/runtime-contract-server --adapters kqueue --output /tmp/runtime-soak.json --idle-levels 1000 5000 --mixed-idle 1000 --soak-seconds 1800
rtk proxy zig build runtime-certify-fixture -Doptimize=ReleaseSafe -Druntime-tsan=true --prefix tsan
rtk proxy python3 tools/bench/runtime_contract_repeat.py tsan/bin/runtime-contract-server --adapter kqueue --repeats 50 --output /tmp/runtime-upgrade-repeat.json
rtk proxy python3 benchmark/results/runtime-investigation-2026-10-05/analyze.py
rtk proxy python3 benchmark/results/runtime-investigation-2026-10-05/report_tables.py
```

On Linux select `epoll`, not `kqueue`. Exact paired baseline build, syscall endpoint loop and CI commands are preserved in the workflow. The private benchmark/fixture can evaluate Reactor without opening its public production gate. Run only safe resource levels for the host; these runners terminate their own children, not unrelated processes.

On a macOS laptop, wrap the soak command in `rtk proxy caffeinate -i python3 ...` to prevent **idle** sleep only for its process lifetime. It does not prevent lid/manual sleep. The resumed local run uses this wrapper; the inner Python `command` field does not include the wrapper. An expired deadline after an externally suspended host is not a passing continuous soak.
