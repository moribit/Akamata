# mobus-backend migration checkpoint

## Verified

Baseline/candidate disposable Native E2E passes, including two-client calls/signals/text/end, firmware digest/size/range and crash upload. Eight gateway/dispatch tests pass. Historical Native delivery failure is not reproduced at the recorded baseline.

## Remaining gates

Native sender echo differs from Workers sender exclusion. Reconcile/test semantics before promotion. Dedicated staging D1/R2/DO and service bindings are required. Database cutover, backup/import rehearsal and real JWT sharing remain separate unresolved gates.

## Version and rollback

Original source/dependency and deployed code references are in [baseline](baseline.md). Original checkout and dependency hashes are unchanged. No release pin or deployment has been performed. [Compatibility matrix](compatibility-matrix.md) distinguishes compile evidence from live-provider evidence.
