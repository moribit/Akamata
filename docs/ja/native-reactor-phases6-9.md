# Native Reactor Phase 6–9：実装・検証・公開判定

**判定は Reactor Not Ready。Threaded を production default とし、公開 `.runtime = .reactor` は `error.ExperimentalRuntimeDisabled` のまま維持します。** application execution の隔離は実装・検証できましたが、通常HTTPの大きな性能差が残りました。実装量を理由にgateを解除しません。

基準は `75fcb26`、最終runtime修正は `40ed7e4`。Phase 6 は `cf2b6c0`、Phase 7 は `82a7f73`、Phase 8 は certification runner／race検証と `26017bd`・`40ed7e4` の修正です。raw data・環境・binary SHA・command・CI結果は [Phase 8 evidence](../../benchmark/results/runtime-phase8-2026-10-05/README.md)、最適化前後は [Phase 7 evidence](../../benchmark/results/runtime-phase7-2026-10-05/README.md) にあります。旧 [Phase 2–5](native-runtime-phases.md) は履歴です。

## Phase 6：有限のapplication execution

以前はsocketを多重化していても、同期upgrade handler／stream producerがworkerのスタックを保持し、readinessやslow readerを待っていました。4長寿命upgradeが4 workerを占有すると、無関係なHTTPが250 ms以内に処理されませんでした。worker数の増加では解決していません。

```text
App → Shared HTTP Core / response cursor
                    ↓
        finite initializer / producer / message / cleanup
                    ↓
        bounded worker admission + completion
                    ↓
    event loop-owned socket / input / bounded output / deadlines
                    ├─ kqueue
                    └─ epoll
```

利用者が選択した方針に従い、Reactorではowned incremental APIを必須とします。既存同期 `startStream`／upgrade は明示的 `UnsupportedApplicationExecution`、default error handlerではHTTP 501です。Threadedの既存同期APIは維持します。

Nativeのexperimental APIは `Response.streamSession()`／`am.ws.upgradeSession()`、定義は `am.http.application_session.Definition.init(State, state, callback, mode)` です。callbackは opened／produce／message／closed を受け、1回の有限な処理と、最大8 KiBの出力、次の input／produce／after_ms／wait／done を返します。HTTP protocol・serializationは共通実装です。Transportはstatic dispatch、callbackは既存endpoint同様のABIへcomptime adapterを使います。新しいtransport vtableやstepごとのtask allocationはありません。

WebSocketのsocket、input、frame組み立て、read-ahead、fragment／control／UTF-8／close検証はevent loop側が所有し、完成したmessageだけworkerへ渡します。idle sessionはworkerを占有しません。外部wake用Resumerはclosed callbackが戻るまでの借用で、application側registryはclosedで送信者を解除・joinする必要があります。stateはconnection arenaまたはapplication所有で、Context／Conn／handler stackへのポインタを持ち出せません。setup失敗・HEAD・cancelではopenedなしでclosedを受ける場合があります。closedは1回だけ配送してからarenaを破棄します。

Streamは1 quantumずつ生成し、出力がpendingならproducerをparkします。slow readerでworkerを保持しません。最後のdataは次のproduceへ進め、その後のstepでdoneを返します。streamのoutputとdoneの同時指定は拒否します。固定長不一致やproducer errorは共通HTTP規則に従い終了します。任意の同期producerのスタックをsuspendする仕組みは導入しません。

## Admission・backpressure・ownership

通常FIFOは `max_pending_application_tasks`（省略時max connections）で制限し、connectionごとにqueued/running borrowは1つです。満杯なら新規workをcloseし、無制限queueや暗黙の再試行は行いません。cleanup専用FIFOもmax connectionsで制限し、通常queueの満杯でcleanupが拒否されない構造です。fixtureのbroadcast mailboxも有限で、overflowしたrecipientをcloseします。

pending outputはconnectionあたり16 KiB、buffered response cursorは4 KiB、session emissionは8 KiB。partial writeのoffsetを保持し、EAGAINはreadiness待ちへ移行します。message上限は既定64 KiB、input growthは上限確認後です。incremental sessionのheader preludeは約8 KiBの固定wire buffer内に収める必要があります。大きな通常buffered responseのheader/bodyは共通cursorで分割します。

公平性は有限FIFO、frame処理64個、notification処理128個のquantumで確保します。idle／active WebSocketとslow streamを同時に保持して通常HTTPを測定するContract、および旧4-worker starvation regressionが成功側に変わりました。CPU-bound／第三者blocking callbackは協調的に有限である必要があります。そのcallback自身がworkerを長時間占有する問題までunsafeにpreemptしません。

socketをcloseするのはevent loop ownerだけです。workerはborrow中のconnectionを破棄せず、completionをrelease公開してから参照しません。event loopはacquire後に結果を読みます。generation tokenでstale event／fd再利用を識別し、disconnect／timeout／errorはrunning borrowをjoinしてcleanupへ進みます。

