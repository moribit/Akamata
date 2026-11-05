# Optimization decisions

## Statement ownership candidate — rejected

A: use the existing Stmt.ptr directly for SQLite's stable sqlite3_stmt handle.
This removes the adapter's 24-byte heap wrapper and its free. No change to Stmt,
Db, leases, vtables, tracing, FULLMUTEX or portable backends. It borrows no stack
memory. Exactly-once finalize and Db-outlives-Statement remain caller obligations.
The public facade is linear by convention; copying it does not create ownership.

B: per-connection wrapper freelist rejected without implementation: introduces
connection-local synchronization, close ordering and outstanding-node tracking
for an approximately 23 ns measured allocation. More complexity than A.

C: retain wrapper with correct cleanup on allocation failure if A lacks repeatable
benefit. The baseline omits finalize when wrapper allocation fails after successful
SQLite prepare. This is a correctness fix independent of throughput and must not
be presented as a normal-path speedup.

## Row conversion

Existing readRow already resolves field types and indices at comptime. No column
name lookup exists to remove. Null checks preserve required-vs-optional behavior.
No new direct SQLite row specialization or vtable batch method is justified by
the initial roughly 100 ns phase versus roughly 910 ns prepare. Blob has explicit
columnBlob; readRow byte slices are text, not a new schema-aware blob type.
Statement-backed text must be copied before finalize when returned by a handler.
No zero-copy change is planned.

## Pool

No slot-scan, notification or lock-free change is planned without evidence. Eight
slots and existing closed/deadline/generation/join behavior are retained. The
initial microbenchmark's production Pool is not slower than the benchmark-only
pthread gate; that does not prove a universal advantage. Contended short runs
have large dispersion, with scheduling and SQLite-global allocation effects
still unseparated. Do not ascribe all high-concurrency time to the Pool.

## Statement cache / SQLite synchronization

No prepare cache, FULLMUTEX relaxation, PRAGMA change or response shortcut.
Prepare is the largest observed single-thread phase, but engine parse/allocate/
mutex subcosts are not independently measured. A future opt-in cache needs reset,
binding, schema invalidation, eviction, owner-lifetime and cross-adapter design.

### Pool candidates reviewed against Zig 0.17

- Slot selection: eight entries, no measured scan attribution. A freelist adds
  metadata/invariants without evidence the scan dominates. Not implemented.
- Notification suppression: Zig 0.17 Io.Condition.signal already returns after
  an atomic load when no unconsumed waiter exists; it wakes one otherwise.
  Adding another Pool.waiters check does not remove a demonstrated expensive
  syscall in the empty case. No duplicate optimization added.
- Lock duration: current critical region owns lease generation/active counts and
  close/join notification. Moving notify after unlock risks deinit reclaiming
  the last-release owner before notify. Retain the safe ordering.
- Caller atomic/cache placement: acquire entry is counted before locking so
  deinit also joins callers waiting for the mutex. No cache-miss profile exists
  to justify padding or changing this ownership counter. Retain it.

Contended acquire/release wall times are material, but a lock-free pool or new
scheduler is not justified by wall scopes alone. Next investigation should
attribute futex sleep/reacquisition and worker scheduling with same-binary caller
admission controls. No close/deadline/generation semantics are weakened.

## Final decision

Direct-handle candidate is **reverted**. Paired micro tests do not show a reliable
benefit. The full 192-case paired HTTP screen has DB c32 147,976 → 144,771 HTTP
200/s (−2.17%), P99 1.467 → 1.528 ms; DB c1024 −3.09%, P99 44.590 → 50.788 ms.
Neither the +10% goal nor an acceptable repeatable performance benefit is met.
Do not infer precise causation from these exploratory local differences.
All ordinary/diagnostic results and the rejected patch remain available.

The shipped change keeps StmtBackend and adds errdefer finalize when allocating
it fails. Its deterministic allocation-failure regression checks SQLite has no
outstanding statement and the connection recovers. This repairs a real ownership
leak, **not** normal-path allocation count or a claimed throughput improvement.
No row-copy, typed row, Pool, FULLMUTEX, cache or runtime performance change is
retained. The final error-path fix was regression-tested, not represented by the
rejected candidate's measured after column.

## Regression-test correction

An initial new 32-thread query ownership test imposed a one-second acquisition
SLO and failed in Debug. A diagnostic repeat confirmed Timeout (not incorrect
rows or double lending). It now uses the existing acquire() to verify all 32,000
queries and cleanup. Independent absolute-deadline/close/release tests are kept
unchanged; production budgets and Pool implementation are not relaxed. The
initial failed test log is retained as `raw/initial-validation-0.log`.
