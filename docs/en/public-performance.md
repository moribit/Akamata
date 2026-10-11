# Native performance snapshot

The introduction retains the measurement of `a7605ba` on an Apple M2 with
16 GiB memory, macOS 27 arm64 and Zig 0.17.0. Threaded remains the Native
production default. No runtime optimization was part of this documentation work.

| Workload | HTTP 200 throughput, all-round mean |
|---|---:|
| GET /hello | 164,610 req/s |
| POST /echo | 163,790 req/s |
| GET /db/1 | 86,793 req/s |

ReleaseFast, 32 keep-alive connections, IPv4 loopback, oha 1.15.0, three rounds
of three seconds per workload. The SQLite path is warmed with 1,000 requests.
The echo payload is `{"name":"x","n":42}`. No builds or tests ran concurrently.
Every saved round is included, with no client errors. Each round rate is its
HTTP 200 count divided by actual measured duration; the table takes their
arithmetic mean. Slides round to the nearest thousand.

This is a short workstation snapshot, not a controlled performance certification,
a capacity promise or a comparison with other frameworks. Tail latency, database
contention, network topology and application work change the result.

[Raw oha output, RSS samples and binary SHA](../evidence/public-presentation/threaded-main.json)
and [commit, CPU, toolchain and commands](../evidence/public-presentation/environment.json)
are retained in the repository.

```sh
zig build -Dexample=bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_compare.py zig-out/bin/bench /tmp/threaded-main.json --rounds 3 --duration 3s
```

Requires oha and an unused local port 8080. The runner stops only its own server.
[Earlier DX regression evidence](../evidence/developer-experience/reproduce.md)
compares against `6744595`. Reactor is parked/fail-closed and is not a feature
or performance claim of this introduction.

## v0.2.1 paired reliability investigation

Compare saved `f0eb0b6` and final runtime fixture binaries, rather than the
historical presentation figures above. M2 / 16 GiB / macOS 27.0 / Zig 0.17.0,
ReleaseFast with DebugAllocator, oha 1.15.0, loopback, 32 keep-alive clients,
three 3-second rounds, **medians of every round**. This matrix starts a fresh server
per case and samples CPU/RSS/threads; the presentation runner's persistent/warmed
protocol differs. Do not attribute the absolute difference between snapshots to
the v0.2.1 changes.

| HTTP 200/s | Before | After | Difference |
|---|---:|---:|---:|
| /hello | 97,696 | 97,658 | −0.04% |
| /echo | 97,689 | 96,947 | −0.76% |
| /db/1 | 82,249 | 81,991 | −0.31% |

P99 is 0.730→0.761 ms, 0.834→0.711 ms and 2.887→2.857 ms respectively.
Backing allocation calls are approximately 0.020/request for hello/echo and
1.020/query for db, including startup/100-request connection renewal; retained
warm JSON adds no backing calls in the diagnostic fixture.

The concrete improvement is reliability: 64 KiB JSON keep-alive bodies could
stall in a buffered read; after the fix all load rounds complete without client
errors. No speculative borrowed-response or buffer-pool optimization is adopted.
Metrics are opt-in with measured overhead.

At the default 1024-connection boundary, long runs have errors and tail variation
on both binaries. Echo P99 remained worse in a 10-second paired repeat; its cause
is unresolved. This is not zero-error capacity certification or a P99-parity claim.

[Raw rounds, environment, binary SHA and commands](../../benchmark-results/v0.2.1/README.md)
cover 32/128/512/1024 clients, large JSON, metrics on/off, short-lived, Pool
saturation, shutdown and tail diagnostics. [Reliability guide](performance-reliability.md).
