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
Wrong clocks return `InvalidDeadlineClock`; cancelable timed Io waits may return
`Canceled`. The bounded standard condition waiter representation is protected by
`PoolOverloaded` rather than overflowing. `initWithOptions` accepts an explicit
Io owner and existing `am.mw.metrics.Counters`; both must outlive the pool.

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
