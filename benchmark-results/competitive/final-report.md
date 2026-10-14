# Competitive initiative: evaluation status

**The requested full measurement matrix is not complete.** This report separates
implemented/verified work from remaining measurement gates. Do not use the
short screens as five 30-second-round competitive certification.

## Source and environment

Initial main `8a521fb`; frozen competitive fixtures `023b101`; verified core and
documentation candidate `13ac0849a0234ddc3a4822a15371059cd6e5ac59`. Apple M2,
macOS 27.0 (26A428), Zig 0.17.0, ReleaseFast measurements, oha 1.15.0.
Pinned compiler/framework versions and SQLite source digest are in
[environment](raw/environment.json), [methodology](methodology.md) and manifests.
No comparison against the historical M2 v0.2.1 fixture's absolute rates is made.

## Implemented and verified

- Pinned Actix/Axum/Go/zap/Akamata fixtures, exact HTTP/1.1 wire conformance,
  identical SQLite source/SQL/data and eight-handle pool setup.
- Checkpointed, serial, resume-validated measurement; successful HTTP rates
  separated from failed attempts; owned generators cleaned on interruption.
- [Threaded idle notification](idle-shutdown.md): hot socket-only probe before
  parking quiet connections. Refined 1024-idle CPU median 37.63% → 1.70%, RSS
  approximately unchanged, shutdown median 125.42 → 126.20 ms.
- [JSON numeric Writer](routing-json.md): integer-array micro time 3440 → 2195 ns
  and valid wide-number panic fixes. Other measured shapes broadly unchanged.
- [Private sharded Reactor](runtime-comparison.md): fixed total worker budget,
  global admission, shared HTTP/Session/Cursor and incremental ownership.
  The research path does not enter production App.serve.
- [Actual Workers WASM/Hono host fixture](workers-comparison.md): seven exact
  response checks with fake D1. No live Cloudflare measurements or superiority.

## Reliability evidence

Local final runtime candidate: 136 Transport tests, 12 application isolation
scenarios and 24 stress/fault scenarios passed, plus three-adapter session/race
validation. Native ReleaseSafe full suite: 178 passed, one skipped, zero failed.
The first full build ran out of disk before affected tests executed; cache
cleanup and successful rerun are recorded separately.

For core SHA `13ac084`, [normal CI](https://github.com/moribit/Akamata/actions/runs/38514430563)
passed all 23 jobs, including Linux/macOS, Native/Workers/Container, docs,
generated clients, living examples and scaffold/update/sync. [TSan](https://github.com/moribit/Akamata/actions/runs/38515245637)
passed Linux and macOS, including sharded upgrade publication repeats. These
results do not automatically certify later uncommitted optimization candidates.

The [large-output shutdown probe](raw/drain-probe-instrumented.json) distinguishes
a runner's premature 10-second kill from the configured 30-second drain: the
process exited normally after 24.5 seconds, framework live bytes zero, 54 read
timeouts, no writer-budget timeout. Wall samples show partial-request readiness
waits. The root network/burst cause of those connections remains unknown. Runner
cleanup now permits 45 seconds without changing runtime deadlines.

## Rejected / unproven

- Zero-deadline lock skipping: small/inconsistent benefit; reverted.
- Shared pipe registration on every hot read: severe active-traffic regression;
  rejected and replaced by the quiet-connection-only park.
- Group/custom scheduler/lock-free replacement/unsafe event-loop handlers:
  not introduced without evidence.
- SIMD/trie rewrite: isolated costs recorded, but no measured end-to-end reason
  to change security checks or the prepared App route index.
- Native vectored large-output candidate: reverted after the five-round,
  10/30-second paired subset. Large echo improves ~13.5%, but plaintext P99
  worsens ~21%. The candidate patch and all results remain in the repository.

## Runtime adoption decision

**No production promotion.** Threaded remains default; `.runtime = .reactor`
continues to return `ExperimentalRuntimeDisabled`.
The four-loop screen improves high-concurrency latency/resources, but c32
plaintext remains 121709 versus Threaded 178734 HTTP 200/s, failing the proposed
5% low-concurrency throughput gate. c1024 P99 is 15.415 versus 31.981 ms and
idle RSS is about 31 MiB versus 119 MiB, demonstrating a research tradeoff,
not passage of all criteria. Full five-round results are still required.

## Remaining completion gates

1. Resume the full frozen baseline (250/1260 cases at the last checkpoint), then
   the final frozen after matrix, with no local builds/tests/other load.
2. Rerun final test/fixture additions and collect their cross-platform CI result;
   the vectored candidate is already rejected, with production writer restored.
3. Populate the final full framework/runtime tables from every round/error,
   retaining source/environment/command/binary hashes.
4. Update this status report with exact completion, remaining unknown causes and
   adoption decision, then commit/push evidence. No tag/release is created.

The durable supervisor in `benchmark/competitive/scripts/run_initiative.py`
resumes fixed binaries and writes process/stage status independently of a terminal.
Its completion is not presumed merely because it has been launched.
