# Native HTTP runtime and Transport Contract (Zig 0.17)

The baseline is main `3f92014`. App.serve and ServeOptions remain compatible;
Threaded stays production and `.reactor` stays fail-closed.

## Architecture

```text
App.serve → serve.zig
              ├─ Native: runtime/threaded.zig (listener / admission / lifecycle)
              │            ↓
              │      http/connection.zig (shared HTTP driver)
              │            ↔ runtime/socket_transport.zig
              │                   ├─ readiness_poll.zig (production)
              │                   ├─ reactor_kqueue.zig (evaluation)
              │                   └─ reactor_epoll.zig (evaluation)
              └─ Workers: existing WASM bridge

Transport → parser → Request → App.dispatchWithPeer → Response → serialization → Transport
```

The shared driver owns arena/buffer lifetime, framing error statuses, read
budgets, keep-alive/request caps, pipeline residue, stream finalization and
upgrade ownership. Response.writeTo/endStream retain serialization semantics.
There are no socket descriptors, threads or kernel readiness calls in the HTTP
driver. Socket transport is statically dispatched using anytype: read, writer,
bufferedInput, peerIp, streamPtr, ioPtr and close. Existing std.Io Reader/Writer
interfaces provide streaming; no new transport vtable or heap allocation exists.
The stream/io pointers preserve existing websocket handoff plumbing.

The old reactor HTTP/worker loops duplicated dispatch, serialization and
keep-alive. Their fixed buffers, missing limits/deadlines/peer metadata and
stream/upgrade support, EAGAIN write spin, incomplete shutdown and hand-written
epoll ABI could not establish safety parity. They were replaced by kernel
readiness adapters using standard OS types, including packed Linux epoll_event.

Private evaluate entrypoints use the established thread-per-connection lifecycle
and the same shared driver. **They certify readiness-adapter compatibility, not
multiplexed reactor parity.** Both direct reactor serve entrypoints and public
App.serve(.reactor) fail before opening sockets. No unsafe fallback remains.

## Contract and limits of the guarantee

tests/transport_contract.py applies the same 20 black-box socket tests to each
adapter. It covers normal/disconnected clients, malformed framing, header count
and byte limits, body/declared chunk size limits, unsupported TE, keep-alive and
request caps, pipeline/body residue/partial next headers, idle/header/body/total
read timeouts and trickle attacks, chunked and fixed-length streams, stream
errors/truncation, upgrade ownership and coalesced frames, max-connections and
overload recovery, slow-reader isolation/reset, peer and trusted proxy policy,
graceful shutdown, idle and partial connections, and in-flight responses.

```sh
zig build transport-contract-test -Doptimize=ReleaseSafe
zig build runtime-poc-test -Doptimize=ReleaseSafe
zig build transport-contract-build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseSafe
```

Threaded plus kqueue pass 40 socket tests on macOS; Group passes another 20.
The Linux runner chooses epoll instead, and CI executes the same tests. Linux
cross-compilation alone is not claimed as execution evidence.

total_request_timeout_ms is a **request read budget**, not preemption of handlers
or writes. Header/body budgets retain their existing request-start origin.
Timeouts close the connection. Streams close after finalization. write_timeout_ms
remains reserved: backpressure tests establish bounded admission, waiting rather
than spin, isolation and reset recovery, not bounded writes or forced drain of
uncooperative peers. The existing graceful-drain/handler/websocket ownership
policy remains in place.

Boundary defects corrected by the Contract: consume already buffered reader
bytes before kernel waits; preserve upgrade read-ahead in Conn's owned buffer;
finalize fixed-length as well as chunked streams; flush a short stream's prefix
then close without padding or a second status; advertise close on the final
capped response; discard incomplete-parser allocations before retry; reject
oversized declared chunks before waiting for data; return 413 at the wire-buffer
ceiling; fail closed on socket-configuration/setup errors; and drain workers
without spinning. Wire buffering retains the header limit + body limit + 4 cap.

## Zig 0.17 workaround audit

The installed 0.17.0 stdlib source (Io.zig, Io/Threaded.zig, posix.zig, c.zig)
was audited, rather than assuming online master has the same API.

| Area | Current decision |
|---|---|
| libc accept | Keep in production: netAcceptPosix still treats EAGAIN as errnoBug; readiness races between acceptors need recoverable nonblocking accept. Standard blocking accept is cancelable inside the separate Group PoC |
| libc poll | Keep for read budgets: no per-stream deadline; SO_RCVTIMEO EAGAIN is unsafe in Threaded. One std.c.poll call lets the transport recompute absolute budget after EINTR; posix.poll retries its original timeout |
| manual poll/flag ABI | Replace with standard target definitions |
| pthread mutex/condition | Keep wrappers for DB pool/hub/model APIs that do not own an Io. Io.Mutex/Condition require a deliberate Io/cancellation ownership change |
| 96-byte pthread storage | Remove; use std.c.pthread_mutex_t/pthread_cond_t |
| libc signal/SIG_IGN workaround | Remove; use typed SIG/Sigaction, restore INT/TERM on scope exit, rely on Threaded's SIGPIPE handling |
| detached connection threads | Keep production lifetime model; safely drain even on partial setup failure |
| atomic active count | Keep for admission and borrowed app/io/context lifetime; Group experiment instead uses concurrent_limit and await |
| no-op timeout helper | Remove; reserved write deadline is documented explicitly |

