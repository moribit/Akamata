# Native HTTP runtimeとTransport Contract（Zig 0.17）

これは946f021時点の設計記録です。現行write／drain仕様は
[Phase 2–5の記録](native-runtime-phases.md)を参照してください。

基準はmain `3f92014`です。公開`App.serve`／`ServeOptions`とThreadedのproduction選択を維持し、HTTP接続処理をsocket実装から分離しました。性能改善やReactorのproduction有効化は今回の目的に含めません。

## 構造

```text
App.serve → serve.zig（backend選択）
                ├─ Native: runtime/threaded.zig（listener / admission / lifecycle）
                │             ↓
                │       http/connection.zig（共通HTTP driver）
                │             ↔ runtime/socket_transport.zig
                │                    ├─ readiness_poll.zig（production）
                │                    ├─ reactor_kqueue.zig（評価のみ）
                │                    └─ reactor_epoll.zig（評価のみ）
                └─ Workers: 既存WASM bridge

Transport.read → parser → Request → App.dispatchWithPeer → Response
                  ↑                                      ↓
                  └──── keep-alive / request buffer ← serialization → Transport.writer
```

`http/connection.zig`がarena、受信buffer、framing errorのHTTP status、read budget、request回数、pipeline残留、stream終端、upgrade所有権を管理します。socket fd、poll／kevent／epoll、threadには依存しません。Responseの既存`writeTo`／`endStream`がserializationを担当します。

内部Transportは`anytype`によるstatic dispatchです。`read(vec, timeout_ms, shutdown_if_idle)`、`writer()`、`bufferedInput()`、`peerIp(arena)`、`streamPtr()`、`ioPtr()`、`close()`を提供します。socket Transportは既存の`std.Io.Reader`／`Writer`を持ち、後二つのpointerは既存WebSocket APIへのhandoff用です。新しいtransport vtableやtransport用heap allocationはありません。受信buffer・request arena・buffered responseのallocation方式は引き続き既存方式です。

`runtime/threaded.zig`はaccept、TCP設定、connection上限、thread管理、signal scopeだけを扱います。共通driverをcomptimeで選んだreadiness型へ接続できます。

## 現状調査と重複の整理

旧Threaded／kqueue／epollはparser本体を共有していても、request lifecycle、dispatch、response送信、keep-aliveと残留bufferを別々に実装していました。Reactorの固定16 KiB buffer、default parser limit、peerなしdispatch、stream／upgrade未対応、EAGAINでspinするsend loop、期限・上限・shutdownの不足は、productionには利用できない状態でした。旧epoll_eventの手書きlayoutもLinux x86_64のpacked ABIと一致していませんでした。

そのため旧ReactorのHTTP／worker loopを保持して修正する方式は採用していません。kernel readiness adapterへ縮小し、共通driverと実証済みのconnection lifecycleを使うprivate `evaluate`経路を用意しました。kqueue／epollとも標準のOS ABI型を使い、level-triggered readinessから共通Transportへ戻ります。

**これはthread-per-connectionの評価環境です。複数connectionを一つのevent loopで扱うReactorのparity証明ではありません。** productionの`.runtime = .reactor`と両moduleの`serve`は、socketを開く前に`error.ExperimentalRuntimeDisabled`を返します。評価経路は`akamata.zig`からexportしません。旧unsafe serverへ進むhidden fallbackもありません。

## Transport Contract

`tests/transport_contract.py`はruntimeの実装を知らず、同じprivate fixtureへsocketを接続します。20 test methodを各adapterへ適用します。

| 領域 | 必須の観測結果 |
|---|---|
| 通常HTTP／disconnect | 正しいstatus/body、途中切断後も別connectionが処理できる |
| 不正framing／encoding | duplicate CL等400、未対応TE501、そのconnectionを閉じる |
| header／body上限 | byte/count上限431、CLと宣言chunk size上限413 |
| keep-alive／request上限 | 同じsocketで複数request、最後はConnection: close |
| pipeline／残留buffer | 複数request、body後のrequest、途中までの次headerを失わない |
| timeout | idle、header、body、total read budgetを超えて閉じる。trickleで期限を延長しない |
| stream | chunked終端、handler error後の安全な終端、固定長の完了／短いbodyでEOF |
| upgrade | 101を一度だけ送信、二重closeしない。HTTPと同じrecv内の最初のframeを保持 |
| admission／overload | max_connections超過を閉じ、切断でslotを回復 |
| backpressure | slow readerで一つのwriterが待機してもaccept／他connectionを止めない。reset後に回復 |
| peer／proxy | 直接peerを記録。trust optionとpolicyの両方が許可したpeerだけ転送headerを利用 |
| shutdown | admission停止、未送信／keep-alive idleを閉じ、進行中responseを完了。partial requestは設定済み期限内で終了 |

