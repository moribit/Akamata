# v0.2.1 Performance & Reliability evidence

Baseline source: `f0eb0b63b1eb5885542c1fc43d35c7e284b7db64` (origin/main).
Zig 0.17.0. Production Native remains Threaded; Reactor remains parked/fail-closed.

Existing framework already has absolute read/write budgets, forced I/O drain,
connection admission, shared HTTP session/cursor, retained arenas, opt-in cost
and allocation instrumentation, portable providers, typed error mapping and
schema-aware API diff. This phase extends those mechanisms rather than replacing them.

Measurement uses the existing HTTP fixture and `tools/bench/runtime_matrix.py`.
Before binaries are copied to `.zig-cache/v021/before` before implementation.
Uninstrumented 3-round runs and allocation-instrumented runs are separate.
Raw oha JSON retains status/error distributions and P50/P95/P99. CPU is process
CPU-time delta / measurement wall time; RSS is sampled; allocation counts exclude
SQLite/libc allocation and OS thread stacks. Historical M2 numbers are context,
not a directly comparable before measurement.

Commands and binary SHA are retained in each result. No live Cloudflare claim.

## Implementation and design record

| Phase | Existing mechanism reused | Change / decision |
|---|---|---|
| 0 | Threaded HTTP fixture, oha matrix, retained arenas, private cost counters | Paired baseline and separate logical/backing allocation attribution |
| 1 | Db / Lease and existing Prometheus Counters | std.Io Mutex / timed Condition; absolute .awake deadlines; tryAcquire, close; cooperative deinit; ownership-on-success; stale release defense |
| 2 | Existing admission, read/write budgets and drain registry | Active/idle/rejected/thread/lifetime/drain metrics; close the accepted fd on transport initialization failure |
| 3 | Shared HTTP Session / Reader / Response / Cursor | Fix buffered readVec tails blocking before dispatch; preserve owned bodies and retained arenas; no speculative allocation optimization |
| 4 | Metrics middleware, DB spans, Server-Timing | Optional borrowed App / ServeOptions Counters, six fixed HTTP phase labels; inclusive wall timings are not a CPU breakdown |
| 5 | Provider and WASM host contracts | Reuse SQLite/D1/Turso, FS/R2 and Queue fixtures; document streaming/retry/cancellation differences; Workers synchronous streaming remains fail-closed |
| 6 | Typed Endpoint, OpenAPI, TS generator, testing.Client | Preserve enum literals and ordinary tagged-union JSON; shared defaults/null/enum/array/nested/union fixture on Native and Workers; real mapped-error contract |
| 7 | Runtime Contract, stress/fault, TSan, living examples | Saturation/race/allocation diagnostics; paired 32/128/512/1024, metrics on/off, large JSON, fixed-rate short-lived and tail repeats |
| 8 | Existing docs and release process | English/Japanese guides, draft notes and 0.2.1 package/CLI version; stable scaffold still pins v0.2.0; no tag/release publication |

Core files include `src/db/pool.zig`, `src/runtime/threaded.zig`,
`src/runtime/socket_transport.zig`, `src/http/connection.zig`, `src/app.zig`,
`src/context.zig`, `src/http/response.zig`, `src/mw/metrics.zig`,
`src/contract/handler.zig`, `src/openapi.zig` and `src/client_gen.zig`.
No new dependency, runtime, global provider locator or production Reactor path.

## Same-environment comparison

Apple M2 / Mac14,2, 8 cores, 16 GiB, macOS 27.0 build 26A428, Zig 0.17.0,
ReleaseFast, fixture DebugAllocator, oha 1.15.0, TCP loopback. Three rounds ×
3 seconds, medians of all rounds. Fresh server per case, before/after order
alternated; eight acceptors and the existing 100-request connection limit.
No local builds/tests overlapped final runs. Workstation background activity is
not controlled. These figures are not a capacity or performance certification.

