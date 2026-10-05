# Phase 3: Group suitability, decision B (defer adoption)

Apple M2 / macOS arm64, Zig 0.17.0 ReleaseFast, oha 1.15.0. Both implementations
use eight acceptors, the same handlers, shared HTTP/socket driver, SQLite handle,
DebugAllocator, connection cap, request cap, write/read/drain budgets and bind address.
Each case starts a fresh child; runtime order alternates between rounds.

- matrix.json: 76 cases, 4/32/128 connections; keep-alive saturation and paced
  short-lived requests, two 2s rounds, plus 64/256 idle connections. Allocation
  tracking enabled for both. Every final tracked allocator live count is zero.
- untracked-db.json: instrumentation disabled, three paired 3s DB rounds at
  32/128 connections. Use this to confirm DB regression independently of counters.
- tasks.json: separate instrumented Group probes record actual task peak/completion
  counts and zero active tasks after drain, plus thread/fd/RSS/CPU observations.
- *.sample.txt.gz: full 5s macOS sample profiles during untracked 32-connection DB
  load. *.profile-summary.txt contains collapsed leaf stacks. Sampling timings
  are not used for throughput claims.
- unpaced-partial.json: incomplete short-lived saturation attempt, excluded from
  decisions. A subsequent startup client could not connect; TIME_WAIT/source-port
  pressure is suspected but the precise OS error was not retained. The complete
  matrix limits short-lived traffic to 500 requests/sec to keep host usage safe.
  Those rows report latency/resources at that rate, not a capacity ceiling.

Throughput counts HTTP 200 responses per elapsed second. CPU is process CPU-time
delta / wall time (100% means one core); RSS is sampled mean, thread count sampled
peak. fd count is sampled before stopping the server. Allocation statistics count
app.gpa only: SQLite/libc malloc and OS thread stacks are excluded. Counters perturb
performance, so the primary DB decision uses untracked-db.json. Samples are short
local observations, not general production capacity guarantees.

| DB connections | Runtime | rps median | P50 µs | P95 µs | P99 µs | CPU % | RSS MiB |
|---|---|---|---|---|---|---|---|
| 32 | Threaded | 87,128 | 245.3 | 884.0 | 2,476.6 | 433.0 | 6.26 |
| 32 | Group | 78,178 | 229.5 | 1,085.6 | 3,408.1 | 439.5 | 6.29 |
| 128 | Threaded | 75,993 | 533.1 | 5,181.1 | 23,311.0 | 489.9 | 13.51 |
| 128 | Group | 68,125 | 448.2 | 6,249.8 | 26,901.0 | 515.2 | 13.82 |

Group DB throughput is −10.3% / −10.4%, P99 +37.6% / +15.4%. At 4 connections
the instrumented DB difference is about +0.9%; the penalty appears under contention.
Instrumented hello/echo throughput remains close (+0–2% at 32/128 connections).
At 256 idle connections Threaded/Group have 264/265 OS threads and approximately
22.05/22.16 MiB RSS: structured ownership does not create multiplexed I/O.

Both profiles show SQLite mutex waits from prepare/bind/column/step/finalize.
Group has more observed mutex-wait samples (721 vs 413 collapsed leaf samples)
and pool futex wait samples. These are blocked-thread stack observations, not CPU
percentages or proof that any one function causes the throughput difference.
The principal shared-DB contention hotspot is identified; the additional Group
penalty is not fully isolated. No speculative optimization was applied.

Decision B: retain production Threaded. Group has simpler task ownership and
await/cancel cleanup, but does not improve idle thread/RSS cost and the DB/tail
regression is material. Keep the PoC, counters, profiles and contract for later
reassessment. A different Io backend or controlled SQLite connection-pool study
would be a new phase, not evidence for enabling Group now.

```sh
zig build -Dexample=bench -Doptimize=ReleaseFast
zig build runtime-group-bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_matrix.py threaded=zig-out/bin/bench group=zig-out/bin/runtime-group-bench --output /tmp/matrix.json --stats
python3 tools/bench/runtime_matrix.py threaded=zig-out/bin/bench group=zig-out/bin/runtime-group-bench --output /tmp/db.json --connections 32 128 --endpoints db/1 --modes keep_alive --skip-idle --rounds 3 --duration 3s
python3 tools/bench/runtime_matrix.py group=zig-out/bin/runtime-group-bench --output /tmp/tasks.json --stats --connections 4 32 128 --endpoints hello --modes keep_alive --rounds 1 --duration 1s
python3 tools/bench/runtime_profile.py threaded=zig-out/bin/bench group=zig-out/bin/runtime-group-bench --output-dir /tmp/profile
```

Profile acquisition uses macOS sample; matrix resource sampling supports Linux
via /proc. The runners only stop children they started and refuse an occupied port.
