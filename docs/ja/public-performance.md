# Native性能の測定記録

紹介PDFでは`a7605ba`をApple M2 / 16 GiB / macOS 27 arm64 / Zig 0.17.0で再測定しました。
Native production defaultはThreadedです。今回はruntimeの性能最適化を行っていません。

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
