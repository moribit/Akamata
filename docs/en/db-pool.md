# DB Pool deadlines and ownership

`Pool.init(allocator, handles)` and `acquire()` retain their existing behavior.
Initialization transfers handle ownership only on success. A pool must remain at
a stable address. Contexts and handlers borrow leases; they never destroy the pool.

```zig
var pool = try am.db.Pool.init(allocator, &.{db});
defer pool.deinit();
var lease = try pool.acquireWithDeadline(pool.deadlineAfter(250));
defer lease.deinit();
```

`tryAcquire()` returns null on exhaustion, and `PoolClosed` after closure.
`acquireWithDeadline()` takes an absolute `std.Io.Clock.Timestamp` on the `.awake`
monotonic clock. Spurious wakeups and progress do not renew the budget. Under the
pool mutex, closure wins over timeout; timeout wins over an available connection.
The deadline bounds eligibility, not OS scheduling or mutex reacquisition latency.
Wrong clocks return `InvalidDeadlineClock`; cancelable timed Io waits may return
`Canceled`. The bounded standard condition waiter representation is protected by
`PoolOverloaded` rather than overflowing. `initWithOptions` accepts an explicit
Io owner and existing `am.mw.MetricsCounters`; both must outlive the pool.

Call `close()` to stop acquisition and wake waiters. Stop starting calls before
`deinit()`, which joins already-entered acquisitions and outstanding leases before
closing databases and freeing storage. Return every lease before calling deinit
on the same thread. This is cooperative: queries are not preempted. Do not copy
leases or use their Db after release. Generation checks prevent a stale copied
lease from releasing a subsequently borrowed slot; they do not authorize copying.

Prometheus metrics use the existing `akamata_` prefix and no labels:

| Name suffix | Type / unit | Measurement |
|---|---|---|
| db_pool_active_connections | gauge / handles | outstanding leases |
| db_pool_idle_connections | gauge / handles | available handles; zero after close |
| db_pool_waiters | gauge / callers | currently blocked acquisitions |
| db_pool_acquire_wait_seconds | summary / seconds | count and total duration of acquisitions that waited |
| db_pool_acquire_timeouts_total | counter / attempts | expired acquisitions, including immediate expiry |

Gauges aggregate pools sharing a Counters owner. Wait summaries include mutex
reacquisition and the final outcome, with no quantile approximation. Immediate
successful/nonblocking acquisitions do not enter the wait summary. Pool metrics
are Native-only; Workers D1 bindings do not use this native connection pool.

## Native runtime metrics

Pass the same borrowed Counters owner to `app.serve(.{ .metrics = &counters })` and the existing metrics middleware/exporter. Default null disables runtime instrumentation.

| Prometheus name | Type / unit | Meaning |
|---|---|---|
| akamata_http_connections_active | gauge / connections | admitted connection threads, including idle and upgrades |
| akamata_http_connections_idle | gauge / connections | HTTP idle readiness wait, including initial request; excludes upgraded sessions |
| akamata_http_connections_rejected_total | counter / connections | connection-limit and thread-spawn rejection |
| akamata_http_connection_threads_created_total | counter / threads | successful connection thread spawns |
| akamata_http_connection_lifetime_seconds | summary / seconds | completed connection thread count and lifetime sum |
| akamata_http_shutdown_drain_seconds | summary / seconds | shutdown-start to final connection exit, count and sum |

Native Threaded only, no labels. Gauges are concurrent snapshots rather than atomic multi-metric transactions. Lifetime begins at thread entry; drain includes acceptor shutdown. CPU-bound handlers remain cooperative and can exceed the I/O drain deadline.

## Request phases

`akamata_http_phase_seconds` is a summary (count/sum, seconds) with one fixed `phase` label: `read`, `parse`, `route_middleware`, `handler`, `serialize`, `write`. No route values or identities are labels. `App.metrics` explicitly borrows the same Counters owner for application phases, including in-process tests. Native serve supplies it from ServeOptions and restores the previous pointer after drain.

Read includes readiness/idle wait; parse counts session steps, not only successful requests. Route/middleware is dispatch elapsed time minus terminal handler time. Handler includes binding and JSON serialization; serialize measures Response.json. Write covers buffered HTTP response serialization and flush; synchronous streaming and upgraded frame I/O are currently outside this phase metric. These inclusive measurements overlap: do not add them as a request total or treat wall time as CPU time. Workers can enable application handler/serialization phases with App.metrics, while native socket/read/parse/write metrics are unavailable there. Existing DB query spans, backend metrics and Server-Timing remain unchanged.
