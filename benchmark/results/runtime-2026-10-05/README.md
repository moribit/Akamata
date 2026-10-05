# Native HTTP runtime measurements, 2026-10-05

Apple M2, macOS arm64, Zig 0.17.0, ReleaseFast, oha 1.15.0.
All clients target loopback, 32 connections, three 5-second rounds per endpoint.
Observability and BENCH_RUNTIME are unset. SQLite is in-memory with the existing
bench handlers. The script warms /db/1 for 1,000 requests before sampling.

- before.json: production bench from main 3f92014, preserved before editing.
- after.json: final shared-protocol Threaded binary.
- group.json: isolated Io.Group experiment using the same handlers and database.
- after-variable.json: exploratory earlier binary, with a large late-round drop.
- after-repeat.json: repeated earlier binary, before tightening read slices to
  the configured wire-buffer ceiling. These two runs do not supply the final table.

Each JSON includes timestamp, platform, binary SHA-256, oha version, full command,
raw latency percentiles/status/error distributions, mean and peak sampled RSS.
RSS is sampled every 100ms using ps. Binary hashes distinguish builds; explicit
runtime-group-bench does not install the default bench binary.

The tables in [the runtime report](../../../docs/en/runtime-transport.md) use
medians across the three final rounds. Successful throughput is HTTP 200 count
divided by summary.total, since oha requestsPerSec includes failed attempts.
The server is stopped with SIGTERM and must exit within 15 seconds; the script
refuses an occupied port and never terminates an unrelated process.

Local variability prevents precise small-regression claims. The final main
throughput medians stay within 2% of baseline; Group's SQLite throughput is
about 9% lower than current Threaded. Neither result justifies reactor enabling
or production adoption of the PoC. More details and limitations are in the report.
