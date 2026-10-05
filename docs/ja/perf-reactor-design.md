# Reactor設計：多重化より先に共通protocolを確立する

`.runtime = .reactor`は`error.ExperimentalRuntimeDisabled`を返します。
両Reactor moduleの直接entrypointもsocketを開く前にfail closedです。
Threadedをproductionとして維持し、throughputではなく安全性parityで有効化を判断します。

## 現在の構造

`serve.zig`がbackendを選び、`runtime/threaded.zig`がlistener、admission、
connection workerを管理します。`http/connection.zig`がHTTP parsing、request lifetime、
App dispatch、serialization、keep-alive、stream、upgrade、read budgetを共通化します。
`runtime/socket_transport.zig`のstatic境界は既存のstd.Io Reader／Writerを使い、
poll／kqueue／epollがreadinessを提供します。

旧per-core prototypeのHTTP／worker loopには固定受信buffer、EAGAINでのspin、
limits／deadlines／peer IP／upgradeの不足がありました。このloopは削除し、
標準のtarget ABI型を使うkernel readiness adapterへ縮小しました。
Linuxのpacked epoll_eventも標準定義を使います。

private `evaluate`は実証済みのthread-per-connection lifecycleを使い、
共通HTTP driverをkqueue／epoll readinessへ接続します。
これはsocket adapterの互換性評価で、**多重化Reactorのparity証明ではありません**。
公開worker_countはReactor無効中の予約設定として維持します。

## 検証と有効化条件

```sh
zig build transport-contract-test -Doptimize=ReleaseSafe
zig build runtime-poc-test -Doptimize=ReleaseSafe
```

共通20 socket testはThreadedとhost kernel adapterを検証します。
Group PoCは別経路です。framing／limits／deadlines、keep-alive／pipeline、
stream、upgrade read-aheadとownership、admission、backpressure分離、
peer／proxy、disconnectとshutdownを扱います。

production有効化前には以下が必要です。

- 非blocking read/write、partial write state、bounded output queue。EAGAINでspinしない。
- Io task backendか共通protocolのincremental driverで接続を多重化し、HTTPを再実装しない。
- stream／upgradeのtask・buffer・socket所有権とcancel。
- deadline／admission／queue上限、kernel wakeup、graceful／forced drainのpolicy。
- 多重化後の同じContractをLinux／macOSで実行し、stress／fault injection／resource leakも検証。
- idle／burst／stream／upgrade workloadのlatencyとRSS比較。

Zig 0.17のIo.Groupは独立PoCです。asyncはinline実行が許されるため、
connectionにはconcurrentが必要です。production採用は別フェーズです。
既存write_timeout_msは予約設定のため、現在のbackpressure testを
write／forced drain deadlineの保証として扱いません。

調査、workaroundの理由、Contract、PoC、benchmarkは[runtime／transport報告](runtime-transport.md)にまとめています。
過去のprototypeの測定は[benchmarks](benchmarks.md)に残しますが、
現在のproduction gateやruntime推奨の根拠にはしません。
