# SIMD evaluation results

Final decision: retain experiments and evidence; adopt no production SIMD
change. HTTP/MIME validation has substantial long-input gains, but short
DEL-first rejection regresses and the final small-request Reactor/Safe tail
latencies do not satisfy the provisional no-regression condition. The original
HTTP/MIME call sites were restored byte-for-byte. Other candidates also lack
sufficient evidence to meet all adoption criteria. This is a completed
evaluation, not a claim of production performance improvement.

The evaluated application candidate was shared HTTP/MIME field-value validation in
`src/internal/byte_ops.zig`. It combines scalar predicate simplification with
16-byte SIMD scans, uses scalar tails, and retains scalar operation when the
target has no SIMD capability. Empty and one-byte fast returns and bounded
suffix traversal avoid setup/checking overhead. Public APIs, wire formats,
allocations, parser errors and CPU feature defaults remain unchanged.

Baseline: `107ad5dbd1ada61cd26314e09aac837b9ce8ee2e`. Last evaluated candidate code:
`09a18f9d8fd6362715b6863964af3373615ff678`. Commands, environment, source
provenance and raw samples are in `baseline.md`, `implementation.md` and `raw/`.

## Exact validation helper, physical Apple M2

Zig 0.17.1, Darwin 27, native CPU target. Ten independent processes per mode,
each with a warmup and >=10ms retained sample per case, alternating order.
The final matrix includes 0..8, 15/16/17, 31/32/33, 63/64/65, 128/256/512,
1/4/16/64KiB, and valid values or DEL at the first/middle/last position.

| Valid value bytes | Fast scalar → candidate ns/op | Reduction | Safe scalar → candidate ns/op | Reduction |
| ---: | ---: | ---: | ---: | ---: |
| 0 | 1.233 → 1.226 | 0.50% | 1.236 → 1.238 | -0.20% |
| 1 | 1.510 → 0.940 | 37.72% | 1.817 → 0.928 | 48.94% |
| 7 | 6.749 → 4.963 | 26.46% | 6.762 → 4.950 | 26.80% |
| 8 | 7.688 → 5.615 | 26.96% | 7.682 → 5.556 | 27.68% |
| 16 | 14.828 → 1.805 | 87.82% | 14.965 → 1.806 | 87.93% |
| 1,024 | 923.295 → 34.112 | 96.31% | 930.842 → 34.250 | 96.32% |

Full medians, minimum/maximum and throughput are in
`raw/followup-v3/summary-{fast,safe}.csv`. Sub-vector-width gains come from the
equivalent scalar predicate, not SIMD. The separate scan-only experiment gives
94.44% (Fast) / 92.20% (Safe) time reduction at 1KiB with matching scalar/vector
search interfaces; this is distinct from the complete helper comparison above.

The initial helper had empty/one-byte setup regressions; the two followup
iterations and their raw evidence are retained. The final valid-small-value
measurements do not show a reproducible >5% slowdown.

There is a specific exception to a blanket per-kernel relative-regression
criterion: ReleaseFast DEL-first rejection takes ~1.8ns instead of ~1.5ns for
short values, or ~2.1ns with a full vector block. This is ~0.3–0.6ns absolute
overhead (20–40% relative). ReleaseSafe is approximately unchanged in those
cases. Middle/last rejection generally benefits. Do not describe this change
as faster for every input. Malformed-HTTP network performance is not established
by the valid-request E2E measurements; its security semantics are covered by
differential and existing adversarial/transport tests. This exception is
explicitly retained for review against the provisional adoption thresholds.

## Full HTTP server

Authoritative final candidate dataset: `raw/final-http/`, collected using the same original
main executables and the final helper executables. Ten independently restarted
AB/BA pairs for each combination of Threaded/Reactor, Fast/Safe, and empty/4KiB
Cookie value. Each process has 1s warmup and 5s measured load, eight keep-alive
connections and `/json`, with exact body preflight. Retained acceptance pairs
are required to have zero measured HTTP errors.

Two baseline Reactor/Fast/small attempts failed that requirement. The first
collector did not persist the failed oha body, so its detailed cause is unknown.
It stopped before either member of that pair was retained. Failure persistence
was fixed and the complete pair was repeated; earlier complete pairs remained
unchanged. The failure and the missing diagnostic are explicitly documented in
`raw/final-http/failed-attempt-reactor-fast-small-pair5.md`.

The second failure returned 369,203 HTTP 200 responses, two premature connection
closures and four canceled operations. Its cause remains unresolved. The failed
oha stdout/stderr and server log are retained, and the already completed first
member was archived under `discarded-pair6-candidate/` before repeating the
whole pair. See `failed-attempt-reactor-fast-small-pair6.md`. Successful-pair
statistics are conditional on the zero-error acceptance rule; these failed
attempts must be considered separately when assessing reliability.

