# mimoc_news — final staging result

Source: `24eb3e140f9e669ec62c842b4074d5ee63e548d4` (unchanged). Framework candidate
2714af0, library source 0ea0c17. Native SQLite tests and Workers build: **成功**.
Default Native build is a dev launcher, not a Native HTTP implementation.

## Actual provider acceptance — 成功

Dedicated empty D1 plus R2; existing 0001_initial.sql applied only there. Both old
v0.2.0 dependency WASM and candidate WASM passed the same scenario:
public listing/detail, Basic-auth admin, invalid Origin rejection, missing required
title image rejection, two 9 MiB JPEG fields (title/main), byte-exact GET and HEAD,
parallel detail reads, text-only edit retaining both images, replacing both images, old R2 object cleanup,
10 MiB + 1 file rejection (400), delete cleanup and missing detail (404).
Status, Content-Type and top-level JSON keys match the tested baseline cases.

Request ID and Server-Timing are present. A public GET tail probe correlates its
Request ID to structured status/route/timing, one D1 query and zero storage ops.
Authenticated write log payloads were not retained; actual R2 bytes/deletions prove
those operations separately. This is not an aggregated operation-count benchmark.

`MIMOC_NEWS_AUTO_MIGRATE=false` is retained in production and staging config;
no migration middleware is registered in that mode. Dependency update requires
no schema change. The production deployment script can apply migrations, so it
must not be run blindly. No production data, image or credential was copied.

## Ownership and gates

Custom unowned bridge provides image proxy, logging and upload behavior. It was
not directly edited or force-synced. Matching CLI sync dry-run correctly refuses
replacement (`ManagedFileModified`). The bridge still buffers HTTP requests; its
post-read 21 MiB check is not a pre-buffer streaming admission guarantee. Keep
this distinction in any production readiness claim and future bounded-host work.

Final staging version: `4fee605c-2317-4fb1-b888-da11f26fdafe`. Production rollout,
production performance and production rollback rehearsal: **未実施**.
See [evidence](evidence/news-final.json) and [deployment report](deployment-report.md).
