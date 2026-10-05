# Native HTTP runtime / Transport Contract（Zig 0.17）

Threadedがproduction defaultです。public Reactorはsocketを開く前にfail-closedします。[application execution](reactor-application-execution.md)、[Phase 7測定](../../benchmark/results/runtime-phase7-2026-10-05/README.md)、過去の[Phases 2〜5](native-runtime-phases.md)も参照してください。

```text
App → Shared HTTP (session / connection / response cursor)
                   ↓
       Finite application steps / static Transport
                   ├─ Threaded: production
                   └─ Reactor: private multiplexed evaluation
                              ├─ kqueue (macOS/BSD)
                              └─ epoll (Linux)
```

```sh
zig build transport-contract-test runtime-contract-unit runtime-isolation-test runtime-stress-test -Doptimize=ReleaseSafe
zig build runtime-certify-fixture -Doptimize=ReleaseSafe
python3 tools/bench/runtime_certify.py zig-out/bin/runtime-contract-server --output certification.json --idle-levels 100 1000 --mixed-idle 100 --soak-seconds 1200
```

`http/session.zig`が入力/framing・absolute read budget・limit・pipeline残留、`http/connection.zig`が共通dispatch/error、`http/response_cursor.zig`がHEAD/upgradeを含む共有serializerを担当します。WebSocket fragment/control/UTF-8/close validationは`ws/message_state.zig`に集約します。selector側にHTTP実装を持ちません。

Transportはstatic dispatchで、新しいvtableやper-step task allocationはありません。finite callbackはcomptime adapterで既存endpoint型のABIへ変換します。Threadedの同期APIは維持し、Reactorの同期stream/upgradeは明示unsupported（default HTTP 501）、owned incremental sessionを必須とします。idle/readiness/timer/output待ちはworkerを保持しません。event loopがsocket I/Oを所有し、workerは有限initializer/producer/message/cleanup一stepを実行します。

connectionごとのqueued/running borrowは一つです。通常FIFOとcancel用予約FIFOは固定上限です。outputは16 KiB pending slot、response cursorは4 KiB quantum、sessionは8 KiB emissionです。EAGAINでは残りoffsetを保持しreadinessを待ち、入力/message limitは拡張前に検証します。cleanupはsender/worker borrowをjoinし、closedを一回deliverしてからarenaを破棄します。fdはsocket ownerだけがcloseします。

HTTP header/body/total read budgetはabsoluteで、partial progressで延長しません。total timeoutはhandlerをpreemptしません。WebSocketはframeごとにbudgetを持ち、complete control/fragment frame後は次frameへ移ります。`write_timeout_ms`は最初のoutputからbuffered response/stream全体（producer待ちを含む）、WebSocketはhandshake/frameごとを制限します。partial writeで更新せず、0はoutputを許しません。shutdownは受付停止、graceful drain、期限でI/O force shutdownです。CPU-bound/第三者blocking callbackは協調completionが必要で、任意codeのunsafe cancelやprocess終了期限を保証しません。

共通33ケースをThreaded同期、Threaded incremental、host Reactorへ実行します（99件）。framing/limit/timeout、keep-alive/pipeline/read-ahead、disconnect、peer/proxy、stream/upgrade、backpressure/admission、graceful/forced shutdownを検証します。idle/active upgradeとslow streamを混在させ、通常HTTPが250 ms以内であることも要求します。allocation failure、stale token、session cleanupも検証します。長時間certificationはmanual CIに分離し、Contract成功だけではgateを解除しません。

基準はinstalled Zig 0.17.0です。libc accept/pollはoperation deadline・shutdown readiness・errno処理、pthread mutex/conditionは同期ownershipのため維持します。signal handlerはstateだけをpublishし、runtime cleanupがfd closeを所有します。Groupの過去の性能/cancellation評価が採用を正当化しなかったため、Threaded connection threadとatomic drainは維持します。Groupはtask ownershipの責務でHTTP semanticsではありません。Reactorは標準OS ABIとindexed deadline heapを使います。

private `-Druntime-tsan=true`で対応targetのContract fixtureをinstrumentできます。成功は観測範囲の証拠で、すべてのrace不在の証明ではありません。allocation counterはSQLite/libc mallocとthread stackを含みません。Native incremental callbackはexperimentalで、Workers event adapterは現在明示unsupportedです。

現在の検証・公開判定は [Phase 6–9 report](native-reactor-phases6-9.md) を参照してください。
