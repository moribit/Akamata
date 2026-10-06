# Getting Started

Helloからtyped JSON、validation、DB、test、deployへ段階的に進みます。

## 1. Installation

```sh
git clone https://github.com/moribit/Akamata.git
cd Akamata
./scripts/install.sh
```

Zig 0.17.xを使用し、`$HOME/.local/bin`へPATHを通します。Node.js/WranglerはWorkers、DockerはContainerを使う場合のみ必要です。

## 2. Hello World

```sh
akamata init myapp
cd myapp
zig build run
# another terminal
curl http://127.0.0.1:8080/
```

default projectはDB/providerを初期化せず`Hello, myapp!`を返します。build file、`src/main.zig`、README、`.gitignore`のみです。Native portは`PORT`で変更します。

依存はv0.1.5へ固定されます。このguideの新typed APIには最新mainが必要です。local checkoutでoverrideします。

```sh
zig build --fork=/absolute/path/to/Akamata run
```

生成bootstrapは利用可能ならordinary-function APIを選び、v0.1.5でも同じHello responseを返します。update/syncは既存application sourceを書き換えません。

## 3. Routing

```zig
fn hello() []const u8 { return "Hello, Akamata!"; }
pub const Application = ak.App(.{
    .routes = .{ ak.get("/", hello) },
});
```

明示allocatorで型を初期化し、`defer deinit`、`serve`を呼びます。完全な[minimal source](../../tests/docs/minimal.zig)をCIでcompileします。動的登録には従来の`ak.App(State)`を使用できます。

## 4. JSON API

普通のstructと明示sourceの`ak.Json(CreateUser)`、`ak.Path(u64, "id")`、`ak.Query(?u32, "page")`を使用し、`.value`を読みます。structはJSON、stringはtext、`ak.created(value)`は201になります。

[Typed handlers](guides/typed-handlers.md) · [Native/Workers fixture](../../tests/dx_application_fixture.zig)

## 5. Validation / Errors

DTOの`validation` metadataは既存model ruleを再利用し、machine-readable 422形式を維持します。有限error setはHTTP mapping、`anyerror`にはfallbackが必要です。同じendpoint metadataをOpenAPIとclient生成で使用します。

[Validation](guides/validation.md) · [Error handling](guides/errors.md)

## 6. Database

必要なら明示ownerの`am.db.Db`をStateへ追加し、`am.db.open(allocator, url)`でopen、Contextからborrowします。SQLite/TursoとD1/Tursoは共通facadeで、deploy設定は異なります。

[Database backends](db-backends.md) · [Provider lifecycle (English)](../en/provider-lifecycle.md)

```sh
akamata init notesapp --template=notes --target=both
cd notesapp
zig build run
```

明示templateは`/notes` CRUD、validated input、SQLite model migration、空のversion付きmigration directoryを維持します。必要なら`DATABASE_URL`を設定します。`akamata migrate generate NAME`と`akamata migrate up`で履歴を管理します。D1 bridgeは非transactionalなのでmigrationとenvironmentを明示確認してください。

## 7. Testing

`app.client(allocator)`、`client.post("/users").json(value).send()`、`response.expectStatus(.created)`、`response.json(User)`を利用でき、port/socketは不要です。Principal injectionとprovider effect assertionもguideで説明しています。

[Testing](guides/testing.md)

## 8. Native deployment

```sh
zig build -Doptimize=ReleaseSafe
./zig-out/bin/myapp
```

production defaultはThreadedです。ReactorはPark/fail-closedを維持します。Container deploy fileは`--target=containers`または`both`で生成します。

[Deployment](portable-backend.md)

## 9. Workers deployment

```sh
# create with --target=workers or --target=both
zig build -Dbackend=workers -Doptimize=ReleaseSafe
cd deploy
npx wrangler dev --local
```

Workers entryは同じapplicationをimportします。HelloはD1/R2不要です。account/resource設定と認証後、project rootから`akamata deploy --workers`を実行します。stateful applicationはbindingの宣言と設定が必要です。validationはresource作成やlive readinessの証明ではありません。

[Workers](cloudflare.md) · [Portable Production Contract](portable-production-contract.md)

## Next steps

[Documentation home](README.md) · [Tutorial](tutorial.md) · [Handbook](handbook.md)
