# Runtime investigation — work in progress

Production remains **Threaded**. Public Reactor remains fail-closed. The private
competitive executable can evaluate the existing multiplexed runtime; that is
not a new runtime implementation or production certification.

## Baseline evidence

Source `023b101`, frozen binary identities in [manifest](raw/baseline-manifest.json).
The first [32-connection plaintext comparison](framework-comparison.md) uses
the requested 10-second warmup / 30-second measurement / five-round conditions.
Threaded median: 89,479 req/s, P99 0.569 ms, 40 sampled threads.
Existing Reactor: 71,292 req/s, P99 0.903 ms, nine sampled threads.
The roughly 20% throughput difference in this subset exceeds the proposed 5%
candidate gate. It is not a final workload or high-concurrency conclusion.

The load generator uses several cores on this local host. [Calibration](generator-calibration.md) completed: splitting at the same total
32 connections did not improve throughput. This does not prove unlimited
generator headroom or a controlled server ceiling. No multi-loop candidate
has been measured yet. No optimization has been accepted from this table.

## Attribution design

`-Druntime-cost=true` is a separate instrumented build; ordinary benchmark
binaries retain disabled probes. Existing inclusive wall/thread-CPU spans cover
read, parse, dispatch, serialization, send, selectors, worker admission and
completion. Additional spans cover accept readiness wait, thread spawn, peer IP
formatting and write-deadline clearing. Nested spans must not be summed.

Diagnostic counters distinguish observed admission-limit rejection, thread-spawn
failure, hard/resource accept failures, transport read timeout, write budget
expiration, EAGAIN/readiness waiting, EPIPE and ECONNRESET. They do not change
existing public metric meanings or runtime decisions.

Counters describe their actual call sites:

- `read_timeout` counts transport operations, not necessarily failed requests.
- `write_timeout` counts budget expiration observed by the writer; watchdog
  shutdown can instead surface as EPIPE/reset. Those are separate observations,
  not an inferred root cause.
- `poll_call` counts raw read/write readiness calls, excluding the standard
  accept-poll wrapper's internal EINTR retries. `accept_wait` counts wrapper
  invocations. Exact whole-process syscall counts require an OS tracer.
- `readvec_call` is a std.Io reader operation, not a guaranteed one-to-one recv
  syscall count. macOS syscall/context-switch totals remain unknown until traced.

Instrumentation incurs clocks and shared atomics. Instrumented throughput is
not used as the normal-run performance comparison. macOS `sample` supplies wall
stack samples; it must not be labeled CPU percentage.

## Pending investigation

1. Generator calibration, then request matrix on the frozen baseline binaries.
2. 32/128/512/1024 idle resources and retained-connection/shutdown checks.
3. Instrumented 32/1024 read/write/admission attribution and normal wall samples.
4. Reproduce the historical echo P99 change with its original allocator,
   keep-alive renewal and admission ceiling distinguished from this fixture.
5. Select and verify a private multiplexed candidate only after attribution.

The new fixture's real eight-connection DB pool and practically unlimited
keep-alive are different from the previous shared-DB/100-requests fixture.
Historical absolute rates cannot be treated as this experiment's before values.

## Diagnostic observations (not certification)

The [instrumented request attribution](runtime-attribution.md) covers plaintext,
JSON and 1 KiB echo at 32/1024 connections, 2-second warmup and 5-second measured
load, one round. All 12 child processes exited cleanly and framework allocator
live bytes returned to zero. This excludes SQLite/libc/kernel/stack allocation.

At plaintext c32, Reactor publishes one application task per request, with about
one selector add and delete, but only 0.04 notification writes per request:
empty-to-nonempty batching already works. Inclusive completion wait is about
246 us/request; queue wait is about 9 us/request. At c1024, completion wait grows
to about 1233 us/request. These diagnostic waits are not exclusive CPU costs or
percentages explaining the normal throughput gap. The instrumented event loop
uses about 85% of one core; instrumentation itself adds overhead.

Threaded deadline clearing averages two calls per request: inclusive wall time
about 6 us/request at c32 and 41 us/request at c1024. The registry lock is a
candidate for further study, not permission to remove timeout/close coordination.

**Connection errors occurred at c1024 and remain unresolved.** Threaded reports
31/44/38 client errors for plaintext/JSON/echo respectively; its observed limit
rejection, spawn-failure, accept-resource and transport-timeout counters were zero.
Reactor reports 1822/861/1142 errors, including reset/cancel/write errors. These
remain in the raw results. Short instrumented burst behavior cannot be classified
as a production regression or attributed to listen backlog without more proof.

By contrast, the [sequential idle diagnostic](raw/idle-diagnostic-before.json)
established and retained every connection, verified another request on each and
shut down with clients still connected:

| Connections | Threaded RSS KiB | Reactor RSS KiB | Threaded CPU % | Reactor CPU % | Threaded shutdown ms | Reactor shutdown ms |
|---:|---:|---:|---:|---:|---:|---:|
| 32 | 7,696 | 5,328 | 0.8 | below resolution | 129 | 4 |
| 128 | 18,800 | 7,824 | 2.6 | below resolution | 130 | 4 |
| 512 | 62,960 | 17,824 | 14.3 | below resolution | 131 | 4 |
| 1024 | 121,952 | 31,120 | 39.0 | below resolution | 127 | 8 |

Five seconds, one round: diagnostic only. CPU uses coarse ps process time,
one core=100%; zero measured delta does not mean no CPU consumption. These
measurements establish a scalability tradeoff, not full candidate gate passage.

[macOS wall profiles](raw/profile-threaded/profile-metadata.json) and
[Reactor profiles](raw/profile-reactor/profile-metadata.json) retain binary hashes
and sampling commands. Wall stacks must not be reported as CPU percentages.
[Disabled-probe codegen check](raw/disabled-probe-codegen.json) finds the normal
ReleaseFast executable's Mach-O `__TEXT,__text` equal to the frozen baseline after
the diagnostics change; enabled error classification is explicitly comptime-gated.
This check is narrower than whole-artifact or performance equivalence.

Validation so far: ReleaseSafe instrumented runtime units (68 tests), ReleaseFast
instrumented runtime units, normal ReleaseSafe shared Transport Contract on the
three macOS adapters, and four offline reporting checks. Linux/TSan and full
post-optimization regression have not yet been run for this initiative.
