# Evidence boundaries

Candidate: 2714af09fb6c910581a8397c0cb69ebe6a4eccda. Snapshot files contain only
allowlisted CI outcomes, app/binary identities and synthetic staging contracts.
No secret values, JWTs, credentials, user records or database dumps are included.
Detailed local build/browser/raw-provider logs remain ignored scratch.

- candidate-ci.json: exact candidate, all 23 CI and both Linux/macOS TSan jobs.
- candidate.json: all 12 Consumer --fork test/build commands at library source
  0ea0c17; library/build source identical in final candidate 2714af0.
- final-staging-deployments.json: actual version IDs and WASM SHA-256 values for
  news, Ehagaki, application handler and gateway. Yaku version is in deployment-report.
- final-live.json: sequential final actual-provider command exits; individual
  news/Ehagaki/Mo-Bus files give tested contract boundaries.
- final-cli.json: matching CLI binary hash, reviewed sync protection outcomes and
  unsupported dry-run rejection. Real artifact dry-run uses Wrangler explicitly.
- news-baseline/candidate.json: equal status, Content-Type and top-level DTO keys
  for the tested cases. news-final adds an image-retaining text-only edit test.
- news-log-evidence.json: one public request structured-log correlation, not an
  aggregate authenticated-write operation census.
- storage-header-before-fix.txt: controlled old-two-line implementation fails
  deterministic poison-on-close regression; fixed direct suite passes 28/28.
- baseline/candidate-mobus-e2e-isolation.json: old app sender-exclusion failure and
  corrected application pass, with clean server exits.
- original-checkouts-after.json: original sources/untracked state retained.
- staging-resources.json: only dedicated empty test-resource inventory.

Tools in tools/consumer-migration are explicit manual runners, not normal CI
provisioners. They require the local isolated app checkouts, Zig 0.17.0, Node 24
with JSPI for the host fixture, Python, Wrangler 4.120.0, GitHub CLI and this
workspace RTK setup. Private app fixes are committed and locally bundled, not
embedded in this public repository. Do not copy production .env/.dev.vars files.

Re-run order after reviewing dedicated targets: validate_consumers.py --candidate;
validate_staging_artifacts.py (dry-run); optional --deploy-staging; final_live.py;
news_log_probe.py; cli_final.py; collect_evidence.py. prepare_staging.py and
staging_config.py create only the explicit dedicated inventory/test secrets and
must not be invoked as automatic production setup. Preserve the ignored inventory
between runs. See migration-guide.md before any approved release/pin/deployment.

## Approved publication and rollout

See [current operational report](../publication-and-rollout.md) and [publication snapshots](publication/). Earlier snapshots remain immutable historical evidence. Production snapshots include only versions, schema fingerprints, Secret names and synthetic-test summaries, never values or user data.