```sh
zig build transport-contract-test -Doptimize=ReleaseSafe
zig build runtime-poc-test -Doptimize=ReleaseSafe
zig build transport-contract-build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseSafe
```

macOSではThreaded＋kqueueの40 socket test、Group PoCの20 socket testが通ります。Linuxでは同じrunnerがepollを選びます。Linux cross-buildを確認し、Linux／macOS CIへ実行stepを追加しました。cross-buildだけでLinuxの実行成功とは扱いません。

現在のproduction保証の範囲も明示します。`total_request_timeout_ms`はrequestの**読み込みbudget**で、任意のhandlerやwriteを強制停止する期限ではありません。header／body budgetは従来どおりrequest開始から計測します。streamは終了後connectionを閉じます。`write_timeout_ms`は従来どおり予約設定で、bounded write deadlineではありません。backpressure testは待機・分離・切断回復を検証し、uncooperative clientへの強制shutdown期限を保証しません。既存のhandler／WebSocket ownershipとgraceful drain policyを変更していません。

## Contractで整理した境界の不具合

- reader内部にbufferがある場合、kernelの新しいreadinessを待つ前に消費します。
- upgradeのread-aheadをResponse内の内部handoff metadataとしてConnのowned receive bufferへコピーします。通常HTTPには追加allocationを導入しません。
- 固定長streamも`endStream`でfinalizeします。短いstreamは既に書いたprefixをflushして閉じ、paddingや二つ目のstatus lineを送信しません。
- request回数上限で閉じる最後のresponseがkeep-aliveを広告する問題を修正しました。接続寿命・上限値は変えません。
- Incomplete parserのallocationは試行ごとにresetします。chunk size上限はbodyを待つ前に判定し、wire buffer上限時も413を返します。wire buffer自体にはheader limit＋body limit＋4の上限を維持します。
- descriptor設定失敗とaccept threadの途中spawn失敗はfail closed／drainします。backoff待機とidle readはshutdown確認の短い区間に分け、active connectionのdrainでCPUをspinしません。

## Zig 0.17 workaroundの再評価

実際に利用する0.17.0の`lib/std/Io/Threaded.zig`、`Io.zig`、`posix.zig`、`c.zig`を確認しました。オンラインmasterを固定versionの代わりには扱いません。

| 対象 | 判断と0.17現在の理由 |
|---|---|
| libc accept | productionで維持。netAcceptPosixはEAGAINをerrnoBug扱いにする。複数acceptorのreadiness raceをrecoverできない。Group内のblocking標準acceptはPoCで評価 |
| libc poll | read deadlineで維持。標準stream readerにper-read deadlineがなく、SO_RCVTIMEOのEAGAINもerrnoBug。posix.pollはEINTR後に元のtimeoutを再利用するため、一回のstd.c.poll後に共通Transportでabsolute budgetを再計算 |
| 独自pollfd／fcntl constants | 手書きABI・OS flagを削除し、標準のtarget定義へ置換 |
| pthread mutex／condition | wrapperは維持。DB pool、hub、model cacheのAPIはIoを所有／受け渡さない。Io.Mutex／Conditionへ置換するにはIoとcancellationの責任範囲を設計する必要がある |
| pthreadの96-byte仮storage | 削除。std.c.pthread_mutex_t／pthread_cond_tのOS／ABI定義を使用 |
| libc signal／SIG_IGN alignment workaround | 削除。0.17のSIG／SigactionでINT／TERMを登録し、serve scope終了時に元へ復元。PIPEはIo.Threaded自身の処理を使用 |
| Thread.spawn＋detach | productionで維持。寿命変更をHTTP切り出しと同時に行わない。部分setup failure時もworkerが借用するcontextの終了を待つ |
| atomic active_connections | productionで維持。admission上限とborrowed app/io/contextのdrainを保証。Group PoCではconcurrent_limitとawaitへ置換 |
| timeout設定のno-op helper | 削除。書き込み期限が未実装である事実をServeOptions／文書へ明記 |

signalはprocess-wideです。一つのserving AppがINT／TERMのownerとなる既存前提を維持します。multi-server signal brokerは今回の対象ではありません。

## std.Io.Group experiment

`runtime/io_group_experiment.zig`は独立したserver experimentです。cancelableな標準blocking acceptをGroup.concurrentで動かし、connectionも別Groupへ登録します。stop admission → accept Group.cancel → connection Group.awaitの順で、Thread.spawn／detach、active counter、手動join／spinを使いません。max_connectionsはIo.Threaded.concurrent_limitで制限します。

Group.asyncは有限taskのawait testに使用します。asyncはinline実行が許されるため、長寿命connectionには正しさのためconcurrentが必要です。blocked std socket readerのcancel／close、共通readiness gateを通るcancelもテストします。raw readinessはIo cancellation pointではないため最大100msの区間でcheckCancelへ戻します。macOSで後者のcancelは約74msでした。

