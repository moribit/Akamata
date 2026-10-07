# Guestbook: canonical typed HTTP

## What you will learn

Ordinary Zig function → typed request/response → validation → database →
OpenAPI/client → in-process application tests.

## Why this example exists

This is the first stateful HTTP reference after the minimal scaffold. Tasks
teaches background effects; chat teaches realtime; device_messaging teaches
production owners. Guestbook deliberately has one database capability.

## Run Native

From the repository root, with Zig 0.17.0:

```sh
zig build -Dexample=guestbook
PORT=8080 ./zig-out/bin/guestbook
curl -sS http://127.0.0.1:8080/entries?limit=10
```

Native initializes the development schema before accepting traffic. Failure
stops startup. **Development convenience is not a production migration policy.**
The browser UI is embedded; visit `/` with `Accept: text/html`.

## Run / Build Workers

```sh
zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe
zig build -Dexample=guestbook
./zig-out/bin/guestbook --print-schema > /tmp/guestbook.sql
```

Apply reviewed schema to your configured D1 resource **before deployment**.
`deploy/guestbook/wrangler.toml` and its managed glue select D1 binding `DB`.
No request or isolate initialization performs DDL. Workers compilation is offline
coverage, not proof of remote resource readiness. Follow the
[Workers deployment guide](../../docs/en/guides/workers-deployment.md).

## Test

```sh
zig build guestbook-test -Doptimize=ReleaseSafe
```

The test uses the production `setup.Application` with an explicitly owned
in-memory database, `app.client(allocator)`, JSON requests and typed response
assertions. It verifies validation, path/query binding, mapped errors, persisted
rows, generated OpenAPI/client and graph allocation-failure cleanup. No listener
or application worker is started.

## Architecture

```text
contract.routes → Application → ordinary typed handlers → borrowed Db
       ├─ router / capability validation
       ├─ OpenAPI / TypeScript client
       └─ production and test graph
Native entry owns SQLite     Workers isolate owns D1
```

`handlers.CreateEntry` reuses model validation, but excludes server-owned id/time
fields. `createEntry(Context, Json(CreateEntry))` returns `Result(Entry, 201)`.
`showEntry(Context, Path(i64, "id"))` maps NotFound to 404. The list binds an
optional typed limit and limits SQL results to 100. Context is retained for
HTML/content negotiation and artifact delivery, not for manual JSON binding.
Unexpected DB errors map to an explicit 500 fallback without leaking error names.

The **only** route declarations are in `contract.zig`; `DatabaseEndpoint` is gone.
Generate artifacts without opening a DB:

```sh
./zig-out/bin/guestbook akamata-openapi > /tmp/guestbook-openapi.json
./zig-out/bin/guestbook akamata-client > /tmp/guestbook-client.ts
./zig-out/bin/guestbook akamata-capabilities workers > /tmp/guestbook-contract.json
zig build cli
./zig-out/bin/akamata inspect capabilities --target=workers \
  --manifest=/tmp/guestbook-contract.json --config=deploy/guestbook/wrangler.toml
```

`DATABASE_URL` must agree with the declared provider. To use Turso, explicitly
select `.turso` with no D1 binding in the Contract and supply its URL. Changing
an opaque URL alone does not bypass deployment validation. The handlers and
Db facade stay shared. Entry points own the DB; App/Context borrow it and are
finished before the DB closes. Failed initialization closes acquired resources.

For versioned Native migrations use `guestbook migrate-up --dir=PATH`. Review
schema changes and backups rather than treating model diff as a production
migration engine.

## Next

[Tasks effects/testing](../tasks/README.md) ·
[Typed handlers](../../docs/en/guides/typed-handlers.md) ·
[Validation](../../docs/en/guides/validation.md) ·
[Learning path](../README.md)
