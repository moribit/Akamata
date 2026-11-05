# Direct C SQL-length control

Same final executable, only explicit length parameter differs. Three rounds, medians.
All inputs refer to the same valid sentinel-backed literal. Not a production API change.

| Threads | Excluding NUL ops/s | Including NUL ops/s | -1 ops/s |
|---|---:|---:|---:|
| 1 | 819333 | 829714 | 825025 |
| 8 | 1110204 | 1119438 | 1111896 |
| 32 | 257613 | 227278 | 245073 |
| 128 | 157657 | 156401 | 153058 |

The one-thread difference is small; high-concurrency rounds are dispersed.
This does not identify the historical HTTP gap or justify changing Db.prepare to
read beyond a slice. No sentinel-specific public API or stack-copy shortcut is added.
