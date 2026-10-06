# Application errors

Return an ordinary finite Zig error set from a typed handler. Declare the HTTP meaning alongside the route:

```zig
ak.endpoint(.{
    .method = .GET,
    .path = "/users/:id",
    .handler = show,
    .errors = .{ .NotFound = .not_found },
})
```

Every declared error needs a mapping unless you explicitly choose a fallback. `anyerror` requires `.fallback = .internal_server_error`. Mappings and fallback must use a 4xx/5xx status. A mapped error returns `{ "error_kind": "NotFound" }`; fallback returns `internal_server_error` without exposing internal error names. Framework allocation/serialization failures still follow the existing App error handling.

The mapping is also the OpenAPI error response source. Errors sharing a status are grouped under one schema with an `error_kind` enum. Principal binding contributes its 401 unauthorized response. Security scheme declarations remain explicit; the presence of a principal is not proof of a particular authentication mechanism.

Generated TypeScript keeps ordinary async methods and throws `HttpError`, an Error subclass with `status` and `body`. Known errors have operation-specific status/body union types and runtime guards:

```ts
try {
  await api.getUsersById(42);
} catch (error) {
  if (is_getUsersByIdError(error)) {
    console.log(error.status, error.body.error_kind);
  } else {
    throw error;
  }
}
```

Unknown gateway/network/framework failures are not forced into that known-error union. Decode and validation errors preserve existing 400/422 envelopes and are separate from application error mappings. See [the shared source](../../../tests/dx_application_fixture.zig) and [DX tests](../../../tests/dx_test.zig). The Workers runner can transform and execute the generated client on supported Node versions; that smoke test is not a TypeScript static type check.
