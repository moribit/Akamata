# DB optimization baseline

Starting main: `dd50c00d601f054972bef3c4c827d7619be3c19c` (origin/main checked).
Zig 0.17.0, Native Threaded, FULLMUTEX, SQLite repository amalgamation 3.53.1.
Existing Competitive Matrix and raw data are unchanged. Its 32-connection DB
result (85,302 req/s) belongs to an earlier cohort and is not this experiment's
before measurement. Axum/Actix/Go/zap use a benchmark-only pthread pool and C row
copy; Akamata uses real Db/Pool and request arena ownership.

## HTTP path

Threaded socket → shared HTTP Session → typed endpoint → Pool.acquire →
Db.prepare → SQLite prepare → allocate 24-byte StmtBackend → bindAll → step →
readRow → copy name into request arena → finalize/destroy → Lease.deinit →
JSON serialize → shared Response Cursor → bounded socket writer.

Db/Stmt use static backend vtables (indirect function calls). readRow resolves
field types/indices at comptime, but null-check and column access are separate
backend calls. No column-name lookup. Text is borrowed until reset/step/finalize;
the arena copy in the HTTP fixture is required and will remain.

Pool uses std.Io.Mutex/Condition, atomic caller tracking, an eight-slot scan and
generation-checked leases. Acquire/release retain closure/deadline/join semantics.
No statement cache. SQLite FULLMUTEX unchanged.

## Measurement boundaries

`db-optimization-bench`: A direct C and B Db use an identical benchmark-only
pthread admission gate. C replaces that gate with production Pool; D adds
readRow; E adds retained-arena name copy; F adds JSON generation. A/B/C manually
read all columns and check NULL just as D does. A-D consume borrowed bytes before
finalize; E/F copy before finalize. All six use the same eight Db-owned handles,
SQL, parameter 1, schema and PRAGMAs. A is direct SQLite calls with pthread
admission, not an unsynchronized handle shared across threads.

The latency clock pair per operation is present in both diagnostic and ordinary
micro builds; micro timing is not equivalent to uninstrumented HTTP throughput.
Detailed phase clocks and allocation wrapper exist only with `-Ddb-diagnostics=true`.
Each worker warms 100 operations before a synchronized start. Worker creation and
warmup are excluded from operation throughput, included in external process CPU.
A/F differ in ownership/output work; compare incremental cases, not as identical
application functionality. F intentionally holds its lease through JSON, unlike
HTTP, and is not a model of HTTP pool occupancy.

Commands and binary hashes are saved with every new raw result. Normal and
diagnostic results must never be pooled. No perf/strace claims are inferred from
wall-clock phase sums. SQLite internal malloc is not counted by Zig allocators.
