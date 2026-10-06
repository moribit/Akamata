# Reactor application execution — Phase 6 implementation

For current output/Session ownership, memory costs and completion publication fixes, see [CPU / memory investigation](native-reactor-performance-memory.md). The Phase 6 measurements below are historical.

The user selected explicit incremental execution for Reactor. Threaded retains synchronous stream/upgrade APIs; Reactor rejects them with `UnsupportedApplicationExecution` (HTTP 501 in the default error handler). The public Reactor gate remains disabled.

`am.http.application_session.Definition.init(State, state, callback, mode)` creates one callback ABI with a compile-time adapter, matching the existing endpoint convention. No transport vtable or per-step allocation is introduced. Native `Response.streamSession()` / `am.ws.upgradeSession()` transfer arena-owned state after initializer return; Context/Conn stack pointers must not escape. Workers currently returns explicit unsupported until its event adapter exists; core events/actions contain no platform API.

Callbacks receive opened/resumer, produce, message or closed/reason and emit one bounded 8 KiB quantum plus input/produce/after/wait/done. Output backpressure parks the session, not a worker. Idle WebSockets and parked producers have no queued/running application work. Shared frame assembly validates fragments/control/UTF-8, reuses bounded scratch state, and yields after 64 frames. Each event-loop turn processes at most 128 notifications.

Buffered HTTP responses also use the shared response cursor: Reactor sends 4 KiB quanta outside workers, including arbitrarily large headers/bodies. Threaded uses the same serializer. Queues are fixed-capacity with one queued/running borrow per connection; a separate cleanup FIFO is bounded by live connection capacity and cannot be rejected by normal admission saturation. Close joins an existing step, delivers closed once on a worker, then destroys state. CPU/foreign blocking calls require cooperative completion. Resumer borrows end with closed; application registries must unregister/join senders. The fixture mailbox joins broadcast/detach under its membership mutex and closes overflow recipients.

Read deadlines are absolute per frame (partial bytes do not renew them). Stream output budgets begin with headers and include producer waits; WebSocket budgets apply per handshake/frame. Shutdown stops admissions, drains finite streams within grace, closes idle/upgraded sessions, force-shuts I/O at deadline, and joins running application work.

Local validation: 33 shared cases each on legacy Threaded, incremental Threaded and kqueue (99 total), isolation/admission gate, stress and allocation/lifecycle faults. The fixture asserts equal created/closed session counts and GPA cleanup. Linux/epoll passed the same targets in CI 37286692679 (all 15 jobs passed).

Reproduce: `zig build transport-contract-test runtime-contract-unit runtime-isolation-test runtime-stress-test -Doptimize=ReleaseSafe`. See [raw evidence](../../benchmark/results/runtime-phase6-2026-10-05/README.md). The following is the pre-implementation investigation/baseline, not the current implementation status.

---

# Reactor application execution — incomplete Phase 6

Baseline: `75fcb26`. **Phase 6 is incomplete.** Do not begin Phase 7 optimization,
Phase 8 certification or Phase 9 experimental release until application isolation
passes. Threaded remains default; Reactor still returns
`ExperimentalRuntimeDisabled`.

## Ownership constraint

`http/connection.zig.dispatchOne()` calls application handlers synchronously.
`ws.upgrade()` returns a stack-owned `Conn`, borrowing the handler arena and
transport writer/control. Its `readMessage()` polls until a frame arrives.
`Response.startStream()` returns a synchronous writer whose Reactor adapter waits
on a condition until the fixed 16 KiB output slot drains. This bounds output,
but retains both the handler stack and its worker. Handlers may also sleep or
make blocking DB calls between writes.

Returning early from read/write cannot safely resume the rest of an arbitrary
handler. Saving Context/Conn pointers does not preserve their stack or arena;
unwinding executes application defers. Increasing workers or assigning a thread
to each upgraded connection does not satisfy finite application execution.
Group alone on the current Threaded backend does not solve this blocking-task
ownership problem.

## Implemented foundations

