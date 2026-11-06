# Ehagaki migration checkpoint

## Verified

Baseline/candidate Native tests/build and Workers build pass. Actual WASM host simulation passes with Node JSPI enabled, including authentication, ownership, expiry and migration retry. Simulation does not prove production secret interoperability.

## Remaining gates

Missing-secret fallback must fail closed before production; first-request migration policy requires explicit review. Preserve existing posts; do not run production migration. Existing Mo-Bus JWT compatibility and staging HTTP remain unverified.

## Version and rollback

Original source/dependency and deployed code references are in [baseline](baseline.md). Original checkout and dependency hashes are unchanged. No release pin or deployment has been performed. [Compatibility matrix](compatibility-matrix.md) distinguishes compile evidence from live-provider evidence.
