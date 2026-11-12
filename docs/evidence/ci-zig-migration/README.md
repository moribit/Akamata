# Zig test migration and CI compilation work

Baseline: `9f6d64550b23d04bd6cc259f45b5816675134a8c`. Native production runtime and Workers APIs are unchanged.

## Scope

Python test assertions/orchestration migrate to the native Zig runner. Actual JavaScript/WASM hosts and TypeScript checking remain, as explicitly confirmed by the user. Offline test evidence is not live Cloudflare certification. Pure benchmark measurement/reporting utilities are inventoried separately from tests.

`python-inventory.json` freezes Python test-function identities before removal. Transport cases, deadlines, fixture ownership, error detection and mode/OS coverage must survive migration. No Python subprocess wrapper counts as a migrated test.

## Completed and checked locally (Zig 0.17.0)

- Maintained documentation links: same 37 documents.
- Bilingual PDF contract: 13 pages each, dimensions, nonblank text, expected/allowed links, current code and stale-claim rejection. Poppler only decodes the document; all assertions are Zig.
- CLI operations: exact mocked argv, no provisioning on rejected deployment, build failure, db/container/build/dev dispatch, watcher restart and child reaping. Mock executables are symlinks to Zig code, with no Python runtime.
- CLI capabilities: environment/TOML/JSONC resolution, strict validation, malformed manifests, redaction, drift, preflight ordering and read-only configuration safety.
- Shared support: explicit process/socket owners, monotonic absolute deadlines, bounded capture and temporary-resource cleanup.
- Transport: all 34 original cases, including partial/pipelined reads, absolute write/drain deadlines, stream/frame ownership, isolation and overload. Local macOS run: 136/136 across Threaded, kqueue, sharded and Threaded incremental. Group remains a separate evaluation path.
- Scaffold: notes/minimal Native/Workers build modes, migrations applied twice, public build helper, named D1 and Turso metadata, actual HTTP and clean shutdown.
- Public journey: init, ordinary/typed function editing, CLI test/check/dev, actual 201 JSON response, Workers ReleaseSafe and bounded dev shutdown.
- Project update/sync: old v0.1.0 fixture, dry-run immutability, edited managed-file refusal, backup/force recovery, application-owned markers, Native/Workers build and template version rejection.
- Living path: 59 commands with strict TypeScript checks, eight Native example builds, six application-test target invocations, four real Workers WASM/JSPI hosts, protocol TS/C output, migration history, two-peer Native WebSocket/persistence and documentation/source equality checks. SQLite host is Zig with the repository's bundled SQLite, not Python sqlite3.
- Application isolation: Threaded/kqueue/sharded, held upgrades/slow streams, admission overflow/recovery, bounded I/O drain and zero allocator/session leaks. Repeated sanitizer case checkpoints retain binary hash and live failure diagnostics.
- Stress: all 24 quick scenarios across Threaded/kqueue/sharded passed locally, including concurrent pipeline/reset churn, slowloris, 512 KiB partial echo, stream/upgrade errors, slow-reader forced drain, latency probes, isolation, and a child-only RLIMIT_NOFILE=64 accept-exhaustion/recovery test. Resource/allocator/session samples are retained. Each parallel client has its own allocator; all threads join before result inspection.

The driver uses a fixed Native Debug build so application Debug/ReleaseSafe and WASM builds do not multiply driver compilation. No application build mode is removed.

## Final migration validation

All framework test-driver entrypoints in `build.zig`, normal CI and the sanitizer
workflow now use Zig. The retired shell compile-fail and Workers-sync drivers
also migrated. No Python test files remain under `tests/`; manual Python benchmark
measurement/reporting programs remain separate and use shared native evidence
guards. See [coverage and commands](coverage.md) for the explicit migration ledger.

Local final regression passed 60/60 build steps and 89/89 ordinary Zig tests
(74 lifecycle + 15 DX), plus 170 socket cases, 24 quick stress scenarios, 15
session/race/mixed scenarios, 12 isolation scenarios, all 33 compile-fail cases,
CLI operations/capabilities, scaffold/journey/update/sync and five Workers binding
combinations. The separate full unit suite passed 202/203 with the existing one
RS256 skip when OpenSSL is disabled. The OpenSSL CI job tests that backend.
The 51-command batched living path passed with all five strict TS invocations.
Real saved data also passed the new guards: 288 paired DB micro rows, 192 HTTP
ABBA cases and the full 1,260/630 competitive before/after matrices. No raw
benchmark data or frozen application binary was changed.

