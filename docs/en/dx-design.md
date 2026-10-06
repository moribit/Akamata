# Developer API inventory and design

Baseline: main 6744595. Runtime/Shared HTTP remain unchanged; Native production uses Threaded and Reactor remains parked.

Existing App(State)/Context(State) already own routing/middleware/response dispatch and request-local services. contract.Endpoint, BoundForPath and TypedEndpoint provide compile-time graph checks, source wrappers, finite error-map validation and OpenAPI metadata, but ordinary functions require a Context plus an aggregate wrapper struct and manual response handling. Context.input/validatedJson already combine permissive DTO parsing with model validation and a stable 400/422 response format. Principal attachment exists but has no type check on borrowed retrieval. testing.Client provides request builders and owned responses; MemoryStore/QueueRecorder are bounded explicit test owners.

OpenAPI and the HTTP TypeScript client already share the schema collector. Event Protocol and TS/C protocol generation remain separate. Capability Contract/Provision, checked DB/Storage/jobs/Queue/Realtime owners and binding validation are retained. CLI source/metadata runners, managed glue and minimal scaffold are extended rather than rewritten.

The additive developer layer uses ordinary functions and the existing contract.Path(T,name), Query(T,name), Header(T,name), Cookie(T,name), Json(T) markers as individual parameters. Explicit markers avoid guessing whether a struct is query or JSON. A Context(State) parameter is optional. No runtime reflection, locator or new provider interface is introduced.

App(State) retains its existing type and initialization. App(.{ .routes = .{ get(path,function), ... } }) returns a thin allocator-owned application wrapper around the existing App; init is fallible because route registration allocates. Explicit State uses initWithState; .core exposes existing middleware, streams, custom responses, providers and lifecycle. Application values are initialized at runtime, never hidden in a global constant.

Finite handler errors require exhaustive HTTP mappings. anyerror requires an explicit fallback. Binding/decode failures are request errors, separate from application error sets. Ordinary strings become text; JSON values become existing Context.json responses; void preserves manual Context responses. Small status wrappers carry fixed success status metadata. DTO validation uses the existing engine and error format; custom validation remains ordinary Zig code.

Endpoint metadata remains the shared boundary for graph validation, capability decorations, OpenAPI, clients and tooling. Incremental work updates guides and executable fixtures together. Config/artifact hardening is isolated from HTTP semantics and fails closed whenever proof is unavailable.