`raw/final-http/http-summary.csv` records median requests/sec, P50/P95/P99,
paired throughput-gain confidence intervals, RSS snapshots, OS-reported peak
RSS, and server CPU ns/request. CPU excludes the load generator and includes
startup, warmup, load and shutdown; it is normalized by all successful requests
including the warmup and preflight. The older root-level HTTP reports are the
initial implementation, not the final acceptance dataset.

| Runtime/mode | Cookie bytes | Median paired rps gain | Paired mean 95% interval | P95 old → candidate, ms | P99 old → candidate, ms |
| --- | ---: | ---: | --- | --- | --- |
| Threaded/Fast | 0 | -0.121% | -0.685..0.397% | .102313 → .102459 | .125250 → .124229 |
| Threaded/Fast | 4096 | 5.810% | 5.152..6.549% | .141146 → .133771 | .183938 → .176250 |
| Threaded/Safe | 0 | -0.303% | -0.699..0.436% | .102104 → .102375 | .123854 → .122729 |
| Threaded/Safe | 4096 | 6.197% | -1.662..29.823% | .151250 → .145542 | .206145 → .200354 |
| Reactor/Fast | 0 | 4.232% | -22.512..36.650% | .336313 → .323459 | .435896 → .433438 |
| Reactor/Fast | 4096 | 17.429% | 16.634..17.814% | .290854 → .243020 | .327021 → .276417 |
| Reactor/Safe | 0 | -0.825% | -4.911..1.473% | .167750 → .175646 | .229480 → .237292 |
| Reactor/Safe | 4096 | 11.824% | 11.428..12.636% | .358084 → .320833 | .415104 → .382396 |

The full table including CPU and memory is `raw/final-http/table.md`.
Long-Cookie CPU/request falls 12.50% / 13.12% for Threaded Fast/Safe and
11.13% / 8.59% for Reactor Fast/Safe. Peak RSS differences range -40..+24KiB
across workloads; these small process-level differences are not allocator gains.
Small Reactor/Safe P95 rises 4.71%, P99 3.40%, and CPU/request 6.14%.
Paired throughput uncertainty includes zero for all small workloads and for
Threaded/Safe long input. Large scatter and collection pauses are visible in
timestamps/raw data. No samples were removed as slow outliers. Thus the large
input gains do not establish the required overall absence of regressions.

The result applies to the stated local HTTP workloads. It is not a claim of
the same improvement for DB/TLS-heavy applications, other concurrency levels,
or an unspecified traffic mix. Multipart shares the validated primitive; full
multipart upload throughput has not been measured separately.

## Candidates not adopted

| Candidate | Evidence and decision |
| --- | --- |
| Shared HTTP/MIME control scan | Valid 1KiB improves 96.31% Fast / 96.32% Safe on M2 and long-Cookie HTTP CPU improves, but DEL-first Fast and small Reactor/Safe tails regress. Original call sites restored; private experiment retained. |
| JSON vector escaping | At 1KiB clean ASCII, Fast 652.222 → 51.681ns (-92.08%). Dense escapes regress 22.47% Fast / 43.69% Safe on M2; 8-byte clean strings regress 9.09% Fast. Preserve production JSON. |
| WebSocket mask kernels | At 1KiB, explicit vector32 copy-then-XOR saves 89.72%; fusion cuts that vector result another 41.43%. Scalar fusion alone saves 4.47%. Word32/64, unrolled, vector16/32 and both memory-pass variants are retained separately. Small inputs can regress, and full decode/network + dynamic-key setup evidence is missing. Preserve production decoder. |
| Form bulk scalar/vector | At 1KiB clean ASCII, bulk scalar saves 22.32%, vector bulk 92.41%; dense `+` input is ~5.4x slower for both bulk approaches. Preserve production Form decoding. |
| Form direct scalar output | Separately removes per-byte ArrayList operations, with the same reserve/toOwnedSlice contract. At 1KiB, saves 27.61% clean ASCII and 26.86% dense `+`, but only 3.12% for the percent-encoded Japanese fixture in Fast. No full application E2E evidence. Experimental only. |
| HTTP names/targets/numeric checks | No measured replacement selected. Keep the existing security-sensitive validation. |
| HTTP/MIME boundary search | std.mem already has SIMD scalar-search/equality and length-dependent substring algorithms. No replacement demonstrated a justified application benefit. |

The masking experiment uses a fixed mask and hot reusable buffers. Compiler
constant propagation of mask setup is possible; these figures are kernel
comparisons, not frame-decode throughput. Fusion and SIMD are deliberately
reported separately. Form direct/scalar-bulk/vector-bulk controls similarly
separate ArrayList overhead from bulk-copy and vector-search effects.

