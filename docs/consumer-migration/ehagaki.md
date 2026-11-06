# Ehagaki migration checkpoint

## Verified

Baseline/candidate Native tests/build and Workers build pass. Actual WASM host simulation passes with Node JSPI enabled, including authentication, ownership, expiry and migration retry. Simulation does not prove production secret interoperability.

## Remaining gates

Missing-secret fallback must fail closed before production; first-request migration policy requires explicit review. Preserve existing posts; do not run production migration. Existing Mo-Bus JWT compatibility and staging HTTP remain unverified.

## Version and rollback

Original source/dependency and deployed code references are in [baseline](baseline.md). Original checkout and dependency hashes are unchanged. No release pin or deployment has been performed. [Compatibility matrix](compatibility-matrix.md) distinguishes compile evidence from live-provider evidence.

## Isolated security fix

Local isolated commit `8ba1655` removes the missing-secret fallback and rejects empty/development-placeholder values. Existing valid JWTs retain the same HS256 verification path. ReleaseSafe tests: 23/23; Workers build: pass; actual WASM JSPI simulated-D1 scenario: pass. Reproduce using `/Users/mimoc/.nvm/versions/node/v24.19.0/bin/node --experimental-wasm-jspi tests/worker_smoke.mjs`; PATH can select a different Node binary in this environment. This commit has not been promoted to the original Consumer or production. Migration policy remains unresolved.
