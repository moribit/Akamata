# Native Reactor: CPU / memory investigation（2026-10-05）

基準は `8bbe7d4` 以降の main。Threaded を production default とし、公開 `.runtime = .reactor` の `ExperimentalRuntimeDisabled` を維持する。この調査は gate 解除の認証ではない。

## 判断

**Reactor開発は Stop / Park：experimental research runtimeとして一旦固定する。** Linux の軽量 HTTP の差は今回の小さな改善では解消できない。実測なしで lock-free queue、application の event-loop 実行、worker 増員、Group を導入する根拠はない。一方、5,000 idle WebSocket を5 threadsで保持し、live memory / connection を約55%削減できた。Shared HTTP Core、Transport Contract、incremental sessions、bounded output、deadline、shutdown、fault/TSan 検証は維持する。Realtimeの実需要と追加profileが得られた時点で再開を判断する。

次の投資判断には、専用 Linux ホストで observer overhead の少ない CPU / scheduler profile と、実際の realtime application の mixed workload が必要。現在の evidence は generic HTTP production runtime の公開を支持しない。

## 測定と限界

raw data、binary SHA、command、環境、CI run、導出 script は [調査記録](../../benchmark/results/runtime-investigation-2026-10-05/README.md) に保存した。ReleaseFast の uninstrumented matrix と `-Druntime-cost=true` の attribution matrix を分離した。計測はデフォルト無効で、無効時は counter / timestamp / extra connection state を compile-time で除去する。

`Span` は wall clock と **thread CPU clock** を記録する。mutex、enqueue、worker work、dispatch 等には包含関係があるため合算しない。Threaded の read は poll 待ちを含み、Reactor の read は recv の区間なので wall 値を直接比較しない。queue/completion wait は wall のみ。多数connectionの並列待ちを `1 / throughput` と比較して CPU の割合を計算しない。

Linux `perf` は runner の `perf_event_paranoid=4` により使用不能。設定変更は行っていない。`strace -f -c` を別runで使用し、startup/shutdown を含む10,000 requestsで正規化した。ptrace は scheduling/futex回数を歪めるため syscall の絶対値を通常runの CPU costへ換算しない。macOS `sample` は **wall-stack sample** であり、CPU percentage として扱わない。macOS syscall trace、正確な context-switch count、exclusive CPU gap attribution は未取得。

`ps time` の process CPU は粗い。特に500 qpsの短時間runで0%となる値は CPU 使用なしを意味しない。GitHub hosted runner は専用ホストではなく、macOS の Threaded before/afterにも変動がある。2 rounds / 3 seconds は方向性の evidence で、統計的な性能保証ではない。短寿命connectionは fd/ephemeral-port を無制限に消費しない500 qpsの固定rateで測定し、throughput ceiling を測定したとは主張しない。

ここでuninstrumentedはCPU attribution無効を意味する。`BENCH_STATS`のallocator counterは両runtime / before / afterで同条件に有効であり、全instrumentationが無いという意味ではない。通常benchmarkもDebugAllocatorを使う。production allocatorやcounter無効での追試は別の測定条件として扱う。

## Request cost と handoff

最終数値表は下の測定表に示す。共通 parser / dispatch が軽量requestで Reactor 固有の主要差になっている evidence はない。追加の queue admission、worker wake/acquire、completion publish、event-loop bookkeeping が存在する。

正常な keep-alive request は application enqueue / dispatch / completion / notify が各1回。普通のresponseに `event loop → worker → event loop → worker` の二重dispatchはない。serializeは Threaded の cursor init に対し、Reactor は init + fill + 終端fill の約3回。stream/frameの追加stepsは別の有限application workとして扱う。

serialize計測範囲も非対称である。ThreadedのnextSlice/Writer処理全体を囲んだexclusive timerではないため、そのCPU差をそのままReactor固有serialization費用と解釈しない。parseの約2回/requestにはinput不足を判定するpassも含む。raw `copy_bytes` は旧pending-output copyのcounterであり、全framework copy量ではない。最終ReactorでもCursor.fillによるResponse→4 KiB writer bufferのcopyは残り、ThreadedにもWriter bufferへのcopyがある。

mutex/condition counterはAkamataのwrapperを数える。SQLite/libc/allocator内部lock全体や OS context switchを数えるものではない。Reactor は request当たり約15 mutex lock、Threadedは約2。empty→nonempty completion batching は既に効き、pipe wake は requestごとではなく数十分の一。さらなる時間ベースbatchingは latency/fairness の対価を正当化できず採用しない。workerは約1 requestずつ acquireし、condition signalは1/request。lock-free queueの優位を証明する profile はない。

