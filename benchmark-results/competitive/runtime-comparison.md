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
