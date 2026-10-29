# Completed matrix: decision evidence

Apple M2, macOS 27.0, ReleaseFast Akamata, HTTP/1.1 loopback, oha 1.15.0.
Warmup 10 s + measurement 30 s × five rounds; medians of all rounds.
Latency is median of round percentiles for completed requests, not pooled latency or a timeout-inclusive SLO.
CPU: one core = 100%. RSS is median sampled round mean. All client errors retained.
Exact source/toolchain/binary identities and invocations are in the raw matrices and manifests.

## Observed Threaded before/after at 32 connections

Separate time cohorts: observed differences are not causal optimization estimates.

| Workload | Before HTTP 200/s | After HTTP 200/s | Change % | Before P99 ms | After P99 ms | Before CPU % | After CPU % | Before RSS KiB | After RSS KiB | Before/after client errors |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| plaintext | 89,479 | 142,245 | +59.0 | 0.569 | 0.863 | 206.3 | 340.9 | 8,233 | 8,281 | 0 / 0 |
| json | 136,871 | 154,732 | +13.0 | 1.045 | 0.878 | 321.7 | 336.2 | 8,186 | 8,403 | 0 / 23 |
| routing | 132,714 | 144,203 | +8.7 | 1.022 | 0.924 | 318.2 | 323.6 | 8,232 | 8,280 | 0 / 18 |
| db | 85,302 | 125,333 | +46.9 | 1.776 | 1.734 | 299.2 | 345.7 | 8,325 | 8,172 | 0 / 15 |
| echo-64 | 136,583 | 137,240 | +0.5 | 1.117 | 1.272 | 322.0 | 302.8 | 8,217 | 8,511 | 0 / 0 |
| echo-1024 | 120,336 | 129,342 | +7.5 | 1.468 | 1.057 | 293.4 | 315.8 | 8,627 | 8,597 | 0 / 0 |
| echo-65536 | 52,852 | 51,136 | -3.2 | 1.004 | 1.338 | 251.5 | 243.9 | 14,059 | 14,327 | 0 / 0 |

## Final runtime cohort

