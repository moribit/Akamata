# Test applications without sockets

Initialize the same application with your test allocator and provider state. `app.client(allocator)` borrows the existing core; it does not start a listener or a thread:

```zig
var app = try Application.init(std.testing.allocator);
defer app.deinit();
var client = app.client(std.testing.allocator);
var response = try client.post("/users").json(.{ .name = "Alice" }).send();
defer response.deinit();
try response.expectStatus(.created);
const user = try response.json(User);
```

The response owns its arena, headers and staged request allocations. Parsed JSON borrows that response. `send()` consumes the request builder; do not reuse or copy it after sending. Referenced header/raw-body data must remain alive until send completes. Failed send cleans up staged allocations too.

Inject a test identity with `client.get("/profile").as(UserIdentity{ ... }).send()`. The value is shallow-copied and attached through Context.setPrincipal in the request arena. Middleware still runs and can reject or replace it. This does not mock credential validation: use `.bearer(token)` when testing that authentication backend. `.as` is an in-process test operation, not a production auth shortcut.

The existing bounded owners provide effect assertions:

- `MemoryStore.expectExists(key)` checks the object owned by the fake filesystem/R2-compatible Store.
- `QueueRecorder.expectPublished(Descriptor)` checks event name/version and decodes its payload with the existing descriptor. It does not claim delivery, retry scheduling or durability.

Provider owners still belong to the test/application state. Context borrows their production facades. MemoryStore is bounded to 16 objects; QueueRecorder defaults to 64 events. Use the existing adapter/integration suites for backend lifecycle and delivery behavior.

[DX tests](../../../tests/dx_test.zig) include denied injected principals and allocation-failure cleanup. The [shared fixture](../../../tests/dx_application_fixture.zig) runs typed requests and principal injection on both Native and Workers WASM; [provider fixture](../../../tests/portable_application_fixture.zig) checks queue effects.
