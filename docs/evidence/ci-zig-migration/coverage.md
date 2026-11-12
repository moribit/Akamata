# Test-driver migration ledger

Baseline `9f6d645`; original Python identities are frozen in `python-inventory.json`.
Framework/application behavior is unchanged. JS/WASM host execution and strict
TypeScript checking stay in their actual runtimes, as requested by the user.

| Retired driver | Native Zig contract | Preserved checks |
|---|---|---|
| documentation_links.py | runner/documents.zig | 37 maintained documents, anchors/relative paths excluded as before |
| public_slides.py | runner/documents.zig | 13 pages/language, page dimensions/text/code/current claims/PDF links; Poppler decodes only |
| cli_operations_smoke.py | runner/operations.zig | exact external argv, preflight/failure ordering, no side effects on refusal, watch restart/child reaping |
| cli_capabilities_smoke.py | runner/capabilities.zig | provider/environment/TOML/JSONC drift, duplicate declarations, redaction and fail-fast diagnostics |
| minimal_scaffold.py | runner/minimal.zig | Native build/test, Workers build, minimal file tree, metadata, actual HTTP and shutdown |
| public_journey.py | runner/journey.zig | init/edit typed route/test/check/dev HTTP/Workers and bounded dev shutdown |
| scaffold_smoke.sh | runner/scaffold.zig | notes build modes, migration idempotency/helper, named binding and Turso metadata, managed glue |
| project_update_sync.sh | runner/update.zig | legacy project, dry-run immutability, app-owned files, modified managed-file protection/backup, builds/version rejection |
| workers_capability_sync.sh | runner/capability_sync.zig | five binding combinations, actual Workers compilation, explicit removal/no dangling import |
| compile_fail.sh | runner/compile_fail.zig | same 33 source fixtures and expected diagnostic substrings |
| inline scaffold shell assertions | runner main/scaffold-files | generated main, Wrangler config and Dockerfile |
| native HTTP http_fuzz.mjs CI invocation | runner/adversarial.zig | all 15 attack variants, four-worker mixed load, health before/after and owned process cleanup; manual JS tool retained outside CI |
| command_timing.py + ci_timing_test.py | runner/support.zig + main/living | nonzero status/output, monotonic timings/child CPU, checked failures and partial evidence |
| living_examples.py + living_chat.py | runner/living.zig + chat.zig | 8 Native artifacts, 6 application-suite invocations, 4 Workers artifacts/hosts, metadata, TS/C, migration and two-peer chat persistence |
| living_sqlite.py | runner/sqlite_host.zig | isolated SQLite D1-shaped host; actual WASM tests exercise the bridge; not live D1 certification |
| transport_contract.py | runner/transport.zig | all 34 case identities/deadlines/profiles; Threaded, host selector, sharded, Group and Threaded incremental |
| runtime_stress.py | runner/stress.zig | all eight quick scenarios/adapter, full idle/wave sizes available; fd exhaustion remains child-only |
| runtime_application_isolation.py | runner/isolation.zig | four held-session/admission scenarios/adapter, 250 ms unrelated HTTP gate, allocator/session cleanup |
| runtime_contract_repeat.py | runner/repeat.zig | bounded repeat count, binary identity, per-run checkpoint, failure log/runtime snapshot |
| runtime_certify.py | runner/sessions.zig | 100-peer broadcast, concurrent streams, 256 fd reuse races, 64-peer shutdown race, idle levels, mixed HTTP/DB/stream/WS and bounded soak |
| db-optimization/smoke.py | runner/db_smoke.zig | 6 equivalent paths, complete row checksum, zero errors and latency ordering |
| db-optimization/test_reporting.py | runner/reporting.zig | 10 original completeness/duplicate/error/checksum/ABBA/failed-attempt contracts |
| competitive/scripts/test_reporting.py | runner/reporting.zig | 9 original guard intents: matrix/errors/drift, reserve boundary, owned-process cleanup, future counters, summary failures, unsafe counts and spill-file ownership |

Private benchmark evidence validation, metrics, summary formatting, reserve checks
and zap spill-file cleanup are now shared Zig code, not a second untested Python
implementation. Manual Python measurement/reporting programs remain outside the
test suite and call these native guards via `native_evidence.py`. The owned-child
interruption contract exercises the native process owner used by the new test
drivers; it does not certify arbitrary interruption behavior of manual Python
measurement programs. Build the native tool **before** measuring, never during a
measurement interval. Existing raw data and frozen application binaries are not
rewritten by migration.

## Local commands

```sh
zig build test -Dtest-layout=grouped -Doptimize=ReleaseSafe --summary all
zig build ci-runner ci-sqlite-host
./zig-out/bin/akamata-tests support
./zig-out/bin/akamata-tests reporting
zig build compile-fail-test workers-capability-sync-test
zig build transport-contract-test runtime-poc-test runtime-stress-test runtime-isolation-test runtime-session-test -Doptimize=ReleaseSafe
zig build living-examples-test
```

Use Zig 0.17.0 and Node 24. Set `AKAMATA_DX_TSC` to a TypeScript 5.9.3 `tsc.js`
for generated-client checks; CI refuses to omit it. `--zig /absolute/zig` can be
placed before the runner suite when executing a prebuilt driver directly.

Unit results run every time by default, including warm builds. Explicit
`-Dcache-test-results=true` restores cached verdicts for local use; CI never uses
it. This is a tracked build option, avoiding configure-cache sensitivity to
changed environment variables. The legacy CI rerun environment flag is no longer
needed. The runner inherits the current environment; its compiler is passed as
an argument so build configuration does not freeze TS/report/timing settings.

`living-native-check` batches the same four binaries and three application suites
in one build graph **per mode**. The living report has 51 commands rather than
59 because eight separate Native build/configuration invocations are folded into
two graphs. Both modes still report 13 actually executed application tests and
all eight Native artifacts are hashed. Workers builds/host cases remain intact.

Long soak and TSan remain explicit workflows, not normal push/PR additions. A
five-second session run is not represented as a completed twenty-minute soak.
Reactor production admission remains unchanged and fail-closed.
