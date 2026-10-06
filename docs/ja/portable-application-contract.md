# Portable Application Contract

基準は`e4919f0`です。既存のApp／Contextとservice facadeを接続し、applicationが必要とする機能、targetごとのprovider、binding、handlerからのアクセスを追えるようにしました。Native production defaultはThreadedのままです。ReactorはPark／fail-closedを維持します。

## 作業前の棚卸し

| 領域 | 既存実装 | 今回の接続 |
|---|---|---|
| HTTP | App／Context、runtime route、static route graph、typed input／response／validation／error mapping | 既存Endpoint metadataへportable requirementを追加 |
| Capability | physical Kind、Target、requireKinds、Requires | application requirementと明示providerを区別 |
| Binding | D1／R2／Queue／DO／Secret／Var marker | providerのresource名・kindと照合 |
| DB | Db／Stmt、Native SQLite／Turso、Workers D1／Turso | 既存State.dbとc.dbを維持、D1 named bindingを修正 |
| Storage | Store、FS／R2、range／ETag／conditional request | State.storeからc.storage、既存request trace |
| Queue | Producer／Consumer／Delivery、Native jobs、Workers QueueProducer | 既存facadeのborrow、共通descriptorとdelivery metadata |
| Events／Realtime | Descriptor／Protocol、Service／Room、Native hub、Workers DO control plane | Protocol由来descriptor、State.realtimeからborrow |
| Schema | Endpoint→OpenAPI→HTTP TS、Protocol→TS／C | 同じZig typeとversionを維持 |
| Testing | in-process testing.Client、backend／runtime tests | 共通application fixtureとbounded test provider |
| Observability | request ID／trace／metrics／timing、DB／HTTP／Storage spans | 新frameworkを作らずDB／Storage facadeに既存traceを接続 |
| CLI | check／doctor／inspect／routes／config、managed glue | inspect capabilities、check opt-in、route metadata表示 |

新router、DB abstraction、Storage abstraction、scheduler、universal schema ASTは追加していません。

R2では途中失敗時のwrite handle cleanupを追加し、conditional putの不成立を既存PreconditionFailedへ揃えました。Storeの公開signatureは維持し、private glueはdependencyと一緒にsyncします。

発見した不整合は、requirement／binding／Stateの独立、`d1:NAME`がNAMEを無視して`env.DB`を使う問題、Queueでidempotency key／max attemptsが落ちる問題です。D1「mock」テストの一部はSQLiteテストであり、Workers adapterの証拠には使えません。旧Routerコメントと0.16前提のschemaコメントも整理しました。

## Capabilityの設計

`capability.Application`はapplicationの要求、既存`capability.Kind`はplatformのfacilityを表します。`Contract(name, requirements, provisions)`は明示providerを受け取ります。`defaultProvider`はcompile-timeの候補選択であり、serviceを生成しません。

| Application | Native | Workers | Container |
|---|---|---|---|
| database | SQLite、明示Turso | D1 binding、明示Turso | SQLite、明示Turso |
| object_storage | filesystem | R2 binding | filesystem |
| queue | native_queue、明示Producer owner | workers_queue binding | native_queue、明示Producer owner |
| realtime | native_realtime | durable_objects binding／既存DO control plane | native_realtime |
| outbound_http | native_http | workers_fetch | native_http |
| crypto | native_crypto | workers_crypto | native_crypto |

Physical Kind一覧は、filesystem、threads、sockets、sqlite、d1、durable_objects、outbound_http、outbound_tcp、r2、queues、websocket、persistent_disk、persistent_storage、crypto_random、web_cryptoです。既存のavailability判定をsource of truthとして再利用します。Containerのdisk永続性はvolume設定に依存します。

```zig
const C = am.capability.Contract("uploads", &.{.object_storage}, &.{.{
    .capability = .object_storage,
    .provider = .r2,
    .binding = "FILES",
}});
const Env = struct { files: am.binding.R2("FILES") };
comptime { am.binding.validateContract(Env, C, .workers); }
const State = struct {
    pub const application_contract = C;
    store: am.storage.Store,
};
```

