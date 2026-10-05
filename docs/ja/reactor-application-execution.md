# Reactor application execution — Phase 6設計・検証途中

基準は`75fcb26`。**Phase 6は未完了**です。Phase 7の性能最適化、Phase 8のproduction certification、Phase 9のexperimental公開判断には進みません。Threadedをdefaultとして維持し、Reactorの`ExperimentalRuntimeDisabled`を維持します。

## 確認したownershipの問題

`http/connection.zig.dispatchOne()`はhandlerを同期呼び出しします。`ws.upgrade()`の`Conn`はhandlerのスタック上にあり、socket/control/writerを借用し、`readMessage()`は次のframeまでpollを繰り返します。handlerが戻るまでrequest arenaとConn、Hub membershipが有効でなければなりません。

`Response.startStream()`もhandlerに同期writerを返します。Reactorのwriterは16 KiBのpending slotが空になるまでconditionで待ちます。slow readerによるbackpressureはbufferを制限しますが、writerの呼び出しスタックとworkerを解放しません。handlerはwriter間でsleepやDB処理を行うこともできます。

このAPIのままwriter/readMessageから途中returnする方法では、安全にhandlerの残りを再開できません。`Conn`や`Context`のポインタを保存するだけではstackとarenaの寿命が足りず、例外で巻き戻せばhandlerのdeferが実行されます。Groupへ移すだけでも、現在のThreaded backendのblocking taskがthreadを占有する問題は解消しません。worker増加やlong-lived connection専用threadへの移動をPhase 6完了とは扱いません。

## 今回実装した基盤

### 明示的なapplication admission

`ServeOptions.max_pending_application_tasks: ?usize`を追加しました。private Reactor evaluationでのみ利用し、`null`は`max_connections`を上限とします。Threadedでは無視します。0またはconnection上限より大きい値は初期化時に`InvalidApplicationTaskLimit`です。

固定容量FIFOはinit時の一回だけallocateし、enqueue/dequeue時にはallocateしません。実行中taskはpending数に含めず、同一connectionには既存のbusy状態によって一つのborrowしか存在しません。queue overflowは最も新しい未admit connectionをcloseし、応答をcommitしません。既にqueueへ入ったtaskを上書き・破棄しません。未admit taskに存在しないcompletionを待たず、その場でfd/arenaを回収します。shutdownではI/Oをabortし、worker join後にqueue borrowとconnectionを回収します。

この上限はresource protectionです。同期handlerが有限taskになったことやHTTP isolationを保証しません。

### WebSocket message semanticsのincremental化

`ws/message_state.zig.State.accept()`はdecoded frame一つを受け取り、`more / message / pong / closed`を返します。socket、poll、timer、threadを持たず、I/Oを待ちません。fragment aggregation、control frameのinterleave、UTF-8、close payload validationをここへ集約し、既存`Conn.readMessage()`も同じstateを使います。

messageはstateのbufferを借用し、次のaccept/deinitまでのみ有効です。旧`readMessage(arena)`は従来どおりcallerのarenaへコピーして返します。aggregate size limitはallocation/copy前に確認し、fragment用bufferのcapacityもmax payload以下に制限します。allocation failure時のcleanupをunit testで確認しています。新しいpublic WebSocket APIとしてはexportしていません。

これは有限frame taskを作るためのprotocol境界です。socket readinessからtaskへ渡すsession adapter、workerを解放するproducer、broadcastのsession token ownershipは未実装です。

## Isolation gateと実測

`runtime-isolation-test`は長寿命接続と通常HTTPを同時に流し、HTTPが250 ms以内に処理されることを要求します。現在は既知のisolation失敗によって非zero終了します。`runtime-isolation-evaluate`は同じ測定を行い、未達条件をJSONへ保存します。CIでは後者を実行しますが、CI成功をPhase 6成功と読み替えません。

検証scenario:

