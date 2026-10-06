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

Current first-stage metadata includes body/response schemas and typed path/query/header/cookie OpenAPI parameters. Client query/error generation and auth integration are subsequent work; do not treat their coverage as complete. Static declarations freeze route registration: use the original App(State) for dynamically registered routes.

Authentication middleware attaches an identity with `c.setPrincipal(identity)`. A handler can borrow it with `ak.Principal(UserIdentity)` (`.value` is `*const UserIdentity`) or `try c.requirePrincipal(UserIdentity)`. Missing or incorrectly typed identities produce 401 before invoking the typed handler. No credentials are inferred or checked by the wrapper: your existing auth middleware still runs. Specify endpoint `.security = &.{"bearerAuth"}` and the matching OpenAPI Info security scheme explicitly; scopes/roles remain application authorization code. Direct writes to erased `principal_data` are no longer accepted by typed retrieval; use setPrincipal.

Register middleware before the static graph freezes registration: declare `.middleware = .{.{ .call = authenticate }}`. Advanced startup configuration can use `.configure = configure`, where `fn configure(app: *ak.App(State)) !void` configures the existing core before mounting. `.core` is the runtime escape hatch, but registration methods remain frozen after initialization.

The shared [application fixture](../../../tests/dx_application_fixture.zig) runs with `zig build dx-test -Doptimize=ReleaseSafe` and `zig build portable-application-test -Dbackend=workers -Doptimize=ReleaseSafe`. Workers executes the same contract ten times inside WASM with simulated host imports; this is offline application evidence, not live Cloudflare certification.

TypeScript generation uses the same endpoint metadata: path scalars retain their type, query keys preserve optional/required binding, ordinary scalar responses become type aliases, and text responses use `Response.text()`. JavaScript numbers cannot exactly represent every Zig u64; use explicit string IDs if exact large identifiers are required. Known application-error body typing is still pending.
