# DB Poolのdeadlineとownership

既存の`Pool.init(allocator, handles)`と`acquire()`の使い方は維持します。
初期化成功時だけDB handleのownershipがPoolへ移ります。Poolのアドレスを
固定し、handlerはleaseを借用します。

```zig
var pool = try am.db.Pool.init(allocator, &.{db});
defer pool.deinit();
var lease = try pool.acquireWithDeadline(pool.deadlineAfter(250));
defer lease.deinit();
```

`tryAcquire()`は枯渇時にnull、close後に`PoolClosed`を返します。
`acquireWithDeadline()`は単調時計`.awake`の絶対`std.Io.Clock.Timestamp`を
受け取ります。spurious wakeupや進捗で期限を更新しません。mutex内の判定では
closeをtimeoutより優先し、timeoutを空き接続より優先します。不正な時計は
`InvalidDeadlineClock`、cancel可能なIo待機は`Canceled`を返し得ます。
標準Conditionの待機数上限は`PoolOverloaded`で保護します。
`initWithOptions`でIoと既存`am.mw.metrics.Counters`を明示できます。
どちらのownerもPoolより長く生存させてください。

`close()`は新規取得を停止し待機者を起こします。`deinit()`開始前に新規呼出しを
止めてください。deinitは既に開始した取得処理とlease返却を待ち、DBを閉じて
メモリを解放します。同じスレッドでdeinitする前に全leaseを返してください。
queryの強制preemptは行いません。leaseをコピーしたり返却後にDbを使ったり
しないでください。世代検査は古いコピーによる新leaseの返却を防ぐ防御です。

既存Prometheus exporterへ以下を追加します。prefixは`akamata_`、labelなしです。

| 名前のsuffix | 型・単位 | 計測対象 |
|---|---|---|
| db_pool_active_connections | gauge・handle | 借用中の接続 |
| db_pool_idle_connections | gauge・handle | 空き接続。close後は0 |
| db_pool_waiters | gauge・caller | Condition待機中の取得処理 |
| db_pool_acquire_wait_seconds | summary・秒 | 待機した取得処理の回数と合計時間 |
| db_pool_acquire_timeouts_total | counter・attempt | 即時期限切れを含むtimeout |

同じCountersを使うPoolのgaugeを集計します。待機時間にはmutexの再取得と
最終判定を含み、quantileは計算しません。即時取得と非blocking取得はwait summaryへ
入れません。Native専用の計測です。Workers D1はこの接続Poolを使いません。
