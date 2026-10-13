# Competitive performance fixtures

This directory is benchmark infrastructure, not an application tutorial or a
new production runtime. Native fixtures share HTTP/1.1 bodies, Content-Type,
payload limit and keep-alive policy. Dedicated runtime entrypoints cannot enable
Reactor through public App.serve. Dependencies here are benchmark-only.

Build: `COMPETITIVE_ZIG=/path/to/zig-0.17.0 python3 benchmark/competitive/scripts/build.py`.
zap has an upstream-compatible compiler/SDK recipe in its README. Pin all
transitive Rust/JS dependencies with the included lockfiles. Hono host checks:
`npm ci --prefix benchmark/competitive/workers && npm test --prefix benchmark/competitive/workers`.

Freeze binaries before making runtime changes:

```sh
python3 benchmark/competitive/scripts/snapshot.py benchmark/competitive/fixtures/native.json .zig-cache/competitive/baseline --output benchmark-results/competitive/raw/baseline-manifest.json
python3 benchmark/competitive/scripts/measure.py benchmark-results/competitive/raw/baseline-manifest.json --output benchmark-results/competitive/raw/native-baseline.json
```

The architecture baseline and every future command/result live in
[`benchmark-results/competitive`](../../benchmark-results/competitive/architecture-baseline.md).
Results without matching workload semantics are not ranked together. A short
development smoke measurement must never be relabeled as the required five
30-second rounds with ten-second warmup.

Before interpreting local throughput as a server ceiling, calibrate the load
generator at the same **total** connection count:

```sh
python3 benchmark/competitive/scripts/calibrate.py benchmark-results/competitive/raw/baseline-manifest.json --output benchmark-results/competitive/raw/generator-calibration-32.json
python3 benchmark/competitive/scripts/summarize.py benchmark-results/competitive/raw/native-baseline.json
python3 benchmark/competitive/scripts/test_reporting.py
```

Calibration retains each generator's distribution; it does not average latency
percentiles. A frozen executable's source revision and digest identify the code
being measured. Resume checks those identities and records harness revisions
separately, allowing documentation/profiling work between checkpointed runs.
