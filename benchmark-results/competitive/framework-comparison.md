# Competitive comparison — interim baseline

Frozen fixture source: `023b101d6c3b3b22b2e5bed489c3e398cefa3098`.
Akamata core baseline: `8a521fb16e2a6dbffb92627b73350cdb8c551925`.
Mac M2, macOS 27, Release builds, HTTP/1.1 loopback, oha 1.15.0.
See [methodology](methodology.md), [environment](raw/environment.json) and
[manifest](raw/baseline-manifest.json) for versions, commands and binary hashes.

This is **one subset**, not the complete competitive matrix or a release claim.
The fanless workstation showed variation across rounds. Generator CPU was
substantial; [split-generator calibration](generator-calibration.md) completed without improved throughput from splitting. Values describe this local
experiment, not a controlled server ceiling or universal framework ranking.

Evidence: `benchmark-results/competitive/raw/baseline-plaintext-32.json`; classification: requested-duration.

Medians of all completed rounds. Latency columns are medians of round percentiles, not pooled percentiles. CPU: one core = 100%. RSS: median of round sampled means. Errors are summed, never removed.

| Workload | Connections | Framework | Rounds | req/s | P50 ms | P95 ms | P99 ms | P99.9 ms | CPU % | RSS KiB | Threads | Non-200 | Client errors |
|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| plaintext | 32 | actix | 5 | 86,758 | 0.359 | 0.444 | 0.586 | 3.014 | 214.8 | 7,232 | 10 | 0 | 0 |
| plaintext | 32 | akamata-reactor | 5 | 71,292 | 0.424 | 0.640 | 0.903 | 1.311 | 159.6 | 5,392 | 9 | 0 | 0 |
| plaintext | 32 | akamata-threaded | 5 | 89,479 | 0.346 | 0.430 | 0.569 | 2.553 | 206.3 | 8,233 | 40 | 0 | 0 |
| plaintext | 32 | axum | 5 | 94,506 | 0.329 | 0.427 | 0.545 | 1.512 | 214.8 | 7,119 | 9 | 0 | 0 |
| plaintext | 32 | go | 5 | 83,211 | 0.352 | 0.609 | 1.167 | 4.018 | 334.4 | 23,477 | 17 | 0 | 0 |
| plaintext | 32 | zap | 5 | 86,024 | 0.348 | 0.543 | 1.029 | 5.139 | 300.2 | 30,304 | 9 | 0 | 0 |

Failed cases: 0. Full requested matrix completion is not implied by a subset table.

## Remaining evidence

Other workloads and connection levels, allocation attribution, idle resources,
private runtime candidates and paired post-change results are pending.
No production runtime gate has changed. No winning claim is made.
