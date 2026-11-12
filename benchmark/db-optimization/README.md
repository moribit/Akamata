# DB cost investigation (private fixture)

Starting main: dd50c00. Zig 0.17.0 / repository SQLite 3.53.1.
[Results and decisions](../../benchmark-results/db-optimization/final-report.md).
No production runtime selector, DB API or SQLite mutex-mode change.

Build **before measuring**, freeze binaries, and keep every round. Example:

```sh
zig build db-optimization-bench competitive-bench -Doptimize=ReleaseFast -j2
# Copy executable files to distinct stable before/candidate paths first.
python3 benchmark/db-optimization/micro.py /path/to/before --paired /path/to/candidate --output /path/to/micro-paired.json
python3 benchmark/db-optimization/measure_http.py /path/to/http-before /path/to/http-candidate --output /path/to/http.json
```

The HTTP default is two ABBA cycles for each of four workloads and six connection
levels (192 cases), 2 s warmup / 5 s measurement. This is an exploratory paired
screen, **not** the prior competitive 10/30/5 certification matrix. Override
`--warmup` / `--duration` for confirmation; unchanged digests and settings are
required by `--resume`. No builds, tests or downloads during load. The inherited
competitive collector records server and generator CPU/RSS/thread samples, all
HTTP statuses/client errors, and exact body verification. HTTP/1.1 loopback/oha.
Before/after `pmset -g therm` output is retained on macOS; frequency and die
temperature are not measured. No privileged security settings are changed.

A/B microcases compare raw SQLite calls and Db over an identical pthread gate;
C uses the production Pool, D adds typed row, E adds copy, F adds JSON. See
[boundaries](../../benchmark-results/db-optimization/baseline.md). `DB_THREADS`
(1..128), `DB_OPS` (per worker) and `DB_CASE` (0..5) configure the executable.
100 warmup ops/worker precede measured admission. Per-op latency clocks remain
in the ordinary micro build; this is not a zero-instrumentation HTTP run.

For allocation and phase timings build **separately**:

```sh
zig build db-optimization-bench -Doptimize=ReleaseFast -Ddb-diagnostics=true -j2
python3 benchmark/db-optimization/micro.py zig-out/bin/db-optimization-bench --rounds 1 --output /path/to/diagnostic.json
zig build ci-runner
./zig-out/bin/akamata-tests db-smoke zig-out/bin/db-optimization-bench
```

Diagnostics include clock/allocator overhead, warm retained-arena capacity, and
exclude SQLite/libc malloc. Do not merge their throughput with ordinary runs.
Build `zig build ci-runner` before offline CSV/report regeneration with
`python3 benchmark/db-optimization/report.py`; evidence validation uses the
same native Zig guards as CI.
Existing competitive evidence is read-only for this investigation.

Additional controls (run serially after builds/tests finish):

```sh
python3 benchmark/db-optimization/sql_length.py /path/to/final-micro --output /path/to/sql-length.json
python3 benchmark/db-optimization/sample_db.py /path/to/final-micro /path/to/profile-directory
```

The SQL control only changes the known literal's length argument in direct C
case A; all three modes have valid NUL-backed storage. `sample_db.py` owns and
joins its process; macOS sampling may require permission outside an app sandbox.
It records blocked-thread wall stacks, not CPU percentages. `validate.py` runs
the local Native/Workers/Transport/TSan command sequence and retains exact logs.
The final report links revision-scoped GitHub CI/TSan evidence separately.
