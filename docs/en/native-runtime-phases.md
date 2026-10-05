Historical record: this document describes Phases 2–5. See the [current Phases 6–9 report](native-reactor-phases6-9.md).

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

## Phase 3 decision: B — defer Group adoption

Both implementations now use eight acceptors. The paired matrix includes
4/32/128 connections, short-lived traffic, keep-alive, 64/256 idle connections,
P50/P95/P99, CPU/RSS/fd/thread/allocator observations, and separate task counters.
Untracked DB repeats show Group throughput −10.3% / −10.4% at 32/128 connections;
P99 increases 37.6% / 15.4%. Idle thread/RSS cost is essentially unchanged.
The production runtime remains Threaded; the Group PoC and common contract remain.

Group improves owned await/cancel and task cleanup. It still requires deliberate
signal, admission, deadline, socket ownership and error propagation policies;
cancel does not preempt application work. Threaded's registry now provides safe
forced socket drain and testable cleanup. No new public runtime API is needed.

Sampling identifies shared SQLite mutex contention and Group pool waits, but
does not isolate one cause for the additional regression. No optimization based
on that inference was applied. app.gpa counters exclude libc/SQLite/stacks;
untracked repeats avoid attributing instrumentation overhead to the runtime.
See [decision record, profiles and raw data](../../benchmark/results/runtime-phase3-2026-10-05/README.md).

## Phase 4: private true HTTP multiplexing

`http/session.zig` is the incremental input/parser/request lifetime state machine.
`http/connection.zig` shares dispatch, response framing, stream finalization,
keep-alive and upgrade semantics. Threaded drives Session synchronously; the
private Reactor owns Session in one event loop and calls the same dispatch on a
bounded fixed worker pool. No reactor-specific HTTP parser or serializer exists.

The selector uses standard target kqueue/epoll ABI definitions, level-triggered
nonblocking sockets, generation-tagged tokens, bounded wakeup notifications and
an indexed deadline heap (one timer per connection). Read work is capped at
64KiB per event and admissions at 64 per pass. Hard accept failures suspend
readiness with bounded backoff. Socket close and selector changes are serialized
with the ownership registry; queued stale tokens cannot reference freed memory.

Each connection has a 16KiB pending producer slot and existing 4KiB Writer buffer.
Partial sends preserve offsets; EAGAIN returns to readiness. A producer waits on
a condition rather than growing output or spinning. The write budget begins when
first output enters the Transport (before its first send), and never renews on
progress. Stream/upgrade flush waits for delivery to the kernel. Small normal
responses can release a worker with pending output; Session is retained until
that output drains, then pipelined input advances. Request input is not mutated
while a worker borrows it. Buffered upgrade bytes are copied before handoff.

Upgrade owns its borrowed socket in the handler scope. Its existing synchronous
read API uses nonblocking recv plus bounded poll and preserves frame fragments.
The event loop sends its output. This means long-lived upgrade handlers still
occupy workers; slow stream producers can do the same. This is a specific
production evaluation gap, not a claim of fully multiplexed application tasks.
Force drain interrupts sockets and bounded producer waits, but does not preempt
arbitrary CPU-bound application handlers.

MacOS Threaded and true kqueue pass the same 27 Contract cases. The Linux epoll
fixture cross-compiles and the same Contract now passes on Linux CI. The public
App and direct reactor serve gates remain disabled while Phase 5 evaluates
resource behavior, handler starvation and platform parity.

## Phase 5 decision: Reactor Not Ready

kqueue registers read/write filters separately; epoll combines IN/OUT/RDHUP
in one packed standard event. Both are level-triggered and use the same
generation token and shared HTTP/lifecycle state, not different parsers.

The final suite adds zero write budget and concurrent Hub broadcast/disconnect.
A completed worker with failed pending output is reclaimed immediately even
when its completion notification was already consumed. Hub snapshots retain
Conn borrows; deinit joins them before destroying borrowed transport state.
The handler must detach all Hub memberships before deinit. Nonblocking upgrade
recv revalidates descriptor identity under the close registry lock; a recycled
descriptor unit test verifies no data theft or double close.

