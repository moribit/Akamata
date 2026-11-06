# Yaku migration checkpoint

## Verified

Stateless Typed HTTP baseline and local candidate tests/builds pass. Existing production smoke verifies catalog 38, quiz generation/grading and answer privacy, glossary 49, OpenAPI/client and the 4 KiB limit. Keep the app-owned pre-buffer body limiter. Git-SHA dependency is not accepted by tagged-only sync; do not rewrite the dependency before release approval.

## Remaining gates

Mobile E2E, candidate isolated Preview, static asset verification and formal release pin remain pending.

## Version and rollback

Original source/dependency and deployed code references are in [baseline](baseline.md). Original checkout and dependency hashes are unchanged. No release pin or deployment has been performed. [Compatibility matrix](compatibility-matrix.md) distinguishes compile evidence from live-provider evidence.
