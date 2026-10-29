# 競合性能の調査

Nativeの本番defaultは **Threaded** です。Multiplexed runtimeは専用入口で
評価する研究実装で、`.runtime = .reactor` は引き続きfail-closedです。
Workersとapplication/HTTP contractを共有し、benchmarkの改善だけを理由に
本番runtimeを切り替えません。

[Competitive initiative](../../benchmark-results/competitive/architecture-baseline.md)
ではActix Web、Axum、Go net/http、zap、Honoのfixtureを固定しています。
Nativeは同一ホストでHTTP/1.1、body、Content-Type、payload、SQLite source/SQL、
keep-alive条件を揃えて逐次測定します。自動headerとruntime構造の差は記録します。
zapはupstream対応のZig toolchainを使い、架空のAkamata向け移植はしません。

数値を読む前に[測定方法](../../benchmark-results/competitive/methodology.md)と
[負荷生成器の校正](../../benchmark-results/competitive/generator-calibration.md)を
確認してください。全roundの中央値と全エラーを保持します。loopback測定を
性能認証や負荷生成器の無限の余力の証明として扱いません。HTTP 200の完了数と
失敗を含むattempt数は分けて報告します。

## 全matrixの完了結果

[最終レポート](../../benchmark-results/competitive/final-report.md)にbaseline
1,260件とafter 630件を保存しています。7 workload・6接続段階で、warmup 10秒＋
測定30秒を各5回実施し、欠落なく検証しました。失敗も保持しています。
[判断用の表](../../benchmark-results/competitive/decision-evidence.md)では全roundの
中央値、CPU/RSS、P99、エラー、round間のばらつきを確認できます。

4-loopは最終Threaded比で1,024接続plaintextのP99を39.249→19.127 ms、RSSを
131.9→31.7 MiBに抑える一方、32接続のthroughputは31.9%低下しました。
大きなEchoのP99もblockerです（512接続で25.095→366.327 ms）。
Reactorは **Not Ready** と判断し、fail-closedを維持します。

before/afterのmacro差は異なる時期の観測値であり、最適化による因果的な改善率
ではありません。32接続plaintextはthroughputと同時にCPU・P99も増加し、環境の
変動も大きく見られます。普遍的な競合優位性は主張しません。clientの接続・reset
エラーの正確な原因も未解明です。

## 限定的な変更と証拠

- Threadedのidle接続は、100msごとの起床の代わりにAppが所有する共有shutdown
  通知を待てます。[3回のidle試験](../../benchmark-results/competitive/idle-shutdown.md)
  では1,024接続のCPUが大幅に低下し、thread数/RSSはほぼ同じでした。
  多数のthreadを同時に起こすためshutdown latencyにはトレードオフがあります。
  read/write deadlineとCPU handlerの協調的drainは維持します。
- JSONの数値を既存Writerへ直接出力します。[5回のmicro測定](../../benchmark-results/competitive/routing-json.md)
  では整数配列が改善し、広い数値の固定bufferによるpanicも修正します。
  HTTP JSON全体に同じ改善率が出るとは主張しません。
- privateな4-loop候補は、合計8workerを分割し、接続/taskの上限を全体で守ります。
  Session、Cursor、incremental stream/frameのownershipを再利用します。
  Reactor評価では同期stream/upgradeを明示unsupportedとし、Threadedでは維持します。

Nativeの全matrixは完了しています。Linux性能と実Workers性能は未測定です。
revisionを明記したContract/CI/TSan結果は最終レポートから辿れます。
[raw evidence](../../benchmark-results/competitive/raw/)と
[再現script](../../benchmark/competitive/README.md)で短時間screen、instrumentation、
idle測定、指定時間での測定を区別します。逐次測定中はbuild/test/他の負荷を
実行しないでください。

## Workersの証拠レベル

[Akamata WASM/Hono host試験](../../benchmark-results/competitive/workers-comparison.md)
はresponse bytesとfake D1 adapterを検証します。実CloudflareのCPU時間、edge
latency、cold startは測定していません。専用live resourceは用意されておらず、
実環境の性能優位性や認証は主張しません。