## Native, Wasm and execution environments

- Physical M2/macOS: final kernel and HTTP E2E evidence, both modes.
- CI M1 virtual/macOS and Xeon 8370C/Linux x86-64: independent native kernel
  runs, both modes. The initial 1KiB field-search reductions are 94.70% and
  93.78% respectively in Fast; VM scatter is retained, not hidden by a CI speed
  threshold. Final-version artifacts additionally cover Linux ARM64.
- Final source `09a18f9` CI hardware is AMD EPYC 9V74 (Linux x86-64),
  Neoverse-N2 (Linux ARM64), and Apple M1 Virtual. At valid 1KiB, exact-helper
  time reductions are respectively 93.94%/92.71%, 92.84%/92.85%, and
  96.36%/96.26% (Fast/Safe). Full ten-process data and environments are in
  `raw/ci-final/`; intermediate-source runs are in `raw/ci-d3/`.
- x86-64 baseline and v3, Linux AArch64, Wasm with/without SIMD128: instruction
  probes; a cross-build alone is not performance validation.
- Local Node v24.19.0: standalone Wasm scalar/SIMD probes in Fast and Safe;
  times include JS/Wasm call and harness overhead. Existing application ABI/D1
  host checks pass for original/final Fast/Safe artifacts.
- Local workerd via existing Wrangler 4.120.0: both feature configurations pass
  116,359 checks each, in Fast and Safe. Runtime supports only 2026-08-08, so
  this temporary probe date is older than the unchanged application's date.
- Real Cloudflare: not deployed or measured. Stock application Wasm still has
  no explicitly enabled SIMD128 feature. Native mask-kernel gains are not
  counted as Workers gains. No live Workers CPU/latency improvement is claimed.

Native NEON, baseline SSE and AVX-enabled probe output, plus `v128` operations
and scalarized Wasm output, are retained in `codegen.md` and `raw/`.

## Size, allocations and measurement limits

The local competitive Native executable changes from 1,879,184 to 1,879,296
bytes in Fast (+112), and 2,287,680 to 2,287,776 in Safe (+96). The common helper
does not allocate. The allocation profile retains parse: one allocation / 896
requested bytes; JSON header/body: two / 291; warm 1,000 JSON responses: zero
backing-heap allocations. Final process memory/CPU samples are in the HTTP CSV.
These size and memory comparisons describe the evaluated candidate. After
restoring the original call sites, no runtime optimization or associated
size increase is adopted; the private experiment module is not imported by
the public library. Benchmark-only instrumentation remains.

Actual application Wasm sizes and probe sizes are recorded separately. SIMD
probe size changes must not be presented as application Wasm changes. Initial
build RSS/times and later cached builds used different cache/load conditions;
they are recorded but do not establish a build-time improvement. Per-operation
hardware cycles were not collected. Scientific claims use isolated alternating
samples, not the exploratory stock-micro logs collected during other activity.

Last evaluated candidate Wasm changes from 1,172,489 to 1,172,873 bytes in Fast (+384),
and 1,084,507 to 1,084,895 in Safe (+388). Standalone Fast probes are 3,418 bytes
without SIMD128 and 3,163 with it; Safe probes are 7,735 and 7,476 respectively.

The existing portable benchmark now honors `-Doptimize=ReleaseSafe` and prints
an observable checksum. The identical measurement-only changes were applied
to the original main worktree for its control comparison. The patch and ten
alternating process results per mode are retained under `raw/portable/`.
`raw/portable/summary.csv` reports medians and ranges: typed-event encoding is
101.5 → 101.5ns Fast and 134 → 135ns Safe. This unchanged-path control is not
evidence for a SIMD gain.

## Correctness, CI and remaining work

See `correctness.md` for exhaustive byte/length/alignment comparisons, random
Form input, Writer/allocation failure, immutable mask input, and actual guard
pages. Both modes pass the ten standalone tests. Existing mandatory CI and
Linux/macOS TSan are run on the work branch; exact run states/source SHAs are
retained in `raw/` with links in the final report.

Last evaluated candidate `09a18f9` passed [CI 26/26 jobs](https://github.com/moribit/Akamata/actions/runs/45646492481)
and [TSan 2/2 jobs](https://github.com/moribit/Akamata/actions/runs/45646495583).
The collector-only `9d12de4` passed [mandatory CI](https://github.com/moribit/Akamata/actions/runs/45743683827).

Remaining scope: live Cloudflare CPU/latency, Linux HTTP E2E, full Multipart and
Form request benchmarks, dynamic-key full WebSocket decode/network workloads,
application-specific Ehagaki data, cold-memory behavior, and other CPU families.
No merge, release, consumer dependency update, or production deployment occurs.
