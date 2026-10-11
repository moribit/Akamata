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
deadlineは取得可否の期限です。OSのschedulingやmutex再取得による復帰遅延までの厳密な上限ではありません。
標準Conditionの待機数上限は`PoolOverloaded`で保護します。
`initWithOptions`でIoと既存`am.mw.MetricsCounters`を明示できます。
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

## Native runtime metrics

既存metrics middleware/exporterと同じCounters ownerを`app.serve(.{ .metrics = &counters })`へ渡します。defaultのnullではruntime計測を無効にします。

| Prometheus名 | 型・単位 | 計測対象 |
|---|---|---|
| akamata_http_connections_active | gauge・接続 | idle / upgradeを含む、受け入れたconnection thread |
| akamata_http_connections_idle | gauge・接続 | 最初のrequestを含むHTTP idle readiness待機。upgradeは対象外 |
| akamata_http_connections_rejected_total | counter・接続 | 接続上限・thread spawn失敗による拒否 |
| akamata_http_connection_threads_created_total | counter・thread | 成功したconnection thread生成 |
| akamata_http_connection_lifetime_seconds | summary・秒 | 終了したconnection threadの回数と生存時間の合計 |
| akamata_http_shutdown_drain_seconds | summary・秒 | shutdown開始から最後のconnection終了までの回数と時間の合計 |

Native Threaded専用でlabelはありません。gaugeは並行処理のsnapshotであり、複数metricの一括transactionではありません。生存時間はthread開始時から、drainにはacceptor終了を含みます。CPU-bound handlerの終了は協調的で、I/O drain deadlineを超える場合があります。

## Requestの処理段階

`akamata_http_phase_seconds`はcount / sumを持つ秒単位のsummaryです。固定label `phase`は`read`、`parse`、`route_middleware`、`handler`、`serialize`、`write`の6種類です。route値や利用者IDをlabelにしません。`App.metrics`はin-process testを含むapplication計測用に同じCounters ownerを明示borrowします。Native serveはServeOptionsから設定し、drain後に元のpointerへ戻します。

readにはreadiness / idle待機を含みます。parseは成功requestだけでなくsession stepを数えます。route / middlewareはdispatch経過時間からterminal handler時間を引いた値です。handlerにはbindingとJSON serializationを含み、serializeはResponse.jsonを計測します。writeはbuffered HTTPのheader serializationとflushを含み、同期streamとupgrade frame I/Oは対象外です。これらは重複する計測なので、request totalとして加算したりCPU時間とみなしたりしないでください。WorkersではApp.metricsからapplicationのhandler / serializationを有効にできますが、Native socket / read / parse / writeのmetricは利用できません。既存DB query span、backend metric、Server-Timingは維持します。
