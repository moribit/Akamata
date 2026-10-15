# Reproducible competitive methodology

Baseline main `8a521fb`; Phase 0 record `e04dbeb`. Fixture commits and actual
binary SHA are saved separately: rebuilding a private fixture is not a measured
optimization. Zig 0.17.0 for Akamata; other pinned versions are in
`benchmark/competitive/fixtures/toolchains.json` and Cargo/package lockfiles.

## Same workload, separate meanings

HTTP/1.1, exact body bytes, explicit Content-Type, persistent connections, same
oha version, Release builds, one server at a time on TCP loopback port 8088.
Plaintext is 13 bytes; JSON is serialized from a normal value, not a prerecorded
JSON response shortcut. Echo returns raw 64/1,024/65,536-byte payloads unchanged.
Routing extracts two numeric parameters. zap has no equivalent generic parameter
router in this release: its manually extracted route is separately classified.
Headers automatically inserted by different servers must be retained in the
wire verification record; identical body bytes do not imply identical wire cost.

SQLite 3.53.1 is compiled from the repository amalgamation with the same flags.
Eight independent in-memory databases contain the same three rows. MEMORY journal,
synchronous OFF and temp_store MEMORY. Prepare/bind/step/finalize per request,
no cached statements. Akamata uses its real Pool/Db facade; Rust/Go/zap use a small
benchmark-only C owner returning a copied typed row; each framework uses its
own ordinary JSON serializer rather than a cached DB response string. This makes engine configuration comparable, not provider
implementation identical. Pool timeout/saturation is a separate diagnostic and
must not be described as HTTP DB throughput. D1 is a separate Workers comparison.

## Primary matrix

Connections 1, 8, 32, 128, 512, 1024; warmup 10 s, measurement 30 s, 5 rounds.
All rounds and errors are retained; use medians, not the best round. The runner
shuffles framework order reproducibly inside each workload/connection/round,
starts a fresh server, verifies all workloads and checkpoints each result.
Warmup output is retained but excluded from measurement medians. It has bounded
load-tool drain and only terminates its own child process. OS limits are recorded
and excessive concurrency is refused. Framework admission ceilings/defaults are
not identical; only below-limit normal workloads are ranked, and any errors
remain in the reported rates. Short smoke runs are explicitly exploratory.

Record req/s, P50/P95/P99/P99.9, process CPU (one core=100%), sampled RSS,
threads, every status/error, transfer bytes and load generator resource samples.
oha totalData describes application payload bytes, not TCP/IP overhead. Latency
is closed-loop and conditional on completed requests; retain timeouts/rejections
alongside percentiles. Process ps CPU resolution limits short-run attribution.
oha's `requestsPerSec` includes failed client attempts. Report expected HTTP 200
completions/second separately from that attempt rate, with client failures and
non-200 responses retained. Aggregate error percentage includes both; warmup is
not part of measurement medians or error rates.
Thread count sampling excludes invisible child processes, so verify single-process
fixtures; otherwise aggregate children or exclude the result.

No builds/tests/downloads run during primary load. Workstation background activity
cannot be fully controlled; record it as a limitation. macOS does not offer the
same CPU affinity controls as Linux. Instrumented counters and wall-stack samples
are diagnostic only; sample's wall stacks are not CPU percentages. Generator CPU
and split-generator calibration must be reviewed before claiming a server ceiling.
Without generator headroom or a remote generator, report a local lower bound.

## Reproduction

```sh
COMPETITIVE_ZIG=/path/to/zig-0.17.0 python3 benchmark/competitive/scripts/build.py
# Build zap separately with its documented upstream-compatible compiler.
python3 benchmark/competitive/scripts/measure.py benchmark/competitive/fixtures/native.json --output benchmark-results/competitive/raw/native-baseline.json
```

The full matrix is deliberately long (hours). Never relabel reduced duration or
fewer rounds as completing it. A resumed run rejects changed binary digests and
per-binary source SHA, and records harness revisions separately. Live Workers runs are opt-in on isolated resources; host simulation
never proves Cloudflare CPU time, cold-start performance or production superiority.

## Pinned zap spill files

The pinned unmodified facil.io path leaves named request-body files in macOS
`/var/tmp`. [The investigation](zap-tempfile-cleanup.md) records this behavior.
The harness removes only verified benchmark payload files after each zap process
has exited, outside measured intervals. File creation/write/close remain measured;
the competitor binary and its spill threshold are unchanged. Per-case cleanup
counts and bytes are recorded. Nine pre-correction large-echo cases are preserved
as excluded raw evidence and rerun, rather than mixing filesystem cleanup policies
or deleting unfavorable results. A low disk reserve still stops admission.
