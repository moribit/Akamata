# Local generator calibration

Evidence: `benchmark-results/competitive/raw/generator-calibration-32.json`. Binary hashes, commands and individual oha distributions are retained there.

One versus two generators at the same total connection count. Recorded (connections, warmup seconds, measurement seconds): [(32, 10, 30)]. Values below use all available rounds; a partial file is not a completed calibration.

| Framework | Generators | Rounds | Median completed HTTP 200/s | Min | Max | Median server CPU % | Client errors | Non-200 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| akamata-threaded | 1 | 5 | 99,370 | 88,647 | 105,923 | 211.6 | 0 | 0 |
| akamata-threaded | 2 | 5 | 87,920 | 82,974 | 99,325 | 205.2 | 0 | 0 |
| axum | 1 | 5 | 95,460 | 91,883 | 112,377 | 215.0 | 0 | 0 |
| axum | 2 | 5 | 90,516 | 86,745 | 105,912 | 210.7 | 0 | 0 |

Splitting a generator also changes scheduling and CPU contention on the same machine. No improvement from splitting does **not** prove unlimited generator headroom. This remains a local closed-loop measurement; dedicated remote generation is needed for stronger server-ceiling claims. Individual latency distributions are not pooled or averaged. CPU: one core = 100%.
