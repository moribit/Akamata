# Isolated staging deployment report

No formal tag, GitHub Release, production deployment, production DB migration,
production service switch, production resource deletion or tag rewrite was performed.
Production rollback references remain in [baseline](baseline.md).

## Final targets

| Target | Version | Status |
|---|---|---|
| yaku-akamata-migration-20261106 | 1b1318c7-cf37-4b0e-8c1f-f666921da6f2 | 成功 |
| akamata-migration-20261106-news | 4fee605c-2317-4fb1-b888-da11f26fdafe | 成功 |
| akamata-migration-20261106-ehagaki | 736912e9-0942-41bf-a797-09853467aed5 | 成功 |
| akamata-migration-20261106-rt | 37183f27-c433-4580-8f51-abdbc881136f | 成功 |
| akamata-migration-20261106-mobus | e4eae085-faf5-40ff-8310-85c947dd6977 | 成功 |

URLs are `https://<target>.mimoc-maker.workers.dev`. Exact WASM hashes and app
SHAs are recorded in [final deployments](evidence/final-staging-deployments.json).
Yaku has no provider bindings. All other D1/R2/DO/service references were checked
against an explicit isolated-resource allowlist before deployment. No production
resource or data was copied. Test secrets were generated locally, uploaded from
mode-0600 files and never printed or committed.

## Acceptance

- **成功**: four sequential final live acceptance commands exit 0, including actual
  D1/R2/DO, gateway-to-Ehagaki, JWT interoperability, Realtime, firmware HEAD/Range,
  byte/SHA/size checks and crash upload. See [final live](evidence/final-live.json).
- **成功**: news current-dependency and candidate status/Content-Type/top-level JSON
  keys match across the tested CRUD/error cases. This is not a universal schema diff.
- **成功**: correlated structured news access log contains Request ID, route, status,
  timing and one D1 query; Server-Timing is present. Public-list probe has zero
  storage operations. Authenticated-write log payloads were not collected to avoid
  recording authorization headers; R2 effects were checked by bytes and cleanup.
- **成功**: dedicated R2 `crash/2.bin` readback equals the synthetic four bytes `dump`
  (SHA-256 b6ca0868bca6a2926b70aa1a71592038d9030fe26d4214edcfbd6cf41f2f4654).
- **未実施**: production post-deploy checks, production Secret equality, real ESP32
  hardware E2E, production latency measurement and production rollback rehearsal.

## Migration decision

| App | Schema change caused by this dependency update | Staging action | Production action |
|---|---|---|---|
| Yaku | none: no DB | none | none |
| mimoc_news | none: existing 0001_initial.sql unchanged | apply existing schema to new empty D1 | do not run migration for dependency update |
| Ehagaki | none: model/schema unchanged | existing deferred bootstrap validated on new empty D1; final Worker disables it | default request migration off; no migration for dependency update |
| mobus-backend | none: four existing SQL files unchanged | apply all four to new empty D1; history/status succeed | no migration for dependency update; SQLite-to-D1 cutover is a separate blocked gate |

Ehagaki Native auto-migration remains a development convenience. Workers now
requires explicit `EHAGAKI_AUTO_MIGRATE=true` for that convenience; final staging
is false. mimoc_news `MIMOC_NEWS_AUTO_MIGRATE=false` remains unchanged in production
and staging configuration. No production schema was inspected or certified by
these isolated tests. If production schema is behind, obtain a separately reviewed
migration plan, backup and approval rather than letting dependency deployment
apply it implicitly.

## Recovery and retention

A Worker code rollback uses the old version in baseline; it is not a database
rollback. No production schema rollback is required by this work. New empty test
D1s and dedicated R2 buckets use the `akamata-migration-20261106-` prefix; DO state
belongs only to the dedicated gateway namespace. Synthetic staging data/resources
are retained temporarily for approval review, not configured with automatic TTL.
Inventory them before explicit test-resource cleanup; never substitute production
IDs. No production dump or credential was placed in the repository.

App fixes are committed only in isolated checkouts (and private local Git bundles),
not promoted to original Consumer main branches. Approved-tag dependency pinning,
reviewed managed sync, app-fix promotion and production approval are still required
before production rollout.
