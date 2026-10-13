# Akamata fixture

`zig build competitive-bench -Doptimize=ReleaseFast` produces
`zig-out/bin/competitive-akamata`. Source: `src/competitive_bench.zig`, in the
private root so it can reuse existing internal runtime modules without public API.
Ordinary typed handlers and the production Shared HTTP path are exercised.
`COMPETITIVE_RUNTIME=reactor` selects only this executable's private evaluator.
It does not enable `.runtime=.reactor` in public App.serve.

Uses the Release smp allocator. Optional `BENCH_STATS=1` and `-Druntime-cost=true`
are separate instrumentation builds/runs, never ranked with normal throughput.
Eight SQLite handles, one prepare/bind/step/finalize per request. Unlimited
practical keep-alive request count, 60-second idle, 1 MiB body, loopback port 8088.