CPU差の**exclusiveな何%を各処理で説明できるかは unknown**。inclusive spanの合計で架空の100%分解を作らない。代わりに、実測の呼出回数、CPU区間、syscall削減、独立変更のthroughput効果を示す。測定表の gap closed は `(Reactor_after - Reactor_before) / (Threaded_before - Reactor_before)` であり、CPU attributionの割合ではない。

初回最終CIのLinux hello straceでは、total syscallはThreaded 3.713 / Reactor 11.234、差7.521/request。そのうちfutexの差6.580は**syscall回数差の約87.5%**、epoll_ctl + epoll_wait − Threaded pollの差0.988は約13.1%。他項目にはaccept等の負の差もあるため各項目の合計が単純なpartitionにはならない。これはtraced syscall回数の分解であり、CPU差の87.5%をmutexで説明したという意味ではない。futexにはallocator等の内部同期も含むので全量をtask queueに帰属させない。

observer overheadは大きい。初回最終CIのLinux c32 helloはuninstrumentedでThreaded約132k / Reactor約55k req/s、clock/counter有効時は約90k / 23k。clockが多いReactorほど歪む。最適化を判断した根拠はtimer合計ではなく、selector syscall数、不要copyの確認、sizeof/arena capacity、独立したuninstrumented比較である。低overheadのsampling / exclusive profiler不足はPark判断の理由でもある。

## 保持した改善

### Bounded eager send（`0cc0b72`）

response cursorの有限4 KiB quantumを、writable登録の前にnonblocking sendする。1 turnは最大16 KiB。EAGAINは残りを保持しwritable待ちへ移る。続きがある場合のself notificationもbounded。partial write、absolute deadline、shutdown、parser semanticsは変更しない。

baseline kqueue はread/writeそれぞれADD/DELETEの約4 syscall/request、epollはADD/MOD/DELETEの約3。軽量responseでは最終的にread ADD/DELETEの約2となる。Linux straceで epoll_ctl は3.017→2.007/request、epoll_waitは約0.064→0.033、wake writeは約0.061→0.032となった。ただし futex は減っておらず、LinuxのHTTP差の大部分は残る。

local macOSの交互3 rounds / 32 connectionsでは eager単独でhello +14.6%、echo +9.2%、db +3.8%。別ホストの最終matrixでは改善が一様ではないので、このlocal値をLinuxへ外挿しない。

### Borrowed output + lazy fallback（`f9546e8`）

有限responseは安定したconnection writer buffer、incremental outputはsession wireを送信完了まで借用する。未送信sliceがある間、bufferの再利用、producer admission、session destructionを行わない。socket所有者はevent loopのまま。

常設16 KiB copy slotを除去し、protocol-errorの同期Writer用だけ必要時に16 KiBを確保する。通常hello/echo/dbの約119/128/131 bytes/requestのcopyを除去したが、copyがCPU bottleneckだったとは主張しない。HTTP hot pathへallocationを追加していない。fallback allocation failure、partial send、EAGAIN、disconnectはunit/faultで検証する。

borrow単独のlocal throughput差はtrial間でhello −2.5〜−2.9%、echo −3.8〜+1.1%、db −1.2〜+3.0%。速度改善として採用せず、固定メモリ削減を理由に保持した。

### Sessionのarenaから分離（`f9546e8`）

内部 `application_session.Session` はgpaが所有し、dispose/deinit後にdestroyする。application callback state / HTTP request dataは従来のarena lifetimeを維持する。Sessionをarenaへ追加したために発生していたgeometric growthを除去した。fixtureでは6 allocations/idle connectionの総数は変わらない（arena chunkが独立Session allocationに置き換わる）。normal HTTPのrequest arenaは変更しない。

global pool、timer wheel、custom scheduler、queue rewrite、fast-path、worker増員は導入していない。実装してから効果不足でrevertしたoptimizationはない。借用方式の速度の利点は否定し、メモリ効果だけを採用理由とする。

## Idle connection memory budget

ReleaseSafe + DebugAllocator fixture、handshakeとready frame完了後。HTTP parser limitsがmax request256/header8/body64であることに注意。production defaultのHTTP input capacityへこの値を外挿しない。inputはaccept時に先行確保され、defaultの初期16 KiB要求はArrayListのgrowthによりcapacity 24,704 Bとなる。fixtureの518 Bとの差だけで約23.6 KiB/connectionあるため、37.4 KiBという結果はproduction default全般の保証ではない。small/lazy inputはShared HTTPとThreadedのallocation/syscallにも影響するため、今回は変更せず次回の独立測定対象とする。liveはapp.gpaのrequested live bytesであり、RSS、SQLite/libc、thread stack、kernel socket memoryとは異なる。

layout / local memoryの3段階比較は`runtime-cost=true`であり、Connectionへqueued/completed timestamp計16 Bが加わる。通常buildのConnectionは表より16 B小さい。最終CIのmemory / soakは計測無効で、同じ傾向を別途確認した。

