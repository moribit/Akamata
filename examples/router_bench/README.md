# Router benchmark fixture

This is a route-matching measurement, **not a new application router** or a
user-facing application example. Learn the existing typed endpoint graph via
[guestbook](../guestbook/README.md) and the [learning path](../README.md).

```sh
zig build router-bench -Doptimize=ReleaseFast
```

Run from the repository root. [run_matrix.sh](run_matrix.sh) records matcher
comparisons; [comptime benchmarks](../../docs/en/comptime-benchmarks-2026-08-17.md)
explains the measured shapes. Paths stay stable for historical scripts/evidence.
Do not infer end-to-end HTTP throughput from isolated matcher numbers.
