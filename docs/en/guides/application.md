# Application and ownership

Start with `ak.App(.{ .routes = ... })`: this is a type with explicit runtime initialization and allocator ownership. `ak.App(State)` remains the explicit core for dynamic registration. The new layer mounts the existing static route graph and freezes registration; it does not create another router.

Context borrows State and provider facades for one request. Its arena owns decoded input and serialized response data until request completion. A returned DTO may refer to those request-local values; it must not refer to a expired stack buffer. Parsed testing responses borrow their owned Response; destroy parsed values before Response.deinit.

Provider owners are created explicitly outside Context. Keep owners at stable addresses, initialize in order with errdefer cleanup, stop/drain background work before destroying its dependencies, and destroy App before its borrowed providers. App.deinit does not close arbitrary State resources. The `.configure` callback runs before mounting on a temporary App; it must not retain that address or start tasks borrowing it.

Endpoint metadata drives the existing route graph, capability validation, OpenAPI and HTTP clients. Capability is a requirement, Provision selects a provider, and Binding identifies a platform resource. Validation is not provisioning and offline evidence is not live readiness. Beginners need none of these for Hello; stateful applications should read [Portable Application Contract](../portable-application-contract.md) and [Provider lifecycle](../provider-lifecycle.md).

Platform extensions remain explicit. Threaded is Native production default; Reactor remains parked/fail-closed. No new scheduler, DI container or service locator is involved.
