# Native性能の測定記録

紹介PDFでは`a7605ba`をApple M2 / 16 GiB / macOS 27 arm64 / Zig 0.17.0で再測定しました。
Native production defaultはThreadedです。この紹介資料の測定時にはruntimeの性能最適化を行っていません。

| Workload | 全round平均のHTTP 200 throughput |
|---|---:|
| GET /hello | 164,610 req/s |
| POST /echo | 163,790 req/s |
| GET /db/1 | 86,793 req/s |

ReleaseFast、32 keep-alive connections、IPv4 loopback、oha 1.15.0。
各workloadで3秒を3round実行し、SQLiteを先に1,000 requestでwarm-upしました。
echo payloadは`{"name":"x","n":42}`です。build/testとの同時実行はありません。
全roundを使用し、client errorはありません。各roundの200件数を実測時間で割り、
算術平均を取っています。PDFは千単位へ丸めています。

短時間のworkstation snapshotです。controlled performance certification、capacity保証、
他frameworkとの比較ではありません。tail latency・DB contention・network・application処理で変わります。

[raw oha・RSS・binary SHA](../evidence/public-presentation/threaded-main.json)と
[commit・CPU・toolchain・command](../evidence/public-presentation/environment.json)を保存しています。

```sh
zig build -Dexample=bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_compare.py zig-out/bin/bench /tmp/threaded-main.json --rounds 3 --duration 3s
```

ohaと空いているlocal port 8080が必要です。runnerは自身のserverだけを停止します。
[以前のDX regression比較](../evidence/developer-experience/reproduce.md)も参照できます。
ReactorはPark/fail-closedで、紹介資料の主要feature・性能claimには含めません。

## v0.2.1の同一環境・変更前後比較

保存した`f0eb0b6`と最終runtime fixtureのbinaryを比較します。上の紹介資料の値を
Beforeとして使いません。M2 / 16 GiB / macOS 27.0 / Zig 0.17.0、ReleaseFastと
DebugAllocator、oha 1.15.0、loopback、32 keep-alive clients、3秒×3回の**全roundの中央値**です。
このmatrixはcaseごとにserverを起動しCPU / RSS / threadをsampleします。紹介資料の
serverを継続・warmupするrunnerとは条件が異なり、過去の絶対値との差をv0.2.1の
変更によるものとは判断しません。

| HTTP 200/s | Before | After | 差分 |
|---|---:|---:|---:|
| /hello | 97,696 | 97,658 | −0.04% |
| /echo | 97,689 | 96,947 | −0.76% |
| /db/1 | 82,249 | 81,991 | −0.31% |

P99は順に0.730→0.761 ms、0.834→0.711 ms、2.887→2.857 msです。
backing allocationはhello / echoで約0.020回/request、dbで約1.020回/queryで、
起動と100 requests/connectionでの接続更新を含みます。診断fixtureでretain-capacity後の
warm JSONは追加backing allocationが0でした。

具体的な改善は信頼性です。64 KiB JSON keep-alive bodyがbuffered readで停止する
不具合を修正し、修正後の全load roundでclient errorが0でした。推測によるborrowed
responseやbuffer poolの最適化は採用しません。metricsは計測済みの負荷がありopt-inです。

defaultの接続上限1024では、長い試験で両binaryにerrorとtail latencyの変動があります。
10秒の再比較でもechoのP99が悪化しており、原因は未確定です。zero-error capacity
certificationやP99 parityを主張しません。

[raw round・環境・binary SHA・command](../../benchmark-results/v0.2.1/README.md)に
32 / 128 / 512 / 1024接続、large JSON、metrics on/off、短命接続、Pool飽和、shutdown、
tailの診断を保存しています。[信頼性ガイド](performance-reliability.md)も参照してください。
