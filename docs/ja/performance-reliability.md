# v0.2.1 performance / reliability

Native production defaultはThreadedを維持します。ReactorはPark / fail-closedです。
今回release tagやGitHub Releaseは公開しません。

[DB Poolのdeadlineとmetrics](db-pool.md)を参照してください。Zig 0.17の
std.Io Mutex / Conditionと単調時計の絶対deadlineを使用します。closeは取得停止、
deinitは既存の取得処理とlease返却を待って解放します。初期化成功時だけDBの
ownershipが移ります。queryの強制cancelは行いません。

ServeOptions.metrics / App.metricsから既存Prometheus Countersを明示borrowします。
request ID、DB span、Server-Timingと既存backend labelは維持します。phaseの
read / parse / route_middleware / handler / serialize / writeはwall timeです。
handlerとserializeは重複し、合計をrequest totalやCPU時間として扱えません。
同期stream / upgrade I/Oは新しいwrite phaseの対象外です。

## Native / Workers対応表

| 機能 | Native Threaded | Workers managed host |
|---|---|---|
| Buffered HTTP | 対応 | 対応。instance内のWASM ABI transactionを直列化 |
| HTTP Streaming / SSE | bounded write / drain付きで対応 | 同期Response streamingは未対応・fail-closed |
| WebSocket / Realtime | Native socket owner / Service | 明示DO gateway / control owner。transport lifecycleは異なる |
| DB | SQLite / Turso、Native Pool deadline | D1 / Turso。Native Poolは使わない |
| Storage | Filesystem Store / bounded reader / caller-owned page | R2 Store bridge / caller-owned opaque page |
| Queue | jobs.Queue provider / stop・join | 明示producer binding / consumer dispatch |

[Cloudflare Streams](https://developers.cloudflare.com/workers/runtime-apis/streams/)の
対応とAkamataの同期socket producer対応は別です。現在のglueは完成したWASM
responseをコピーし、allocatorとresponse registryを共有するtransactionを直列化
します。安全なReadableStream bridgeには独立producer lifetime、bounded pull、
abort cleanup、error伝播、Content-Length検査が必要です。完成bufferをstreamで
包むだけのshimは採用しません。socket writerがなければUnsupportedOnTargetです。

Pool取得のtimeoutはquery timeoutではありません。SQLite / Turso / D1のquery
limit・cancellationはprovider固有です。自動query retryやexactly-onceは保証しません。
Queueはat-least-onceで、event ID / version / attempt / correlation / idempotency
metadataを維持します。retry・dead-letter policyはextensionです。Storageのcancelと
conditional errorは既存Store / bridge Contractへ従います。

## Typed wire contract

同一Endpointの実HTTP error response、OpenAPI、TypeScriptでstatusとerror_kindを
照合します。Enumをliteral typeとして保持します。Tagged unionはZig標準JSONの
active-tag objectで、void payloadは空objectです。[Handler API](handler-api.md)参照。
optional / nullとdefault / omissionを区別し、custom serializerのschemaは推測しません。

## Allocationと不採用判断

`zig build http-allocation-profile -Doptimize=ReleaseSafe`でarenaへの論理allocationと
backing heapを区別します。小さなfixtureではparse・header・static body copyが各1回、
JSON header/bodyが2回です。Cursor/writeのheap allocation、retain-capacity後のJSON
1,000回の追加heap allocationは0でした。全APIのallocation-freeという意味ではありません。

Borrowed Response、自己参照inline buffer、global buffer poolは導入しません。
測定したwarm heap costではownershipと保守の複雑化を正当化できません。既存arena、
body ownership、static dispatchを維持します。transport初期化失敗時のsocket cleanupを
修正しました。DTOのrequired検査後のzero初期化fallbackを除きtagged unionに対応しました。

## 再現方法と証拠

raw dataは[benchmark-results/v0.2.1](../../benchmark-results/v0.2.1/README.md)です。
binary SHA、oha結果、CPU / RSS / thread、error、shutdownを保存します。instrumented
runをthroughput比較と混ぜません。build mode、allocator、input、接続寿命、samplingを
合わせて比較してください。HTTP fixtureは100 requests/connectionなのでheap集計には
起動と接続renewalを含み、論理allocation/requestとは異なります。

```sh
zig build -Dexample=bench -Doptimize=ReleaseFast
python3 tools/bench/runtime_matrix.py after=zig-out/bin/bench --output /tmp/after.json --connections 32 128 512 1024 --rounds 3 --duration 3s --modes keep_alive
python3 tools/bench/runtime_matrix.py after=zig-out/bin/bench --output /tmp/metrics.json --connections 32 --idle 32 --rounds 3 --duration 3s --observability metrics
python3 tools/bench/runtime_matrix.py after=zig-out/bin/bench --output /tmp/large-json.json --connections 32 --idle 32 --rounds 3 --duration 3s --endpoints echo --echo-bytes 65536 --stats
zig build test db-pool-test transport-contract-test runtime-contract-unit -Doptimize=ReleaseSafe
zig build portable-application-test documentation-test -Dbackend=workers -Doptimize=ReleaseSafe
zig build db-pool-test -Druntime-tsan=true -Doptimize=ReleaseSafe
```

既存Linux/macOS TSan workflowにPool raceを追加します。offline adapter Contractと
WASM host simulationはlive Cloudflareの保証ではありません。live testには専用resourceと
credentialsが必要で、通常CIからresourceを自動作成しません。

準備済みstatic routeと空handler、同じrouteとpassthrough middlewareは、診断fixtureではともにarenaへの論理allocationが0です。route登録・prepare・response payload生成は含みません。

## 測定上の残課題

32接続の最終paired中央値ではhello・echo・dbのthroughput差は1%以内です。
接続上限である1,024接続の10秒echo再試験では、P99が28.834 → 37.758 msとなり、
原因は未解明です。この境界でmetrics付きDB負荷には接続拒否とclient errorが
記録されました。1,000接続の診断では全3 roundの拒否数は0ですが、少数のclient
errorは残ります。短時間のローカル測定であり、zero-error capacityやP99の
同等性を保証するものではありません。
[全測定レポート](../../benchmark-results/v0.2.1/README.md)を参照してください。
