# Native performance snapshot

The introduction uses a fresh measurement of `a7605ba` on an Apple M2 with
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
