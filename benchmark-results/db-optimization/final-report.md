# Native SQLite investigation — final report

## Outcome

The direct-statement-handle performance candidate is **rejected and reverted**.
The +10% / +20% DB throughput goals were not achieved. The shipped production
change fixes statement ownership on wrapper-allocation failure; it does not
claim normal-path throughput or allocation improvement. Threaded stays the
production default, Reactor stays parked/fail-closed, and Workers/D1/Turso APIs
are unchanged. No new dependency, statement cache or FULLMUTEX relaxation.

Starting main: `dd50c00d601f054972bef3c4c827d7619be3c19c`. The private diagnostic
fixture was committed as `d04139d`; frozen candidate = that SQLite source plus
[candidate.patch](raw/candidate.patch). Final code restores the wrapper and adds
failure cleanup. [Environment and binary SHA-256](raw/environment.json) identify
each executable separately; the measured candidate is **not the shipped fix**.

## Measured findings

- SQLite prepare is the largest measured one-thread phase: about 910 ns.
- Wrapper allocation is about 23 ns; baseline B-F allocate/free one 24-byte
  Zig object per operation. Removing it saves that object but not total SQLite allocation.
- Typed decoding already resolves fields/indices at comptime and performs no
  field-name search. Approximately 99 ns versus explicit checked columns ~95 ns
  does not justify a new row-specialization API or unsafe borrowed response.
- At 32/128 callers, measured Pool acquire/release wall time dominates query
  work. Separate wall stacks show workers blocked in ulock/futex acquisition and
  release. This identifies contended admission as material, not the eight-slot
  scan or a particular SQLite mutex as the cause.
- Direct C versus Db with the same pthread gate at one thread is about 828k
  versus 807k ops/s (roughly 2.7% whole-path difference). It is not a vtable-only
  measurement and cannot apportion the historical ~31% HTTP competitor gap.
- The existing competitive C fixture passes NUL-terminated SQL with length -1;
  the portable slice path safely passes its explicit length. SQLite makes an
  extra temporary SQL copy for the latter. A [same-binary length control](sql-length.md)
  has only a small one-thread difference and noisy contention results; no new
  public API or beyond-slice read is justified.

[Detailed boundaries and parity audit](profile.md), [allocation analysis](allocation.md),
[all micro medians](microbenchmark.md), [raw CSV](microbenchmark.csv).

## Paired HTTP comparison — rejected candidate

M2 MacBook Air, macOS 27.0.1, Zig 0.17.0, ReleaseFast/SMP allocator, SQLite 3.53.1,
eight private in-memory handles, same SQL/row/PRAGMAs, prepare/finalize each query.
HTTP/1.1 loopback, oha 1.15.0. Two ABBA cycles at each cell: four observations per
binary, 2 s warmup + 5 s measurement. This is an exploratory screen, **not** the
previous 10/30/5 competitive certification matrix. No builds/tests during load.
Every 1/8/32/128/512/1024 cell for DB/plaintext/JSON/echo-1KiB was measured.

The after/candidate column below is the **reverted** candidate. No candidate
performance number is attributed to the final error-path fix.

| Workload (32 connections) | Before 200/s | Candidate 200/s | Change | P99 before/candidate ms | CPU before/candidate % | RSS before/candidate KiB |
|---|---:|---:|---:|---:|---:|---:|
| db | 147,976 | 144,771 | -2.17% | 1.467 / 1.528 | 333.7 / 333.4 | 7869 / 7885 |
| plaintext | 162,501 | 163,764 | +0.78% | 1.190 / 1.140 | 289.2 / 299.8 | 7961 / 7923 |
| json | 152,040 | 153,377 | +0.88% | 1.177 / 1.117 | 305.9 / 311.0 | 7941 / 7903 |
| echo-1024 | 143,780 | 143,186 | -0.41% | 1.427 / 1.530 | 301.2 / 301.4 | 8368 / 8155 |

At DB/1024: 134,267 → 130,117 successful requests/s (−3.09%); P99 44.590 →
50.788 ms. Neither repeatable improvement nor a safe P99 win is demonstrated.
Full P50/P95/P99/P99.9, CPU, RSS, threads and round spread are retained in
[all cells](before-after.md) and [summary JSON](raw/http-summary.json).
Medians of round percentiles are not pooled percentiles or timeout-inclusive SLOs.

192/192 HTTP cases completed, with no non-200 responses, failed cases, forced
server cleanup or nonzero server exits. Client errors are **not zero**: see
every cell and the raw error distributions; they are counted separately from
successful 200/s. Inherited descriptor limit was 61,440, above tested concurrency.
No exact CPU frequency/die temperature was available; pmset outputs and server/
generator CPU/RSS/thread samples remain in each row. Round/cohort host variation
prevents a precise causal interpretation of small changes.

