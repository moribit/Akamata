# Reactor design: shared protocol before multiplexing

`.runtime = .reactor` returns `error.ExperimentalRuntimeDisabled`. Both direct
reactor module entrypoints also fail before opening a socket. Threaded remains
production. Safety parity, rather than throughput, determines when this changes.

## Current structure

`serve.zig` selects backend; `runtime/threaded.zig` manages listener, admission
and connection workers. `http/connection.zig` owns HTTP parsing, request lifetime,
App dispatch, serialization, keep-alive, streaming, upgrade and read budgets.
`runtime/socket_transport.zig` provides a static transport seam with existing
std.Io Reader/Writer interfaces. Poll, kqueue and epoll provide readiness.

The old per-core prototypes had duplicated HTTP loops, hardcoded receive buffers,
unbounded EAGAIN send loops and incomplete limits/deadlines/peer-IP/upgrade support.
Their unsafe HTTP/worker loops were removed. The replacement kernel adapters use
standard target ABI types, including Linux's packed epoll_event.

Private `evaluate` paths run the same HTTP driver through the established
thread-per-connection lifecycle with kqueue/epoll readiness. These tests establish
socket-adapter compatibility; they do **not** establish multiplexed-reactor parity.
The public worker_count option remains reserved while the reactor is disabled.

## Evaluation

```sh
zig build transport-contract-test -Doptimize=ReleaseSafe
zig build runtime-poc-test -Doptimize=ReleaseSafe
```

The same 20 black-box socket tests run on Threaded and the host kernel adapter.
Group experiments are separate. Limits, framing, deadlines, keep-alive/pipelining,
streaming, upgrade read-ahead/ownership, connection admission, backpressure
isolation, peer/proxy policy, disconnects and shutdown are covered.

## Required before production

- Nonblocking read/write with bounded output queues and partial-write state;
  never spin on EAGAIN.
- Multiplexed connection lifecycles using an Io task backend or an incremental
  shared-protocol driver, without copying HTTP semantics into a reactor.
- Explicit streaming and upgrade task/buffer/socket ownership and cancellation.
- Deadline and queue admission parity, kernel wakeup and graceful/forced drain
  policies, including slow readers and long-running handlers.
- The full Contract after multiplexing, on Linux and macOS, plus stress,
  disconnect/fault injection and resource leak checks.
- Representative idle/burst/stream/upgrade latency and RSS measurements.

Zig 0.17 Io.Group is a promising separate lifecycle experiment, not a replacement
already selected by App.serve. async may run inline; connections require
concurrent. Existing production write_timeout_ms remains reserved, so current
backpressure isolation tests do not claim bounded write or forced drain deadlines.

See [runtime/transport report](runtime-transport.md) for the audited workarounds,
Contract guarantees, PoC and before/after benchmark. Historical May/August
measurements remain in [benchmarks](benchmarks.md); they describe older prototypes
and cannot enable the current gate or justify recommending reactors in production.
