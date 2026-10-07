# Request validation

Use ordinary struct fields for the JSON shape, including optional fields and Zig defaults. Declare rules on the same DTO:

```zig
const CreateUser = struct {
    name: []const u8,
    pub const validation = .{ .name = .{ak.model.rule.min_len(1), ak.model.rule.max_len(100)} };
};
fn create(body: ak.Json(CreateUser)) ak.Result(User, 201) {
    return ak.created(User{ .id = 42, .name = body.value.name });
}
```

The new spelling uses the existing model validator; `__schema.validates` remains supported. Declare one spelling per typed DTO. Unknown field names, non-tuple rules, negative length limits and reversed ranges fail at compile time. Missing required fields and failed rules preserve the existing 422 `{error_kind, errors}` response; malformed JSON is 400. No separate schema is required.

For custom checks, use the existing `model.rule.custom` or `customInt` with an ordinary Zig function. These functions receive the request allocator and return an optional error message; allocated messages must use that allocator. Business errors belong to the handler's explicitly mapped error set.

Length rules count bytes, not Unicode code points. Do not interpret them as OpenAPI `minLength`/`maxLength`. Existing format checks are simple framework checks rather than complete standards validators. Integer min/max/range rules whose entire field domain fits i64 now emit matching OpenAPI minimum/maximum constraints. Optional fields remain nullable. Float truncation, wider integers, byte-length and heuristic format rules are not projected as stronger JSON Schema guarantees. A DTO-level validation hook remains subsequent work; custom rules already accept ordinary Zig functions.

The [shared fixture](../../../tests/dx_application_fixture.zig) executes DTO validation on Native and Workers WASM. Old model projection behavior is retained; strict unknown-field metadata diagnostics apply to the new typed handler adapter.

## Living reference

The current main [guestbook](../../../examples/guestbook/README.md) demonstrates these APIs in one compiled application graph. Continue to [tasks](../../../examples/tasks/README.md) for queue effects and testing. Platform ownership belongs in entrypoints, not Context.