Signal registration remains process-wide, with one serving App owning INT/TERM.
A multi-server signal broker is outside this change.

## Structured concurrency experiment

runtime/io_group_experiment.zig is isolated from production selection. A
concurrent accept Group uses standard blocking accept; another Group owns
connection tasks. Shutdown stops admissions, cancels acceptors, then awaits
connections. No Thread.spawn/detach, active counter or manual join/spin loop is
used. Threaded.concurrent_limit bounds accepted connection tasks.

Group.async is tested on finite awaited tasks. It may execute inline, so
long-lived connections use concurrent. Tests cover blocked standard socket
reader cancellation and close, as well as the shared raw readiness gate. The
gate returns to checkCancel at most every 100ms; one macOS sample took 74ms.
Unit allocation checking verifies task cleanup.

| Aspect | Production | Experiment |
|---|---|---|
| Shutdown | Detached workers and atomic drain | Owned Group.await/cancel |
| Cancellation | Shutdown flag and read budget | Standard syscall cancellation; periodic checks around raw readiness |
| Lifetime | Workers borrow app/io/context | Group waits for task cleanup; defer closes socket |
| Allocation | pthread thread/stack plus HTTP buffers | Task closure/Threaded pool plus the same HTTP buffers |
| Complexity | Acceptor list, spawn cleanup, active count and drain | Two Groups and concurrent_limit; force-cancel policy still needs design |

Cancellation does not preempt arbitrary SQLite or CPU handlers, and graceful
await does not force a slow writer to finish. The next phase can make Io the
runtime scope owner, with Io-aware deadlines, forced drain policy, upgrade task
ownership, admission and task-error propagation designed together.

## Benchmark

Apple M2 / macOS arm64, Zig 0.17.0 ReleaseFast, oha 1.15.0, loopback,
32 connections, three 5s rounds per endpoint, observability disabled.
Throughput counts HTTP 200 responses per elapsed second (not failed attempts).
Each figure is the median across rounds; RSS is the median of per-round sampled
mean RSS. These are exploratory local measurements, not capacity guarantees.

| Endpoint | Before: rps / P50 µs / P99 µs / RSS MiB | Threaded after | Group experiment |
|---|---|---|---|
| /hello | 167,430 / 157.5 / 826.7 / 6.58 | 165,600 / 167.6 / 695.2 / 6.38 | 167,179 / 167.9 / 689.8 / 6.14 |
| /echo | 166,213 / 157.3 / 963.7 / 6.56 | 165,094 / 158.3 / 836.7 / 6.44 | 166,923 / 165.5 / 731.6 / 6.17 |
| /db/1 | 86,893 / 229.6 / 3,010.5 / 6.75 | 88,263 / 222.8 / 2,664.0 / 6.60 | 80,433 / 211.5 / 3,555.4 / 6.42 |

Production throughput changes are −1.1%, −0.7%, +1.6%; /hello P50 rises
6.4% while P99 falls. There is no consistent broad regression in these runs.
Individual throughput ranges are 166–169k / 157–167k / 78–89k before and
154–166k / 162–165k / 87–88k after. An earlier trial showed a larger late-round
drop across all endpoints, so before/after were repeated without simultaneous
builds. Both exploratory after runs are retained, rather than hiding variation.
A pinned, paired run is needed for smaller performance claims.

The baseline recorded 12,345 transport errors over all nine rounds; after
recorded 17 (/hello's third round), Group zero. The capped response now advertises
Connection: close; this removes the baseline's reuse-after-close defect, but
remaining measurement/client errors are not attributed without evidence.

Group's /db throughput is 8.9% lower than current Threaded and P99 is 33.5%
higher. Its task pool/cancellation scope and single acceptor differ from the
production eight-acceptor lifecycle; this is not an isolated optimization
comparison. RSS and ownership are promising, but SQLite contention and task/IO
costs need profiling before adoption. No per-request allocation count is claimed.

Build both binaries explicitly (an explicit build step does not execute the
default bench installation):

```sh
zig build -Dexample=bench -Doptimize=ReleaseFast
zig build runtime-group-bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_compare.py zig-out/bin/bench /tmp/after.json
python3 tools/bench/runtime_compare.py zig-out/bin/runtime-group-bench /tmp/group.json
```

[Raw runs, binary hashes and measurement notes](../../benchmark/results/runtime-2026-10-05/README.md)
include commands, latency distributions, errors and RSS samples summarized per round.

## Before enabling production reactors

Implement bounded nonblocking output/partial-write state; multiplex connections
through an Io backend or incremental shared-protocol driver; prove stream/upgrade
ownership and cancellation; run the full Contract after multiplexing on Linux
and macOS; add stress/fault/disconnect/slow-reader/leak tests; design write and
forced-drain deadlines compatibly; and measure representative idle/burst/stream/
upgrade workloads. Throughput alone must not change the gate/default.

The [Japanese detailed report](../ja/runtime-transport.md) covers the same scope.
