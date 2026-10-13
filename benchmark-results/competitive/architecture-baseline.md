# Competitive initiative: architecture baseline

Baseline: `8a521fb16e2a6dbffb92627b73350cdb8c551925`, fetched from main on
2026-10-13. Zig 0.17.0. This document distinguishes existing evidence from new
competitive measurements; no competitive result exists yet.

## HTTP path

`threaded.acceptLoop → connectionThread → socket_transport.Transport →
http.connection.run → Session.next → parser.parseRequest → App.dispatchWithPeer
→ Response → Response Cursor → bounded_writer → send`.

The listener is nonblocking; eight acceptors are a benchmark setting, not an
application default. Each admitted connection creates a detached OS thread.
An atomic admission count and drain registry protect lifetime. Request arenas
retain capacity across keep-alive requests; input storage belongs to Session.
Reader and Writer each have 4 KiB bounded transport buffers. Input initially
reserves up to 16 KiB and can grow only within configured parser limits.

Read readiness uses libc poll in slices of at most 100 ms, including idle
connections. This is also a cancellation/shutdown observation bound. Output
uses nonblocking send, advances only on positive progress, polls on EAGAIN and
keeps an absolute write deadline. Graceful drain stops admission and force-closes
I/O at its deadline; arbitrary application CPU work remains cooperative.

## Allocation, parsing, routing, output

Existing v0.2.1 logical allocation fixture: parse 1 allocation / 896 bytes;
prepared empty route and passthrough middleware 0; response header 1 / 160 bytes;
owned static body 1 / 150 bytes; JSON header/body 2 / 291 bytes. The retained
arena makes 1,000 warmed JSON iterations incur no further backing heap calls.
These are specific diagnostic shapes, not universal allocation-free claims.
[Raw attribution](../v0.2.1/allocation-phases.txt).

Parser finds CRLFCRLF, validates request line/target, walks headers, validates
Host and framing, rejects duplicate Content-Length and CL/TE ambiguity, and
enforces header/body limits. Incomplete bodies can cause repeated parse attempts;
Session owns incremental buffering. The static router uses the existing comptime
route graph; runtime routes are prepared separately. JSON uses the current
comptime emitter with standard-library fallback, preserving owned body storage.
Cursor borrows that storage only during serialization and preserves partial
progress. Threaded currently serializes into a bounded Writer and flushes.

Syscalls/request are **not yet established for competitive workloads**. Existing
opt-in `runtime-cost` counters include parse/dispatch/read/send/selector wall and
thread CPU time, readVec/send/poll counts and reactor handoffs. Clock probe cost
and nested regions make this an attribution build, not the throughput build.
New measurements must retain raw counters rather than guessing one read/write.

## Existing bottleneck evidence

v0.2.1's 1,024 idle sample: 1,032 threads, approximately 113 MiB RSS, 0.33 core;
roughly 107 KiB RSS increment per extra idle connection. A 10-second echo repeat
showed P99 28.834 → 37.758 ms with similar throughput; causality was unresolved.
The old fixture renews a connection every 100 requests and uses DebugAllocator.
It is not a fair direct baseline against permanently kept-alive competitor
fixtures or a Release allocator. Exact admission-boundary load also had rejected
connections and client errors. [Full prior evidence](../v0.2.1/README.md).

## Reactor research boundary

Existing reactor really multiplexes sockets with one event loop and a bounded
worker pool. Session/Cursor semantics are shared. Incremental stream/frame APIs
separate worker work from connection lifetime; synchronous stream/upgrade remains
explicitly unsupported on this evaluation path. Completion wake batching,
selector-interest suppression and previous memory reductions already exist.
Past research found lightweight handoff/scheduling overhead, platform-dependent
throughput deficits, and earlier synchronous worker starvation. Do not simply
repeat rejected Group/lock-free/unsafe event-loop-handler experiments.

Threaded stays production default. Reactor stays parked/fail-closed in App.serve.
New runtime comparisons use a private executable, and must rerun the shared
Contract, stress/fault and two-platform TSan before any candidate judgment.

## Investigation order

1. Pin fixtures and toolchains; verify exact wire bodies and headers.
2. Measure same environment, allocator, keep-alive and connection limits.
3. Separate cost counters / sampling from uninstrumented throughput rounds.
4. Attribute idle wakeups and high-load errors before changing runtime policy.
5. Retain only measured improvements; never infer competitive leadership from
   historical Akamata-only numbers or simulator wall time.
