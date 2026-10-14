# Threaded idle shutdown optimization

Baseline: frozen `023b101` binary in [manifest](raw/baseline-manifest.json).
Candidate source: the commit containing this change, Zig 0.17.0 ReleaseFast;
[candidate identity](raw/idle-refined-manifest.json) and executable digests in
the raw results identify the locally built patch. This binary also contains the
JSON numeric Writer change, which plaintext/echo measured handlers do not use.

## Ownership and semantics

Two nonblocking CLOEXEC pipe descriptors belong to the serving loop. They
outlive all detached connection owners and are closed after drain. Admission
stops before one notification; the byte remains unread so every idle waiter
observes it. Socket ownership stays with the connection thread.

Each idle-read operation first waits on the socket alone for at most 100 ms.
Active keep-alive traffic therefore keeps its existing single-descriptor path.
Only a quiet connection parks on socket plus shutdown descriptor for the
remaining absolute idle budget. Shutdown wins when both descriptors are ready.
Active partial headers/bodies and the Io.Group experiment retain their existing
100ms cancellation/deadline checks. Write budgets, forced I/O drain and
cooperative CPU-handler ownership are unchanged.

## Measurements

[Refined idle retention](raw/idle-refined-retention.json): 1024 connections,
10 seconds, three serial rounds, every retained connection checked again before
shutdown, no failed case or forced kill. CPU uses coarse ps process time with
one core=100%; these are local diagnostics, not certification.

| Metric | Before median | Refined median |
|---|---:|---:|
| Idle CPU % | 37.63 | 1.70 |
| RSS KiB | 121,936 | 121,984 |
| Threads | 1032 | 1032 |
| Shutdown ms | 125.42 | 126.20 |

[HTTP screen](raw/idle-refined-screen.json): warmup 2 s, measurement 5 s, three
rounds, same host, alternating/shuffled serial order. Completed HTTP 200/s,
not attempts/s; client errors remain in the raw data.

| Workload | Clients | Before HTTP 200/s | Refined | Before P99 ms | Refined P99 ms |
|---|---:|---:|---:|---:|---:|
| plaintext | 32 | 178,299 | 179,616 | 1.120 | 1.099 |
| echo 1 KiB | 32 | 171,508 | 172,570 | 1.238 | 1.219 |
| plaintext | 1024 | 164,764 | 168,070 | 33.461 | 33.478 |
| echo 1 KiB | 1024 | 153,769 | 157,310 | 34.374 | 33.933 |

The screen supports retaining this small idle-CPU change for full verification;
small throughput differences are not claimed as significant improvements.
The full 10/30-second five-round matrix remains separate required evidence.

## Rejected alternative

Always registering the shared descriptor on every read reduced idle CPU but
severely regressed active traffic: at 1024 plaintext clients, 167,399 → 34,210
HTTP 200/s, P99 31.981 → 238.857 ms. It is rejected. Exact kernel lock cost is
unknown; no CPU-percentage attribution is invented. The failed candidate's
[complete screen](raw/runtime-candidate-screen.json) is retained rather than
discarded. Its offline reporting-check overlap is documented; the regression
repeats across workloads and rounds and is not a basis for a success claim.