| 領域 | before | after | allocation / idleで必要か |
|---|---:|---:|---|
| Connection全体 | 21,368 B | 5,024 B | accept時。writer4 KiB、Output、HTTP session112 B、cursor/node等を含む |
| うちOutput | 16,592 B | 248 B | Connection内。旧16 KiB slotを除去、error fallbackだけlazy |
| HTTP input capacity | 518 B | 518 B | accept時に確保。upgrade後もescaped request dataのlifetimeを維持 |
| request arena capacity | 62,952 B | 15,936 B | request/header/application state。Session分離後もidle callback stateを保持 |
| 内部Session | arena内16,768 B | 独立16,768 B | upgrade時。application output8,192 B + wire8,256 B + metadata |
| fixture UpgradeState | arena内8,272 B | arena内8,272 B | mailbox8,192 Bを含む。applicationが選ぶ費用 |
| WebSocket input/message/scratch | activity依存 | activity依存 | incoming frame時にboundedでgrow。idle時にmax message size全量は確保しない |
| deadline / queue / slot metadata | shared固定 | shared固定 | max_connections容量に対し約80 B/slot。16,384 slotsで約1.25 MiB |

SessionとUpgradeStateをarena capacityへ再加算しない。ConnectionとOutput/writerも二重計上しない。fixture SessionGroupの約128 KiBはshared stack stateで、app.gpa liveへ加算しない。

最終local layoutを重複なしで分けると、base/cursor/node等568 B、writer4,096 B、Output248 B、HTTP Session112 B、input518 B、内部Session16,768 B、fixture application state/mailbox8,272 B、残りarena capacity7,664 B、chunk等53 Bで**38,299 B**。最後の53 Bは1000→5000のlive差分とsizeof/capacityの差から求めた概算。shared queue費用と一時measurement connectionはこの傾きから除かれる。

localの1000→5000差分から求めたbudget：

| idle connection当たり | before | borrowed output | Session分離後 |
|---|---:|---:|---:|
| live bytes | 84,915 B / 82.93 KiB | 68,571 B / 66.96 KiB | 38,299 B / 37.40 KiB |
| 5,000 total live | 406.18 MiB | 328.23 MiB | 183.88 MiB |
| 5,000 RSS | 463.17 MiB | 312.53 MiB | 351.41 MiB |
| fixture allocation calls | 30,153 | 30,153 | 30,153 |

live改善は約54.7%、最終RSS改善は約24%。Session分離だけを見るとDebugAllocatorのsize class/page retentionによりRSSがborrowed-onlyより増える。**live −55%をRSS −55%と表現しない。** production allocator別のRSS/churn比較は残課題。今のarena約15.6 KiBとSession約16.4 KiBにも削減余地はあるが、段階的buffer化を測定せず追加しない。fixture mailboxはframework固定費と区別する。

## Correctness上の修正

TSanの初回Linux runはupgrade room testでEOFとなった。macOS反復でも再現し、baseline `97f04ac` のruntimeでも再現した。mailbox overflowは0、allocatorは最終live0。TSan data-race reportではなくcompletion publicationの論理的raceだった。

`refresh` が `done.load(.acquire)` を複数回行い、最初のsession分岐では未完了、後の通常HTTP分岐では完了を見た場合、公開されたincremental sessionを普通のHTTP closeへ送っていた。`5815bbc` で一度のcompletion snapshotに統一した。deadline/queue容量/Contract assertionを緩めていない。修正後local TSan 50反復は成功し、Linux/macOS sanitizer CIにも50反復を追加した。失敗runとbaseline再現もrawに残す。

attribution buildのclock probeがrecv/sendのerrnoを変更しないよう、`44eeb29`でSpan.endのerrnoを保存・復元した。production計測無効buildには影響しない。

## 検証、適したworkload、残課題

Threaded/kqueue/epollの共通Contract、incremental Threaded、isolation、session ownership/races、bounded-output/allocation fault、stress、TSanの結果はraw CI記録と下の表を参照。stream/upgradeの同期APIはReactorで明示unsupported、Threadedは従来どおり。CPU-bound/第三者blocking処理のunsafe preemptionはしない。

runtime source `44eeb29` の検証結果：

| 検証 | Linux | macOS | evidence |
|---|---|---|---|
| 通常CI（Native / Workers / CLI / ReleaseSafe / OpenSSL / Docker等） | success | success | run `37324533705`、15 jobsすべてsuccess |
| 共通Contract | Threaded + epoll + incremental Threaded、99件success | Threaded + kqueue + incremental Threaded、99件success | 同runのNative jobs |
| unit / allocation / lifecycle / bounded-output fault | success | success | 通常CI + investigation prerequisites |
| isolation / stress / session race | success | success | `ci-postfix` artifact |
| TSan Contract / isolation / session races | success | success | run `37324583960` |
| TSan upgrade publication / disconnect反復 | 50/50 success | 50/50 success | `tsan-postfix` artifact |
| 最終paired cost / benchmark / 1000・5000 idle /240秒mixed | success | success | run `37324577434` |

