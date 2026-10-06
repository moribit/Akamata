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

現在はrequest/response schemaと型付きOpenAPI parameterを接続しています。clientのtyped binding・error mapping・Principal bindingも接続しています。static宣言後のroute登録はfreezeされます。動的routeは従来App(State)を使ってください。

[実行可能なcontract](../../../tests/dx_test.zig)と[英語Guide](../../en/guides/typed-handlers.md)も参照してください。

認証middlewareで `c.setPrincipal(identity)` を呼び、handlerの `ak.Principal(UserIdentity)` 引数でborrowできます。`.value` は `*const UserIdentity` です。未認証・型不一致はhandler実行前に401を返します。Contextからは `try c.requirePrincipal(UserIdentity)` も使えます。wrapperはcredentialを検証しないため、既存auth middlewareをそのまま実行してください。OpenAPI securityはendpointの `.security` とInfoのschemeで明示します。role/scope判定はapplication側です。erased principal_dataへの直接代入はtyped retrievalできません。setPrincipalを使ってください。

middlewareはstatic graphのfreeze前に `.middleware = .{.{ .call = authenticate }}` で登録します。高度なstartup設定は `.configure = configure` と `fn configure(app: *ak.App(State)) !void` で既存coreに設定します。初期化後の `.core` は実行時のescape hatchで、登録methodのfreezeは維持します。

The shared [application fixture](../../../tests/dx_application_fixture.zig) runs with `zig build dx-test -Doptimize=ReleaseSafe` and `zig build portable-application-test -Dbackend=workers -Doptimize=ReleaseSafe`. Workers executes the same contract ten times inside WASM with simulated host imports; this is offline application evidence, not live Cloudflare certification.

TypeScript生成も同じmetadataを利用します。Pathのscalar型、Queryのoptional/required、scalar responseのtype alias、text responseのtext decodeを維持します。JavaScript numberは全u64を正確には表現できません。大きなIDの正確性が必要なら文字列IDを明示してください。同じmappingからoperation別error型とruntime判定関数を生成します。[Error handling](errors.md)を参照してください。

Endpointは既存の`description`、`tags`、`deprecated`、`limits` metadataも共有します。limitsの意味は既存APIと同じで、metadataの宣言だけで新しいtimeout機構を追加するものではありません。未知のoptionはcompile errorです。typed success statusは最終2xx/3xxのみ、204/205はbody禁止で、status helperと`success_status`の不一致も検出します。特殊responseには明示Contextを使用してください。

`.configure`は一時的なApp/Stateのaddressを保持したり、それをborrowするtaskを開始してはいけません。初期化はAppを値で返します。provider ownerは別途取得し、application lifetime中は安定したaddressを維持してください。

`Application.Metadata` is a pure endpoint-only view accepted by existing
`openapi.generate` and `client_gen.generate`; it does not initialize State, acquire
providers or run `.configure`. Runtime middleware names are intentionally absent
from this declaration view. For runtime middleware metadata use the initialized
Application directly, whose `routeViews` delegates to the core.

The minimal scaffold implements `akamata-openapi` and `akamata-capabilities`
before App initialization. These tooling modes are included in v0.2.0. Use
`zig build run -- akamata-openapi` or
`zig build run -- akamata-capabilities workers`.
The latter emits a manifest accepted by `akamata inspect capabilities --manifest=PATH`.
For a stateful application replace the empty Hello Contract with its existing
explicit Contract/provider declarations; do not hand-edit generated manifests.

Generated-client CI runs TypeScript 5.9.3 with `--strict --noEmit`, including
expected errors for wrong path IDs/missing bodies and narrowing known HTTP errors.
The optional local command is:

```sh
npm install --prefix /tmp/akamata-dx-ts typescript@5.9.3 --ignore-scripts --no-audit --no-fund
AKAMATA_DX_TSC=/tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js zig build documentation-test -Dbackend=workers -Doptimize=ReleaseSafe
```

This is test tooling, not a framework runtime dependency. Syntax transformation
and mocked-fetch checks remain separate from static type checking.
