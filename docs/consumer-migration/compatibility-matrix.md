# Local compatibility evidence

Candidate: `280c53481b527b7c11e4d7edb2b1252b7f03f2e6`. Zig 0.17.0; ReleaseSafe; isolated clones. Dependency URLs/hashes remain unchanged. `--fork` selects the local candidate. These are build/test-command results, not live-provider certification.

| Application | Tests | Default build | Workers build | Additional evidence |
|---|---|---|---|---|
| Yaku | pass | pass | pass | existing production stateless HTTP smoke pass |
| mimoc_news | pass | pass (dev launcher only) | pass | four JS host tests pass; actual D1/R2 pending |
| Ehagaki | pass | pass | pass | actual WASM with simulated D1 pass |
| mobus-backend | pass | pass | pass | baseline/candidate Native E2E pass; eight gateway/dispatch tests pass |

## Reproduction

Run `python3 tools/consumer-migration/validate_consumers.py --candidate` after preparing isolated Consumer clones. Logs and command durations are local ignored scratch, not public user-data artifacts. New CLI changes require a new frozen candidate and revalidation.
