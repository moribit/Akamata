# Examples: Living Reference 最終設計

Baseline: `c69bbd8190e0e53e612f25448a6a6c86f83b70ef`（作業開始時のorigin/main）。
実装候補: `c817872`。Zig 0.17.0。初期棚卸しは[audit](audit.md)、
frameworkへ吸収する／しない判断と実アプリ比較は[boilerplate](boilerplate.md)。

## 学習経路と変更

| 順序 | Reference | 最終責務 | 単一source / test |
|---|---|---|---|
| 0 | scaffold / `tests/docs/minimal.zig` | 普通の関数がHTTPになる。DB・Providerを先に説明しない | CLI scaffold/public journeyとdocumentation-test |
| 1 | guestbook | Typed HTTP、validation、DB、OpenAPI、TS client | `contract.routes` → `setup.Application` → production/test/Metadata |
| 2 | tasks | Queue、有限consumer、DB effect、Native SSE、testing | 同じApplication graph＋QueueRecorder / real jobs.Provider |
| 2 | chat | portable domain/Protocol/Serviceとplatform transportの区別 | 同じroute graph、HTTPとframe/DO messageが同じpersist処理 |
| 3 | device_messaging | 複数provider、Principal、binding、partial acquisition、shutdown | `application.endpoints`＋Contract/Provision＋明示entrypoint owner |

新しいHello projectは追加せず、scaffoldをcanonical minimalにした。
chatの旧`ws_hub.zig`、重複UI、旧ChatRoom JSを削除した。example名は維持。
bench/router_benchは教材indexから分離し、fixture READMEを追加した。
CI/script/履歴への影響を避け、物理パスは移動していない。

## Handler / metadata / testing

- guestbook: Json(CreateEntry)、Path(id)、Query(limit)、Result(Entry,201)、
  NotFound/InvalidId mapping。モデルのvalidationをDTOでも再利用。
- tasks: typed CRUDは導入済み機構を使用し、主題をpublication → consumer effectへ移した。
  QueueRecorderでmetadataを確認し、重複deliveryとqueue拒否後のDB状態も検証。
- chat: room/message DTOにrequired/min/max、bounded wire values、typed response。
  HTTPとNative frame、Workers named messageで同じ保存処理を使用。
- device: middlewareでJWTを一度検証しContext.setPrincipal。typed Principal＋Jsonによる
  POST /recordsと、Client.asによる同じattachment pathを検証。middlewareを無効化しない。
- Context escape hatch: HTML/content negotiation、OpenAPI/client artifact response、SSE、
  socket upgrade、storage streaming、手動SQL／realtime control plane。便利さのために隠さない。
- guestbook/tasks/chatは同じgraphをproduction/testで使う。guestbookはgraph allocation failureも検証。
  deviceのintegrationは同じ登録処理と実SQLite/filesystem/jobs/realtime ownerを使用。
  coreのprovider/portable fixturesはpartial startup failure・adapter cleanupを継続検証。

Endpoint metadataからrouter、capability validation、OpenAPI、HTTP TS clientを生成。
Realtimeは既存events.ProtocolからTS/Cを生成し、HTTP schemaと巨大ASTへ統合していない。

## Owner / lifecycle / migration

| Provider | Native | Workers |
|---|---|---|
| DB | checked openForContract、entrypoint Db | isolate Db、D1 binding DB |
| Storage | Io＋directory owner、StorageFactory借用 | isolate factory、R2 FILES |
| Queue | stable heap jobs.Provider、Effects借用、stop/join後deinit | stable QueueOwner、初期化成功後consumer登録、EVENTS |
| Realtime | stable Native registry＋socket transport gate | explicit RealtimeOwner＋DO AKAMATA_REALTIME、named service |

App/Contextはfacadeをborrowしownerをdestroyしない。try/errdeferでpartial acquisitionを巻き戻す。
Nativeはworkerをstop/joinしてからAppとproviderを逆順cleanupする。
Workersはstable globals、initialized commit、isolate lifetime。requestごとの再初期化／cleanupはしない。
同じpatternでもowner集合と失敗境界が異なるため、新しいuniversal lifecycle helperは導入していない。

Native tutorial（guestbook/tasks/chat）の初期schemaはadmission前の開発便宜。
Workers request/consumerではDDLしない。deviceは明示versioned migrate-upを基本とし、
--dev-initだけがinitial schema作成を選択する。2回migrate-upして履歴1件を検証する。
jobs.Provider自身のengine table初期化はapplication migrationと区別する。

Queueはat-least-once。event/version/correlation/idempotency/attemptを保持する。
DB writeとenqueueはatomicではない。publication失敗時にDB行が残ることをtest/documentする。
必要なapplicationはoutbox/reconciliationを選択する。exactly-onceを主張しない。
Native SSEはbounded snapshot ringで、Workersでは明示501。DO購読と同一とは扱わない。

