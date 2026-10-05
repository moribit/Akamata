# Akamata アーキテクチャ

Akamataは同じZig applicationをNative／VPS／Container／Cloudflare Workersで動かすportable backendです。HTTPは`App → Context → endpoint/middleware → runtime`の単一系統です。

## Applicationとadapter

- `src/app.zig`がroute登録、middleware chain、lifecycle hook、dispatchを管理します。`src/context.zig`がrequest、response、application state、portable serviceを提供します。handlerは`*am.Context(State)`、middlewareはContextと`am.Next(State)`を受け取ります。
- `src/static_router.zig`、`static_middleware.zig`、`contract.zig`は同じAppへのcompile-time登録／bindingを提供します。別系統のHTTP Server APIではありません。
- `src/serve.zig`がbackendを選択します。Nativeのlistener／admission／lifecycleは`runtime/threaded.zig`、HTTP処理は共通の`http/connection.zig`に置き、`runtime/socket_transport.zig`をstatic dispatchします。Threadedは共通incremental Sessionを同期駆動し、private kqueue／epollは一つのevent loopと固定worker poolでsocketを多重化します。production Reactor gateは維持します。[現行lifecycleとTransport Contract](runtime-transport.md)を参照してください。
- Workersは`src/runtime/workers.zig`と`deploy/worker/`のJavaScript WASM bridgeを使い、同じAppへdispatchします。JSPIによる非同期host操作の中断を含め、request全体を直列化します。bridgeの実装詳細はapplication handlerから隔離します。
- Database、Storage、Queue、Realtimeはportable interfaceとplatform adapterを持ちます。SQLite／TursoとWorkers D1は`am.db.Db`、filesystemとWorkers R2はStorage境界を利用します。platform限定のcapabilityは明示します。

```zig
const State = struct { hits: u32 = 0 };
fn hello(c: *am.Context(State)) !void {
    c.state().hits += 1;
    try c.text("hello");
}
// application初期化時:
// var app = am.App(State).init(allocator, .{});
// defer app.deinit();
// _ = try app.get("/hello", hello);
// try app.serve(.{ .port = 8080 });
```

Nativeで並行requestを処理する場合、共有mutable stateには同期が必要です。

## Native requestの流れ

1. connection上限を守ってacceptし、peer addressを記録します。
2. header／bodyをsize limitとheader／body／idle／total deadline付きでparseし、曖昧なframingを拒否します。
3. Appのroute matching、Context生成、middleware、endpointへdispatchします。
4. responseまたはchunked streamを送信し、keep-alive上限の範囲でconnectionを維持します。
5. Native WebSocket upgradeではconnectionを`am.ws.Conn`へ渡し、upgrade後のlifecycleはそのconnectionが管理します。Workers realtimeはplatform bridgeを使います。

## BuildとC binding

| Backend | Target | 用途 |
|---|---|---|
| Native | Host default | ローカル開発／VPS |
| Native | `x86_64-linux-musl` | Container用static binary |
| Workers | 自動`wasm32-freestanding` | Workers WASM |

Nativeはvendored SQLite amalgamationをcompileします。`build.zig`は公式external translate-cのZig 0.17ブランチの固定コミットでheaderを変換し、`sqlite3` moduleとしてimportします。`-Dopenssl=true`時だけ`src/crypto/openssl.h`をsystem `ssl`／`crypto`のinclude／link探索付きで変換し、RS256署名に利用します。Workersではこのlazy Native依存を生成しません。source内のC importは使いません。[binding方式の比較](v0.2-phase1.md#c-bindings)を参照してください。

## CLI構造

`tools/akamata/src/main.zig`は引数、help、exit動作、command dispatchを担当します。`command/`が処理を組み立て、`project/`がmanifest、scaffold、managed-file hash、update保護を管理します。`process.zig`はsubprocess transport、`native.zig`はdev watcherと共有するPOSIX filesystem ABIを担当します。

Cloudflare操作は`command → cloudflare/operations.zig → cloudflare/wrangler.zig → process`です。deployとD1 create／list／execute／provisionを操作APIに集約し、offline contract test用にrunnerを注入できます。providerの引数・出力形式は`cloudflare/`内、configuration renderingは`cloudflare/config.zig`に置きます。Wranglerが唯一のdefault providerです。現在の`--containers`はLinux binaryとDocker imageをbuildする機能で、Cloudflare Containersのprovision／publishは行いません。

## 運用上の境界

- inbound TLSはCloudflare／nginx／Caddyで終端します。Native outbound HTTPSはOS certificate rootを使う`std.crypto.tls.Client`、Workersはhost fetchです。OpenSSLは署名用で、outbound transportには使いません。
- HTTP parsingは重複CL／Host、曖昧なframing、obs-fold、不正chunk、未対応versionを拒否します。response headerはinjectionを拒否します。Native parsing deadlineとconnection／request上限は`ServeOptions`で設定します。
- metrics、tracing、request ID、timingは既存middlewareとrequest-scoped observabilityを使います。clock／transportはplatform adapterに分離されています。App configurationの整理はPhase 2で評価します。
- Workers D1は非同期JSPI bridgeを必要とし、bridgeが無い場合はfail closedです。Native限定job queueとMQTTはcapability限定です。portable scheduled eventはPhase 2で設計します。

削除API、検証内容、次の設計評価は[v0.2 Phase 1](v0.2-phase1.md)を参照してください。

Native Reactorは有限application stepとconnection ownershipを分離します。同期stream/upgradeはThreadedで維持し、Reactorではincremental sessionを必須とします。共通HTTP・bounded queue/output・static Transportの構造と公開gate判断は [Phase 6–9](native-reactor-phases6-9.md) を参照してください。
