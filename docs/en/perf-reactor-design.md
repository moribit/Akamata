# Reactor design: private multiplexed evaluation

`App.serve(.runtime = .reactor)` and both direct `serve` entrypoints remain
fail-closed. Threaded is the production default.

```text
App.dispatch
    ↑
Shared HTTP: Session + connection dispatch/serialization
    ↑
Static Transport boundary
    ├─ Threaded: synchronous driver, bounded socket writer
    └─ private Reactor: one event loop + bounded handler workers
           ├─ kqueue (macOS/BSD)
           └─ epoll (Linux)
```

The private `evaluate` path now multiplexes nonblocking connection sockets;
it no longer creates a readiness adapter and thread for each connection.
Input, pending output, deadlines, generation and lifecycle are event-loop owned.
Standard OS ABI definitions, level-triggered readiness, generation tokens,
bounded producer output and an indexed deadline heap keep resource ownership
explicit. Application HTTP semantics live only in shared Session/connection.

The same 33 socket Contract cases exercise Threaded and the host Reactor.
Write budgets and forced drain are implemented. Reactor requires owned incremental
stream/frame sessions; synchronous stream/upgrade is explicitly unsupported.
Idle and slow sessions do not occupy workers. Contract and isolation success
still do not certify production readiness; long cross-platform evidence is required.

```sh
zig build transport-contract-test runtime-poc-test -Doptimize=ReleaseSafe
zig build runtime-reactor-bench -Doptimize=ReleaseFast
```

See [current phase report](native-reactor-phases6-9.md) for architecture, budget
semantics, Group decision, platform results and production gate evidence.
[Transport Contract](runtime-transport.md) and historical benchmarks should be distinguished from
current measurements; historical data cannot certify the current Reactor production gate.

Current certification and release decision: [Phases 6–9 report](native-reactor-phases6-9.md).