Native realtimeはMessageArenaをframeごとresetし、callbackとConn破棄の競合をgateで防ぐ。
slow peerは他realtime sendを遅らせ得る。Workers DOはtransportを所有し、named application
handlerはbounded effectsを返す。anonymous chatのnicknameは認証ではない。
deviceはJWT由来identity/roomだが、login shared credentialはidentity serviceの代替ではない。

## 検証と再現

```sh
# Zig 0.17.0 / Node 24 / Python 3
npm install --prefix /tmp/akamata-dx-ts typescript@5.9.3 --ignore-scripts --no-audit --no-fund
AKAMATA_DX_TSC=/tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js python3 tests/living_examples.py
zig build test -Doptimize=ReleaseSafe
zig build documentation-test -Dbackend=workers -Doptimize=ReleaseSafe
```

runnerは4 exampleのNative Debug/ReleaseSafe、guestbook/tasks/chat tests、Workers build、
manifest、OpenAPI、strict HTTP TS、strict Protocol TS、Protocol C object compile、
migration再実行、Native WebSocket wire、実WASM＋現在のmanaged JSPI glueを検証する。
migration追加版57コマンドはローカル通過。
binary SHAと環境・commandは[local.json](local.json)へ保存する。
Workers executable最適化は既存build policyのReleaseSmallで、module設定にReleaseSafeを渡す。

実WASM host checks: guestbook 7、tasks 8、chat 6、device 14。
D1-shaped SQLite、bounded Queue/R2 recorder、DO control-plane hostはoffline simulation。
remote requestは0。live Cloudflare／DO WebSocket hibernation／remote durabilityの証明ではない。
Native wireは2接続のmasked frames、DB保存とbroadcast、接続close後SIGTERM終了を検証。

Linux/macOSのliving-examples jobを追加。既存CIのruntime/CLI/scaffold/update/sync、
Native/Workers documentation、Container、Portable Contract、TSanは継続する。
最新runは[CI](https://github.com/moribit/Akamata/actions/workflows/ci.yml)、
[TSan](https://github.com/moribit/Akamata/actions/workflows/runtime-sanitizer.yml)を参照。
exampleのNative wireはTSan-instrumentedではない。既存runtime Contract/race fixtureがTSan対象。

## 性能回帰確認

[raw data](threaded-current.json): Apple M2/macOS、Zig0.17.0、ReleaseFast、loopback、
oha、32 keep-alive、3秒×3round。200 response throughput中央値:
hello 171,915 / echo 170,400 / db 91,516 req/s。全roundエラー0。
以前の短時間DX evidence（約165k/164k/88k）に対する明確な低下はない。
同時刻のbefore/afterではなく、controlled certificationでもない。ノイズを含むsmoke evidence。
Threaded production default、Reactor parked/fail-closedは変更していない。

## Documentation / compatibility / 残課題

Root EN/JA README、example index、quickstart、typed handler/validation/error/testing/realtime
Guide、tasks tutorial、WebSocket/Workers説明を実コードへ合わせた。
各example READMEはlearn/why/run Native/Workers/test/architecture/nextの同じ構成。
Guideからcanonical sourceへリンクし、README snippetは同じgraph/compiled minimalを参照する。

既存core public APIの削除はない。example APIの変更はある:
chatのHub/ChatRoomとframe formatは新Protocolへ移行、historical DO migrationは自動置換しない。
deviceは明示migrationと必須secret、records validationはtyped422へ変更。
DB URLはContractに一致する必要があり、Tursoは明示provider選択が必要。

exampleで露出したcore修正は独立commit:
Bounded schemaのcomptime選択、custom jsonStringify尊重、内部reflection quota、
204/205/304 Fetch body=null、dotted pathのTS識別子、Protocol TS union構文。
新router/engine/provider abstractionは追加していない。

次のDX候補はboilerplate表へ分離した。優先候補はNative transport lease/retirementの設計、
専用test resourceによるlive provider契約、migration/deployment policyの明示的runner。
benchmark物理移動、Workers lifecycle helper、provider bundleは別判断とし、今回吸収しない。

## Commit一覧

```text
4895587 docs(examples): define the living reference learning path
cff8cda refactor(guestbook): use the typed application graph as the canonical reference
85b0896 refactor(tasks): share typed application graph and portable queue effects
2be84be fix(openapi): select bounded wire schemas at compile time
6673f04 fix(json): preserve custom struct wire representations
13acf6c fix(http): keep typed graph reflection budgets inside the framework
8d4f1b5 refactor(chat): separate portable realtime semantics from transport ownership
80a3c61 fix(workers): construct bodyless Fetch responses safely
ccdf53c refactor(device-messaging): make principal and provider lifetimes explicit
b46d4c1 refactor(examples): keep reflection internals out of application code
3f477a7 fix(client): generate valid identifiers for dotted HTTP paths
2b8965f docs(examples): align guides with the living application references
4b10107 fix(protocol): emit a valid TypeScript event union
d51dbb1 test(examples): validate native and actual Workers living references
de47327 bench: record threaded regression evidence for living examples
a921d02 test(examples): compile generated protocol C translation units
c817872 fix(example): apply only pending device migrations
```
