# DB cost attribution

See [environment](raw/environment.json), [baseline](baseline.md),
[ordinary paired micro runs](raw/micro-paired.json) and
[diagnostic baseline](raw/diagnostic-before.json). Starting main is dd50c00;
diagnostic harness source is d04139d plus the saved paired-run harness changes.
Candidate source delta is [retained separately](raw/candidate.patch).

## Boundaries

All phase counters are thread-local and compile away unless the executable root
explicitly enables `db_diagnostics`. The production observability monotonic clock
is reused. Pool acquisition includes lock and any wait (not just sleep time).
SQLite prepare excludes wrapper allocation. Finalize includes SQLite finalize
and wrapper destruction. Bind/step/decode/copy/JSON are non-overlapping call scopes.
Pool release is separate. The JSON scope also checks exact output bytes for fixture correctness. They do not add up to the entire operation: phase-clock
calls, facade bookkeeping, result consumption and arena reset are outside them.

On this host many individual timestamps quantize to microseconds. Totals average
many operations; an individual zero is not proof an operation is free. These are
instrumented wall durations, not CPU samples, not syscall counts, and not a way
to assign engine malloc/mutex CPU percentages. Absolute ns values must not be
compared to uninstrumented HTTP throughput.

The micro executable also takes one latency-clock pair per operation even when
phase diagnostics are off. External process CPU includes startup, worker warmup,
start admission, sorting and teardown. Throughput excludes worker creation and
100 warmup operations/worker; it includes release and retained-arena reset.
The throughput interval also includes start admission and worker joins/arena cleanup.
Percentiles are per-operation latencies including pool acquisition. Admission
for A/B is the same benchmark-only pthread gate; C-F use the real production Pool.
There are eight independent handles in every case, no statement cache.

## Initial single-thread diagnostic

For B, prepare is approximately 909 ns, wrapper allocation 24 ns, bind 29 ns,
step 115 ns, decode 95 ns, finalize+wrapper free 90 ns, acquire 23 ns, release
24 ns. For D, typed decode is approximately 99 ns. For F, name copy is 24 ns
and JSON generation 124 ns. The generated tables retain every measured value.
Prepare accounts for roughly two thirds to three quarters of the **sum of
instrumented scopes**, depending on case; it is the largest measured phase.
That is not a percentage of the historical HTTP performance gap.

The baseline wrapper contributes one 24-byte Zig allocation and free/operation.
The direct-handle candidate removes both; its absence does not by itself prove
HTTP benefit. Vtable overhead cannot be isolated by subtracting two noisy totals:
the direct and facade paths also differ in safety/error handling and code layout.
readRow has no runtime field-name search and adds very little over explicit
null-checked column reads in a single thread.

## What remains unknown

SQLite parser, VM construction, malloc and FULLMUTEX subcosts are not separately
measured. No Linux perf/strace evidence is available from this macOS workstation.
A wall-stack sample, if obtained, must not be relabeled CPU percentage. The
shared SQLite allocator and scheduling may contribute under contention, but the
short 32/128-thread micro samples are dispersed and do not prove either cause.
The historical Axum/Actix/zap advantage cannot be causally apportioned using
these new Akamata-only runs. The previously measured before/after HTTP cohorts
also cannot be reused as paired controls.

## Competitive C fixture parity audit

| Property | Competitive C / Rust/Go/zap | Akamata HTTP |
|---|---|---|
| Engine / build flags | Repository SQLite 3.53.1, THREADSAFE=1, DQS=0, OMIT_LOAD_EXTENSION, DEFAULT_FOREIGN_KEYS=1, USE_URI=1 | Same amalgamation/options |
| Connections | 8 independent in-memory handles, FULLMUTEX + URI | Same |
| Busy timeout | SQLite default (0) | Adapter sets 5,000 ms; no busy event expected for independent read-only fixture handles |
| PRAGMAs / data / SQL / parameter | MEMORY journal, OFF sync, MEMORY temp, same 3 rows, same SELECT, id=1 | Same |
| Statement lifecycle | prepare/bind/step/finalize per call | Same; adapter additionally owns a Zig wrapper |
| Prepare length | -1: trusted NUL-terminated C literal | explicit slice length excluding sentinel |
| Admission | pthread mutex/condition, used[8], signal on return; Go additionally uses an 8-slot channel before cgo | Io mutex/condition, generations, close/deadline/caller tracking |
| Null contract | fixture guarantees NOT NULL name, checks pointer/length | required typed columns reject SQL NULL |
| Row ownership | copy name into fixed-size C output while statement is alive | arena.dupe before finalize |
| JSON | framework's normal serializer | same typed endpoint serializer as production |
| Response | exact id/name/weight values and JSON wire check | Same verified body |

The SQL length difference is real: SQLite's `sqlite3Prepare` in the vendored
amalgamation (`nBytes>=0 && zSql[nBytes-1]!=0`) makes a temporary NUL-terminated
SQL copy before parsing the generic slice. That proves an extra copy path, not
its cost or a reason to read beyond a Zig slice. The A-F microbenchmark passes
the same explicit length in direct C and Db paths to isolate facade overhead.
A separate direct-C length-mode control can isolate this fixture difference.
The existing competitive raw matrix remains untouched. Neither comparison is
presented as proof that a benchmark C owner equals a portable production API.

## Concurrency differs outside the C call

Actix runs eight HTTP workers; the Go fixture also gates cgo through an eight-slot
channel. Akamata Threaded has a thread per admitted connection and can have 32+
callers contending for the same eight DB leases. This is intentionally not made
identical by rewriting either framework's execution model. The microbenchmark
shows a large 8→32 caller drop even in direct C with a pthread gate, and in the
production Pool, while A/B single-thread differences are small. This implicates
contention/scheduling as an important investigation direction, not proof that
Slot scanning, vtables or a specific SQLite lock is the root cause. Pool.acquire
wall time includes mutex/condition/scheduling delay; release wall time includes
its mutex and notification. Different stages' wall sums at 128 threads overlap
across workers and must not be presented as aggregate CPU percentages.

For the baseline diagnostic D case, acquisition/release average about 44/12 µs
at 32 callers and 578/35 µs at 128 callers; prepare averages about 2.0/2.2 µs.
These are **one instrumented observation per concurrency**, not confidence bounds.
They establish that contended admission is material, while not identifying how
much is condition sleep, mutex reacquisition, notification or scheduler delay.
There is no evidence that scanning eight slots is the expensive part.

A notification cannot simply move past unlock: after the last release reduces
active to zero, concurrent deinit could reclaim the Pool before an out-of-lock
notification. The existing in-lock notification also protects shutdown ownership.
Removing caller tracking, generation checks or join work for a hot-path gain
would change the contract. Such changes are not accepted by this investigation.

## macOS wall-stack observation

[`sample` output](raw/db-wall-stacks.txt) and [exact command](raw/sample-command.json)
record a separate 32-worker D run (3.2 million queries). Most sampled worker
stacks are waiting in `__ulock_wait2` under acquisition or `Lease.deinit`, with
`Io.Threaded.futexWake` also visible. This supports the contended admission/wake
investigation direction. It is wall-stack sampling, including blocked threads,
**not CPU percentage**, a context-switch counter or a quantified SQLite lock
profile. The initial sandbox attach failed; retry outside the sandbox succeeded.
No sudo, security-setting change or production resource was involved.

[Direct C SQL-length control](sql-length.md) isolates the sentinel-length
variation. Its small one-thread effect and dispersed contended results do not
support a production SQL-buffer specialization in this work.
