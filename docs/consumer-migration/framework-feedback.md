# Framework feedback — migration evidence

Candidate begins at `280c534`; no feedback item is yet classified as a new framework feature.

| ID | Repository / area | Observation and reproduction | Classification / priority | Next action |
|---|---|---|---|---|
| F01 | Yaku / app-owned Workers entry | 4 KiB streaming body limiter protects before standard bridge arrayBuffer; current production HTTP smoke rejects >4 KiB | framework API/docs candidate / high | inspect candidate artifact ABI; do not remove app limiter without equivalent host-side bounded-read proof |
| F02 | mimoc_news / build.zig | backend enum is Workers-only; Native artifact is a dev launcher, while migration tests use SQLite | app scope/documentation / medium | distinguish Native tests from a real Native HTTP service; do not mark parity from a launcher build |
| F03 | Ehagaki / Workers lifecycle | deferred request-time migration runs on first request; repository documents it as production convenience | app deployment lifecycle / high | explicit migration plan and fail-closed startup policy before production promotion |
| F04 | Ehagaki / configuration | missing signing-secret path falls back to a development placeholder | app security / blocker for production | fail closed without a configured secret; no secret values read or compared in reports |
| F05 | mobus-backend / existing readiness memo | Native two-client Realtime failure and DB cutover NOT READY are documented | historical app memo / baseline resolved | baseline two-user Native E2E passed including client-originated signals/text/end; repeat candidate and real Workers before considering remote cutover |
| F06 | Ehagaki / repository hygiene | compiled Native/WASM artifacts are tracked | app build/release hygiene / medium | never treat checked-in output as freshly verified; rebuild from the recorded SHA |
| F07 | all consumers / CLI source | no Consumer GitHub Actions workflows; dependency versions differ, Yaku is an unreleased SHA | tooling/documentation / high | use exact candidate CLI and establish explicit command/result matrix; immutable release pin only after approval |

Every promoted issue must add candidate SHA, file, expected/actual behavior,
reproduction command, impact, recommended fix and evidence. Remote production
secret equality, JWT interoperability and DB cutover readiness remain unproven.

## Baseline confirmations

- Existing dependency: all 12 ReleaseSafe test/build/Workers commands passed.
  mimoc_news Native result is explicitly its dev launcher, not Native HTTP parity.
- Yaku current production stateless HTTP smoke passed: 38 catalog entries, all
  difficulties, hidden answer DTO fields, grading, validation, 4 KiB rejection,
  OpenAPI/client, free hand analysis and 49-term glossary.
- Mo-Bus baseline E2E passed on disposable SQLite/filesystem with test-only
  credentials. The historical Native Realtime blocker did not reproduce at
  da3f9c0; no framework change is justified by the old memo alone.
- Ehagaki WASM host test initially could not start because Node 24 does not
  enable JSPI by default. Use the actual supported `--experimental-wasm-jspi`
  flag; this is an environment/documentation issue, not a framework failure.

## CLI finding F08

`tools/akamata/src/project/managed_files.zig` rejected the matching CLI release tag because it compared against the older scaffold bootstrap pin. Fixed in `072b21e`: explicit current/bootstrap template compatibility and matching default update target. Release helper unit test and project-update dry-run regression cover current-tag acceptance, unknown-tag refusal, old-tag compatibility and no file mutation. CLI operations/project-update checks pass. No generated Consumer bridge was edited.
