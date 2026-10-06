# Request validation

JSONの形は普通のstruct、optional型、Zigのdefaultで定義します。同じDTOの `pub const validation = .{ .name = .{ak.model.rule.min_len(1)} };` で既存rule engineを利用できます。旧 `__schema.validates` も維持しますが、typed DTOでは両方を同時に宣言しないでください。

未知field、不正rule tuple、負のlength、逆転rangeはcompile-timeで失敗します。必須field欠落・rule違反は既存422の `{error_kind, errors}`、壊れたJSONは400です。独立schemaは不要です。

複雑なcheckは普通のZig関数と既存 `model.rule.custom` / `customInt` を使います。関数はrequest allocatorと値を受け取り、任意error messageを返します。messageを確保する場合は渡されたallocatorを利用してください。business errorはhandlerのerror mappingで扱います。

length ruleはUnicode文字数ではなくbyte数です。OpenAPI minLength/maxLengthと同じ意味だとはみなしません。format ruleも完全な標準validatorではありません。constraint annotationとDTO単位validation hookは後続作業であり、現時点のJSON schemaはfield型・optional・defaultを表します。

[共通fixture](../../../tests/dx_application_fixture.zig)でNative/Workers WASM双方を検証します。[英語Guide](../../en/guides/validation.md)も参照してください。旧model projectionの挙動は維持し、strict metadata診断は新typed handlerに適用します。
