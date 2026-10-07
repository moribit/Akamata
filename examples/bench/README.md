# HTTP benchmark fixture

This directory measures Native HTTP runtime / DB workloads and companion
language baselines. It is **not** a tutorial application or recommended service
ownership layout. Start application development at the
[learning path](../README.md).

```sh
zig build -Dexample=bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_compare.py zig-out/bin/bench /tmp/native-bench.json --rounds 3 --duration 3s
```

Run from the repository root. The loopback runner reserves port 8080, starts and
terminates only its own process, and records all rounds and binary SHA. Read
[public performance](../../docs/en/public-performance.md) for conditions and
[benchmark reference](../../docs/en/benchmarks.md) for comparison limits.

`router_bench` is a separate matcher fixture. Paths are retained because existing
CI, scripts and historical evidence reference them; physical relocation is
intentionally deferred. Native production remains Threaded. Private Reactor
research tools must not be copied as production application entrypoints.
