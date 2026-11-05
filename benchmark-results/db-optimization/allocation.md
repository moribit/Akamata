# Allocation and ownership

`-Ddb-diagnostics=true` installs a **diagnostic-only** allocator forwarding to the
normal SMP allocator, with thread-local successful allocation/free/byte counters.
No global atomic counters are added to the normal DB hot path. Failed allocation
is not counted as successful. Resize/remap are refused by the diagnostic wrapper;
this can change arena growth and is another reason not to treat it as production
throughput evidence.

Measured scopes start after initialization and 100 warmup operations per worker.
A warmed retained arena keeps capacity. Consequently E's logical name dupe and
F's logical JSON growth need not cause fresh **backing allocator** allocations
per operation. Both logical operations are still timed. Teardown frees retained
chunks after the measured snapshot and is excluded from per-operation frees.
`peak_sum_bytes` sums each worker's maximum requested live bytes (including its
warm retained arena); peaks need not occur simultaneously. It is neither RSS nor
a precise global simultaneous peak. Latency arrays, thread stacks, Pool metadata
and initial Db allocation are not included in request allocation counts.

Baseline B-F: exactly one successful 24-byte StmtBackend allocation and one free
per operation; A: zero Zig allocations. Candidate B-F: zero wrapper allocations
and frees. SQLite still allocates its statement/VM internally through libc; these
are **not** counted by the Zig allocator. No exact SQLite malloc/op or SQLite
maximum temporary allocation claim is made. Changing global SQLite allocation
callbacks would itself alter multithread contention and is not installed.

Db and Pool ownership is unchanged. A Stmt is a linear resource by convention:
finalize exactly once before closing Db or releasing its Pool lease. Copying its
value does not create a second owner and calling deinit on copies is unsupported.
No global registry or reference counting is added merely to tolerate misuse.
Generation checking protects stale Pool lease releases, not use of a Db after
release. readRow text is borrowed until the next step/reset/finalize or a backend column conversion. The HTTP
fixture's request-arena copy is kept. Blob uses columnBlob explicitly; optional
NULL and empty text remain distinct in typed row decoding.

## Observed one-worker diagnostic peaks

| Case | Before Zig alloc/free per op | Candidate | Before requested peak bytes | Candidate peak bytes |
|---|---|---|---:|---:|
| A | 0 / 0 | 0 / 0 | 0 | 0 |
| B/C/D | 1 / 1, 24 bytes | 0 / 0 | 24 | 0 |
| E | 1 / 1, 24 bytes | 0 / 0 | 94 | 70 |
| F | 1 / 1, 24 bytes | 0 / 0 | 398 | 374 |

This establishes allocation removal, not a throughput benefit or a 24-byte RSS
reduction. SMP allocation granularity/retention, SQLite memory and stacks differ
from requested live bytes. Zero diagnostic counters in an ordinary build mean
**not measured**, not zero allocations. CSV fields are blank in that case.
