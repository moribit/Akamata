# Native runtime Phase 2–5

基準はmain 946f021、stdlibはインストール済みZig 0.17.0です。
Threadedをdefaultに保ち、Reactorのproduction gateは検証結果で判断します。

## Phase 2: write / shutdown contract

write_timeout_msはresponseの最初のsocket出力から数えるabsolute budgetです。
partial write、EAGAIN、flush、少量のclient readでは更新しません。
最初の出力前のhandler処理は含まず、streamのproducer pauseは含みます。
0は出力を許可しません。WebSocketはhandshakeと各frameに個別のbudgetを適用し、
frame間のidle時間は含みません。既存read timeoutは維持します。

bounded writerは既存4KiB bufferとcallerのsliceを利用し、MSG_DONTWAIT/NOSIGNAL
のsendでpartial offsetを保持します。EAGAINはPOLL.OUTで待機し、100ms以下の区間で
cancelとabsolute budgetを確認します。新しいoutput queueはありません。
HTTP serializationは直接writerへ出力し、response全体のwire copyを追加しません。
Response.body自体は既存application APIのbufferであり、runtime pending queueではありません。

registryはproducerがwriteを呼ばない間も期限を監視します。Threadedの制御loopは
最大100ms間隔、期限scanは最大20Hzです。scheduler遅延を含むreal-time保証ではありません。
registry lockでshutdown、owner close、deadline解除を直列化し、再利用されたfdを誤って
shutdownしません。forced drainはshutdown(RDWR)でI/Oを解除し、closeはownerが行います。

shutdown_drain_timeout_msを追加しました。defaultは30秒です。最初のrequestShutdown
時刻から数え、繰り返しsignalでも更新しません。stop admission → graceful drain →
期限切れsocket shutdown → owner cleanup / joinという順序です。短いwrite期限はdrain中も
有効です。idle connectionは従来どおり速やかに終了します。

保証範囲: socket I/Oは期限と制御loopの範囲で解除しますが、CPU-bound handler、独自の
blocking syscall、第三者libraryを安全にpreemptするとは保証しません。handlerは協調終了が
必要です。借りたApp/Io/arenaを保持して終了まで待つため、非協調handlerを含むprocess全体の
exit時間はboundedではありません。upgradeのConnもhandler scope内で所有・deinitし、
borrowed request arenaやruntime controlをescapeさせないでください。

共通Contractへslow-reader進捗、producer pause、slow writer drain、partial request drain、
upgrade read/write、disconnect during drain、graceを超えるhandler、repeated signalを追加しました。
CPU handlerを強制終了するassertionはありません。

```sh
zig build test integration tasks-test transport-contract-test runtime-poc-test -Doptimize=ReleaseSafe
zig build transport-contract-build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseSafe
zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe
```

macOS Threaded/kqueueの54 socket test、Groupの27件とlifecycle unitが通りました。
ReleaseSafe unit/integration/tasks、Workers chat、Linux fixture cross-buildも通りました。
Linux実行は最終CIで確認し、cross-buildだけで代用しません。
[Phase 2 raw benchmark](../../benchmark/results/runtime-phase2-2026-10-05/README.md)
のthroughput中央値はhello/echo/dbで−0.5%／−0.4%／+4.1%でした。
重大な全体的退行は確認されません。P50/P99/RSSとhelloのP99変動も記録しています。

## Phase 3判断: B — Group採用見送り

両実装のacceptorを8に揃え、4/32/128 connections、keep-alive、短命connection、
64/256 idleで比較しました。P50/P95/P99、CPU/RSS/fd/thread/allocator、別途task数を記録しています。
instrumentation無効のDB再測定では32/128 connectionsでthroughput−10.3%／−10.4%、
P99+37.6%／+15.4%でした。idleのthread/RSSも実質的に改善していません。
productionはThreadedを維持し、PoC・共通Contract・測定用counterを残します。

Groupはawait/cancelによる所有権とcleanupを単純にしますが、signal、admission、deadline、
socket所有権、error propagationのpolicyは依然必要です。application処理のpreemptionも保証しません。
Threaded側はPhase 2 registryでforced socket drainとcleanupを検証できるようになりました。
新しいpublic runtime APIは増やしません。

