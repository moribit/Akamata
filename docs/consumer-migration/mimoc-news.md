# mimoc_news migration checkpoint

## Verified

Baseline/candidate tests and Workers builds pass. Native build is a development launcher, not a Native HTTP server. Four host bridge tests pass. Custom unowned glue provides image proxy behavior and bounded uploads; force-sync would lose app behavior and is prohibited.

## Remaining gates

Actual local/staging D1 and R2 multipart lifecycle including 9 MiB uploads, Basic auth, Origin and observability remain pending. Production script performs migrations, so it must not be invoked without separate migration approval.

## Version and rollback

Original source/dependency and deployed code references are in [baseline](baseline.md). Original checkout and dependency hashes are unchanged. No release pin or deployment has been performed. [Compatibility matrix](compatibility-matrix.md) distinguishes compile evidence from live-provider evidence.