missing／duplicate provider、capabilityとproviderの不一致、unsupported target、binding不足／kind不一致、routeの未宣言requirementはfail-fastします。診断にapplication／route、capability、provider、targetを含めます。resource providerのbindingは必須です。resourceを使わないproviderにbindingを指定することも拒否します。

providerの宣言はopaque facadeの実装や接続先の稼働を証明しません。例えばruntimeのDATABASE_URLをTursoへ切り替えるdeploymentでは、明示providerもTursoに揃える必要があります。旧URL-driven DB APIを壊さず、この責務を隠さない設計です。

## Contextとownership

Opt-in Stateの既存field型をApp.initで検証します。

| Requirement | State field | Request-local view |
|---|---|---|
| database | db: Db | c.db() |
| object_storage | store: Store | c.storage() |
| queue | queue: Producer | c.queue() |
| realtime | realtime: Service | c.realtime() |

outbound HTTP／cryptoは既存のstateless APIを使います。Stateにcontractがないapplicationは従来どおりです。c.state／c.cfgと明示platform moduleはescape hatchとして残します。

ownerはentry point／provider／App.own等で明示します。Contextはborrowのみでdestroyしません。Appをdeinitしてからservice ownerをcloseします。observed facadeはrequest外へ保存しません。Storage Readerは既存どおりcloseが必要です。Storage spanはfacade操作を計測し、後続readerの全lifetimeまでは計測しません。Native並行requestのownerには適切な同期が必要です。

## Endpointとschema

`capability.Uses(Endpoint, applications)`はroute-level requirementを追加します。`Requires(Endpoint, physicalKinds)`はplatform-specific escape hatchです。両decoratorを併用してもschema function、handler、error map、security、operation metadataを維持します。

OpenAPIには`x-akamata-capabilities`と`x-akamata-platform-capabilities`を追加します。既存HTTP TS clientのschema collector／method名は変更しません。runtime App.endpointのsignatureも変更しません。typed registrationではState contractを検証します。runtimeで任意metadataを登録する旧経路からのcapability推論は行いません。

`Protocol.descriptor(.tag)`で同じPayload／event名／versionをQueueとRealtimeに使えます。`dispatchDescriptor`／`consumeEnvelope`は既存Producer／Consumerの補助APIです。event ID／correlation ID／attempt／idempotency key／max attemptsを維持し、不一致version／eventをhandler前に拒否します。retry／deduplication／dead-letterはbackend ownerの責務です。idempotency keyだけでexactly-onceを保証しません。`generateProtocol`は既存TS／C generatorへProtocolのunionとversionを渡します。

## DeploymentとCLI

```bash
akamata inspect capabilities --target=workers --config=deploy/wrangler.toml
akamata check --quick --capabilities --target=workers --config=deploy/wrangler.toml
```

applicationは`akamata-capabilities <target>` tooling protocolでContract.writeManifestのversioned JSONを出力します。service初期化やmigrationより前に処理します。独立JSON schemaを手で管理しません。custom runner／repository exampleには生成manifestを`--manifest=PATH`で渡せます。hookがない旧projectはserverを起動せずエラーにします。

inspectは宣言providerを検証し、既存TOMLのresource sectionとbinding名／kindを照合します。表示は`declared`／`binding_configured`／`missing_binding`です。missing bindingはexit 1で、remote readinessをreadyとは表示しません。config／application sourceを変更しません。checkは`--capabilities`指定時だけこの検証を追加します。既存doctor／config／deployへ重複commandを追加していません。

`routes explain`はOpenAPI経由でportable／physical requirementを表示します。source-only fallbackはimport先のmetadataを推論できません。inspect capabilitiesのmanifestにはmethod／path／operation ID／route requirementsも入ります。

D1 named bindingはZig→JSまで対応し、default DB経路も維持します。Zig dependency upgrade時にはmanaged glueもsyncしてください。新WASMのprivate importsと古いglueを混在させないことが必要です。managed fileの既存保護・backup・user-owned設定の境界は維持します。

