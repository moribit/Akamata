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

The driver uses a fixed Native Debug build so application Debug/ReleaseSafe and WASM builds do not multiply driver compilation. No application build mode is removed.

## Pending

Scaffold/journey, living examples/SQLite host/chat, transport/stress/isolation/session/TSan repeat, benchmark reporting guards, workflow wiring and before/after hosted measurements are still in progress. The old paths remain until their replacements are checked.
