# v0.2.1 Performance & Reliability evidence

Baseline source: `f0eb0b63b1eb5885542c1fc43d35c7e284b7db64` (origin/main).
Zig 0.17.0. Production Native remains Threaded; Reactor remains parked/fail-closed.

Existing framework already has absolute read/write budgets, forced I/O drain,
connection admission, shared HTTP session/cursor, retained arenas, opt-in cost
and allocation instrumentation, portable providers, typed error mapping and
schema-aware API diff. This phase extends those mechanisms rather than replacing them.

Measurement uses the existing HTTP fixture and `tools/bench/runtime_matrix.py`.
Before binaries are copied to `.zig-cache/v021/before` before implementation.
Uninstrumented 3-round runs and allocation-instrumented runs are separate.
Raw oha JSON retains status/error distributions and P50/P95/P99. CPU is process
CPU-time delta / measurement wall time; RSS is sampled; allocation counts exclude
SQLite/libc allocation and OS thread stacks. Historical M2 numbers are context,
not a directly comparable before measurement.

Commands and binary SHA are retained in each result. No live Cloudflare claim.
