# v0.2.1 publication and approved rollout — 2026-11-06

The user explicitly approved v0.2.1 publication and deployment. They separately
confirmed that Mo-Bus updates only its existing Workers (/dev); legacy production
/api and its DB/routing remain in place. Earlier approval-pending reports are
historical checkpoints, superseded by this operational record.

## Release — success

- [Akamata v0.2.1](https://github.com/moribit/Akamata/releases/tag/v0.2.1), non-draft/non-prerelease.
- Immutable commit: `2714af09fb6c910581a8397c0cb69ebe6a4eccda`.
- Annotated SSH ED25519-signed tag; local verification against the existing public
  key succeeded. This does not assert a particular GitHub signature trust badge.
- Tag object: `7b0cf0aabaf025e07a01d6be70dd4ab0be807b72`. No existing tag was changed.
- Candidate CI 23/23, Linux/macOS TSan 2/2; tag release workflow 42176760090 succeeds
  and publishes four architecture-specific chat-example archives. These are not CLI installers.
- All four Consumers now pin the same immutable archive and verified hash:
  `akamata-0.2.1-uJIoI3crPQE12CxtQ0Iv_d0wHvo0M3USWct-sZKaIc1_`.
- Published-archive Consumer tests/default/Workers builds: 12/12 pass **without --fork**.
  Separate cold-global-cache Yaku run: 29/29 tests; scaffold and update/sync pass.
- Post-tag commit 7e11714 updates the bootstrap scaffold pin/hash, changelog and
  bilingual entry guides, preserving explicit v0.2.0 template compatibility.
  Released tag content is unchanged; follow-up CI is distinct from candidate CI.

## Final application and deployment identities

| Product | App main commit | Active Worker version | Scope |
|---|---|---|---|
| Yaku | b7c75c373d59ae7e6aef347f35863e2aceecfe39 | 1e4dc0d0-4e81-49e0-9e9b-09bd98f3f012 | production yaku-mvp |
| mimoc_news | 1c3478704bcac9537f5e7f891084d32308c5fd9c | ed98b409-ab1a-4654-ab41-b0cd4a8638f3 | production mimoc-news |
| Ehagaki | c0e1b21007601e910e03d6f530683060bef320f0 | 594ae616-2b32-4219-b399-2c57afd451a5 | production ehagaki |
| mobus-backend | 668f99acfaa19c6bdd818bbbd9072be49fb7c303 | a8a01cb9-62c9-413b-8ee4-6e996fbcb46d | existing /dev Worker, not legacy production /api |
| Mo-Bus application handler | same | dbccb2ec-c55f-4cb8-9d6e-e5b131d49851 | existing /dev named service |

Each application was dry-run first, then deployed sequentially. Mo-Bus handler
preceded gateway. Active versions were reread after source pushes and match the
recorded manual deployments. Exact WASM hashes and rollback versions are in
[evidence](evidence/publication/production-rollout.json).

All Consumer commits were pushed to their main branches and original local main
checkouts were fast-forwarded only after clean-tracked-state checks. Existing
untracked .DS_Store/zig-pkg files were preserved. Ehagaki tracked build outputs
were not committed as source updates; builds/deployments used fresh isolated
artifacts. No stash, force push, reset, production resource deletion or tag rewrite.

## Actual acceptance

| Product | Result and evidence |
|---|---|
| Yaku | Success: catalog/quiz difficulties/privacy/grading, 4 KiB guard, errors, OpenAPI/client and static pages via production HTTP smoke. |
| mimoc_news | Success: Basic-auth admin, Origin rejection, dedicated temporary article, two 9 MiB images, byte-exact GET/HEAD, text-only edit retaining images, replacement, size rejection, delete and R2 cleanup. Temporary article/images removed; existing content untouched. Request ID/Server-Timing and a header-filtered public GET structured-log/D1 timing correlation pass. |
| Ehagaki | Success: fresh tokens issued by unchanged production Mo-Bus accepted with matching user_id; public/private visibility, owner/nonowner handling, wrong-signature denial, deletion, existing mimoc.jp/ehagaki health proxy. Final run removes two temporary posts and both temporary accounts. No signing-secret value was fetched. Initial Kanji test title correctly returned 400 under the existing ASCII/Katakana rule; its temporary accounts were also removed before retry with a valid fixture. |
| Mo-Bus /dev | Success: actual DO/named service user rooms, offer/accept, bidirectional Signal/Text, sender exclusion, reconnect, unauthorized-room denial, call end/inactive state, /dev WebSocket and HTTP proxies, Ehagaki service, dedicated Crash Dump upload and byte-exact R2 readback. Three clearly marked synthetic dev accounts and a test crash object remain; no existing data was overwritten. |

The final /dev HTTP probe initially returned 403 with Python default User-Agent;
explicit verification User-Agent returns 200, as in the earlier staging probe.
This probe correction is recorded rather than concealed as a first-run success.

## Data, secrets and migration boundaries

No DB schema migration or SQLite-to-D1 switch was performed. Read-only pre/post
schema fingerprints match for all three existing D1s. Worker Secret names before
and after match exactly; no secrets were replaced or re-uploaded. The existing
local Basic credential was used only in memory against production news, never
copied to staging or printed. JWTs/passwords stayed in memory; no tokens, private
keys, production rows or dumps are included in committed evidence.

Production **data** was touched only through the explicitly scoped temporary
acceptance CRUD described above; claiming that no DB write occurred would be
incorrect. Production **schema, bindings and DB/routing selection** were retained.
Ehagaki request-time migration is explicitly false; news remains false. Code
rollback and database rollback remain distinct; no DB rollback was needed.

## Verification limits / follow-up

- Real ESP32 hardware tests, long production soak and a new throughput/latency
  matrix were not run. Functional timings are not performance certification.
- Existing /dev has no published esp32s3/stable firmware (latest returns 404).
  Firmware registration/upload/publication was deliberately not performed there;
  full SHA/size/GET/HEAD/Range acceptance passed in isolated staging. Existing
  published production firmware/legacy OTA paths were not modified.
- Mo-Bus synthetic dev test records can be cleaned in a separately reviewed,
  fixture-scoped operation. No broad delete or production-data import was used.
- The retained custom news bridge still has documented host buffering limits.
  This rollout does not assert universal streaming or production certification.

## Zig 0.17 cache issue found after tagging

Bare `zig fetch <tag-tar-url>` computed the correct hash but recompressed the
cache with an extra archive directory. Consumer/scaffold builds then reported
an N-V naked-package hash. `--pkg-dir` alone did not help because no-save mode
has no local storage in Zig Maker. `zig fetch --save=akamata <same-url>` in a
Consumer normalized the cache; all 12 no-fork builds and a separate cold-cache
run passed using the **same** immutable hash. No tag or declared hash was
changed and validation was never bypassed. Workaround is in the Release notes
and bilingual releasing guides; this is a Zig tooling feedback item.

## Recovery

Pre-rollout versions are in [production-before](evidence/publication/production-before.json).
If a verified regression appears, use the corresponding Worker version rollback
with its existing config and recheck HTTP. Do not roll back the DB or switch the
legacy production API. No rollback was required during this rollout.
