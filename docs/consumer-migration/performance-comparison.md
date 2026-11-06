# Performance evidence

No new Consumer performance comparison has been measured. Build durations and functional E2E success are not latency or throughput benchmarks. Existing Akamata competitive/DB evidence is retained unchanged in `benchmark-results/`; it cannot establish Consumer production performance.

Before any performance claim, freeze baseline/candidate artifacts and record environment, workload, warmup, repeated alternating measurements, errors, CPU/RSS and P50/P95/P99. Production probes must be read-only and bounded. No regression or improvement is claimed at this checkpoint.

## Final reliability fixes

2714af0 keeps the Threaded default and parked Reactor. Storage download metadata now incurs two small request-arena snapshots (Content-Type and optional ETag) to avoid use-after-cleanup. Plaintext/JSON/DB hot paths are not changed by this fix. No speedup or zero-overhead claim is made, and this functional investigation did not measure a new before/after throughput or Consumer latency series. CLI option rejection has no request-time path.
