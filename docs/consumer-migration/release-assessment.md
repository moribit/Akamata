# Release assessment — in progress

Starting candidate: `280c53481b527b7c11e4d7edb2b1252b7f03f2e6`. Published stable release: v0.2.0. Package and CLI identify as 0.2.1, but no 0.2.1 tag has been created. Version selection remains provisional until compatibility review is complete.

## Verified evidence

- Starting SHA existing CI: 23 successful jobs (run 42009937630). This is prior CI evidence, not a new run for uncommitted changes.
- Four Consumers: 12 baseline and 12 local-candidate ReleaseSafe commands passed.
- Mo-Bus disposable Native end-to-end scenario passed before and after candidate substitution.
- Ehagaki actual WASM/D1 host simulation passed; this is not live Cloudflare validation.

## Release blockers / unresolved gates

- CLI template checks incorrectly use the previous scaffold bootstrap tag; a focused fix is under test.
- Ehagaki missing-secret fallback and request-time migration need production-safe review.
- Mo-Bus Native sender echo differs from Workers sender exclusion; common Realtime scenario still needs semantic reconciliation.
- mimoc_news custom glue owns image proxy/upload behavior and cannot be force-replaced with standard glue.
- Staging E2E, mobile E2E, live provider coverage and candidate-specific full CI remain incomplete.

Stable release is not approved. Threaded remains the Native production default; Reactor remains parked/fail-closed. Tag creation and Release publication require the user approval specified in the task.

## Additional local candidate checks

CLI fix `072b21e`, documentation `087793d`, migration checkpoint `85c36ae`. `zig build test documentation-test db-pool-test -Doptimize=ReleaseSafe -j2 --summary all`: 92/92 steps, 169 tests pass, one skip, exit 0. `zig build portable-application-test documentation-test -Dbackend=workers -Doptimize=ReleaseSafe -j2 --summary all`: 8/8 steps, exit 0, ten simulated-provider runs pass. CLI operations and project-update tests pass including current-tag dry-run and unknown-tag rejection. These local results do not replace Linux/macOS candidate CI or staging live tests.

## v0.2.0 comparison: provisional classification

| Area | Classification | Evidence / migration consideration |
|---|---|---|
| DB Pool | additive API and lifecycle behavior | `8607435`, `005f110`: deadline acquisition, close/waiter ownership; preserve lease release before deinit |
| SQLite | compatible safety fix | `ccd7662`: finalize prepared statement if wrapper allocation fails |
| Threaded/HTTP | correctness and performance behavior | `278e2c5` buffered request tails; `87e5d93` owned shutdown notification; deadlines unchanged |
| Observability | additive metrics, optional cost | `ab56634`, `289abf2`: bounded-cardinality lifecycle/phase diagnostics |
| OpenAPI/client | generated source compatibility impact | `3f477a7`, `2be84be`, `9e707f0`, `8128827`: valid identifiers, bounded wire schemas, strict enums/tagged unions; regenerate clients and type-check caller assumptions |
| Workers bridge | compatible Fetch correctness | bodyless statuses use null response bodies; review managed diffs, retain app-owned entry/gateway behavior |
| CLI | compatibility fix | `072b21e`: separate current template support from old scaffold bootstrap; unknown versions fail closed |
| Experimental runtime | not release-promoted | `78ed9c5` evaluation only; Reactor remains parked/fail-closed |

No new App/Context, provider, auth or Realtime abstraction is proposed. Existing Consumer compilation is evidence of source compatibility for those four SHAs, not proof of all public API compatibility. v0.2.1 is the provisional patch candidate because retained production changes are additive/corrective; generated TypeScript tightening requires explicit migration notes. Final version and stable status await the remaining gates. Candidate CI: https://github.com/moribit/Akamata/actions/runs/42166135796 (running when recorded).