| 項目 | production Threaded | Group experiment |
|---|---|---|
| shutdown所有権 | detached worker＋atomic drain | scope-owned Group.await／cancel |
| cancellation | flagとread deadline、handlerは協調 | 標準blocking syscallはcancel可能。raw readinessは区間ごとにcheckCancel |
| connection寿命 | threadがapp/io/contextを借用 | Groupがtask終了を待ち、deferでsocketを解放 |
| allocation | pthreadのthread／stack、既存HTTP buffer | task closure＋Threaded thread pool、同じHTTP buffer。unit allocatorで解放を確認 |
| complexity | acceptor list、spawn failure、atomic countとdrain | Group二つ＋concurrent_limit。force cancelのpolicyはまだ必要 |

キャンセルは任意のSQLite呼び出しやCPU handlerをpreemptするものではありません。graceful awaitもslow writerを強制終了しません。promiseできる保証を増やしてからproduction採用を判断します。次フェーズではIoをruntime scopeのownerとして、Io対応read deadline、forced drain deadline、upgrade taskのowner、error propagationとadmission limitをまとめて設計することが有望です。

## Benchmark

Apple M2／macOS arm64、Zig 0.17.0 ReleaseFast、oha 1.15.0、
loopback、32 connections、各endpoint 5秒×3 round、observability無効で測定しました。
throughputはHTTP 200件数／経過秒です。失敗したattemptを含むrequestsPerSecは使いません。
各値は3 roundの中央値、RSSは各roundでsampleした平均RSSの中央値です。
ローカルの探索的測定であり、capacityの保証ではありません。

| Endpoint | 変更前: rps／P50 µs／P99 µs／RSS MiB | Threaded変更後 | Group experiment |
|---|---|---|---|
| /hello | 167,430／157.5／826.7／6.58 | 165,600／167.6／695.2／6.38 | 167,179／167.9／689.8／6.14 |
| /echo | 166,213／157.3／963.7／6.56 | 165,094／158.3／836.7／6.44 | 166,923／165.5／731.6／6.17 |
| /db/1 | 86,893／229.6／3,010.5／6.75 | 88,263／222.8／2,664.0／6.60 | 80,433／211.5／3,555.4／6.42 |

Threaded throughputの変更前比は−1.1%、−0.7%、+1.6%です。/helloのP50は6.4%増、
P99は減少しました。この測定では一貫した全体的な退行は確認されません。
各roundのthroughput範囲は変更前166–169k／157–167k／78–89k、
変更後154–166k／162–165k／87–88kです。先行測定では後半roundで全endpointが
大きく低下したため、buildを並行実行せず変更前後を再測定しました。
先行する2回の変更後raw JSONも保存しています。小さな性能差を断定するには、
実行環境を固定した交互測定が必要です。

9 round合計のtransport errorは変更前12,345件、変更後17件（/helloの3 round目）、
Groupは0件でした。request上限の最終responseがConnection: closeを広告する修正により、
変更前のreuse-after-close問題を解消しています。残った測定／client errorの原因は
証拠なく断定しません。

Groupの/db throughputは現行Threaded比−8.9%、P99は+33.5%です。
task pool／cancel scopeと、productionの8 acceptorに対する単一acceptorという差があり、
単一の最適化を比較した測定ではありません。RSSと所有権の単純さは有望ですが、
SQLite競合やtask／IOのcostをprofileしてから採用を判断します。
requestごとのallocation回数は測定していません。

二つのbinaryを明示的にbuildします。explicit stepだけではdefaultのbench installは
実行されません。

```sh
zig build -Dexample=bench -Doptimize=ReleaseFast
zig build runtime-group-bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_compare.py zig-out/bin/bench /tmp/after.json
python3 tools/bench/runtime_compare.py zig-out/bin/runtime-group-bench /tmp/group.json
```

[raw結果・binary hash・測定ノート](../../benchmark/results/runtime-2026-10-05/README.md)
にはcommand、latency分布、error、roundごとのRSS平均／peakを保存しています。

## Reactor production有効化まで

1. 同じHTTP driverへ接続する非blocking read/write、bounded outgoing queue、partial writeの状態管理を実装する。EAGAIN時のspinを許さない。
2. std.Io task backend、または共通protocolのincremental driverで、複数connectionを一つのevent loopへ多重化する。kernel readiness testだけで代用しない。
3. stream／upgradeのtask・buffer・socket所有権とcancelを証明する。
4. deadline、admission、pending queue、shutdown wakeup／drainを多重化後の同じContractで実行し、OS別stress／fault injection／slow-reader検証を追加する。
5. write／forced shutdownの期限を互換性を含めて設計し、CPU handlerの協調cancel範囲を明示する。
6. LinuxとmacOSで実行し、idle/burst/stream/upgrade workloadsのlatency、RSSとresource leakを確認する。

それまではproduction gateを維持します。throughputだけでdefaultやgateを変更しません。
