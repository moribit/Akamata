# Competitive performance research

Akamata's Native production runtime remains **Threaded**. Multiplexed runtimes
are private research entrypoints; `.runtime = .reactor` still fails closed.
Workers application/HTTP contracts remain shared. No runtime is automatically
adopted because a benchmark improves.

The [competitive initiative](../../benchmark-results/competitive/architecture-baseline.md)
pins Actix Web, Axum, Go net/http, zap and Hono benchmark fixtures. Native runs
use identical HTTP/1.1 bodies, Content-Type, payload sizes, SQLite source/SQL and
keep-alive settings on one host, serially. Automatic headers/runtime designs
differ and are recorded. zap uses its upstream-compatible Zig toolchain, not an
unreleased Akamata API port.

Read the [methodology](../../benchmark-results/competitive/methodology.md) and
[generator calibration](../../benchmark-results/competitive/generator-calibration.md)
before interpreting rates. Report medians of all rounds and all errors. Local
loopback figures are neither a controlled performance certification nor proof
of unlimited load-generator headroom. Failed attempts are reported separately
from completed HTTP 200 responses.

## Targeted changes under validation

- Threaded idle connections can wait on one App-owned shutdown notification
  instead of waking every 100 ms. The [three-round idle experiment](../../benchmark-results/competitive/runtime-comparison.md)
  reduces CPU substantially at 1,024 idle clients while retaining the same
  thread count/RSS. Waking many threads together has a shutdown-latency tradeoff.
  Read/write deadlines and cooperative CPU-handler drain are unchanged.
- JSON numeric values write through the existing Writer. A [five-round micro
  experiment](../../benchmark-results/competitive/routing-json.md) improves the
  integer-array shape and fixes fixed-buffer traps at wide numeric boundaries.
  It does not imply the same improvement for HTTP JSON throughput.
- A private four-loop candidate partitions eight total workers and keeps
  connection/task admission global. It reuses Session, Cursor and incremental
  stream/frame ownership. Synchronous stream/upgrade execution remains explicitly
  unsupported in Reactor evaluation; Threaded retains it.

The full requested matrix and post-change cross-platform verification must be
completed before a final comparison/adoption claim. The [raw evidence](../../benchmark-results/competitive/raw/)
and [reproduction scripts](../../benchmark/competitive/README.md) distinguish
short screens, instrumentation, idle measurements and requested-duration runs.
Do not run builds/tests/other load during the serial matrix.

## Workers evidence

[Akamata WASM/Hono host checks](../../benchmark-results/competitive/workers-comparison.md)
verify response bytes and fake D1 adapter behavior. They do not measure live
Cloudflare CPU time, edge latency or cold starts. Dedicated live test resources
were not established; no live performance advantage or certification is claimed.