## Deadline・shutdownで見つかった不具合

HTTPのheader／body／total read budgetはabsoluteで、部分readでは更新しません。WebSocketはframeごとのabsolute budgetです。producerやbroadcastによる出力が部分frameのread deadlineを更新してしまう不具合を `26017bd` で修正しました。event loopはworker借用前にdeadlineをsnapshotし、producer実行中・pending output中も期限を管理します。修正前のThreaded/kqueue双方の失敗logを保存し、400 ms部分frame＋120 ms間隔broadcastのregressionを共通Contractへ追加しました。

write budgetはbuffered response／streamの最初のoutputからabsolute、producer待ちも含みます。WebSocketではhandshake／各frame単位です。partial writeで更新せず、0ではoutputを許しません。Threadedのincremental WebSocket送信も、未完了inputがある場合は残read budgetを超えて待ちません。

shutdownはstop admission→graceful drain→deadlineでI/O shutdown→borrow join→closed／freeです。繰り返しsignalでbudgetを延長しません。bounded I/O drainは任意handlerのbounded process exitを保証しません。TSanがsignal handlerのerrno破壊を実際に検出したため、`40ed7e4` で標準 `std.c._errno()` の値を保存・復元し、unit regressionを追加しました。両OSのTSan再実行はsuppressionなしで成功しました。

## Phase 7：profileに基づく限定的な改善

macOSのall-thread stack samplingでは、worker handoffのcondition／mutex、event loop、send/read、wakeup writeが観測されました。sleep stackを含むためCPU使用率の内訳ではありません。Linux runnerでは `perf_event_paranoid=4` によりperfが拒否され、LinuxのCPU cost breakdownは未取得です。dispatch／allocation等の完全なexclusive costは測定できていません。

採用した変更はcompletion notification queueがempty→nonemptyになるときだけpipeをwakeするbatchingです。128 notificationのfairness処理後も残件があればzero-time pollで続け、人工的な遅延を入れません。32 connectionsのsampleでwake writeは79→39、128では修正後5でした。前後paired測定ではechoのthroughputが32で約+6.7%、128で約+9.2%。hello32は約−0.4%、db128は約−1.1%で、全workload改善とは主張しません。

lock-free queue、推測に基づくselector batching、event-loop handler fast path、Group採用は行っていません。有限callbackでもDB／CPU workはworkerへ隔離します。Groupの以前の不採用判断を覆す根拠は得ていません。

## Phase 8：cross-platform・resource・race検証

同じ33 Contractをlegacy Threaded／incremental Threaded／host Reactorで実行し、各OS99ケースが成功しました。Linuxはepoll、macOSはkqueueです。両者ともlevel-triggered selector、標準OS ABI、共通HTTP、indexed timer heap、同じworkerモデルを使います。OS差はselector／readiness通知実装に隔離しています。BSD一般の実機certificationは行っていません。

通常CIは最終runtime `40ed7e4` で全15ジョブ成功し、Native Debug／ReleaseSafe／OpenSSL、Workers、CLI／generated project、Dockerを維持しています。追加のsession suiteは256 disconnect／partial frame／RST／fd reuseと64 shutdown-close-completion raceを含みます。handlerがsignal handlerをinstallする前に追加signalを送るrunner不具合もbarrierで修正しました。

allocation failure、partial read/write、EAGAIN、EPIPE／reset、accept failure、stale token、overflow、timeout vs producer/completion/shutdown、error cleanupをunit／stress／Contractで確認しました。TSanはLinux/macOSのContract・isolation・session raceで成功しています。これらは観測した実行での証拠であり、全race不存在の証明ではありません。

deadline修正後のcross-platform CI cohort (`26017bd`) のkeep-alive32 connections・2回平均req/sは以下です。初回cohortもraw `summary.json` に保持しています。別CI host/timeのcohort間差を修正の性能効果とは解釈しません。

| OS / endpoint | Threaded | Reactor | 差 |
|---|---:|---:|---:|
| Linux hello | 83,297 | 35,109 | −57.9% |
| Linux echo | 81,464 | 34,608 | −57.5% |
| Linux db | 49,628 | 36,153 | −27.2% |
| macOS hello | 56,547 | 40,382 | −28.6% |
| macOS echo | 53,666 | 32,421 | −39.6% |
| macOS db | 36,341 | 30,418 | −16.3% |

4／32／128／256、keep-alive／paced short-livedのP50／P95／P99、CPU、RSS、thread、allocator、shutdownをrawへ保存しました。matrixのReactorは8 worker＋loopでthread数がconcurrencyによらずboundedです。session fixtureは4 worker＋loopの5 threadです。軽量HTTPでのworker handoff等の固定costは候補ですが、未測定部分を原因と断定しません。