Intermediate commit `d3aa062` passed all 23 hosted CI jobs in
[run 43211221165](https://github.com/moribit/Akamata/actions/runs/43211221165).
This is evidence for the intermediate migration, **not** the final batched
configuration or a statistically controlled speed result. Final hosted timing
and sanitizer results are recorded separately once complete. Historical evidence
commands are historical records, not current runner instructions.

First hosted run `43210370724` found Linux Debug example ELF files exceeding the test helper's 64 MiB text-read cap during artifact hashing. The application build itself passed. Hashing now streams fixed-size blocks and has a >64 MiB sparse-file regression check; the cap remains for textual test inputs. Cross-compilation of the complete runner to x86_64-linux-musl succeeds; actual hosted tests are still required.

## Shared compilation experiment

Zig 0.17.0, Apple M2 (8 CPU), 16 GiB RAM, macOS 27.0.1 (26A434), ReleaseSafe. Sequential runs used distinct initially empty **local** caches and an existing global compiler cache; these are not clean hosted-runner or repeated statistical measurements. Source was the working changes on `63cc519` (catalog plus literal imports). Both layouts actually ran the same 203 cases: 202 pass, 1 skip.

| Layout | wall seconds | child user seconds | child system seconds | max RSS bytes | build steps |
|---|---:|---:|---:|---:|---:|
| isolated | 117.08 | 359.72 | 10.87 | 1,040,564,224 | 86 |
| grouped | 68.92 | 143.13 | 3.91 | 1,306,640,384 | 40 |

Local wall time fell 41.1%; max RSS rose 25.6%. CI tries `-Dtest-layout=grouped`, keeping the same OS/modes/check names; public default remains isolated and is available for bisecting test-process interactions. Standalone source/example/CLI suites keep their own roots. Documentation-only tests stay independent. The explicit grouped imports are checked against `unit_catalog.zig` at compile time.

Raw `/usr/bin/time -l` output: `isolated-local.time`, `grouped-local.time`. `grouped-invalid-*.time` are failed setup attempts (literal import / comptime quota), **excluded** from the comparison. Reproduce with `AKAMATA_CI_RERUN_TESTS=1 zig build test -Dtest-layout=isolated|grouped -Doptimize=ReleaseSafe --cache-dir <new-directory> --summary all`, sequentially. No test or application runtime behavior was removed for this result.

Zig 0.17 uses `.protocol` for unit-test runs. The prior forced-rerun guard checked
only legacy `.zig_test`; it now accepts both. Further warm testing exposed that
configure-cache reuse can freeze environment-conditioned choices. Test verdicts
therefore rerun **by default**, independently of environment variables. Explicit
`-Dcache-test-results=true` is the local opt-out; CI does not use it. Compilation
still uses the ordinary Zig cache. Compiler selection is passed to the native
driver as `--zig`, keeping runtime TS/timing/report settings out of cached Run
environment snapshots.

## Dependency transport reliability

Final batching candidate `4ccebf7` passed 22/23 normal jobs in run
`43218854054`; `cli-build` failed before compilation while fetching the pinned
Codeberg aro source (`ProtocolError`). Linux TSan passed in `43218871134`;
macOS TSan failed at the same dependency download, before instrumented tests.
These failures are not recorded as passing tests or speed improvements.

The follow-up caches only immutable translate-c/aro source directories, keyed by
OS, Zig version and the dependency manifest. Generated projects share that source
directory through `ZIG_LOCAL_PKG_DIR`. Cold downloads get at most three bounded
attempts, and their package hashes must match the existing manifest pins. Tests
and builds are never retried by this helper. Compiler outputs and test verdicts
are excluded; the previously rejected compiler-cache experiment remains disabled.
Local rehashing verified both pins, and the runner support test plus Linux
cross-compilation passed after exit-status diagnostic normalization.

The first cold hosted trial (`7dc5f33`, run `43222536489`) exposed a bootstrap
bug: `zig fetch --pkg-dir` without `--save` only filled the global archive cache,
so reading the local package manifest failed. Warm local verification had missed
this. The fix uses `--save` with a private scratch **build.zig and manifest**;
Zig locates its build root using build.zig. A genuinely empty local/global cache
in `/tmp` then fetched both exact pins, materialized both directories and left
the original manifest byte-for-byte unchanged. This failed trial is excluded
from speed claims; it does not represent a framework/test failure.
