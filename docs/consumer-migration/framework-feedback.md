# Framework feedback — final release validation

**Published rollout update:** user approval received; v0.2.1 is public and approved Worker updates are complete. The remainder below records pre-publication validation. See [current publication/rollout](publication-and-rollout.md) for actual versions, commits, data boundaries and verification limits.

Framework candidate: 2714af0. Full source SHAs and evidence are linked from
[release assessment](release-assessment.md). No new capability/runtime abstraction
was added to work around Consumer code.

| ID / priority | Repository / file | Reproduction, expected vs actual | Classification / result |
|---|---|---|---|
| F01 high | Yaku app-owned request_limit.mjs; Akamata worker template dispatch | Body must be rejected before unbounded host materialization; Yaku 4 KiB guard does so, canonical bridge still arrayBuffers first | API/docs backlog; retain guard, do not claim universal pre-buffer admission |
| F02 medium | mimoc_news/build.zig | default build succeeds but produces Native dev launcher, not HTTP server | app scope/docs; corrected matrix, no fake Native parity claim |
| F03 high | Ehagaki/src/worker.zig, config.zig | production should not apply schema on first request; old worker always registered migrator | app deploy lifecycle; fixed 3889b75 explicit opt-in, final staging false; no schema change |
| F04 high | Ehagaki/src/config.zig | missing JWT secret should fail startup; old app used development fallback | app security; 8ba1655 + 3889b75, live missing-secret 500; empty/placeholder unit rejection |
| F05 medium | Mo-Bus historical readiness memo | historical Native delivery failure did not reproduce in baseline acceptance | historical issue closed for tested scenario, not production DB cutover certification |
| F06 medium | Ehagaki tracked zig-out artifacts | checked-in output can be mistaken for fresh build | app hygiene; rebuilt separately, original files preserved |
| F07 medium | Consumer tooling | PATH Node/CLI can differ; no Consumer CI workflows found | DX/docs; explicit binaries and SHA/wasm hashes recorded; JSPI flag uses actual Node 24 |
| F08 high | tools/akamata/src/project/managed_files.zig, command/update.zig | same-version CLI should accept matching release tag; bootstrap v0.2.0 incorrectly rejected v0.2.1 | framework bug; fixed 072b21e, current/old/unknown-tag regressions pass |
| F09 high | Mo-Bus/src/application.zig nativeRealtime | client event should reach peer without sender echo; old Native notifyCall broadcast all | app bug; minimal saved-baseline failure and Native/Workers success after c389a8e/dd8273b; existing core broadcastExcept reused |
| F10 blocker resolved | src/storage.zig serveDownload | HEAD metadata must survive reader close; Native firmware HEAD crashed in response serialization | framework bug; 0ea0c17 request-arena metadata snapshot; old-two-line poison test fails, corrected 28/28 and full acceptance pass |
| F11 high resolved | tools/akamata/src/command/deploy.zig | unsupported --dry-run must not deploy; source parser ignored unknown flag | framework CLI safety bug; 2714af0 rejects before any external command; mock validates zero migration/build/deploy calls |
| F12 medium | mimoc_news custom unowned Workers bridge | sync must preserve image proxy/logging/10 MiB upload behavior; standard replacement loses behavior | app integration/docs; ManagedFileModified protection retained, actual D1/R2 contracts pass without bridge edits |

## Test assumptions corrected (not product regressions)

- News creation requires a title image (400 without it); image-free update is
  distinct. Do not infer new optional-create semantics from an idealized test.
- Ehagaki returns 404 for nonowner delete to avoid leaking existence, not 403.
- Restricted browser launch and missing JSPI flag were environment failures; explicit
  supported runtime/permissions passed. A public Python probe returned 403 until
  an explicit User-Agent was supplied; Node/curl and corrected probe succeeded.
- Native fixture now handles TLS and HTTP upgrade read-ahead before remote reuse.

## Still not proven

Production Secret equality, production DB migration/cutover readiness, real ESP32
hardware compatibility, production performance and long-duration application leak
certification remain unverified. Staging functional success and framework TSan
must not be presented as those stronger claims. No speculative core workaround,
Reactor activation, production data import or automatic production provisioning
was used to make this matrix pass.

## F13 — Zig 0.17 fetch cache (high; upstream/tooling documentation)

Bare fetch returned the correct v0.2.1 hash but wrote a nested-root recompressed cache; subsequent consumers saw N-V manifest mismatch. The package archive and declared hash were unchanged. Local-storage `zig fetch --save=akamata` and cold-cache build pass; --pkg-dir alone was not an effective fix. See the current rollout report. Do not change immutable tags or disable hash checks to work around this tooling behavior.
