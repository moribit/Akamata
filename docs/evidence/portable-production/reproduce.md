# Portable Production Contract evidence

Baseline source: fc8e00e9bb358453a92b13e9c506742c435dda6f.
Candidate application/runtime source: d959c94d8a597cb80be86e736766b7662d50861f.
Later follow-up changes add regression tests, benchmark probe reuse and documentation only.

Zig 0.17.0, macOS loopback, ReleaseFast, 32 connections, keep-alive, three rounds of three seconds per workload. Raw JSON includes platform, timestamp, binary SHA-256, oha version, each command, RSS samples and complete oha output. This short workstation comparison is a regression check, not a controlled performance certification. Builds/tests were not deliberately run alongside candidate measurements. Baseline first run began near the completion of the separate reference build; repeat runs were added to check ordering/environment drift.

```sh
# Build baseline from a clean fc8e00e checkout and retain its binary separately.
zig build -Dexample=bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_compare.py BASELINE_BINARY threaded-before.json --rounds 3 --duration 3s
# Build candidate in the current checkout.
zig build -Dexample=bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_compare.py zig-out/bin/bench threaded-after.json --rounds 3 --duration 3s
# Repeat in the same order; raw files retain both batches.
```

Local regression commands:

```sh
zig build test integration tasks-test -Doptimize=ReleaseSafe
zig build portable-application-test -Dbackend=workers -Doptimize=ReleaseSafe
zig build cli-capabilities-test cli-operations-test -Doptimize=ReleaseSafe
zig build scaffold-local-test project-update-test workers-capability-sync-test compile-fail-test
zig build transport-contract-test runtime-contract-unit runtime-isolation-test runtime-session-test runtime-stress-test -Doptimize=ReleaseSafe
zig build -Dexample=device_messaging -Doptimize=ReleaseSafe
zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe
node --test tests/workers_realtime_test.mjs
node --check tests/cloudflare_live.mjs
# Intentionally fails with exit 2 before any network operation:
env -u AKAMATA_LIVE_RESOURCE_MANIFEST -u AKAMATA_LIVE_ISOLATED node tests/cloudflare_live.mjs
```

Native integration includes the actual SQLite/filesystem/jobs reference. Worker tests are WASM host simulation and actual managed JS tested with injected bindings, not live Cloudflare. The live workflow was not dispatched: isolated test resources and credentials were not supplied. CI provides Linux epoll/Container verification; the separately dispatched runtime-sanitizer workflow provides Linux/macOS TSan. These runs evaluate retained research runtime contracts without enabling Reactor production.

The retained runtime stress/isolation/session JSON was recorded during implementation at source 9505e0b with a dirty working tree, as its own metadata states. It is not relabeled as a clean final checkout. Runtime/Shared HTTP files are unchanged from fc8e00e; clean cross-platform CI/TSan runs provide separately identified commit evidence.
