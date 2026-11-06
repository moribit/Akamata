# Consumer migration baseline — 2026-11-06

No release tag, production deploy, production migration or service switch is authorized yet.
Original working trees remain intact; builds use isolated shared clones under
.zig-cache/consumer-migration. No .env/.dev.vars, credentials or production data
were copied. Secret **names only** were read; values were neither fetched nor recorded.

## Repository references

GitHub default branches and main SHAs were checked through the connected GitHub API.
All five local HEADs matched remote main before changes.

| Repository | Baseline SHA | Dependency | Pre-existing untracked paths |
|---|---|---|---|
| Akamata | `280c53481b527b7c11e4d7edb2b1252b7f03f2e6` | framework | none |
| Yaku | `f1f809fb6cba61b819dab35592b59ca7fae27db8` | `git+https://github.com/appleuser634/Akamata.git#c332887a56065b70d4db6edb19b603715ccd7fa7` | none |
| mimoc_news | `24eb3e140f9e669ec62c842b4074d5ee63e548d4` | `https://github.com/moribit/Akamata/archive/refs/tags/v0.2.0.tar.gz` | `?? .DS_Store`, `?? deploy/.DS_Store` |
| Ehagaki | `9962b4a12bda794b4ceaf7304ca02f02c2f47d23` | `https://github.com/moribit/Akamata/archive/refs/tags/v0.2.0.tar.gz` | `?? .DS_Store`, `?? deploy/.DS_Store`, `?? zig-pkg/` |
| mobus-backend | `da3f9c025c46e7c17ddb53f539c3bed6ecb76f0d` | `https://github.com/moribit/Akamata/archive/refs/tags/v0.2.0.tar.gz` | none |

Exact dependency hashes and public version IDs are in [baseline.json](baseline.json).
Zig 0.17.0 everywhere; installed Wrangler 4.120.0. Candidate CLI must be built
from the frozen framework source rather than an unverified PATH CLI. Akamata
package/CLI say 0.2.1, but the latest published release is **v0.2.0**; no v0.2.1
tag/release is assumed. Scaffold bootstrap pin remains v0.2.0 per release policy.

## Active Worker code rollback references

Read-only Wrangler deployment history and secret-name lists were captured.
These are current Worker traffic versions, not proof of the application source SHA,
secret equality, DB state or the domain/proxy routing in front of each service.

| Worker | Deployment | Traffic code version | Secret names |
|---|---|---|---|
| yaku-mvp | `c26ecc38-ed46-4aac-8b2a-3d73e222f0c5` | `902175ab-8d7a-45dd-8e02-83dfb013b4be` (100%) | none |
| mimoc-news | `a306ad23-4451-41cd-8e15-7c868ca7be94` | `199079db-6915-424e-8182-f96cf7c33984` (100%) | BASIC_AUTH_TOKEN |
| ehagaki | `87ff645f-9b88-46d5-836a-b78131a96fc1` | `5082d8fd-af87-4a35-b306-e8a613c6e5aa` (100%) | JWT_SECRET |
| mobus-backend | `4e661645-3241-4e2b-b063-a9a53ee8cd84` | `5fd6ea15-f2cc-42fc-bc43-417e46a6a107` (100%) | ADMIN_SECRET, JWT_SECRET |
| mobus-realtime-handler | `41ea1ac4-3431-490b-a8e0-4670c9e7233d` | `75d3d501-a46c-4e60-b8a8-53a50da97c58` (100%) | JWT_SECRET |

Worker code rollback uses the recorded previous version after operator approval.
A code rollback does not restore or roll back D1 data/schema. No production
backup/dump is taken or stored by this inventory. Existing data stays untouched.

## Target and deployment differences

| Consumer | Native | Workers / bindings | Migration / deployment boundary |
|---|---|---|---|
| Yaku | HTTP application + in-process tests | yaku-mvp, no DB/R2/auth | managed bridge + app-owned entry/request_limit; no migration |
| mimoc_news | **Dev launcher and SQLite migration tests only**, no Native HTTP entrypoint | mimoc-news; D1 DB, R2 NEWS_IMAGES; Basic auth secret | versioned migrations; AUTO_MIGRATE=false in production; deploy script also applies remote migrations, so it must not be run blindly |
| Ehagaki | HTTP + SQLite | ehagaki; D1 DB; shared JWT secret name | current Worker runs deferred request-time migration; production lifecycle requires review before promotion |
| mobus-backend | HTTP + SQLite/filesystem + Native Realtime | gateway + realtime-handler; D1 DB, R2 FILES, DO AKAMATA_REALTIME; service bindings AKAMATA_REALTIME_HANDLER and EHAGAKI | versioned migrations; existing readiness memo says SQLite→D1 production cutover NOT READY; migration and service switch are separate approvals |

Wrangler config remains app-owned. Its exact baseline content is recoverable from
the repository SHAs; all binding names above are preserved. No generated bridge
is edited directly. No Consumer currently has a checked-in GitHub Actions workflow.
Existing repo tests and commands are inventoried in the compatibility results.

## Known starting risks

- Yaku is pinned to unreleased immutable c332887, while the other three use v0.2.0.
- mimoc_news cannot honestly be reported as a Native HTTP app without new app work.
- Ehagaki request-time migration and missing-secret fallback need explicit production review.
- mobus-backend has an old Native two-client Realtime failure and unaudited DB
  cutover/readiness requirements. Reproduce before attributing anything to the candidate.
- Secret presence is verified, **secret equality and real JWT interoperability are not**.
- Existing Wrangler workerd may lag Yaku compatibility_date; any local compatibility
  override must be labeled local-only, not silently change production configuration.
- Dedicated remote staging D1/R2/DO environments have not yet been established.
