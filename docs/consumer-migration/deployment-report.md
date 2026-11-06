# Deployment status

No tag, GitHub Release, production deployment, migration or service switch has been performed in this investigation. A dedicated resource-free Yaku staging Worker has been deployed. Existing production versions and rollback references are recorded in [baseline](baseline.md). Worker rollback does not roll back database schema.

## Gates still open

1. Freeze the candidate after CLI regression verification and complete release CI.
2. Finish isolated staging E2E, binding/secret-name validation and rollback rehearsals.
3. Present a concrete release assessment for explicit tag/Release approval.
4. Pin all Consumers to the approved immutable tag/hash and review managed sync diffs.
5. Obtain separate production approval, then deploy sequentially: Yaku, mimoc_news, Ehagaki, mobus-backend.

No production JWT values were fetched. Presence of a secret name does not prove equality, valid configuration, or cross-application JWT compatibility. No production database cutover is authorized.

## Yaku isolated staging

- URL: https://yaku-akamata-migration-20261106.mimoc-maker.workers.dev
- Version: `398395c8-e63d-42d2-b17a-d19979a7733f`.
- No DB, bucket, service binding or secrets; production Worker name unchanged.
- Source app baseline `f1f809f`, candidate runtime built with local `--fork` at `280c534`; subsequent candidate `38e5036` changes CLI/docs only, not the deployed runtime.
- Wrangler 4.120.0 dry-run and deploy succeeded. Stateless real HTTP suite passes: all quiz difficulties/privacy/grading, validation/body limit, OpenAPI/client, hand analysis and glossary 49.
- Browser E2E passed 36/36 across mobile Chromium/WebKit, Android and desktop Chromium.
- Staging is retained for verification; deletion is not automatic. No production rollback is required because production was untouched.