| Workload | Connections | Runtime | HTTP 200/s | vs final Threaded % | P95 ms | P99 ms | CPU % | RSS MiB | Threads | Client errors |
|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|
| plaintext | 32 | akamata-threaded-after | 142,245 | +0.0 | 0.397 | 0.863 | 340.9 | 8.1 | 40 | 0 |
| plaintext | 32 | akamata-reactor-single-after | 72,121 | -49.3 | 0.618 | 0.788 | 182.9 | 5.3 | 9 | 0 |
| plaintext | 32 | akamata-reactor-sharded-after | 96,831 | -31.9 | 0.584 | 0.881 | 371.0 | 6.2 | 12 | 0 |
| json | 32 | akamata-threaded-after | 154,732 | +0.0 | 0.376 | 0.878 | 336.2 | 8.2 | 40 | 23 |
| json | 32 | akamata-reactor-single-after | 88,652 | -42.7 | 0.495 | 0.607 | 190.7 | 5.3 | 9 | 0 |
| json | 32 | akamata-reactor-sharded-after | 103,508 | -33.1 | 0.658 | 0.796 | 324.1 | 6.2 | 12 | 0 |
| db | 32 | akamata-threaded-after | 125,333 | +0.0 | 0.555 | 1.734 | 345.7 | 8.0 | 40 | 15 |
| db | 32 | akamata-reactor-single-after | 75,114 | -40.1 | 0.647 | 0.828 | 226.4 | 5.4 | 9 | 0 |
| db | 32 | akamata-reactor-sharded-after | 98,481 | -21.4 | 0.569 | 0.787 | 363.6 | 6.3 | 12 | 0 |
| echo-1024 | 32 | akamata-threaded-after | 129,342 | +0.0 | 0.453 | 1.057 | 315.8 | 8.4 | 40 | 0 |
| echo-1024 | 32 | akamata-reactor-single-after | 77,193 | -40.3 | 0.601 | 0.820 | 170.6 | 5.9 | 9 | 0 |
| echo-1024 | 32 | akamata-reactor-sharded-after | 95,808 | -25.9 | 0.636 | 0.863 | 336.3 | 6.6 | 12 | 0 |
| echo-65536 | 32 | akamata-threaded-after | 51,136 | +0.0 | 0.744 | 1.338 | 243.9 | 14.0 | 40 | 0 |
| echo-65536 | 32 | akamata-reactor-single-after | 18,973 | -62.9 | 2.229 | 2.992 | 119.8 | 10.1 | 9 | 0 |
| echo-65536 | 32 | akamata-reactor-sharded-after | 21,432 | -58.1 | 2.931 | 3.458 | 270.5 | 11.1 | 12 | 0 |
| plaintext | 512 | akamata-threaded-after | 144,047 | +0.0 | 11.964 | 21.877 | 338.7 | 67.8 | 520 | 0 |
| plaintext | 512 | akamata-reactor-single-after | 85,937 | -40.3 | 6.968 | 7.673 | 180.4 | 17.5 | 9 | 3 |
| plaintext | 512 | akamata-reactor-sharded-after | 121,101 | -15.9 | 10.715 | 12.331 | 368.4 | 18.4 | 12 | 13 |
| json | 512 | akamata-threaded-after | 171,776 | +0.0 | 11.758 | 21.505 | 326.9 | 68.0 | 520 | 0 |
| json | 512 | akamata-reactor-single-after | 95,044 | -44.7 | 6.210 | 6.884 | 185.5 | 17.5 | 9 | 0 |
| json | 512 | akamata-reactor-sharded-after | 135,349 | -21.2 | 10.672 | 11.796 | 398.7 | 18.4 | 12 | 0 |
| db | 512 | akamata-threaded-after | 131,729 | +0.0 | 15.400 | 33.821 | 349.1 | 67.2 | 520 | 0 |
| db | 512 | akamata-reactor-single-after | 82,309 | -37.5 | 7.345 | 7.760 | 229.3 | 17.6 | 9 | 0 |
| db | 512 | akamata-reactor-sharded-after | 123,987 | -5.9 | 12.531 | 15.842 | 381.3 | 18.5 | 12 | 0 |
| echo-1024 | 512 | akamata-threaded-after | 138,953 | +0.0 | 12.766 | 23.288 | 323.7 | 73.3 | 520 | 0 |
| echo-1024 | 512 | akamata-reactor-single-after | 82,653 | -40.5 | 7.637 | 8.757 | 158.8 | 23.1 | 9 | 0 |
| echo-1024 | 512 | akamata-reactor-sharded-after | 119,857 | -13.7 | 11.097 | 14.136 | 380.1 | 24.0 | 12 | 0 |
| echo-65536 | 512 | akamata-threaded-after | 29,114 | +0.0 | 18.436 | 25.095 | 200.9 | 160.9 | 520 | 0 |
| echo-65536 | 512 | akamata-reactor-single-after | 12,913 | -55.6 | 49.464 | 55.004 | 115.1 | 92.4 | 9 | 0 |
| echo-65536 | 512 | akamata-reactor-sharded-after | 14,017 | -51.9 | 83.584 | 366.327 | 181.9 | 92.4 | 12 | 0 |
| plaintext | 1024 | akamata-threaded-after | 137,681 | +0.0 | 24.293 | 39.249 | 367.4 | 131.9 | 1032 | 1720 |
| plaintext | 1024 | akamata-reactor-single-after | 94,196 | -31.6 | 12.502 | 14.402 | 179.4 | 30.5 | 9 | 0 |
| plaintext | 1024 | akamata-reactor-sharded-after | 152,274 | +10.6 | 15.651 | 19.127 | 389.7 | 31.7 | 12 | 1018 |
| json | 1024 | akamata-threaded-after | 151,338 | +0.0 | 23.115 | 37.449 | 366.7 | 133.7 | 1032 | 2043 |
| json | 1024 | akamata-reactor-single-after | 94,023 | -37.9 | 12.337 | 13.811 | 181.1 | 30.5 | 9 | 2538 |
| json | 1024 | akamata-reactor-sharded-after | 159,595 | +5.5 | 14.337 | 17.657 | 401.3 | 31.6 | 12 | 0 |
| db | 1024 | akamata-threaded-after | 126,368 | +0.0 | 25.714 | 41.619 | 361.9 | 130.2 | 1032 | 1254 |
| db | 1024 | akamata-reactor-single-after | 80,172 | -36.6 | 14.554 | 15.727 | 222.3 | 30.6 | 9 | 11 |
| db | 1024 | akamata-reactor-sharded-after | 143,240 | +13.4 | 15.629 | 19.125 | 389.4 | 31.7 | 12 | 0 |
| echo-1024 | 1024 | akamata-threaded-after | 125,718 | +0.0 | 26.204 | 43.403 | 345.6 | 143.9 | 1032 | 1162 |
| echo-1024 | 1024 | akamata-reactor-single-after | 82,384 | -34.5 | 16.076 | 18.022 | 154.7 | 45.6 | 9 | 68 |
| echo-1024 | 1024 | akamata-reactor-sharded-after | 126,795 | +0.9 | 18.417 | 22.627 | 371.6 | 41.8 | 12 | 0 |
| echo-65536 | 1024 | akamata-threaded-after | 24,861 | +0.0 | 142.606 | 459.215 | 183.0 | 321.8 | 1057 | 613 |
| echo-65536 | 1024 | akamata-reactor-single-after | 12,712 | -48.9 | 89.942 | 97.717 | 114.1 | 178.2 | 9 | 1231 |
| echo-65536 | 1024 | akamata-reactor-sharded-after | 8,802 | -64.6 | 458.131 | 1013.514 | 93.7 | 173.0 | 12 | 1 |

