# Typed handlers

Ordinary functions are adapted at compile time to the existing App/Context ABI:

```zig
fn hello() []const u8 { return "Hello, Akamata!"; }
const Application = ak.App(.{ .routes = .{ ak.get("/", hello) } });
var app = try Application.init(allocator);
defer app.deinit();
try app.serve(.{});
```

`Application` is a type, not a global running server. The caller owns the allocator and runtime value. For explicit providers use `.State = State` and `initWithState(allocator, state)`; existing `ak.App(State)` is unchanged.

Parameters use the existing markers: `ak.Path(u64,"id")`, `ak.Query(?u32,"page")`, `ak.Header([]const u8,"x-request-key")`, `ak.Cookie(?[]const u8,"session")`, `ak.Json(CreateUser)`. Parsed values are in `.value`. Names are explicit; structs are never guessed as query/body. One JSON body and one optional `*ak.Context(State)` parameter are allowed. Every dynamic path segment must have exactly one Path binding. Binding failure responds 400; JSON validation preserves Context.validatedJson's 400/422 formats.

Return a string for text or an ordinary JSON value for JSON. `ak.created(value)`, `accepted(value)` and `noContent()` carry fixed success metadata; declare their concrete return type with `ak.Result(T, 201)`, etc. A void handler can use Context manually; `.core` exposes existing middleware/streaming/upgrade/lifecycle APIs.

Finite application error sets require mappings:

```zig
ak.endpoint(.{ .method = .GET, .path = "/users/:id", .handler = show,
    .errors = .{ .NotFound = .not_found }, .operation_id = "getUser" })
```

An `anyerror` handler requires an explicit `.fallback = .internal_server_error`; fallback responses do not reveal internal error names. Allocation/serialization failures remain framework errors, not application error-set mappings. All declarations adapt to the existing static route graph; no new router, transport or service locator is added.

The executable contract is [tests/dx_test.zig](../../../tests/dx_test.zig). Existing contract.TypedEndpoint/Bound/manual Context handlers remain supported. Migration is optional: move each aggregate wrapper field to an explicit function parameter and return its value instead of calling c.json. Advanced stateful handlers can stay on the original API.

Current first-stage metadata includes body/response schemas and typed path/query/header/cookie OpenAPI parameters. Typed client bindings and mapped errors share this metadata; Principal binding uses existing middleware. Static declarations freeze route registration: use the original App(State) for dynamically registered routes.

Authentication middleware attaches an identity with `c.setPrincipal(identity)`. A handler can borrow it with `ak.Principal(UserIdentity)` (`.value` is `*const UserIdentity`) or `try c.requirePrincipal(UserIdentity)`. Missing or incorrectly typed identities produce 401 before invoking the typed handler. No credentials are inferred or checked by the wrapper: your existing auth middleware still runs. Specify endpoint `.security = &.{"bearerAuth"}` and the matching OpenAPI Info security scheme explicitly; scopes/roles remain application authorization code. Direct writes to erased `principal_data` are no longer accepted by typed retrieval; use setPrincipal.

Register middleware before the static graph freezes registration: declare `.middleware = .{.{ .call = authenticate }}`. Advanced startup configuration can use `.configure = configure`, where `fn configure(app: *ak.App(State)) !void` configures the existing core before mounting. `.core` is the runtime escape hatch, but registration methods remain frozen after initialization.

The shared [application fixture](../../../tests/dx_application_fixture.zig) runs with `zig build dx-test -Doptimize=ReleaseSafe` and `zig build portable-application-test -Dbackend=workers -Doptimize=ReleaseSafe`. Workers executes the same contract ten times inside WASM with simulated host imports; this is offline application evidence, not live Cloudflare certification.

TypeScript generation uses the same endpoint metadata: path scalars retain their type, query keys preserve optional/required binding, ordinary scalar responses become type aliases, and text responses use `Response.text()`. JavaScript numbers cannot exactly represent every Zig u64; use explicit string IDs if exact large identifiers are required. Known error status/body unions and runtime guards are generated from the same mappings; see [Error handling](errors.md).

Endpoint options preserve existing `description`, `tags`, `deprecated` and `limits` metadata. Limits retain their existing meaning; metadata alone is not a new timeout enforcement mechanism. Unknown options fail compilation. Typed success statuses must be final 2xx/3xx responses; 204/205 cannot carry a value, and a status helper cannot disagree with `success_status`. Use explicit Context for specialized responses.

The `.configure` callback must not retain the temporary App/State address or start tasks borrowing it: initialization returns App by value. Acquire provider owners separately and keep their addresses stable for the application lifetime.

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

## Living reference

The current main [guestbook](../../../examples/guestbook/README.md) demonstrates these APIs in one compiled application graph. Continue to [tasks](../../../examples/tasks/README.md) for queue effects and testing. Platform ownership belongs in entrypoints, not Context.
