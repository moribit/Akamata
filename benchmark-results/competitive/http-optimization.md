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

## Large-output and drain diagnostics

The post-change counter build measures approximately **2.000 send calls/request**
for 64 KiB Threaded echo at 32 connections in all three exploratory rounds.
Small responses remain approximately one send. Counter builds are not normal
throughput evidence; readVec is an operation count, not an exact recv syscall.

At 1024 large-echo clients, the original runner killed Threaded after ten seconds
and therefore could not collect final counters. Those three cases are retained
as forced cleanup, not labeled a clean exit or a zero-leak run. A separate
[45-second shutdown probe](raw/drain-probe-instrumented.json) exited normally
after 24.5 seconds with framework live bytes zero. Its wall-stack sample shows
remaining connections waiting in partial-request readiness; the writer timeout
counter is zero and read timeout count is 54. The configured body/drain budget
is 30 seconds. Why these partial connections outlive the load generator remains
a network/burst attribution question, not an invented kernel diagnosis.

Runner cleanup now allows 45 seconds, exceeding that configured budget.
Per-row limits and resume-policy changes are recorded. Runtime deadlines are
unchanged. The old ten-second forced kills must not be counted as proven leaks
or successful graceful shutdowns. Vectored output is a plausible measured
two-send target, but needs its own partial-write/Contract and before/after test
before any production change.

## Bounded two-vector candidate

The common large-body drain co-sends the existing buffered prefix and one body
slice using Zig 0.17's standard `msghdr_const`/`iovec_const` definitions. A shared
comptime-specialized send loop preserves offsets across both vectors, retries
EINTR, waits on EAGAIN, and retains absolute budget/cancellation. Arbitrary
vector/splat shapes use the existing ordered path. No heap queue or borrowed
response API is added; both input borrows live until the synchronous call ends.
A socketpair unit shrinks the send buffer and slowly reads 64 KiB, checking every
byte across partial writes and backpressure.

[Three-round normal-build screen](raw/vectored-screen.json), 2-second warmup,
5-second measurement, all rounds/errors retained:

| Workload | Clients | Before HTTP 200/s | Candidate | Before P99 ms | Candidate P99 ms |
|---|---:|---:|---:|---:|---:|
| 64 KiB echo | 32 | 76,831 | 81,592 | 2.812 | 2.673 |
| 64 KiB echo | 1024 | 24,100 | 27,528 | 430.018 | 383.216 |
| plaintext | 32 | 181,140 | 178,634 | 1.042 | 1.094 |
| plaintext | 1024 | 166,758 | 166,745 | 33.979 | 34.199 |

The large-echo improvement is promising (+6.2% / +14.2%) but this is a screen,
not final adoption evidence. Small-response changes require the longer paired
comparison; c32 P99 is slightly higher. c1024 RSS changes about 268184 → 270419
KiB and sampled peak threads 1046 → 1059, with burst/partial-connection behavior
retained in the data. No deadline or connection ceiling is relaxed to improve
these numbers. The final requested-duration comparison and affected cross-platform
Contract/TSan must determine accept/revert.

### Longer confirmation: rejected

[Requested-duration paired subset](raw/vectored-confirmation.json): 10-second
warmup, 30-second measurement, five rounds, 32 clients, no errors. This is a
completed **subset**, not the full competitive matrix.

| Workload | Before HTTP 200/s | Candidate | Before P99 ms | Candidate P99 ms |
|---|---:|---:|---:|---:|
| 64 KiB echo | 30,416 | 34,528 | 9.292 | 7.770 |
| plaintext | 89,141 | 86,566 | 1.594 | 1.936 |

Large echo improves ~13.5%, but plaintext median throughput declines ~2.9% and
P99 worsens ~21%. Plaintext P99 worsens in four of five rounds. Thermal/host
variation exists and exact causal attribution is not claimed; it does not
justify retaining the coupled scalar-path change. **Candidate reverted.**
[The patch](raw/vectored-candidate.patch) and every round remain available.
The socketpair backpressure regression is retained for the original buffered
writer. Future evaluation should keep its scalar send path intact and isolate
the large-vector path before undertaking another adoption decision.

[Counter confirmation](raw/vectored-cost.json) shows 2.000 → 1.000 send/sendmsg
invocations per parsed request in all three large-echo diagnostic rounds,
framework live bytes zero. Reducing syscalls alone did not satisfy the overall
performance gate, so production output remains the original bounded writer.
