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
