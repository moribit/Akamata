# HTTP optimization decisions

Baseline executable source: `023b101d6c3b3b22b2e5bed489c3e398cefa3098`.
Host and toolchain: [environment](raw/environment.json). All response data remains
owned by the existing response/session arena. No borrowed-body API is introduced.

## Rejected: skipping the registry lock for an already-zero write deadline

Instrumentation found two deadline-clear calls per request and increasing
inclusive mutex wait at 1,024 connections. A candidate retained the mutex for
armed deadlines but returned early for zero. Its frozen executable and exact
command are recorded in [manifest](raw/deadline-candidate-manifest.json) and
[all 36 rounds](raw/deadline-candidate-screen.json).

This was an **exploratory screen**, warmup 2 s, measurement 5 s, three rounds,
ReleaseFast, same Mac, shuffled serial ordering, HTTP/1.1 keep-alive. It is not
the requested 10/30 s, five-round competitive matrix.

| Workload | Connections | Before HTTP 200/s | Candidate | Before P99 ms | Candidate P99 ms |
|---|---:|---:|---:|---:|---:|
| plaintext | 32 | 178,358 | 179,857 | 1.094 | 1.072 |
| JSON | 32 | 178,329 | 179,488 | 1.125 | 1.134 |
| echo 1 KiB | 32 | 169,235 | 171,938 | 1.287 | 1.265 |
| plaintext | 1,024 | 163,100 | 167,114 | 33.438 | 32.051 |
| JSON | 1,024 | 164,329 | 165,902 | 32.564 | 34.200 |
| echo 1 KiB | 1,024 | 153,755 | 155,850 | 34.984 | 33.604 |

Decision: **reverted**. The small throughput differences and inconsistent P99
do not establish a repeatable benefit. Client errors remain in the data:
echo at 1,024 had 498 before versus 757 candidate errors across three rounds.
No claim is made that this change caused those errors. All 32-connection rounds
had zero client errors. The original deadline/expiry synchronization is retained.

Short screens have different thermal/steady-state behavior from 30-second runs;
their absolute rates must not be substituted into the longer comparison table.

## Existing writer path

Threaded `Response.writeTo` already feeds Cursor slices directly into the bounded
Writer. It does not use the Reactor's `Cursor.fill` staging buffer. Small responses
fit the existing 4 KiB Writer and normally flush together. Removing a hypothetical
extra 4 KiB copy would therefore change the wrong path. Vectored output must be
justified using measured large-response send counts, preserving partial progress,
absolute deadlines, EAGAIN backpressure, streaming and arena lifetime.