Threaded, true kqueue and true epoll run the same 29 Contract cases. Linux
ReleaseSafe Contract and quick stress pass in CI; local macOS full stress also
passes. Setup/input/parser allocation failures, constrained partial send/EAGAIN,
EPIPE, stale generations, bounded wakeup overflow and reference-checked timer
churn accompany socket reset/error/timeout/drain coverage. Managed allocation
and FD rollback/cleanup are verified for these bounded runs, not every workload.

Four synchronous long-lived upgrades fill four workers and delay an unrelated
HTTP request beyond 250ms; Threaded answers it. Slow stream producers can also
occupy workers. Forced drain succeeds, but production isolation does not.
Reactor hello/echo throughput at 32 connections is about 46%/47% lower; DB is
19% lower. Profiles show worker handoff, condition/mutex, pipe and selector costs
without proving one causal percentage. No speculative optimization was applied.

At 256 idle clients Reactor uses nine threads versus Threaded's 264, roughly
10% less RSS and about 4ms versus 130ms idle shutdown. Those gains do not remove
the blockers. Threaded remains default; Reactor still fails closed. The final
untracked Threaded check against 946f021 is −0.5% / −0.4% / +5.1% hello/echo/db
throughput with no major broad regression; hello P99 variation is retained.

[Full tables, raw data, profiles and reproduction](../../benchmark/results/runtime-phase5-2026-10-05/README.md)
include latency, CPU, RSS, FD/thread, allocation and shutdown observations.
Short-lived traffic is paced; stream/upgrade fixture timings are smoke results.
Linux performance measurements, longer soak, broader OS/allocator faults and
race/sanitizer analysis remain future certification requirements.

### Zig 0.17 choices and next work

Raw nonblocking accept remains: installed netAcceptPosix does not expose EAGAIN
as recoverable. Threaded poll/read remains for deadlines without detached-worker
Io cancellation scopes. Reactor uses nonblocking recv and kernel readiness;
upgrade's synchronous read needs bounded poll. Bounded send bypasses standard
blocking writers while retaining std.Io.Writer framing. Pthread synchronization
uses std.c ABI types because shared Db/cache/Hub APIs do not own/pass Io. Conn
and runtime queues have Io but retain explicit uncancelable join/abort policy;
this does not claim that 0.17 lacks uncancelable mutex/condition APIs. Signals use
standard SIG/Sigaction; obsolete casts and handmade polling structs are removed.
Detached workers, atomic active count and owned registry drain remain production.
Group improves ownership but measured DB loss and unchanged idle thread cost
do not justify adoption. Reactor workers are fixed and joined.

Next design work: explicit bounded long-lived stream/upgrade admission and
ownership, or portable incremental frame/producer tasks. Group alone does not
make synchronous handlers suspend efficiently. Profile batching/wakeup/selector
costs before optimization, then repeat full Linux/macOS correctness/resource
evaluation. CPU-bound and arbitrary blocking handlers still must cooperate.

```sh
zig build runtime-contract-unit runtime-stress-test -Doptimize=ReleaseSafe
zig build runtime-stress-full -Doptimize=ReleaseSafe
```

CI runs Threaded+epoll on Linux and Threaded+kqueue on macOS, quick stress and
Group PoC. Platform stress JSON is uploaded. Full local stress remains separate
and writes .zig-cache/runtime-stress-full.json.

## Final CI validation

Implementation `ce5ef1f` passed all 15 jobs in [CI](https://github.com/moribit/Akamata/actions/runs/37270065077). Linux Threaded/epoll and macOS Threaded/kqueue each passed the same 29-case Contract, alongside ReleaseSafe fault/unit tests, Group Contract and quick stress. Raw CI stress data and implementation provenance are saved in the [Phase 5 evidence](../../benchmark/results/runtime-phase5-2026-10-05/README.md). Stress success includes reproducing the expected worker-isolation failure; it does not establish production suitability. The decision remains **Reactor Not Ready**.
> Subsequent Phase 6 isolation passed. See the [Phases 6–9 report](native-reactor-phases6-9.md)
> for current certification and the performance-based Not Ready decision.
