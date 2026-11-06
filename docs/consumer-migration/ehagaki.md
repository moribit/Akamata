# Ehagaki — final staging result

**Published rollout update:** user approval received; v0.2.1 is public and approved Worker updates are complete. The remainder below records pre-publication validation. See [current publication/rollout](publication-and-rollout.md) for actual versions, commits, data boundaries and verification limits.

Original SHA: 9962b4a; isolated validated SHA:
`3889b758bd3b12a0869b4c1423b27006e1c37f12` (includes auth fix 8ba1655).
Original checkout and production remain unchanged.

## Changes and validation

- **成功**: JWT_SECRET is required; empty/development-placeholder values fail.
  Dedicated live Worker without the secret returned 500 and accepted no API work.
  Missing-secret health is startup failure, not an authentication 401 claim.
- **成功**: 24/24 ReleaseSafe unit tests, Native build and Workers build.
- **成功**: actual WASM + JSPI with simulated D1, including migration retry.
  Use an explicit Node 24 executable with `--experimental-wasm-jspi`;
  PATH resolved inconsistently in this environment.
- **成功**: real isolated D1 bootstrap, then final deployment with request-time
  migration disabled (`EHAGAKI_AUTO_MIGRATE=false`). Defaults are now off for
  Workers; true is an explicit development/test convenience. Native development
  migration is retained. App schema/model did not change.
- **成功**: anonymous timeline, anonymous create rejection, public/private posts,
  owner visibility, nonowner delete 404 (existing existence-hiding behavior),
  search/paging, Unicode/emoji validation, 1024-byte bitmap and invalid-size rejection,
  owner deletion, expired/wrong-signature JWT rejection.
- **成功**: a JWT actually issued by staging Mo-Bus with a fresh shared test key
  creates Ehagaki posts with the same user_id. Gateway Service Binding to Ehagaki
  health succeeds. No production signing key or token was fetched.

Final staging version: `736912e9-0942-41bf-a797-09853467aed5`.
Production key equality, production schema readiness, production deployment and
production data tests: **未実施**. Local commits and private Git bundles preserve
fixes until approved migration promotion; dependency pin remains unchanged.

See [live evidence](evidence/ehagaki-live.json), [migration guide](migration-guide.md)
and [deployment report](deployment-report.md).