## Baseline competitive cohort at 32 connections

Compare competitors within this cohort; do not rank final Akamata against earlier competitor runs.

| Workload | Framework | HTTP 200/s | P95 ms | P99 ms | CPU % | RSS MiB | Client errors |
|---|---|---:|---:|---:|---:|---:|---:|
| plaintext | akamata-threaded | 89,479 | 0.430 | 0.569 | 206.3 | 8.0 | 0 |
| plaintext | akamata-reactor | 71,292 | 0.640 | 0.903 | 159.6 | 5.3 | 0 |
| plaintext | actix | 86,758 | 0.444 | 0.586 | 214.8 | 7.1 | 0 |
| plaintext | axum | 94,506 | 0.427 | 0.545 | 214.8 | 7.0 | 0 |
| plaintext | go | 83,211 | 0.609 | 1.167 | 334.4 | 22.9 | 0 |
| plaintext | zap | 86,024 | 0.543 | 1.029 | 300.2 | 29.6 | 0 |
| json | akamata-threaded | 136,871 | 0.433 | 1.045 | 321.7 | 8.0 | 0 |
| json | akamata-reactor | 80,157 | 0.585 | 0.809 | 181.2 | 5.2 | 0 |
| json | actix | 133,064 | 0.435 | 1.094 | 291.3 | 8.0 | 0 |
| json | axum | 146,237 | 0.421 | 0.715 | 285.8 | 7.4 | 0 |
| json | go | 117,710 | 0.721 | 1.981 | 359.6 | 23.6 | 0 |
| json | zap | 122,881 | 0.543 | 1.707 | 316.7 | 29.6 | 0 |
| db | akamata-threaded | 85,302 | 0.573 | 1.776 | 299.2 | 8.1 | 0 |
| db | akamata-reactor | 72,020 | 0.671 | 0.967 | 208.9 | 5.4 | 0 |
| db | actix | 115,019 | 0.537 | 1.720 | 298.0 | 7.9 | 0 |
| db | axum | 123,899 | 0.514 | 1.148 | 303.0 | 7.4 | 0 |
| db | go | 93,726 | 0.830 | 1.865 | 370.2 | 23.4 | 0 |
| db | zap | 121,697 | 0.545 | 1.487 | 323.2 | 29.6 | 0 |
| echo-1024 | akamata-threaded | 120,336 | 0.531 | 1.468 | 293.4 | 8.4 | 0 |
| echo-1024 | akamata-reactor | 72,733 | 0.656 | 0.876 | 166.6 | 5.8 | 0 |
| echo-1024 | actix | 114,985 | 0.472 | 1.398 | 268.0 | 9.3 | 0 |
| echo-1024 | axum | 129,261 | 0.440 | 0.913 | 268.5 | 7.5 | 0 |
| echo-1024 | go | 96,165 | 0.900 | 2.002 | 352.0 | 24.4 | 0 |
| echo-1024 | zap | 120,485 | 0.540 | 1.794 | 310.9 | 29.8 | 0 |

## Round spread: plaintext at 32 connections

This spread is retained rather than selecting the best round. It limits attribution and ranking.

| Framework | Round 1 | Round 2 | Round 3 | Round 4 | Round 5 |
|---|---:|---:|---:|---:|---:|
| akamata-threaded | 105,402 | 95,146 | 89,479 | 87,202 | 85,419 |
| akamata-reactor | 87,385 | 74,406 | 71,292 | 69,951 | 68,816 |
| actix | 104,452 | 88,680 | 86,758 | 81,369 | 83,522 |
| axum | 114,529 | 96,120 | 94,506 | 90,867 | 91,204 |
| go | 97,014 | 94,281 | 83,211 | 80,571 | 77,561 |
| zap | 97,015 | 86,043 | 86,024 | 82,349 | 79,240 |
| akamata-threaded-after | 93,206 | 109,635 | 154,506 | 142,245 | 142,458 |
| akamata-reactor-single-after | 61,085 | 66,948 | 98,066 | 72,121 | 98,232 |
| akamata-reactor-sharded-after | 86,944 | 36,619 | 130,245 | 96,831 | 109,622 |

## Completion and errors

1260 baseline + 630 after distinct cases. Failed attempts: 0; forced runner kills: 0; non-200 responses: 0.
Nine pre-cleanup zap large-echo cases remain excluded raw evidence and were replaced, independent of performance.
Client error reasons and server exit codes are preserved in [validation](raw/matrix-validation.json).
Go's -2 exits are the runner's SIGINT shutdown, not forced runner kills or a graceful-drain proof.
See the full baseline/after/matrix tables for all 1/8/32/128/512/1024 connection levels and seven workloads.
