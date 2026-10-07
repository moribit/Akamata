# Application error

普通の有限Zig error setをhandlerから返し、routeで `.errors = .{ .NotFound = .not_found }` を指定します。明示fallbackがない場合は全errorをmappingします。`anyerror` には `.fallback = .internal_server_error` が必要です。mapping/fallbackは4xx/5xxだけです。

mappingしたerrorは `{ "error_kind": "NotFound" }` を返します。fallbackは内部error名を公開せずinternal_server_errorを返します。frameworkのallocation/serialization errorは既存Appのerror処理へ渡します。

同じmappingがOpenAPI response schemaのsourceです。同じstatusのerrorは一つのschemaのenumへまとめます。Principal bindingの未認証401も記録します。security schemeは明示し、Principalだけから認証方式を推測しません。

TypeScript clientはstatus/bodyを持つError subclassの `HttpError` をthrowします。operation別union型と `is_getUsersByIdError(error)` などのruntime guardを生成します。未知のnetwork/gateway/framework errorを既知unionへ無理に分類しません。typed inputは400/bad_request、JSON bodyは422/validationを同じmetadataと既知error unionへ追加します。validationのfield error詳細は既存形式を維持します。必須Principalは引数順にかかわらずrequest decodeより先に確認します。認証middlewareは従来どおり先に実行します。

[共通source](../../../tests/dx_application_fixture.zig)と[DX tests](../../../tests/dx_test.zig)で検証します。documentation CIではTypeScript strict静的型検査と、Nodeによる変換・HTTP実行テストを別々に実施します。[英語Guide](../../en/guides/errors.md)にはclient利用例があります。

## Living reference

最新mainの[guestbook](../../../examples/guestbook/README.md)で、これらのAPIを一つのコンパイル可能なapplication graphとして確認できます。[tasks](../../../examples/tasks/README.md)ではQueue effectsとtestingへ進みます。providerのownerはContextではなくentrypointが持ちます。