## Contract testsとreference application

Native／Workers WASMで同じfixtureをtesting.Clientから実行します。routing、typed input、validation、DB effects、Storage、Queue、Realtime、event schema、201／400／404／503、capability resolution、OpenAPI／HTTP client／Protocol generatorを検証します。

MemoryStoreは16 object×4 KiB、QueueRecorderは64 entry×64 KiBとmetadata上限を持つtest ownerです。production providerやretry engineではありません。test用DB effect recorderもSQL実装ではありません。Native testing allocatorでleakを確認し、Workersは10反復後のWASM page増加を確認します。これだけでhost memory全体のleak-freeを主張しません。

同じStorage contractをFS／MemoryStore／Workers R2 Zig adapterへ適用します。R2／D1／Queue adapterにはtest host bindingを注入します。D1ではnamed/default selectionとStmt cleanup、managed JSでは実sourceを使ったasync binding選択を検証します。既存SQLite／Turso／DO／serialized WASM dispatch／transport testsとは分離し、live Cloudflare E2Eの証拠と混同しません。

malformed typed JSONの400はfixtureが既存onErrorへ明示policyを登録します。frameworkの未処理errorのdefault動作は変えません。R2も実managed JS sourceでabort／conditional errorを検証します。

既存guestbookをreferenceにしました。domain handlerは共通で、contract.zigがSQLite/D1 resolution、D1 marker、route requirementsを持ちます。Native entry pointはApp teardown後にDBをcloseします。tooling commandはDBを開きません。guestbookの既存DB-only domainを保ち、Storage／Queue／Realtimeは共通fixtureで接続を検証します。

```bash
zig build test
zig build test -Doptimize=ReleaseSafe
zig build portable-application-test -Dbackend=workers -Doptimize=ReleaseSafe
zig build compile-fail-test cli-capabilities-test cli-operations-test
zig build scaffold-local-test scaffold-test project-update-test workers-capability-sync-test
```

CIにはWorkers WASM application contract jobを追加しました。Nativeの共通fixtureは既存test job、compile-fail／capability CLIは既存CLI smoke jobで実行します。検証コマンドと範囲は[validation record](../validation/portable-application-contract.md)に記録します。

## Breaking changeと残る差

既存Db／Store／Queue／Service／App／Context APIは維持します。追加fieldはdefault付きです。contractはopt-inです。D1はこれまで無視していたnon-default bindingを正しく使うようになるため、そのbindingが未設定の旧applicationは明確に失敗します。default DBの動作は維持します。

残るplatform差を宣言で隠しません。

- Native jobsはSQLite durable queueを既に持ちますが、portable Producer／Consumerへのcallback wiringは明示ownerの責務です。automatic native_queue factoryは追加していません。
- Workers Realtimeは既存DO／HTTP action control planeです。汎用DO-backed Service factoryの自動生成はありません。明示Service provider／platform escape hatchが必要です。
- R2 list metadataはcaller allocatorのoperation lifetimeで管理します。operation arenaを使います。FS cursorはlexical key、R2 cursorはplatform tokenで、現行list APIにはnext-cursor resultがありません。R2 head metadataはgetより限定的です。
- Workers HTTP download／R2 uploadにはhost側buffering limitがあります。Nativeのstream resource behaviorと同一とは主張しません。
- CLIはrepositoryで使うquoted TOML array sectionを検証します。JSONC／environment override／DO migration class／resource ID／remote provisioningは対象外です。
- DB／Storage／Queue／Realtimeを跨ぐeffectsは単一transactionではありません。Queue ack/redelivery、DO connection ownershipもadapter固有です。

次のDX改善は、既存jobs／DO操作のowner wiring helper、Store list-pageのownership／cursor整理、environmentごとのdeployment validation、live adapter contractの順で進めるのが適切です。別frameworkやCloudflare全機能SDKは作りません。