初回local30分soakは約24分後のホストIdle Sleep（378秒）で中断した。復帰時に1,016接続のframe deadlineがtimeout、mailbox overflow0、created=closed=6,728、final live0となった。`macos-soak-interrupted-by-host-sleep.json` と電源ログ抜粋を保存し、**soak成功には数えない**。再実行は`caffeinate -i`でidle sleepを抑止したが、約15分後のClamshell Sleep（491秒）で再び中断した。`macos-soak-interrupted-by-lid-sleep.json`と電源ログを保存した。両runともcleanup後live0だが連続30分soakは未確認。deadline、kernel/security、global sleep設定は変更していない。次回はsleepのない専用host/CIで長時間試験する。

Threaded性能もbefore/afterを比較した。最終Linuxの12 keep-alive casesは−1.2〜+3.0%、local macOS c32はhello −0.5% / echo +0.3% / db +1.4%。一方hosted macOS c32 helloは−26.6%、db +7.0%、echo +9.7%と大きく変動した。Native/Shared HTTP/Mutexソースは`97f04ac..44eeb29`で同一で、local uninstrumented binaryにcost symbolが残らないことも確認した（raw `threaded-regression-investigation.json`）。一貫したThreaded slowdownは再現していないが、hosted macOSの負の差を隠したり原因確定済みとは扱わない。専用hostでの再測定が必要。

Reactorの利点はbounded threads、idle WebSocket、有限frame/producer stepと通常HTTPのisolation。5,000 idleでfd約5,007、threads5を確認した。fixtureのbenchはworker8 + loopの9 threads、session testはworker4 + loopの5であり、両者のthread数を混同しない。

同条件の1,000 idleではThreadedは1,002 threads、framework live約19.65 MiB、Reactorは5 threads、live約37.7 MiB。ThreadedのSessionはstack上にも費用があるので、gpa liveだけで全メモリ効率を判断しない。初回最終CIではLinuxのRSSはThreaded約447 MiB / Reactor約52 MiB、macOSは約124 / 74 MiB。Threadedの5,000試験はhostの安全なthread/resource範囲を超えるため実行せず、1,000実測から外挿した値を結果に載せない。

mixed workloadは1000 idle WebSocket + active reconnect/frame +4 slow streams + hello/dbを含む。soakは本調査のrun durationを明示し、数分runを長時間認証とは呼ばない。定期sampleのRSS/fd/live/queue driftとfinal live0を確認するが、RSS retentionとlive leakを区別する。既存長時間soakの成功を新allocator配置の長時間成功へ外挿しない。

残課題は専用Linux profile、mutex/futexとnotification drainのexclusive cost、saturated short-lived workload、より長い変更後soak、production allocatorでのRSS/churn、large-message memory、broadcast under load、実application realtime workload。今回の実測だけでgateを解除しない。

## 最終32 connections比較

CPU probe無効・同条件のallocator statistics有効、keep-alive、2 rounds × 3秒の最終CI。差は最終Threaded比。短時間・hosted runnerの変動を含む。

| OS | endpoint | Threaded req/s | Reactor req/s | 差 |
|---|---|---:|---:|---:|
| Linux | hello | 75,356 | 35,158 | −53.3% |
| Linux | echo | 70,316 | 34,319 | −51.2% |
| Linux | db | 40,551 | 33,227 | −18.1% |
| macOS | hello | 53,029 | 41,085 | −22.5% |
| macOS | echo | 56,900 | 35,751 | −37.2% |
| macOS | db | 33,627 | 28,887 | −14.1% |

Reactor自身のbefore/afterはLinux hello +5.4%、echo +4.7%、db −0.9%、macOS hello +14.3%、echo +3.7%、db +5.0%。macOS helloのThreaded controlも低下しているため、最終gap縮小全体を最適化効果へ帰属させない。

## 測定表

以下の数値表はraw JSONから生成する。unitは明示し、instrumented throughputは含めない。

[最終測定表](../../benchmark/results/runtime-investigation-2026-10-05/report-tables.md)にはLinux/macOSそれぞれの4/32/128/256 connections、hello/echo/db、keep-alive/短寿命、P50/P95/P99、CPU/request、RSS、allocation、shutdown、inclusive cost、invocation、syscall、1,000/5,000 idle resourceを載せる。全roundのraw値も保持する。