profileでは共通SQLite handleのmutex競合とGroup pool待機を確認しました。
追加の性能差を単一原因には断定できず、推測による最適化は行っていません。
allocator counterはapp.gpaだけで、libc/SQLite/stackを含みません。
短命connectionはhost負荷を抑える500 requests/secでlatency/resourceを比較し、最大throughputとは扱いません。
[判断記録・profile・raw data](../../benchmark/results/runtime-phase3-2026-10-05/README.md)に再現手順を残しています。

## Phase 4: private true HTTP multiplexing

`http/session.zig`へincremental input/parser/request lifecycleを分離しました。
`http/connection.zig`のdispatch・serialization・keep-alive・stream・upgradeは
ThreadedとReactorで共通です。Reactorは一つのevent loopがSessionとsocketを所有し、
固定worker poolで同じdispatchを呼びます。connectionごとのthread生成は行いません。

kqueue/epollの標準ABI定義、level-triggered nonblocking I/O、generation token、
固定容量notification queue、connectionごとに一件のindexed deadline heapを使います。
一回のreadは64KiB、acceptは64件までとし、hard accept failureはreadinessを停止して
backoffします。closeとselector更新をregistry lockで同期し、stale eventは世代で排除します。

pending outputは16KiB、Writer bufferは4KiBです。partial sendのoffsetを保存し、
EAGAINではevent loopへ戻ります。producerはconditionで待ち、queueを無制限に拡張しません。
write budgetは最初の出力がTransportへ入る時点から開始し、progressでは更新しません。
stream/upgradeのflushはkernelへの送信完了を待ちます。通常の小さいresponseではworkerを
先に解放できますが、Sessionはpending outputが完了するまで保持します。

upgradeはhandler scope内で借用socketを所有します。read-aheadをコピーしてhandoffし、
同期read APIはnonblocking recvとbounded pollを使います。長寿命upgradeや遅いstreamは
workerを占有するため、production判断ではworker starvationを独立に検証します。
forced drainはsocketとproducer待機を中断しますが、CPU-bound handlerはpreemptしません。

macOSではThreaded/kqueue各27 Contractが成功しました。Linux epollもCIで同じContractとquick stressが成功しました。Phase 5の証拠が揃うまでpublic reactor gateを維持します。

## Phase 5 最終判断: Reactor Not Ready

kqueueはread/write filterを別々に登録し、epollはIN/OUT/RDHUPを標準packed eventへ
まとめます。両者はlevel-triggeredで、generation token・HTTP・lifecycleは共通です。

最終Contractへzero write budgetとHub broadcast/disconnectを追加しました。
handlerが完了済みでもpending output失敗時にconnectionを即回収し、通知消費後の残留を防ぎます。
Hub snapshotはConnの借用を保持し、deinitが借用の終了を待ってからtransportを破棄します。
handlerは全Hub membershipをdetachしてからConnをdeinitしてください。
upgrade recvはclose registry lock内でdescriptor identityを再確認します。
fd再利用のunit testで、別socketのdataを読まず、double closeしないことを確認しました。

Threaded・true kqueue・true epollへ同じ29項目のContractを適用しました。
Linux CIではReleaseSafe Contractとquick stress、macOSローカルではfull stressが成功しました。
setup/input growth/parserの全allocation failure、partial send/EAGAIN、EPIPE、
generationによるstale event排除、notification overflow、referenceと比較したtimer churnを
unit testへ追加しました。socket側ではreset/disconnect、handler/stream error、
read/write/total timeout、idle/partial input/write/stream/upgrade中のshutdownを検証します。

64/256 idle、64並列・1024 connectionのburst/churn、pipeline、32 slowloris、
fragmented 512KiB body、stream/upgrade、4 slow-readerの16MiB streamで検証しました。
childだけのfd上限64でEMFILEを再現し、backoff・復帰・fd回収も確認しました。
試験後のfdはbaselineへ戻り、管理対象allocationは0、DebugAllocator deinitも成功します。
これは今回の有限試験での証拠であり、全workloadでのleak不存在を保証しません。

重要な未達条件はworker isolationです。4件の長寿命upgradeが4 workerを占有すると、
Reactorの通常HTTP requestは250ms以内に応答できません。Threadedは応答できます。
forced drainは回収できますが、同期stream producerも同様にworkerを占有します。
この期待される不足を試験結果へ明記し、production parity成功とは扱いません。

