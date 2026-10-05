# Phase 2 write/drain regression check

Before is the preserved 946f021 bench binary (SHA-256 matches the preceding
runtime report). After uses the Phase 2 bounded writer, ownership registry and
direct HTTP serialization. No allocator instrumentation is enabled.

Apple M2 / macOS arm64, Zig 0.17.0 ReleaseFast, oha 1.15.0; 32 connections,
three 5-second rounds per endpoint, /db/1 warmup, no concurrent builds.
Raw JSON retains binary hashes, commands, percentiles, errors and RSS means/peaks.
Summary values are medians; throughput counts successful HTTP 200 responses.

| Endpoint | Before rps / P50 µs / P99 µs / RSS MiB | After |
|---|---|---|
| hello | 165,782 / 167.7 / 678.5 / 6.36 | 164,941 / 165.7 / 737.8 / 6.38 |
| echo | 165,054 / 159.5 / 810.9 / 6.38 | 164,463 / 154.8 / 839.2 / 6.49 |
| db | 84,436 / 235.2 / 2,755.8 / 6.53 | 87,875 / 231.8 / 2,483.9 / 6.73 |

Throughput changes: −0.5%, −0.4%, +4.1%. No major broad regression is observed.
hello P99 increases 8.7%; these local rounds do not establish a smaller latency
claim. RSS changes are within 0.2 MiB. Further matrix/stress measurement follows.

```sh
zig build -Dexample=bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_compare.py /tmp/akamata-phase2-before /tmp/akamata-phase2-before.json
python3 tools/bench/runtime_compare.py zig-out/bin/bench /tmp/akamata-phase2-after.json
```

Preserve the executable before building the changed checkout; copy its executable
mode too. The runner refuses an occupied port and only terminates its own child.