同じincremental callbackを使うstream／WebSocket comparisonもrunnerへ追加しました。Threadedの新incremental外部wake bridgeには最大約100 msのpoll待ちがあり、broadcast差にはこの制約が含まれます。既存Threaded同期WebSocket／Hub全般がその分遅いという意味ではありません。Python負荷生成のsession fixtureはpeak req/s benchmarkではありません。

ローカルkqueueは5,000 idleを5 threadで保持しました。RSS約463 MiB、fd5,007、framework live約406 MiB、establishment554 ms、broadcast56.7 ms、shutdown231 ms。ReleaseSafe/debug allocator fixtureであり、小さいproduction memory footprintとは主張しません。5,000 idle＋active WS＋HTTP/DB＋slow streamの30秒試験も成功しました。10,000は未certifyです。

mixed soakは各adapter20分、100 idle＋16 active／rotating WS、32 HTTP/DB client、broadcast／heartbeat／reconnect、各probe中4 slow streamsです。初回Linux Threaded/epollのHTTP最大は7.56/6.37 ms、macOS Threaded/kqueueは17.32/14.47 ms。deadline修正後のローカルkqueue20分はHTTP最大6.77 ms、fd123→123、live11,669,054→11,669,514 bytes、4,852 sessionすべてclosed、最終live0でした。

一つの初期ローカルsoakはhostの66秒sleepで60秒read deadlineを超えて失敗しました。sleep記録と失敗rawを保持し、完走扱いしません。macOS collectorの旧thread数はps headerを含んでいたため、raw6は実際5です。元rawは変更せず補正方法を記録し、collectorを修正しました。

passing trialではcreated=closed、GPA正常、最終live0、process exit0です。RSSはOS／allocator retentionを含み、traffic中の最後のfd sampleには未回収in-flight workが含まれ得ます。warm-up増加や単一sampleだけでleakと判定しません。counterはSQLite／libc malloc／thread stackを除外します。task/queueは設計上固定上限ですがhigh-water計測は未実装です。20分試験の範囲で既知のresource leakは見つかりませんでした。数時間・高負荷の継続試験による再評価は必要です。

最終CI soak (`26017bd`) はLinux Threaded/epollでHTTP最大6.72/9.79 ms、macOS Threaded/kqueueで22.11/25.48 msでした。Reactorは両OSとも5 thread、fd123→123、shutdown約164/159 ms。epollのRSS15,196→15,448 KiB、live11,666,246→11,666,706 bytes、kqueueのRSS16,592→17,104 KiB、live11,669,054→11,669,514 bytesで、最終live0、created=closedでした。Threadedのmixed sampleは約118〜121 threadです。これらは低レートsoak中の値でありpeak throughput測定ではありません。

hello32のP50/P95/P99はLinux Threaded0.344/0.632/1.084 ms、epoll0.878/1.210/1.531 ms、macOS Threaded0.340/1.305/4.827 ms、kqueue0.634/1.721/2.866 msでした。ReactorのP99が常に悪いわけではありません。Linux helloのCPUはThreaded約154%、epoll約128%ですが、req/sも低いためCPU効率の改善とは直結しません。

[最終通常CI](https://github.com/moribit/Akamata/actions/runs/37308545796)、[TSan](https://github.com/moribit/Akamata/actions/runs/37308578211)、[最終長時間certification](https://github.com/moribit/Akamata/actions/runs/37307456569) はすべて成功しています。TSan/通常CIはerrno修正後 `40ed7e4`、長時間/performanceはその直前 `26017bd` で、最後の差分はsignal errno保存・復元です。

## Phase 9：公開判定と次の作業

isolation・bounded queue/output・I/O drain・両OS Contract／stress／fault／TSan／20分soakの証拠は揃いました。しかし**軽量HTTPのthroughput差を解消または十分説明できていないためNot Ready**です。many idle／realtimeでのbounded threadの利点は認められますが、この差を無条件に受け入れて公開しません。公開gate、Threaded default、App.serve互換性を維持しました。

既知の制約は、Reactor同期stream/upgrade unsupported、incremental callbackの有限性／借用規則、session header/output/message上限、per-connection memory、Threaded新incrementalwakeのpoll latency、Native incremental APIのexperimental性です。Workers側のincremental event adapterはexplicit unsupportedで、既存Workers APIを置き換えていません。portable event/actionとplatform adapterの境界を保ちました。

次は専用Linux/macOS hostでCPU/syscall/queue-wait profileを取り、handoff・selector変更・serialization・allocationのexclusive costを分離します。根拠がある箇所だけ改善し、同じContractとpaired benchmarkで確認してください。次いでper-connection memory budget／queue観測、5,000以上の長時間mixed soak、Threaded incremental wake bridgeの改善、必要なportable Workers adapterを別フェーズで評価します。CPU handlerのunsafe preemptionや根拠のないscheduler／lock-free化は推奨しません。