| 32 connections | Before | After | Difference |
|---|---:|---:|---:|
| /hello HTTP 200/s | 97,696 | 97,658 | −0.04% |
| /echo HTTP 200/s | 97,689 | 96,947 | −0.76% |
| /db/1 HTTP 200/s | 82,249 | 81,991 | −0.31% |
| /hello P99 ms | 0.730 | 0.761 | +0.031 ms |
| /echo P99 ms | 0.834 | 0.711 | −0.123 ms |
| /db/1 P99 ms | 2.887 | 2.857 | −0.030 ms |
| /hello mean sampled RSS KiB | 6,689 | 6,844 | +155 KiB |
| /echo mean sampled RSS KiB | 6,773 | 6,756 | −17 KiB |
| /db/1 mean sampled RSS KiB | 7,316 | 7,283 | −33 KiB |
| /hello backing rawAlloc calls / HTTP 200 | 0.02022 | 0.02019 | effectively unchanged |
| /echo backing rawAlloc calls / HTTP 200 | 0.02018 | 0.02021 | effectively unchanged |
| /db/1 backing rawAlloc calls / HTTP 200 | 1.02024 | 1.02023 | effectively unchanged |

[All connections, P50/P95/P99, CPU and RSS](comparison.md),
[machine-readable medians](summary.json), [environment](environment.json) and
[raw final rounds](final-paired.json). The raw allocation ratios include startup
and connection renewal; they are not logical arena allocation counts. SQLite /
libc allocation and OS stacks are outside the wrapper. CPU is process CPU time
delta / sample wall time, not an attribution to individual HTTP phases.

Small JSON is the echo DTO with one-character `name`. For a 65,536-character
name, before runs completed only 98–123 requests and each had 32 client timeouts;
after runs completed 73,581–74,927 HTTP 200 responses with no errors. Median
successful rate is about 24,854/s after the buffered-read fix. The before rate
is stalled and must not be treated as an ordinary throughput comparison. Tail
latencies in that failed run describe only its few successful responses.
[All large-JSON rounds](paired-large-json.json) are retained, including failures.

The initial runner used indefinite oha request waits and stalled on this bug.
It now has an explicit 10-second client timeout, a duration+60-second runner
drain bound and file-backed stdout/stderr capture. File capture also prevents
pipe-capacity deadlock; the socket bug was separately reproduced and fixed.

## Concurrency, admission and memory

| Idle connections | Before RSS KiB | After RSS KiB | Threads (both) | After CPU % | After shutdown ms |
|---:|---:|---:|---:|---:|---:|
| 32 | 6,704 | 6,720 | 40 | 0.0 | 125 |
| 128 | 17,040 | 17,040 | 136 | 2.9 | 131 |
| 512 | 58,176 | 58,192 | 520 | 10.6 | 126 |
| 1024 | 113,072 | 113,056 | 1032 | 32.9 | 128 |

RSS slope is approximately 107 KiB per extra idle connection, including process
heap and resident thread storage; it is not a framework-only heap budget or
virtual stack reservation. Idle measurements are single lifecycle samples, not
three-round medians. The existing bounded readiness slice wakes idle threads;
32.9% is about 0.33 core, not 33% of all eight cores. No reactor transition or
deadline relaxation was used to reduce it.

The server's default admission limit is **1024**. Tests at 1024 clients therefore
exercise the boundary, including connection renewal every 100 requests.
Longer/high-observability runs have small generic connection errors on both
binaries, and DB runs also register server rejection. These are retained and are
not described as zero-error capacity certification. Rejection totals combine
capacity and thread-spawn failure; this investigation does not infer a reason
for every generic client error from the combined counter.

With metrics enabled at the boundary, after DB rounds report 815/2610/1556
rejections and transport success rates 98.4%/95.1%/97.2%. At 1000 clients the
three after rounds record **zero rejections**, but generic/reset/write errors
remain (median success 99.83%, before 99.91%). Headroom DB medians are
16,878→16,687 HTTP 200/s and P99 183.570→185.378 ms. This separates observable
server rejection from the remaining transport errors; it does not prove the
remaining errors are harmless, client-side, or a particular OS limit.

