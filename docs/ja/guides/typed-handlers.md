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

[実行可能なcontract](../../../../tests/dx_test.zig)と[英語Guide](../../../en/guides/typed-handlers.md)も参照してください。
