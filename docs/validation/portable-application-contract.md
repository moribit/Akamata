# Portable Application Contract validation

Baseline: `e4919f0`. Implementation commits: `d30838d` (capability/services),
`8010100` (named D1), `53a527a` (R2 abort/conditional errors), `8834829`
(CLI/reference application/shared contracts). Local environment:
macOS 27.0 arm64, Zig 0.17.0, Node v24.19.0. Framework/private bridge changes
are tested separately from live Cloudflare behavior.

| Command | Local result | Evidence scope |
|---|---|---|
| `zig build test -j4` | pass | Existing Native suites + new application/provider fixture; default OpenSSL-disabled JWT case remains skipped |
| `zig build test -Doptimize=ReleaseSafe -j4` | pass | Native ReleaseSafe, same shared fixture |
| `zig build portable-application-test -Dbackend=workers -Doptimize=ReleaseSafe -j4` | pass | Ten shared WASM fixture iterations, stable pages after warmup; actual Zig D1/R2/Queue adapters with injected host bindings |
| `node tests/d1_binding_bridge.mjs` | pass | Actual managed/template bridge source, named/default D1, async statements, metadata, missing binding, handle cleanup |
| `node tests/workers_provider_bridge_test.mjs` | pass | Actual managed/template R2/Queue bridge source, bounded write abort, conditional failure, delivery metadata |
| `bash tests/compile_fail.sh` | 20 cases pass | Existing diagnostics plus missing provider/unsupported provider/binding mismatch/undeclared route/missing State facade |
| `zig build cli-capabilities-test -j4` | pass | Resolution, binding drift/comments, invalid manifests/routes, check integration, old-project fail-fast, no config mutation |
| `zig build cli-operations-test -j4` | pass | Existing deploy/D1 failure safety, build, dev restart/shutdown, containers |
| `zig build scaffold-local-test -j4` | pass | Generated app against checkout, Native/Workers, ReleaseSmall/ReleaseSafe, migration double-apply protection |
| `zig build scaffold-test -j4` | pass | Generated app against existing stable dependency; feature guards preserve compatibility |
| `zig build project-update-test workers-capability-sync-test -j4` | pass | Existing update/sync/managed-file protection, selected resource combinations |
| `zig build -Dexample=guestbook -j4` | pass | Shared reference application, Native metadata command before DB initialization |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe -j4` | pass | Same domain handlers and contract on Workers |
| `node --test tests/workers_wasm_dispatch_test.mjs tests/workers_realtime_test.mjs` | 6/6 pass | Existing serialized JSPI request ownership, private DO handlers, explicit broadcast, malformed/oversized/version handling |

The initially added malformed JSON assertion expected 400 without an error
policy. Existing App defaults unhandled decoding errors to 500. The fixture
now explicitly registers `onError` for decoding failures; Native and Workers
both return 400 without DB/queue effects. The framework default remains unchanged.

Application tests use an explicit DB effect recorder and Native in-memory
realtime provider on both targets; these are not live D1/DO parity evidence.
Adapter tests execute actual Zig adapter code; test host bindings model the
documented host behavior. The JS bridge tests execute actual source with fake
resources and an identity JSPI wrapper, so they validate resource selection
and async results rather than engine suspension itself. Existing JSPI ownership
tests cover suspension separately. No resources/accounts were deployed.

R2 failing Reader cleanup is checked from WASM: Reader closes, put abort removes
the host handle, and repeated adapter runs leave no handles/objects. R2 list
uses an operation arena because existing list metadata ownership is not yet
uniform across adapters. Contract tests deliberately do not claim pagination
cursor parity or host memory leak-freedom from a WASM page plateau.

CI remains in `.github/workflows/ci.yml`: Native/ReleaseSafe/OpenSSL, Linux/macOS
runtime contracts, examples, package/container/fuzz, existing CLI protections,
plus the new Workers application contract and CLI capability/compile-fail
steps. Actual CI conclusions should be read from the run for the final Git SHA,
not inferred from these local results.