`ServeOptions.max_pending_application_tasks` optionally bounds waiting Reactor
application tasks independently from active connections/workers. `null` uses
`max_connections`; Threaded ignores it. Zero or a value above the connection
limit is rejected before Reactor resource setup.

The fixed-capacity FIFO allocates once during initialization, never on push/pop.
One connection has at most one queued/running borrow. Overflow closes the newest
unadmitted connection before response commit without evicting admitted work or
waiting for a nonexistent completion. Shutdown aborts I/O, joins workers, then
reclaims queued borrows and connection state. This protects resources; it does
not make synchronous handlers finite or establish HTTP isolation.

`ws/message_state.zig.State.accept()` consumes a single decoded frame without
socket I/O. It yields `more / message / pong / closed`, preserving fragment
assembly, interleaved control frames, UTF-8 and close-payload validation. Existing
`Conn.readMessage()` uses the same state and continues copying its result into
the caller arena. Incremental events borrow state/frame storage until the next
step/deinit. Aggregate size/capacity are bounded before allocation/copy;
allocation-failure cleanup is tested. This state is private, not a newly
advertised public WebSocket API.

The readiness-to-task session adapter, incremental producer ownership, and
generation-token broadcast handoff remain unimplemented.

## Executable gate

`runtime-isolation-test` requires unrelated HTTP completion within 250 ms for:

- Four idle WebSocket sessions.
- Four slow-reader streams.
- Two upgraded sessions plus two slow streams.

It also verifies one-worker/one-pending-task overflow and admission recovery
after disconnect. The gate currently exits nonzero. `runtime-isolation-evaluate`
records the same failure evidence without claiming Phase 6 success; CI runs this
evaluation and uploads its JSON alongside stress data.

Local macOS Threaded passes all three isolation probes; kqueue fails all three.
Overflow recovery succeeds and every fixture reports zero final allocator live
bytes. Raw data, binary SHA, command and environment are saved in the
[Phase 6 evidence](../../benchmark/results/runtime-phase6-2026-10-05/README.md).
The existing 29-case Threaded/kqueue Contract is preserved. Linux/epoll evidence
is collected separately in CI; Linux performance/soak success is not inferred.

## Incremental execution design to implement next

Use explicit finite session/producer steps, not transparent suspension of the
synchronous API:

```text
short HTTP initializer → explicit ownership transfer after handler returns
owned session + bounded input/output + generation token
readable/output-drained/timer → one admitted finite step
worker completion → event-loop output → await next event
```

The initializer runs normal App middleware/authentication. Session state owns
copied request data and never retains stack Context/Conn pointers. Message
decoding/assembly uses shared protocol code; application callbacks and DB work
stay off the event loop. A producer fills a fixed-capacity output slice once,
then is readmitted only after output drains. One queued/running task per
connection and a bounded inbox prevent unbounded closures or producer run-ahead.
FIFO readmission and explicit byte/step quantum provide fairness.

Step scratch arenas reset after completion; session state has a separate
lifetime. Cancel stops new admissions, joins an already-running step, then
destroys state. The event-loop owner closes the fd once. Broadcast uses bounded
generation-token admission rather than handler-stack Conn pointers. Arbitrary
CPU/foreign blocking calls still require cooperative completion; unsafe
preemption and implicit event-loop-safe fast paths are excluded.

Preserve Threaded synchronous APIs. Specify incremental Threaded/Workers
adapters and Reactor synchronous-API support/explicit unsupported behavior
before exposing the new application API. Implement shared stream serialization,
upgrade ownership handoff, token broadcast and isolation/fairness Contract
before performance batching or production certification.

```sh
zig build test runtime-contract-unit transport-contract-test -Doptimize=ReleaseSafe
zig build runtime-isolation-evaluate -Doptimize=ReleaseSafe
zig build runtime-isolation-test -Doptimize=ReleaseSafe # currently fails the gate
zig build -Dbackend=workers -Dexample=chat -Doptimize=ReleaseSafe
```

Phase 7–9 have not been completed. Reactor remains **Not Ready**.

Current certification and release decision: [Phases 6–9 report](native-reactor-phases6-9.md).
