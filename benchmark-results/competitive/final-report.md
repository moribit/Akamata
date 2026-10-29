# Competitive initiative: completed matrix and decision

**All 1,890 Native cases are complete:** 1,260 baseline + 630 after, with all five
rounds, no missing/duplicate completed cases, failed measurement cases, forced
runner kills or non-200 responses. Client failures remain separately reported.
Nine prior zap large-echo cases are preserved as excluded raw evidence and were
replaced under the documented cleanup protocol, independent of performance.

**Reactor Not Ready.** Threaded remains the production default; public Reactor
remains fail-closed. Four loops offer a useful concurrency/resource tradeoff,
but fail the low-concurrency throughput gate and expose a large-response P99
blocker. No tag or GitHub Release is created.

## Evidence and conditions

- [All baseline/competitor results](framework-comparison.md).
- [All final runtime results](runtime-after-table.md).
- [Every before/after comparison](matrix-comparison.md) and [metrics JSON](matrix-comparison.json).
- [Decision tables and round spread](decision-evidence.md).
- [Completeness, errors, exit codes and raw-data digests](raw/matrix-validation.json).
- [Raw baseline](raw/native-baseline.json), [raw after](raw/native-after.json),
  [baseline manifest](raw/baseline-manifest.json), [after manifest](raw/after-manifest.json).
- [Methodology](methodology.md), [environment/toolchains](raw/environment.json),
  [generator calibration](generator-calibration.md), [architecture snapshot](architecture-baseline.md).

Apple M2, macOS 27.0 (26A428), Zig 0.17.0, Akamata ReleaseFast/SMP, HTTP/1.1
loopback, oha 1.15.0. Connections: 1/8/32/128/512/1024. Seven workloads: plaintext,
JSON, parameter routing, eight-handle SQLite pool query, echo 64 B/1 KiB/64 KiB.
Each case uses 10 s warmup + 30 s load, five rounds. SQLite 3.53.1 source,
SQL/data/pool settings and wire bodies/Content-Type match across implementations.
Automatic headers and runtime designs differ and are retained in wire evidence.
Pinned zap v0.11.0 uses its upstream-compatible Zig 0.15.2 toolchain/SDK.

Baseline fixture source: `023b101d6c3b3b22b2e5bed489c3e398cefa3098`, against initial
main `8a521fb16e2a6dbffb92627b73350cdb8c551925`. Final executable source:
`c13650d2bf6c6330cb6f33114b16ddce533c7ad0`; SHA-256
`c165114733bcdbdbfb5eca59aba4a74fed9913d56f63d600f1770c2311f6d909`.
Raw artifacts retain each binary/source identity, command and harness revision.
Both stages exited 0; [supervisor completion](raw/matrix-supervisor-complete.json)
is 2026-10-16 06:41:24 UTC. Resumptions/pauses mean this was not a continuous,
isolated-host performance certification.

```sh
# Requires unchanged frozen binaries; no concurrent builds or load.
python3 benchmark/competitive/scripts/run_initiative.py --launch --after-manifest benchmark-results/competitive/raw/after-manifest.json
# Offline regeneration, without rerunning load:
python3 benchmark/competitive/scripts/compare_matrix.py benchmark-results/competitive/raw/native-baseline.json benchmark-results/competitive/raw/native-after.json --output benchmark-results/competitive/matrix-comparison.md
python3 benchmark/competitive/scripts/report_matrix.py
```

## Observed Threaded before/after

32 connections, medians of all rounds. Rates count completed HTTP 200 responses.
P99 is median of round percentiles for completed requests, not pooled latency or
a timeout-inclusive SLO. CPU means one core = 100%; RSS is sampled mean per round,
then median across rounds. Full tables retain every error and connection level.

| Workload | Before req/s | After req/s | Observed change | Before P99 ms | After P99 ms |
|---|---:|---:|---:|---:|---:|
| Plaintext | 89,479 | 142,245 | +59.0% | 0.569 | 0.863 |
| JSON | 136,871 | 154,732 | +13.0% | 1.045 | 0.878 |
| DB pool query | 85,302 | 125,333 | +46.9% | 1.776 | 1.734 |
| Echo 1 KiB | 120,336 | 129,342 | +7.5% | 1.468 | 1.057 |

**Observed cohort differences are not causal optimization estimates.** Runs were
collected at different times on a shared fanless workstation. Plaintext c32 CPU
rises 206.3% → 340.9%, with worse P99 despite higher throughput. CPU/request from
the ratio of medians is about 23.1 → 24.0 us, not an efficiency win. Baseline
plaintext rounds range 85,419–105,402 req/s; final rounds 93,206–154,506. Final
four-loop rounds span 36,619–130,245. Exact thermal/background/scheduling
contributions are unknown. Active-traffic non-regression is not established.

Compare competitors within the baseline cohort, not final Akamata against older
competitor runs. Baseline c32 Threaded plaintext is about 5.3% below Axum and
3.1% above Actix; DB is materially below both. The evidence does not establish
universal competitive leadership or unlimited generator headroom.

## Multiplexed decision

