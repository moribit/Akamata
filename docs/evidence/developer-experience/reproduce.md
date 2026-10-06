# Developer experience regression evidence

Baseline: 6744595. Candidate runtime/application source: d125906.
Later changes add TypeScript static checking, regression evidence and documentation;
production runtime/application dispatch is unchanged from that measured candidate.

Zig 0.17.0, macOS loopback, ReleaseFast, 32 keep-alive connections, three rounds
of three seconds per endpoint. No builds or local tests ran alongside these saved
measurements. Raw JSON records UTC timestamp, platform, commands, binary SHA-256,
complete oha output and sampled RSS. This is a short workstation regression check,
not a controlled performance certification. An initial baseline attempt lost its
raw output because the output directory was absent; it is not included in the
comparison. The runner now creates that directory before measuring.

| Workload | Before req/s | After req/s | Difference | P50 ms before → after | P99 ms before → after |
|---|---:|---:|---:|---:|---:|
| hello | 164,212 | 165,494 | +0.8% | 0.166 → 0.162 | 0.726 → 0.755 |
| echo | 163,877 | 164,296 | +0.3% | 0.158 → 0.158 | 0.806 → 0.808 |
| db | 86,609 | 87,980 | +1.6% | 0.236 → 0.225 | 2.554 → 2.604 |

All saved rounds had no client errors. Mean RSS before/after: hello 7,356/7,264 KiB,
echo 7,363/7,383 KiB, db 7,615/7,650 KiB. These differences do not demonstrate a
performance improvement or a significant Threaded regression.

```sh
# In an independent clean 6744595 checkout:
zig build -Dexample=bench -Doptimize=ReleaseFast
# Retain that binary separately, then build the candidate:
zig build -Dexample=bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_compare.py BASELINE_BINARY docs/evidence/developer-experience/threaded-before.json --rounds 3 --duration 3s
python3 tools/bench/runtime_compare.py zig-out/bin/bench docs/evidence/developer-experience/threaded-after.json --rounds 3 --duration 3s
```

Application/regression commands:

```sh
zig build test documentation-test -Doptimize=ReleaseSafe
zig build documentation-test -Dbackend=workers -Doptimize=ReleaseSafe
zig build compile-fail-test cli-capabilities-test cli-operations-test project-update-test workers-capability-sync-test workers-realtime-test workers-wasm-dispatch-test -Doptimize=ReleaseSafe
zig build scaffold-test scaffold-local-test -Doptimize=ReleaseSafe
zig build integration tasks-test transport-contract-test runtime-contract-unit runtime-isolation-test runtime-session-test runtime-stress-test -Doptimize=ReleaseSafe
npm install --prefix /tmp/akamata-dx-ts typescript@5.9.3 --ignore-scripts --no-audit --no-fund
AKAMATA_DX_TSC=/tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js zig build documentation-test -Dbackend=workers -Doptimize=ReleaseSafe
```

Cloudflare host simulation is offline evidence, not live production certification.
No Cloudflare resources were provisioned or live credentials used. The runtime
suite evaluates retained private research adapters; Reactor remains fail-closed.
