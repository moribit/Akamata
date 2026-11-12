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

The driver uses a fixed Native Debug build so application Debug/ReleaseSafe and WASM builds do not multiply driver compilation. No application build mode is removed.

## Pending

Stress/session certification, benchmark reporting guards, remaining workflow wiring and hosted before/after measurements are still in progress. Python transport support remains only while the stress/session callers depend on it. Historical evidence commands are historical records, not instructions for the current runner.

## Shared compilation experiment

Zig 0.17.0, Apple M2 (8 CPU), 16 GiB RAM, macOS 27.0.1 (26A434), ReleaseSafe. Sequential runs used distinct initially empty **local** caches and an existing global compiler cache; these are not clean hosted-runner or repeated statistical measurements. Source was the working changes on `63cc519` (catalog plus literal imports). Both layouts actually ran the same 203 cases: 202 pass, 1 skip.

| Layout | wall seconds | child user seconds | child system seconds | max RSS bytes | build steps |
|---|---:|---:|---:|---:|---:|
| isolated | 117.08 | 359.72 | 10.87 | 1,040,564,224 | 86 |
| grouped | 68.92 | 143.13 | 3.91 | 1,306,640,384 | 40 |

Local wall time fell 41.1%; max RSS rose 25.6%. CI tries `-Dtest-layout=grouped`, keeping the same OS/modes/check names; public default remains isolated and is available for bisecting test-process interactions. Standalone source/example/CLI suites keep their own roots. Documentation-only tests stay independent. The explicit grouped imports are checked against `unit_catalog.zig` at compile time.

Raw `/usr/bin/time -l` output: `isolated-local.time`, `grouped-local.time`. `grouped-invalid-*.time` are failed setup attempts (literal import / comptime quota), **excluded** from the comparison. Reproduce with `AKAMATA_CI_RERUN_TESTS=1 zig build test -Dtest-layout=isolated|grouped -Doptimize=ReleaseSafe --cache-dir <new-directory> --summary all`, sequentially. No test or application runtime behavior was removed for this result.

Zig 0.17 uses `.protocol` for unit-test runs. The prior forced-rerun guard checked only legacy `.zig_test`; it now accepts both so warm cached compiler results cannot silently stand in for test execution when `AKAMATA_CI_RERUN_TESTS` is enabled.
