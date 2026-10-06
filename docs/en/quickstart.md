# Getting Started

Start with Hello, then add typed JSON, validation, a database, tests and deployment.

## 1. Installation

```sh
git clone https://github.com/moribit/Akamata.git
cd Akamata
./scripts/install.sh
```

Use Zig 0.17.x and put `$HOME/.local/bin` on PATH. Node.js/Wrangler are needed only for Workers; Docker only for Containers.

## 2. Hello World

```sh
akamata init myapp
cd myapp
akamata dev
# another terminal
curl http://127.0.0.1:8080/
```

The default project returns `Hello, myapp!` without opening a database or initializing providers. It contains build files, `src/main.zig`, README and `.gitignore`. `PORT` changes the Native port.

Current CLI projects pin v0.2.0, which includes these typed APIs. If your CLI generated an older dependency, update it first:

```sh
akamata update --to=v0.2.0
```

For framework development only, `zig build --fork=/absolute/path/to/Akamata run` selects a local checkout. Update/sync do not rewrite existing application source.

## 3. Routing

```zig
fn hello() []const u8 { return "Hello, Akamata!"; }
pub const Application = ak.App(.{
    .routes = .{ ak.get("/", hello) },
});
```

Initialize this type with an explicit allocator, defer `deinit`, then call `serve`. The complete [minimal source](../../tests/docs/minimal.zig) is compiled in CI. Dynamic registration remains available through the original `ak.App(State)`.

## 4. JSON API

Use ordinary structs with explicit parameter sources: `ak.Json(CreateUser)`, `ak.Path(u64, "id")`, `ak.Query(?u32, "page")`. Read `.value`. Return a struct for JSON, a string for text, or `ak.created(value)` for 201.

[Typed handlers](guides/typed-handlers.md) · [Native/Workers fixture](../../tests/dx_application_fixture.zig)

## 5. Validation / Errors

DTO `validation` metadata reuses existing model rules. Validation preserves the machine-readable 422 response. Finite handler error sets require HTTP mappings; `anyerror` requires a fallback. Endpoint metadata feeds OpenAPI and client generation.

[Validation](guides/validation.md) · [Error handling](guides/errors.md)

## 6. Database

Add an explicitly owned `am.db.Db` to State when needed. Open it with `am.db.open(allocator, url)` and borrow through Context. SQLite/Turso and D1/Turso share the facade; deployment configuration differs.

[Database backends](db-backends.md) · [Provider lifecycle](provider-lifecycle.md)

```sh
akamata init notesapp --template=notes --target=both
cd notesapp
zig build run
```

This opt-in tutorial retains `/notes` CRUD, validated input, SQLite model migration and an empty versioned migration directory. Configure `DATABASE_URL` as needed. `akamata migrate generate NAME` and `akamata migrate up` record applied versions. D1 bridge operations are not transactional; review migrations and environment explicitly.

## 7. Testing

Use `app.client(allocator)`, `client.post("/users").json(value).send()`, `response.expectStatus(.created)` and `response.json(User)`. No port or socket is needed. Principal injection and provider effect assertions are documented in the guide.

[Testing](guides/testing.md)

## 8. Native deployment

```sh
zig build -Doptimize=ReleaseSafe
./zig-out/bin/myapp
```

Threaded remains the production default; Reactor remains parked and fail-closed. Generate with `--target=containers` or `both` for Container deployment files.

[Deployment](portable-backend.md)

## 9. Workers deployment

```sh
# create with --target=workers or --target=both
zig build -Dbackend=workers -Doptimize=ReleaseSafe
cd deploy
npx wrangler dev --local
```

The Workers entry imports the same application. Hello needs no D1/R2 resource. Configure account/resources and authenticate before `akamata deploy --workers` from the project root. Stateful applications must declare and configure bindings. Validation neither creates resources nor proves live readiness.

[Workers](cloudflare.md) · [Portable Production Contract](portable-production-contract.md)

## Next steps

[Documentation home](README.md) · [Tutorial](tutorial.md) · [Handbook](handbook.md)