## Competition and unknowns

Original Competitive Matrix/raw files are untouched. Their reference 32-client
DB rates (Akamata 85,302, Axum 123,899, zap 121,697, Actix 115,019, Go 93,726)
belong to that matrix, not these short paired runs. Do not rank this new 147,976
Akamata baseline against old competitor data. Engine settings match, but runtime
execution/admission, C pool, null checks, ownership copies and serializers differ.
Actix has eight workers; Go gates cgo with eight slots; Threaded can place 32+
connection threads at an eight-handle Pool. The direct-C contended micro also
slows sharply at 32 callers, so facade allocation alone cannot explain the gap.

Exact SQLite malloc counts/peak memory, parser/VM/malloc/mutex CPU subcosts,
syscall/context-switch totals and the percentage of the historical HTTP gap
explained by each component remain **unknown**. macOS wall-stack samples include
blocked threads and are not CPU percentages. Linux performance/live Workers
performance were not measured. No remote resource was created.

## Changes retained / rejected

Retained: private reproducible A-F microbenchmark, compile-time opt-in phase/
allocation diagnostics, SQL-length control, ABBA HTTP runner, evidence guards,
CI fixture checks and ownership/lifecycle regressions. Production fix finalizes
a live SQLite statement if its 24-byte Zig wrapper cannot be allocated, preventing
an untracked SQLITE_BUSY connection leak. Caller still owns exactly one Stmt;
finalize before releasing lease/closing Db. Text/blob copies remain required.

Rejected: direct SQLite pointer replacing wrapper (measured but no benefit).
Not implemented: wrapper freelist/cache, null-check removal, unsafe zero-copy,
lock-free Pool, out-of-lock notification, extra scheduler, FULLMUTEX changes.
[All decisions and constraints](optimization-decisions.md) explain why.

## Validation

Local final commands all exited 0; [exact commands/logs](raw/validation.json)
record source-file hashes and core fix `ccd7662`:

- Native Debug: successful final rerun; 14 new standalone tests passed before
  cache reuse. Existing main suite initially passed 178 tests with one skip.
- Native ReleaseSafe: 192 passed / 193 total (one skip) on the compiled suites;
  the initial missing-report link check was corrected, final command successful.
- Native ReleaseFast: 178 passed / 179 total (one skip); standalone pool/statement
  fixture separately passed 14/14.
- Workers WASM/host simulation: ten shared application runs plus managed D1,
  R2/Queue and generated DX client contracts passed. No live provider claim.
- Transport Contract: 136/136 passed, including Threaded and private evaluation
  adapters; runtime gate unchanged.
- macOS local ThreadSanitizer pool/statement fixture: 14/14 passed, no report.
- Fixture smoke: all six A-F paths passed in ordinary ReleaseFast and diagnostic
  ReleaseSafe. Reporting guards: 10/10; developer links: 37 documents passed.

The initial one-second Debug ownership stress failure is retained separately and
was confirmed to be Timeout, not a wrong row. The final stress uses acquire();
independent deadline/close races and production budgets are unchanged. Initial
missing-document and sandbox/cache setup failures are not represented as passes.

GitHub CI **23/23 jobs passed**, and full Linux/macOS TSan **2/2 jobs passed**
for the core fix `ccd7662`:
[CI](https://github.com/moribit/Akamata/actions/runs/42007031671),
[TSan](https://github.com/moribit/Akamata/actions/runs/42007045923).
These links are revision-scoped. Raw [CI metadata](raw/ci-core.json) and
[TSan metadata](raw/ci-tsan.json) retain the tested SHA. Subsequent changes are
benchmark tooling, evidence and documentation (including a column-conversion
lifetime clarification), not another production optimization.

## Next work

1. Profile contended acquisition at equal caller admission (8 versus 32+) and
   distinguish condition sleep, mutex reacquisition and scheduler delay. Retain
   close/deinit ownership before evaluating a different Pool discipline.
2. Attribute SQLite prepare CPU/allocator subcost on a controlled Linux host;
   avoid deriving CPU percentages from wall stacks.
3. Only then consider an explicit, bounded statement cache with schema/reset/
   binding/eviction/owner contracts, evaluated separately from the no-cache
   competitive workload. No cache is introduced or benchmark rule changed here.
4. Confirm any future benefit with longer paired runs and a load generator with
   headroom, rather than optimizing toward the old cross-cohort league table.
