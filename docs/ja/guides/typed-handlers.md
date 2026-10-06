# Typed handler

普通のZig関数を、既存App/Contextとstatic route graphへcompile-timeで適応する追加APIです。既存の `ak.App(State)` は維持します。

```zig
fn hello() []const u8 { return "Hello, Akamata!"; }
const Application = ak.App(.{ .routes = .{ ak.get("/", hello) } });
var app = try Application.init(allocator);
defer app.deinit();
try app.serve(.{});
```

`Application` は型です。実行時のappとallocatorは呼び出し元が所有します。providerを手動で渡す場合は `.State = State` と `initWithState(allocator, state)` を使います。

引数には `ak.Path(u64, "id")`、`ak.Query(?u32, "page")`、`ak.Header([]const u8, "x-key")`、`ak.Cookie(?[]const u8, "session")`、`ak.Json(CreateUser)` を使い、値は `.value` から取得します。structの用途を推測しません。ContextとJSON bodyは各一つまでです。各dynamic pathにはPath引数が必要です。

文字列はtext、その他のJSON値はJSON responseになります。`ak.created(value)`、`ak.accepted(value)`、`ak.noContent()` の戻り値型は `ak.Result(T, status)` です。void handlerから既存Context responseを操作できます。binding errorは400、JSON validationは既存400/422形式を維持します。

有限error setは `.errors = .{ .NotFound = .not_found }` を指定した `ak.endpoint` で網羅的にmappingします。`anyerror` には明示 `.fallback` が必要です。fallbackは内部error名を公開しません。

現在はrequest/response schemaと型付きOpenAPI parameterを接続しています。clientのquery/error生成、認証統合は後続作業です。static宣言後のroute登録はfreezeされます。動的routeは従来App(State)を使ってください。

[実行可能なcontract](../../../tests/dx_test.zig)と[英語Guide](../../en/guides/typed-handlers.md)も参照してください。

認証middlewareで `c.setPrincipal(identity)` を呼び、handlerの `ak.Principal(UserIdentity)` 引数でborrowできます。`.value` は `*const UserIdentity` です。未認証・型不一致はhandler実行前に401を返します。Contextからは `try c.requirePrincipal(UserIdentity)` も使えます。wrapperはcredentialを検証しないため、既存auth middlewareをそのまま実行してください。OpenAPI securityはendpointの `.security` とInfoのschemeで明示します。role/scope判定はapplication側です。erased principal_dataへの直接代入はtyped retrievalできません。setPrincipalを使ってください。

middlewareはstatic graphのfreeze前に `.middleware = .{.{ .call = authenticate }}` で登録します。高度なstartup設定は `.configure = configure` と `fn configure(app: *ak.App(State)) !void` で既存coreに設定します。初期化後の `.core` は実行時のescape hatchで、登録methodのfreezeは維持します。

The shared [application fixture](../../../tests/dx_application_fixture.zig) runs with `zig build dx-test -Doptimize=ReleaseSafe` and `zig build portable-application-test -Dbackend=workers -Doptimize=ReleaseSafe`. Workers executes the same contract ten times inside WASM with simulated host imports; this is offline application evidence, not live Cloudflare certification.

TypeScript生成も同じmetadataを利用します。Pathのscalar型、Queryのoptional/required、scalar responseのtype alias、text responseのtext decodeを維持します。JavaScript numberは全u64を正確には表現できません。大きなIDの正確性が必要なら文字列IDを明示してください。既知application error bodyの型生成は後続作業です。
