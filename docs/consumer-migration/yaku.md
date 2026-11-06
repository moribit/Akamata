# Yaku migration checkpoint

## Verified

Stateless Typed HTTP baseline and local candidate tests/builds pass. Existing production smoke verifies catalog 38, quiz generation/grading and answer privacy, glossary 49, OpenAPI/client and the 4 KiB limit. Keep the app-owned pre-buffer body limiter. Git-SHA dependency is not accepted by tagged-only sync; do not rewrite the dependency before release approval.

## Remaining gates

Mobile E2E, candidate isolated Preview, static asset verification and formal release pin remain pending.

## Version and rollback

Original source/dependency and deployed code references are in [baseline](baseline.md). Original checkout and dependency hashes are unchanged. No release pin or deployment has been performed. [Compatibility matrix](compatibility-matrix.md) distinguishes compile evidence from live-provider evidence.

## Live isolated staging

Dedicated Worker `yaku-akamata-migration-20261106`, version `398395c8-e63d-42d2-b17a-d19979a7733f`: HTTP smoke passes. Browser E2E passes 36/36 across mobile Chromium, mobile WebKit, Android Chromium and desktop Chromium (57.2 seconds). This exercises real staging HTTP and application-served static assets. Browser launch requires sandbox execution permission; the initial restricted run could not launch browsers and was interrupted, then rerun successfully. Original source and production Worker remain unchanged.
