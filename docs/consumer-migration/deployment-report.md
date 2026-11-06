# Deployment status

No tag, GitHub Release, staging deployment, production deployment, migration or service switch has been performed in this investigation. Existing production versions and rollback references are recorded in [baseline](baseline.md). Worker rollback does not roll back database schema.

## Gates still open

1. Freeze the candidate after CLI regression verification and complete release CI.
2. Finish isolated staging E2E, binding/secret-name validation and rollback rehearsals.
3. Present a concrete release assessment for explicit tag/Release approval.
4. Pin all Consumers to the approved immutable tag/hash and review managed sync diffs.
5. Obtain separate production approval, then deploy sequentially: Yaku, mimoc_news, Ehagaki, mobus-backend.

No production JWT values were fetched. Presence of a secret name does not prove equality, valid configuration, or cross-application JWT compatibility. No production database cutover is authorized.
