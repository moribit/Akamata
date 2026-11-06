# Release-candidate final assessment

候補: **v0.2.1**, source **`2714af09fb6c910581a8397c0cb69ebe6a4eccda`**.
候補CIとTSanは完了。正式リリースの承認判断に提示可能。本番反映は別ゲートであり、いずれの公開操作も未実施。

## Decision scope

The candidate is frozen after two release-validation fixes: Storage metadata
lifetime (`0ea0c17`) and unsupported deploy-option rejection (`2714af0`). Subsequent
migration documentation/test-runner commits do not change this fixed release target.
Threaded remains production default; Reactor remains parked/fail-closed.

Status vocabulary: 成功 / 失敗 / 未実施 / 環境制約により未確認.

| Gate | Result | Evidence |
|---|---|---|
| Starting 720464d CI | 成功, 23/23 | run 42166466775 |
| Storage fix 0ea0c17 CI | 成功, 23/23 | run 42168484632 |
| Storage fix Linux/macOS TSan | 成功, 2/2 | run 42168586988 |
| Final candidate CI | 成功: 23/23 jobs | [run 42169950892](https://github.com/moribit/Akamata/actions/runs/42169950892) |
| Final candidate Linux/macOS TSan | 成功: 2/2 jobs | [run 42170078817](https://github.com/moribit/Akamata/actions/runs/42170078817) |
| Local ReleaseSafe unit/docs/Pool | 成功: 92/92 steps; last rerun executes 128 tests, others cached | exact library tree 0ea0c17 |
| Storage cleanup regression | 成功: 28/28 direct module tests | old two-line implementation fails poison-on-close test; corrected implementation passes |
| Workers application/docs contracts | 成功: 8/8 steps, 10 simulated-provider runs | same library/runtime source as candidate |
| Consumer ReleaseSafe matrix | 成功: 12/12 commands | tests/default/Workers per app with local --fork; mimoc_news default is a launcher |
| CLI operations and update/sync | 成功: 30/30 steps, plus new unsupported-option guard smoke | no real deployment during mocked CLI tests |
| Final actual staging artifact dry-run | 成功: four resource-bearing targets plus resource-free Yaku | explicit Wrangler dry-run, not unsupported CLI flag |
| Final live acceptance | 成功: four commands exit 0 | isolated Cloudflare D1/R2/DO, fresh test secrets, synthetic data |
| Production validation/deployment | 未実施, intentionally gated | baseline contains rollback versions |
| New Consumer latency/performance benchmark | 未実施 | no performance improvement/regression claim from functional tests |

## Why the historical 169-success / one-skip run skipped

`tests/jwt_test.zig`: optional OpenSSL RSA-SHA256 signing test returns
`SkipZigTest` when `rs256.signPem` reports `UnsupportedOnTarget`. The default build
does not enable `-Dopenssl=true`. This was not a skipped HS256/JWT authentication
suite or a failing test hidden as success. The separate `native-openssl` CI job
runs `zig build test -Dopenssl=true -Doptimize=ReleaseSafe`; it passed on 0ea0c17.
Final candidate CI also passes that job. Cached local reruns do not reproduce
the same executed-test count; do not add cached counts to invent a new total.

## v0.2.0 change classification

| Area | Classification | Consequence |
|---|---|---|
| App/Context, handler routing, middleware, Capability/Provider | compatible retained interfaces | four Consumers compile with local substitution |
| DB Pool | additive reliability API/lifecycle behavior | monotonic deadlines, tryAcquire, explicit close; preserve lease ownership and shutdown ordering |
| SQLite | compatible safety fix | finalize handle on wrapper OOM; no accepted speculative statement-allocation optimization |
| HTTP parser/response/Threaded | correctness and measured behavior changes | buffered tails, owned shutdown wake, Storage header ownership; deadlines/admission unchanged |
| Observability | additive opt-in metrics | fixed-cardinality labels; disabled production hot paths retain opt-in semantics |
| OpenAPI/TS client | generated-source compatibility impact | strict enum/void-union schemas and corrected identifiers; regenerate/type-check callers |
| Storage/R2 | correctness plus metadata lifetime preservation | no Store signature change in this release comparison; HEAD and buffered response headers request-owned |
| Auth/JWT/Realtime | existing core APIs retained | Consumer-specific secret/migration/sender-exclusion fixes are separate app commits |
| Workers bridge | Fetch bodyless-response correction | review managed diffs; preserve custom image proxy, gateway and upload limits |
| CLI/scaffold/sync/deploy | compatible safety fixes; invalid usage now rejected | matching CLI/template versions; unknown flags fail before side effects; scaffold bootstrap remains previous stable |
| Reactor/sharded research | experimental, not released as production | public gate unchanged |

## SemVer recommendation

Recommend **v0.2.1**, not a retag of v0.2.0. The retained production changes are
compatible reliability/correctness improvements and additive controls, with no
removed App/Context/DB/Store/handler API. A v0.3.0 would be appropriate for deliberate
API removals or a broader application-model release; no such redesign is included.
The documented 0.x SemVer flexibility does not erase generated TypeScript impacts:
strict enum literals, closed void union objects and corrected operation identifiers
must be called out. A prerelease remains the alternative if mandatory candidate
CI/TSan or a major Consumer regression fails. Package and CLI already identify
0.2.1; do not fabricate the unpublished tag/hash or change the previous bootstrap pin.

## Breaking/compatibility considerations

- Regenerated TypeScript callers may require narrowing and corrected operation
  names. Valid JSON wire schemas remain the source of truth.
- Invalid/unsupported deploy flags, especially `--dry-run`, now fail with UsageError.
  They never promised a safe preview and previously could reach real deployment.
- Ehagaki app fix requires an explicit non-placeholder JWT secret; previously
  misconfigured startup silently used a development fallback. Workers request-time
  migration becomes explicit opt-in. These are app configuration changes.
- Native Mo-Bus client-originated frames now exclude the sender, matching Workers.
  REST-originated notifications retain broadcast behavior. This app-specific
  observable correction requires release notes for clients that depended on echo.

## Remaining approval gates and limitations

No formal tag or Release, production deployment, production DB migration, SQLite-to-D1
switch or production resource deletion is authorized. All Consumer dependency
pins remain unchanged until an approved immutable tag exists. App fixes are still
isolated, committed and locally bundled; original working trees are untouched.
Production Secret presence does not prove equality, production schema readiness
or a completed DB cutover rehearsal. Those facts remain unverified; in particular,
Mo-Bus DB cutover is not certified by this staging migration.

See [draft release notes](release-notes-v0.2.1.md), [migration guide](migration-guide.md),
[compatibility matrix](compatibility-matrix.md), [deployment report](deployment-report.md)
and [CI evidence](evidence/candidate-ci.json). All listed candidate gates have passed. The proposed tag target is v0.2.1 at 2714af0; formal tag/Release and each production rollout still require explicit approval.

## Per-application production gate, separate from framework release

| App | Staging contract | What still precedes production approval |
|---|---|---|
| Yaku | 成功 | approved release pin/hash, reviewed sync, exact final app SHA and rollback command |
| mimoc_news | 成功 | same pin; preserve custom glue; confirm existing production schema/secret names without applying migration; acknowledge host buffering limitation |
| Ehagaki | 成功 | promote secret-required/migration-opt-in app commits; keep actual existing signing key; verify production configuration and rollback |
| mobus-backend | 成功 | promote sender-exclusion app/test commits; verify production provider topology; do not combine with unapproved SQLite-to-D1 cutover; device/cutover readiness remains separate |

The prerequisite dependency pin cannot be finalized before the immutable release tag exists. These pending production actions are intentionally not reported as completed validation. No production command is included as an implicit approval.
