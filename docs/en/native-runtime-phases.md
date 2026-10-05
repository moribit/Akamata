# Native runtime Phases 2–5

Baseline: main 946f021, installed Zig 0.17.0 stdlib. Threaded stays default;
production reactor selection remains subject to evidence.

## Phase 2: write and shutdown contract

write_timeout_ms is an absolute response budget from first socket output,
including stream producer pauses. Partial writes, EAGAIN, flush and small client
reads never renew it. Handler execution before first output is excluded. Zero
permits no output. WebSocket handshake and each frame have separate budgets;
inter-frame idle time is excluded. Existing read semantics are retained.

The bounded writer uses the existing 4KiB transport buffer plus borrowed caller
slices, MSG_DONTWAIT/NOSIGNAL, preserved partial offsets, and POLL.OUT on EAGAIN.
Waits are at most 100ms between cancellation/deadline checks. No outgoing queue
is introduced. HTTP serializes directly without a second full wire copy.
Response.body remains an application buffer, not a runtime pending queue.

The registry also monitors write expiry when producers stop calling write.
Threaded control loops wake every 100ms; scans are throttled to 20Hz. Scheduling
delay is not a real-time guarantee. Registry locking serializes shutdown with
owner close and deadline clearing, preventing shutdown of reused descriptors.
Force drain shuts down sockets rather than closing them; owners still close.

shutdown_drain_timeout_ms defaults to 30 seconds from the first shutdown request.
Repeated signals never renew it. Admissions stop, connections drain, expired
grace shuts down I/O, then owners finish and are joined. Shorter write deadlines
remain active during drain. Idle connections still close promptly.

Guarantee boundary: socket I/O is interrupted within budget/control-loop bounds.
CPU-bound handlers, arbitrary blocking syscalls and third-party libraries are
not safely preempted. They must cooperate. App/Io/arena lifetimes remain owned
until handlers finish; process exit is not bounded for uncooperative handlers.
Upgraded Conn must remain in the handler scope and be deinitialized there.
Its borrowed request arena and runtime control must not escape that scope.

The common contract adds slow-reader progress, paused producers, slow-writer
drain, partial-request drain, upgraded read/write, disconnect during drain,
repeated signals and handlers that outlive grace. It never asserts CPU preemption.

```sh
zig build test integration tasks-test transport-contract-test runtime-poc-test -Doptimize=ReleaseSafe
zig build transport-contract-build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseSafe
zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe
```

macOS Threaded/kqueue pass 54 socket tests; Group passes 27 plus lifecycle units.
ReleaseSafe unit/integration/tasks, Workers chat and Linux fixture cross-build
pass. Linux execution is required in the final CI, not inferred from cross-build.
[Phase 2 raw benchmark](../../benchmark/results/runtime-phase2-2026-10-05/README.md):
median throughput changes −0.5% / −0.4% / +4.1% for hello/echo/db; no major broad
regression. The report retains P50/P99/RSS and the hello P99 variation.