Four loops divide **eight total workers**. Shared HTTP Session/Cursor, bounded
output, global admission, deadlines, drain and incremental session ownership
remain. No unconditional event-loop handlers or Group scheduler are introduced.

| Final cohort case | Threaded req/s | Four-loop req/s | Threaded P99 ms | Four-loop P99 ms |
|---|---:|---:|---:|---:|
| Plaintext / 32 | 142,245 | 96,831 | 0.863 | 0.881 |
| Plaintext / 1,024 | 137,681 | 152,274 | 39.249 | 19.127 |
| Echo 1 KiB / 1,024 | 125,718 | 126,795 | 43.403 | 22.627 |
| Echo 64 KiB / 512 | 29,114 | 14,017 | 25.095 | 366.327 |
| Echo 64 KiB / 1,024 | 24,861 | 8,802 | 459.215 | 1,013.514 |

At c32, plaintext is 31.9% slower, failing the allowed 5% deficit. At c1024,
plaintext gains 10.6% throughput, roughly halves P99, and uses 31.7 versus
131.9 MiB RSS / 12 versus 1,032 threads. These advantages do not cancel the
large-echo deficit: throughput −51.9% / −64.6% at c512/c1024, with severe P99.
Equivalent Linux performance is unmeasured. Production promotion is rejected.

## Improvements, rejected experiments and attribution

- [Quiet-connection notification](idle-shutdown.md): separate 1024-idle, 10 s ×
  three-round medians: CPU 37.63% → 1.70%, RSS 121,936 → 121,984 KiB, threads
  unchanged at 1,032, shutdown 125.42 → 126.20 ms. This is an idle-CPU benefit,
  not a fix for thread-per-connection memory or a macro throughput claim.
- [JSON numeric Writer](routing-json.md): five-round integer-array micro time
  3,440 → 2,195 ns (~36% lower), plus wide integer/finite-float boundary fixes.
  No matching percentage HTTP improvement is inferred.
- Shared pipe polling on every hot read: rejected for severe regression.
- Zero-deadline lock skipping: reverted for small/inconsistent benefit and P99.
- [Vectored output](http-optimization.md): five-round 10/30 s subset improves
  large echo ~13.5% but worsens plaintext P99 ~21%; implementation reverted,
  partial-write test retained. Original production writer remains.
- No speculative SIMD/trie/lock-free scheduler/Group/unsafe preemption was added.

[Attribution](runtime-attribution.md) distinguishes inclusive wall waits from CPU
time. Empty→nonempty batching already amortizes wakeups (~0.04 writes/request in
the c32 diagnostic). Handoff/completion are fixed-cost candidates, but an exclusive
percentage explaining the full gap is **unknown**. Exact macOS process-wide
syscalls/context switches are unknown; readVec operations are not recv counts.

## Errors, lifecycle and verification

Across all workloads/connection levels, baseline client errors total: Threaded
6,824; legacy Reactor 1,574; Actix 56; Axum 15; Go 24; pinned zap 533,687. Final
Threaded totals 9,119, single loop 4,018 and four loops 1,204. Use per-case error
rates rather than treating these mixed-workload totals as rankings. Exact root
causes of connection/reset/cancel failures remain unresolved. Completion is not
an error-free-operation claim. Go exits on the runner's SIGINT (-2), not a forced
kill or proof of graceful drain. All runtimes stayed within the runner bound.

[Zap spill-file investigation](zap-tempfile-cleanup.md) identified 781,641 files /
47.7 GiB in `/var/tmp`. Verified payloads are now reclaimed only after server
exit; actual file I/O remains measured and the pinned binary is unchanged.
Nine earlier cases are retained with exclusion reasons and replaced.

Accepted core validation: 136 Transport checks, 12 isolation scenarios, 24
stress/fault scenarios and three-adapter session/race validation passed. Saved
Native ReleaseSafe full suite: 178 passed / one skipped / zero failed. Normal
CI for frozen c13650d passed all 23 jobs; accepted unchanged production code
passed Linux/macOS TSan at 13ac084. Harness c4f3dc1 also passed all 23 normal CI
jobs, including Native/Workers/Container, examples, generated clients, docs and
scaffold/update/sync. [Revision-scoped CI evidence](raw/ci-matrix-completion.json)
preserves the runs; documentation changes do not certify new runtime code.

Completion reporting was rerun offline: nine reporting/cleanup tests passed,
37 developer documents passed the existing link check, all competitive-report
relative links resolved, and both full case sets validated again. No new load
test or benchmark number was substituted during this finalization.

[Workers WASM/Hono host contract](workers-comparison.md): seven response/D1
simulation checks pass. Dedicated live resources were not established; live
Cloudflare CPU/edge/cold-start superiority is untested. Framework allocator
counters do not include all SQLite/libc/kernel/stack allocations.

## Next work

1. Paired/interleaved Threaded confirmation with host/generator headroom and
   focused P99/error diagnostics; do not attribute the observed +59% to the patch.
2. Isolate the four-loop large-output tail, queue/readiness fairness and error paths.
3. Equivalent Linux performance before reconsidering any runtime gate.

Resource/latency advantages justify narrow research, not production migration
or a more complicated scheduler. [Historical progress notes](investigation-history.md)
retain the intermediate failures and decisions.
