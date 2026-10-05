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