The 10-second /db repeat at 512 connections gives 28,251 → 27,973 HTTP 200/s
(−0.99%) and P99 83.103 → 83.350 ms. The large variation between individual
shared-SQLite-handle rounds means the earlier short-run throughput drop was not
confirmed. This DB fixture does **not** use the new Pool; it measures serialized
SQLite contention and scheduling, not pooled query throughput.

The 1024-client 10-second repeat gives /hello P99 31.913 → 33.071 ms and /echo
28.834 → 37.758 ms, despite approximately unchanged throughput and CPU/request.
The echo tail difference remains unexplained and is a limitation of the final
evidence. Do not claim P99 parity or a general speedup at the admission boundary.
No speculative scheduler/allocator change was made to conceal it. See
[tail repeat](tail-repeat.json), [high-observability load](paired-high-observability.json)
and [capacity headroom diagnostic](capacity-headroom.json).

Short-lived cases use a fixed **500 requests/s** at configured concurrency
budgets 32/128/512/1024, avoiding unsafe source-port/thread churn. Actual active
threads are much fewer than that budget. These are latency/reliability samples,
not short-lived saturation throughput measurements. [Raw data](paired-short-lived.json).

## Observability and allocation decisions

At 32 connections, after metrics disabled/enabled medians are approximately
97,658/96,736 (/hello), 96,947/96,839 (/echo), 81,991/80,803 (/db) HTTP 200/s.
The richer instrumentation has measurable CPU cost; it is opt-in and is not
advertised as free. Phase timestamps are inclusive wall time; read includes
idle readiness, handler includes binding/JSON, serialize measures Response.json,
HTTP header encoding is in buffered write. Existing optional runtime cost
instrumentation remains available for separate CPU/header diagnostics.

The high-concurrency metrics snapshot also retains error rates and rejection
counts rather than filtering them out. Current counters do not have request-path
mutexes; atomics and clock reads can still contend. Metrics allocation ratios
are effectively unchanged at about 0.0202 calls/HTTP 200 for hello/echo and 1.0202
for db. A shared owner aggregates measurements; use an explicit owner that
outlives the runtime. No user IDs or parameterized paths are metric labels.

[Metrics allocation rounds](paired-metrics-allocations.json) separate allocation
tracking from the uninstrumented on/off timing comparison. New counters use
atomics, not new request-path locks, and the phase label has exactly six values.
[Phase/lifecycle counters](paired-observability.json) include final active/idle
gauges; instrumentation does not introduce an unbounded request queue.

The logical allocator diagnostic records parse 1 allocation (896 bytes), header 1
(160), owned static body 1 (150), JSON header/body 2 (291); prepared empty route
and passthrough middleware each 0. Fixed cursor/write makes 0 backing calls;
1,000 warm JSON iterations make 0 additional backing calls after retain-capacity.
[Raw attribution](allocation-phases.txt). This is a small fixture, not an
allocation-free claim for all API paths: /db still has roughly one backend
statement-owner allocation per successful query.

Borrowed response buffers, self-referential inline buffers, global pools and
large JSON preallocation were **not implemented**. The observed warm heap cost
does not justify added ownership/maintenance complexity; no measured candidate
was implemented then silently retained despite being ineffective. There is no
reverted performance prototype to report. The buffered-read change is a proven
correctness fix, not an ownership-weakening copy optimization.

## Pool saturation and shutdown

[Three diagnostic rounds](pool-saturation.json): four handles, sixteen workers,
3,200 attempts/round, absolute 2 ms acquisition deadline, 1 ms lease hold. All
rounds end with active=0 and waiters=0 and pass DebugAllocator cleanup. This is
after-only reliability evidence; before has no equivalent timed API. OS scheduling
and mutex reacquisition can exceed 2 ms wall time; deadline eligibility does not
promise hard real-time wakeup. No query cancellation or exactly-once guarantee.