- 四つのidle WebSocket + 通常HTTP
- 四つのslow-reader stream + 通常HTTP
- 二つのWebSocket + 二つのslow stream + 通常HTTP
- worker 1、pending limit 1のqueue overflow、切断後のadmission recovery

macOSの実測ではThreadedは三つのisolation scenarioすべて成功、kqueueはすべて250 ms期限を超えました。queue overflow/recoveryは成功し、全scenario終了後のallocator live bytesは0です。I/O forced drainも回収しました。小さいclient receive windowに残るTCP dataを全て読む時間と、server側ownershipの解放時間は区別しています。

raw data、binary SHA、環境、commandは[Phase 6記録](../../benchmark/results/runtime-phase6-2026-10-05/README.md)へ保存します。既存29件のTransport ContractはThreaded/kqueueで維持しています。Linux/epollの結果はCIで別途確認し、未測定の性能やsoak成功を推測しません。

## 次に実装するportable incremental execution

採用候補は同期handlerの透明なsuspendではなく、applicationが有限stepを明示するsession/producer APIです。以下は設計であり、利用可能なAPIではありません。

```text
initial HTTP handler (短いworker task)
    ↓ explicit ownership transfer after handler returns
owned session state + bounded input/output + generation token
    ↓ readable / output drained / timer
one admitted finite frame/producer step
    ↓ result copied/moved into bounded output
worker completion → event loop → send / await next event
```

- Initializerは通常のApp/middleware/authを使います。Context/stack pointerをsessionへ残しません。必要なrequest dataを明示的にconnection-owned stateへコピーします。
- Frame decodingとmessage assemblyは共通protocol codeを使います。入力・message buffer、fragment state、read-ahead bytesはsession所有です。event loopはDBやapplication callbackを呼びません。
- Producerはruntime提供の固定容量output sliceへ一step分を書きます。pending outputが消費されるまで次のstepをadmitしません。同期writerのconditionでtaskをparkしません。
- Application taskは一connectionにつきqueued/running合わせて最大一つ。read readinessやbroadcastを無制限なclosure queueへ変換せず、generation tokenとbounded inboxで処理します。FIFOで再admitし、step/outputのquantumを制限します。
- Taskの一時allocatorはstep completion後にresetします。session stateとrequest arenaの寿命を区別し、application callbackが借用payloadを次stepまで保持しないcontractを明示します。
- Session cancelは新規stepを停止し、running task completionをjoinしてからstateを破棄します。fdはevent-loop ownerのみがcloseします。Hubへのbroadcastはstack `Conn` pointerをsessionへ流用せず、generation付きtokenとbounded output admissionを使います。
- Arbitrary CPU/第三者blocking callはunsafeにpreemptしません。finite stepには協調completionが必要です。step APIを「event loop上で呼んでもblockしないはず」というfast-pathにしません。
- Threadedの同期APIは維持します。incremental APIもThreaded/Workers adapterで利用できる境界を設計し、Reactorの同期API対応可否と明示的unsupportedの扱いを確定してから公開します。

実装順序はstream stepの共有serialization/lifecycle、upgrade session handoff、generation token broadcast、同一Contractへisolation/fairness追加です。fragment・control・HEAD・fixed-length・エラー・read-ahead・shutdown semanticを保ち、Phase 6完了前にwake batching、selector batching、lock-free化やthroughput調整を進めません。

## 再現

```sh
zig build test runtime-contract-unit transport-contract-test -Doptimize=ReleaseSafe
zig build runtime-isolation-evaluate -Doptimize=ReleaseSafe
zig build runtime-isolation-test -Doptimize=ReleaseSafe # 現在はisolation未達で失敗するgate
zig build -Dbackend=workers -Dexample=chat -Doptimize=ReleaseSafe
```

Phase 6を成功側へ変更する条件は、既存protocol/ownership testを保ちながら、上記isolation gate、多数idle + active WebSocket + HTTP + slow stream、bounded queue、disconnect/timeout/shutdown raceをすべて通すことです。それまではPhase 7〜9未着手、Reactor Not Readyです。
