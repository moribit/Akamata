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

Private multi-loop research uses `COMPETITIVE_RUNTIME=reactor-sharded` with the
competitive Akamata executable: four loops, eight **total** application workers.
`reactor` uses one loop and the same eight workers. Neither can be selected by
production `App.serve`. Re-run `zig build transport-contract-test runtime-stress-test
runtime-isolation-test` before interpreting a candidate's performance.

The offline JSON/parser/matcher fixture builds with `zig build competitive-micro-build
-Doptimize=ReleaseFast`; run `./zig-out/bin/competitive-micro` only after builds
finish. It reports five rounds, checks JSON byte equivalence, and does not claim
network throughput or include prepared App indices/middleware in matcher timings.

To keep the full serial matrix independent of an interactive terminal:

```sh
# First freeze the final after executables and verify their manifest.
python3 benchmark/competitive/scripts/run_initiative.py --launch --after-manifest benchmark-results/competitive/raw/after-manifest.json
```

The supervisor checkpoints its state in `.zig-cache/competitive/supervisor/status.json`
and logs to `supervisor.log`. It resumes the frozen baseline first, then measures
the frozen after manifest, using the requested 10/30-second, five-round defaults.
It never builds or runs tests, retries a failed case silently, publishes a release,
or changes production runtime selection. **Do not run local builds/tests/other
load while it runs.** Inspect the child PID before starting another measurement.
