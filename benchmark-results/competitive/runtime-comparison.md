# Runtime investigation and final decision

The full 1260/630-case matrix is complete. See [final report](final-report.md),
[final runtime table](runtime-after-table.md) and [decision evidence](decision-evidence.md).
Four-loop c32 plaintext remains 31.9% below final Threaded; c512 large-echo P99
is 366.327 versus 25.095 ms. High-concurrency small responses and memory improve,
but the adoption gates are not met. Public Reactor remains fail-closed.

The sections below retain the investigation's chronological snapshots and short
screens; their former pending lists do not describe current matrix completion.

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
generator headroom or a controlled server ceiling. This baseline table alone
does not justify production adoption.

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

The instrumentation-only revision passed the complete GitHub CI and manual
Linux/macOS TSan (`38413470788`). New runtime changes require their own rerun;
the earlier success is not evidence for untested changes.

## Idle shutdown notification candidate

[48 serial idle cases](raw/idle-candidate-screen.json): 10 seconds, three rounds
at each of 32/128/512/1024 connections. Every connection was retained, answered
another request and survived until explicit shutdown. No failed cases or forced
runner kills. CPU is process time, one core = 100%; very small deltas are coarse.

| Connections | Before CPU % | Notification CPU % | Before RSS KiB | Notification RSS KiB |
|---:|---:|---:|---:|---:|
| 32 | 0.80 | 0.20 | 7,696 | 7,776 |
| 128 | 2.79 | 0.30 | 18,784 | 18,832 |
| 512 | 13.77 | 0.70 | 62,960 | 63,040 |
| 1024 | 35.85 | 1.00 | 121,936 | 121,984 |

The two App-owned pipe descriptors replace only idle-read 100ms polling. The
byte is never consumed, so all current and future idle waiters see shutdown.
Admission stops before notification, sockets remain owned by their connection
thread, and the pipe remains alive until all detached owners drain. Active
request/cancel/read deadlines retain their original bounded waits. Io.Group
experiments do not receive the pipe and retain cancellation polling.

At 1024 connections shutdown median is 126 ms before versus 178 ms candidate;
waking many OS threads together adds a scheduling tradeoff. RSS/threads remain
approximately 119 MiB / 1032. This is an idle-CPU optimization, not a change to
Threaded's thread-per-connection memory model. Normal HTTP regression comparison
and two-platform post-change validation are separate gates.

## Private multi-loop candidate

`evaluateSharded` partitions a fixed worker budget across up to eight loops,
each owning its selector, generation tokens, bounded queues, deadline heap and
connections. Four loops in the competitive fixture share **eight total workers**;
the Contract fixture uses two loops and four total workers. The one-worker
admission scenario intentionally uses one loop, not an inflated worker budget.
Connection admission is global; an explicit pending-task limit is also global.
Default one-pending-task-per-connection bounds work without a per-request shared
counter. Cleanup tasks retain their reserved bounded queue. Streams/upgrades use
the same incremental sessions and retain explicit rejection of synchronous
application execution. There is no second HTTP implementation or Group scheduler.

The common listener can wake multiple selectors, and connection distribution is
not guaranteed even. Each loop has metadata capacity for the application's full
connection ceiling; this costs more fixed metadata, not an unbounded queue.
These are measured tradeoffs, not hidden assumptions about nonblocking handlers.

At 1024 idle connections: single loop 31,168 KiB / 9 threads; four loops 31,920
KiB / 12 threads. Four-loop CPU median 0.10%; single-loop delta is below coarse
resolution. Shutdown is about 126 ms versus 9 ms because all loops must observe
the process-wide stop. Full throughput/error/TSan criteria remain required.

Local initial validation passed 136 common Transport tests, 12 application
isolation/admission scenarios and 24 stress/fault scenarios, covering Threaded,
host single-loop and sharded paths. The first sharded Contract run correctly
returned 501 for sync stream/upgrade but the test classified the new adapter as
Threaded; its adapter classification was fixed and all 136 tests rerun.
Public `.runtime = .reactor` remains `ExperimentalRuntimeDisabled`.

## Rejected first notification implementation

[108 exploratory HTTP cases](raw/runtime-candidate-screen.json) use 2-second
warmup, 5-second measurement and three rounds. One offline reporting check ran
during this screen, so it is not a certification run; the large, repeated
regression below warrants rejection rather than selecting favorable rounds.

Always polling both the socket and shared pipe lowered plaintext HTTP 200/s
from 178,734 to 152,907 at c32 and from 167,399 to 34,210 at c1024. c1024 P99
increased 31.981 → 238.857 ms and CPU 313.1% → 641.1%; errors were retained.
JSON and echo reproduced the same pattern. The shared-poll implementation is
**not accepted** on the strength of its idle CPU result. Exact kernel lock cost
has not been isolated, and is not reported as a measured percentage.

A refinement first probes the socket alone for at most 100 ms, preserving the
hot-read path. Only a quiet connection enters the longer shared-notification
park. Its separate `idle-refined-screen.json` remains required evidence before
retaining the change; the full requested-duration after matrix is also required.

The four-loop research candidate improves c1024 plaintext P99 to 15.415 ms and
retains 160,033 HTTP 200/s in this screen, but c32 throughput is only 121,709
versus Threaded's 178,734. Thus its low-concurrency throughput fails the 5%
candidate threshold. Three rounds are not the required five longer rounds,
and Linux performance remains unmeasured. No production gate is relaxed.