32 connectionでReactorのhello/echo throughputはThreadedより約46%/47%低く、
DBも約19%低下しました。profileではworker handoff、condition/mutex、pipe wakeup、
selector更新のコストが見えますが、一つの原因の寄与率までは分離できていません。
推測によるlock-free化やdeadline緩和は行っていません。

256 idleではReactorは9 thread、Threadedは264 thread、RSSは約10%低く、
idle shutdownは約4ms対130msです。ただし、この利点で隔離不足と速度低下を相殺しません。
defaultはThreaded、`.runtime = .reactor`は`ExperimentalRuntimeDisabled`を維持します。

Threadedの最終uninstrumented比較は946f021に対してhello −0.5%、echo −0.4%、
DB +5.1%で重大な全般的regressionはありません。hello P99の約9%増加も隠さず記録します。
[全比較表・raw data・profile・再現手順](../../benchmark/results/runtime-phase5-2026-10-05/README.md)
にP50/P95/P99、CPU、RSS、fd/thread、allocation、shutdownを残しました。
short-livedは500req/sのpaced評価、stream/upgradeは短いfixture exchangeです。
Linuxでの性能測定、長時間soak、より広いOS/allocator fault、race/sanitizer評価は残課題です。

### Zig 0.17 workaroundと次の設計

- raw acceptは維持します。インストール済み0.17 netAcceptPosixはnonblockingのEAGAINを
  回復可能な結果として返さず、readiness後のraceに使えません。
- Threaded read/pollはabsolute deadlineとdetached workerのcancel scope不足のため維持します。
  Reactorはnonblocking recvとkqueue/epoll、同期upgrade readはbounded pollを使います。
- bounded sendはstdlib blocking socket writerへEAGAINを渡さず、std.Io.Writer framingを再利用します。
- pthread Mutex/Conditionはstd.c ABI定義を使います。Db/cache/Hub APIはIoを受けません。
  Conn/runtime queueはIoを持ちますが、借用joinと明示abortのuncancelable方針で共通primitiveを
  維持します。0.17にuncancelable同期APIがないという意味ではありません。
- signalは標準SIG/Sigactionを使い、古いcastや手書きpoll structを削除しました。
  最初のshutdown timestamp、listener interruption、signalを繰り返しても更新しないbudgetは維持します。
- detached connection worker、atomic active count、registry drainはproductionに残します。
  Groupはownership改善だけでなくDB性能低下とidle thread削減なしを評価し、採用を見送りました。
  Reactor workerは固定数でjoinし、HTTP semanticsとは分離します。

次は長寿命stream/upgradeのbounded admission・ownership・通常HTTP隔離を設計するか、
portable incremental frame/producer task APIを検討します。Groupだけでは既存同期handlerの
占有問題は解決しません。wakeup/selector batchingをprofileに基づいて評価した後、
Linux/macOS全Contract・stress/fault/resourceを再実施してください。
CPU-boundや第三者のblocking処理は引き続き協調cancelが必要です。

```sh
zig build runtime-contract-unit runtime-stress-test -Doptimize=ReleaseSafe
zig build runtime-stress-full -Doptimize=ReleaseSafe
```

CIではLinux Threaded/epoll、macOS Threaded/kqueueに同じContractとquick stress、
Group PoCを実行し、platformごとのstress JSONをartifactへ保存します。
full stressは通常CIから分離し、`.zig-cache/runtime-stress-full.json`へ出力します。

## 最終CI検証

実装コミット `ce5ef1f` の[CI](https://github.com/moribit/Akamata/actions/runs/37270065077)は15ジョブすべて成功。Linux Threaded/epoll、macOS Threaded/kqueueは、それぞれ同一の29件のContractに成功しました。ReleaseSafeのfault/unit test、Group Contract、quick stressも成功しています。CIのstress生データと検証対象SHAは [Phase 5測定記録](../../benchmark/results/runtime-phase5-2026-10-05/README.md) に保存しました。stress成功にはworker占有による隔離失敗の再現確認を含み、production適合を意味しません。判定は **Reactor Not Ready** のままです。
> Phase 6のapplication execution調査・基盤と未達gateは
> [reactor-application-execution.md](reactor-application-execution.md) を参照してください。
> Phase 6は未完了で、Phase 7〜9の成功を示すものではありません。
