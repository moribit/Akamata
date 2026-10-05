# Phase 6 application execution baseline (incomplete)

Baseline main: `75fcb26`. This records foundations and an unmet gate, not completion of Phases 6–9.

Environment: macOS-27.0-arm64-arm-64bit-Mach-O; Zig 0.17.0. Binary SHA-256: `cb0c72026c827ea9c41649e79284d2a906ee18d4bc7f038fbc4d5b8a168b93cc`.

| Adapter | Scenario | HTTP isolation / admission | HTTP probe ms | Shutdown ms | Final allocator live bytes |
|---|---|---|---:|---:|---:|
| threaded | four-idle-upgrades | true | 0.259 | 180.168 | 0 |
| threaded | four-slow-streams | true | 0.137 | 179.582 | 0 |
| threaded | mixed-upgrade-stream | true | 0.223 | 183.878 | 0 |
| threaded | application-queue-overflow-recovery | true | 0.000 | 126.242 | 0 |
| kqueue | four-idle-upgrades | false | 250.788 | 177.033 | 0 |
| kqueue | four-slow-streams | false | 251.102 | 176.501 | 0 |
| kqueue | mixed-upgrade-stream | false | 251.111 | 182.448 | 0 |
| kqueue | application-queue-overflow-recovery | true | 0.000 | 1.312 | 0 |

The fixture has four Reactor workers. The admission scenario separately uses one worker and a one-task pending queue. Small receive windows and held clients force synchronous producer backpressure. The HTTP gate is 250 ms, not a throughput benchmark. Zero allocator live bytes describes only the instrumented framework allocator, not all libc/OS resources. No long soak, Linux performance or production certification is claimed.

The existing 29-case-per-adapter Threaded/kqueue Contract and ReleaseSafe full/unit tests pass locally. The strict `runtime-isolation-test` deliberately exits 1 while isolation fails. Evaluation mode writes failure evidence without treating it as readiness.

```sh
zig build runtime-isolation-evaluate -Doptimize=ReleaseSafe
zig build runtime-isolation-test -Doptimize=ReleaseSafe # currently fails isolation
zig build test runtime-contract-unit transport-contract-test -Doptimize=ReleaseSafe
zig build -Dbackend=workers -Dexample=chat -Doptimize=ReleaseSafe
```

Raw JSON includes the exact command and binary SHA. Linux/macOS CI runs `runtime-isolation-evaluate` and uploads its JSON beside runtime stress results. CI success in record-blockers mode is not an isolation pass.

Design and ownership boundaries: [Japanese](../../../docs/ja/reactor-application-execution.md), [English](../../../docs/en/reactor-application-execution.md).

Production gate remains **Not Ready**. Before Phase 7, implement session-owned incremental frame/producer steps, bounded readiness/task admission, and explicit synchronous API support policy; then require isolation/fairness alongside the preserved protocol Contract.
