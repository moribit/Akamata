# Release-candidate compatibility matrix

Status vocabulary: **成功** = observed success; **失敗** = reproduced failure;
**未実施** = not performed; **環境制約により未確認** = evidence unavailable in this environment.
Historical failures remain recorded even when a later fix passes.

Framework candidate: `2714af09fb6c910581a8397c0cb69ebe6a4eccda`.
Its library/runtime tree is identical to Storage-fix commit `0ea0c17`;
only CLI safety/documentation changed afterward. Zig 0.17.0, ReleaseSafe.

| Application | Baseline SHA | Validated app SHA | Native test/build | Workers build | Live staging | Production |
|---|---|---|---|---|---|---|
| Yaku | f1f809f | f1f809f | 成功 | 成功 | 成功: HTTP smoke; earlier browser 36/36 | 未実施 |
| mimoc_news | 24eb3e1 | 24eb3e1 | 成功: SQLite tests/dev launcher; Native HTTP is not implemented | 成功 | 成功: actual isolated D1/R2, multipart CRUD | 未実施 |
| Ehagaki | 9962b4a | 3889b75 (isolated checkout) | 成功: 24 tests and build | 成功 | 成功: actual D1, JWT, visibility, deletion, gateway | 未実施 |
| mobus-backend | da3f9c0 | dd8273b (isolated checkout) | 成功: unit/build and disposable acceptance | 成功 | 成功: DO, named service, two-client acceptance, R2 | 未実施 |

All 12 final Consumer test/build commands passed against `--fork` at `0ea0c17`.
Do not reinterpret the mimoc_news launcher as Native HTTP parity. Dependency
URLs/hashes remain unchanged pending the approved immutable release.

## Regressions discovered and resolved

| Test | Before | After | Attribution |
|---|---|---|---|
| Native firmware HEAD followed by Range | 失敗: process segmentation fault | 成功: complete acceptance exits cleanly | Akamata reader-owned header lifetime; fixed 0ea0c17 |
| Client-originated Native sender exclusion | 失敗 on saved baseline and candidate before app fix | 成功 Native and Workers | app used broadcast rather than existing broadcastExcept; c389a8e/dd8273b |
| Ehagaki missing signing secret | old app fallback unsafe | 成功: live missing-secret startup rejects with 500; unit rejects empty/placeholder | app fix 8ba1655 |
| Unsupported CLI deploy --dry-run | source inspection: silently ignored, would deploy | 成功: UsageError before any external call | framework CLI fix 2714af0 |

## Evidence limits

Unit, host simulation, real staging and production are distinct levels. Staging
uses fresh credentials and synthetic data only. Production JWT equality, production
schema state, production mobile/device behavior and rollback rehearsal are
**未実施**. No new Consumer P50/P95/P99 benchmark is claimed.

See [deployment evidence](deployment-report.md), [release assessment](release-assessment.md)
and the allowlisted [evidence directory](evidence/).