Tests cover immediate acquisition, exhaustion, timeout, return wakeup, concurrent
exclusive lending, close wakeup, close/release/timeout races, stale double release,
deinit waiting for borrowers and allocation-failure ownership. Twenty standalone
race repetitions run eight workers with up to 1,000 attempts each and early close.
Stop new calls before deinit; join concurrent close/snapshot callers separately.
The Pool joins acquisitions and leases, not arbitrary external owner operations.

## Regression / evidence levels

[Local validation manifest](tests.json) records counts, omissions and historical failures.


- Native Debug / ReleaseSafe / ReleaseFast tests and Workers WASM fixtures were
  run; final ReleaseSafe retry passed after clearing exhausted build cache.
- Shared socket Contract: **102 tests passed**, including large keep-alive bodies,
  stream/upgrade, timeout, forced drain, handler cooperation and admission.
- Local stress/fault: **16 scenarios passed**, allocator live=0 in every scenario,
  created/closed incremental sessions balanced. Native accept-fd-exhaustion CPU
  sample was 0%; drain remains bounded for I/O. [Raw stress/fault](stress-fault.json).
- Compile-fail diagnostics: **33 cases passed**. Living examples: **52 commands
  passed**, including Debug/ReleaseSafe, Native/Workers and strict generated TS.
- Optional OpenSSL JWT test is skipped in a non-OpenSSL build; OpenSSL CI covers it.
- Linux/macOS CI and TSan run IDs/status are saved in `ci.json`. Earlier failures
  included external translate-c DNS failure and a startup/admission test race.
  The test now waits for admitted responses and verifies overflow with an actual
  request, without weakening the server limit or sleeping a guessed duration.
- No live Cloudflare/Turso credentialed service test was run. Unit/adapter contract
  and WASM simulation do not imply production-observed certification. Existing
  examples exercise application effects; no new dogfooding performance fixture
  claims to represent an unavailable production deployment.

Historical/intermediate files are retained for audit: `paired.json` overlapped
earlier builds/tests; `*-pre-read-fix.json` describes the intermediate candidate.
Use `final-paired.json` and the supplementary final datasets for conclusions.

## Reproduction

```sh
zig build -Dexample=bench -Doptimize=ReleaseFast
# Copy the baseline fixture before applying these commits; keep its SHA.
python3 tools/bench/v021_validation.py /path/to/before zig-out/bin/bench
python3 tools/bench/v021_summary.py
zig build http-allocation-profile -Doptimize=ReleaseSafe
zig build db-pool-profile -Doptimize=ReleaseFast
zig build test db-pool-test documentation-test portable-application-test -Doptimize=ReleaseSafe
zig build transport-contract-test runtime-contract-unit runtime-stress-test -Doptimize=ReleaseSafe
zig build portable-application-test documentation-test -Dbackend=workers -Doptimize=ReleaseSafe
zig build db-pool-test transport-contract-test runtime-isolation-test runtime-session-test -Druntime-tsan=true -Doptimize=ReleaseSafe
```

Requires oha, an unused port 8080 and enough fd/thread resources. The runner owns
only its own processes and raises its local fd soft limit to at most 2048. Do not
run builds, other benchmarks or tests alongside it. Every command, binary digest,
status/error distribution and round is saved. The final benchmark __TEXT sections (including machine code and constants) match
the measured `f5c4b6b` fixture byte-for-byte. The full binary changed after a
client-schema source update; see [section digests](binary-equivalence.json).
Subsequent changes do not alter the measured HTTP runtime.

Next priorities: profile saturated Threaded tail latency, separate rejection
reasons if needed, quantify idle wakeup cost without weakening cancellation,
then design an explicit asynchronous Workers producer/abort ownership contract.
Keep Threaded production, Reactor parked, and live validation an isolated opt-in.
