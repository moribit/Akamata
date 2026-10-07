# Cloudflare デプロイ

AkamataはNativeとCloudflare Workers (WASM)でapplication contractを共有します。
[Getting Started](quickstart.md)から始め、provider ownerとbindingは明示します。
adapter contract / WASM host simulationはoffline証拠であり、live certificationではありません。

## Cloudflare Containers

ContainerはNative Linux process/providerを利用します。Akamataの`--containers`は
binaryとlocal Docker imageをbuildし、Cloudflareへのprovision/publishは行いません。
別途platform control planeを[最新Cloudflare Containers資料](https://developers.cloudflare.com/containers/)で設定してください。

```bash
zig build -Dexample=chat -Dbackend=native -Dtarget=x86_64-linux-musl -Doptimize=ReleaseFast
docker build -f deploy/Dockerfile -t akamata-chat .
```

filesystem/SQLiteの永続化には明示的なdurable volume/storage戦略が必要です。
Akamataはlocal SQLite fileをD1/DOへ自動変換しません。platformの制限/APIは公式資料を参照してください。

## Cloudflare Workers (WASM)

JS薄ラッパーは`-Dexample=...`で選択したWorkers applicationの安定alias
`akamata_worker.wasm`をロードしてリクエストを送り込む。

```bash
# --target=workers/bothで生成したproject内（HelloにD1は不要）
zig build -Dbackend=workers -Doptimize=ReleaseSafe
cd deploy
wrangler dev --local
```

デプロイ:

```bash
cd ..
akamata deploy --workers
```

### D1

D1が必要なappでは専用resourceを別途明示作成/選択し、binding・実UUIDを設定して
レビュー済みmigrationを適用します。deployはplaceholderを拒否します。
[Deployment validation](deployment-validation.md)を参照してください。validationはresourceを作成しません。
[guestbook](../../examples/guestbook/README.md)のschemaを最小Hello projectへ適用する必要はありません。

### Durable Object: WebSocket

現在のchat referenceは`/realtime/:resource`、共有typed Protocol、managed `AkamataRealtimeRoom` adapterを使います。匿名nickname policyはtutorial限定です。検証済みcredentialの例はdevice_messagingを参照してください。

portable Realtimeでは`/realtime/:resource`を使います。`:resource`は信頼済みroom ID
ではありません。WorkerはAuthorization headerを必須とし、共通Zig handler
`POST /__akamata/realtime/authorize`へ渡します。applicationが認証・参加許可した後に
Principalからroom/logical identityを導出します。client由来`X-Akamata-*` headerは
破棄されます。

Durable Objectは受信messageを自動転送しません。64 KiB、text、JSON envelopeを検査し、
`AKAMATA_REALTIME_HANDLER` service binding経由でapplication handlerを呼びます。
direct/broadcast/sender除外/disconnectの明示actionだけを適用します。

`worker/realtime_handler.mjs`を`wrangler.realtime-handler.toml`で別Workerとして
deployし、gatewayからnamed entrypoint `AkamataRealtimeApplication`へbindingします。
handler Workerのdefault entrypointは常に404です。公開gatewayへのself bindingは
使用しません。

`am.platform.workers.R2Store`はJSPIを使います。現在のHTTP→WASM bridgeは最初に
`request.arrayBuffer()`し、uploadはapplication上限まで集約するためzero-copyでは
ありません。downloadも64 KiBずつreadしますが最終responseはWASM memoryへ集約します。
`get`はETag/Content-Type/custom metadataを伝播し、`list`は
bounded pageを返します。既存`head`のR2実装はsizeのみなのでconditional metadataが
必要な場合は`serveDownload`または`get`を使います。

optional live testはD1 write/read、R2 put/Range 206、認証済み2接続DO WebSocket relay、
内部routeの公開拒否を検証します。Nativeの長時間WebSocket loopでは
`am.realtime.MessageArena`を使い、各frame処理後にresetしてください。

## wrangler.toml の要点

```toml
name = "akamata-chat"
main = "worker/index.mjs"
compatibility_date = "2026-08-17"

[[d1_databases]]
binding = "DB"
database_name = "akamata"
database_id = "<your-d1-id>"

[[durable_objects.bindings]]
name = "AKAMATA_REALTIME"
class_name = "AkamataRealtimeRoom"

[[migrations]]
tag = "v1"
new_sqlite_classes = ["AkamataRealtimeRoom"]
```

[Chat reference](../../examples/chat/README.md) uses a named self-service binding `AKAMATA_REALTIME_HANDLER` for its shared Zig inbound handler; copy the complete configuration, not only the simplified DO excerpt above. Existing ChatRoom deployments need an explicit migration plan.
