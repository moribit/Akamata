# examples/guestbook

A minimal REST API (`/entries` CRUD) that demonstrates Akamata's **URL-driven
DB backend switch**. The exact same handler code runs against:

- **SQLite** (`file:./guestbook.db`) — native, VPS, Cloudflare Containers
- **Turso / libsql** (`libsql://<db>.turso.io?authToken=…`) — native or Workers
- **Cloudflare D1** (`d1:DB`) — Workers only

Switching backends is a one-line change to the `DATABASE_URL` env var. No code
changes, no recompile-with-different-flags.

## Portable application contract

`src/contract.zig` is the shared route/provider metadata source. The database
requirement resolves to SQLite on Native/Containers and D1 (`DB`) on Workers.
`State.application_contract` validates the target and borrowed `Db` facade;
the entry point owns the database and closes it after App teardown. `/health`
requires a database because it runs `SELECT 1`; `/` requires none.

From the repository root, inspect the declaration without starting services:

```bash
zig build -Dexample=guestbook
./zig-out/bin/guestbook akamata-capabilities workers > /tmp/guestbook-contract.json
./zig-out/bin/akamata inspect capabilities --target=workers \
  --manifest=/tmp/guestbook-contract.json --config=deploy/guestbook/wrangler.toml
```

The manifest is generated, never independently edited. Inspection validates
binding names/kinds, not remote database readiness. `DATABASE_URL` remains a
runtime override: using Turso must also change the explicit provider in
`contract.zig` to `.turso` with no binding if inspecting that deployment.
The facade type cannot prove which URL an opaque runtime provider opened.
The domain handlers stay unchanged. Storage/queue/realtime effects are covered
by the shared application contract fixture; this guestbook intentionally keeps
its existing database-only domain.

See [Portable Application Contract](../../docs/en/portable-application-contract.md)
for declaration, ownership, adapter tests and known platform differences.

## Endpoints

| Method | Path | Notes |
|---|---|---|
| GET | `/` | **Browser** (`Accept: text/html`) → HTML UI<br>**curl/fetch** (`Accept: application/json` or `*/*`) → endpoint map + active backend |
| GET | `/health` | `SELECT 1` round-trip — also returns `backend: "native" \| "workers"` |
| GET | `/entries` | last 100 entries, newest first |
| POST | `/entries` | body: `{ "name": "...", "message": "..." }` |
| GET | `/entries/:id` | one entry |
| DELETE | `/entries/:id` | delete one entry |

The HTML UI is `examples/guestbook/src/index.html` embedded with `@embedFile`
so it ships inside the binary / wasm — no static-asset hosting needed.
After `wrangler deploy`, open the worker URL in a browser:
`https://guestbook.<your-subdomain>.workers.dev/` shows a form + entry list,
hitting the same `/entries` JSON endpoints via `fetch()`.

## Run locally with SQLite

```bash
zig build -Dexample=guestbook -Doptimize=ReleaseFast
DATABASE_URL=file:./guestbook.db PORT=8080 ./zig-out/bin/guestbook
```

Schema is bootstrapped automatically for `file:` URLs.

```bash
curl -s -X POST -H 'content-type: application/json' \
  -d '{"name":"musashi","message":"hi"}' \
  http://127.0.0.1:8080/entries
curl -s http://127.0.0.1:8080/entries
```

## Run locally with Turso

```bash
turso db create akamata-guestbook
./zig-out/bin/guestbook --print-schema > /tmp/guestbook.sql
turso db shell akamata-guestbook < /tmp/guestbook.sql
turso db tokens create akamata-guestbook   # bearer JWT

DATABASE_URL='libsql://akamata-guestbook-<org>.turso.io?authToken=eyJab.c' \
PORT=8080 ./zig-out/bin/guestbook
```

Same binary, same `curl` calls. The handler code does not know it changed.

## Deploy to Cloudflare Workers + D1

The schema is derived at build time from `src/models.zig`. Dump it once,
then deploy:

```bash
# from the project root
zig build -Dexample=guestbook -Doptimize=ReleaseFast
./zig-out/bin/guestbook --print-schema > /tmp/guestbook.sql

# Apply reviewed SQL explicitly to your own configured D1 resource before deploy.
zig build -Dexample=guestbook -Dbackend=workers
npx wrangler deploy --config=deploy/guestbook/wrangler.toml
```

Deploy does **not** create a missing database. Provision a dedicated D1 resource
explicitly, replace the repository example database_id with your own resource identifier, and apply reviewed SQL.
`--migrate` performs the requested root-environment remote migration before build
and deploy; named-environment migration remains fail-closed. Configuration
validation is not remote readiness. The guestbook example retains first-request
schema initialization on Workers as a tutorial convenience; production operators
should apply migrations explicitly before deployment.

When building this repository rather than a generated project, select the example
explicitly: `zig build -Dexample=guestbook -Dbackend=workers`. The repository's
default example is chat, so a plain CLI build must not be assumed to select this
artifact. Use the reviewed deployment config and matching built WASM.

## Deploy to Cloudflare Workers + Turso

Edit `deploy/guestbook/wrangler.toml`:

```toml
[vars]
DATABASE_URL = "libsql://akamata-guestbook-<org>.turso.io?authToken=eyJab.c"

# Comment out [[d1_databases]] — not needed when DATABASE_URL is libsql://
```

`wrangler deploy`. Same wasm, same handlers. The JSPI bridge transparently
routes outbound libsql calls through `fetch()`.

## File layout

```
examples/guestbook/
├── README.md
└── src/
    ├── app.zig         # State: { db: am.db.Db }
    ├── handlers.zig    # CRUD handlers (backend-agnostic)
    ├── setup.zig       # Shared route + state wiring (used by main and worker)
    ├── models.zig      # schema source
    ├── contract.zig    # route/provider metadata
    ├── main.zig        # native entry: reads DATABASE_URL, am.App.serve
    └── worker.zig      # Workers entry: same setup.zig, wasm export

deploy/guestbook/
├── wrangler.toml       # vars.DATABASE_URL — flip d1:DB <-> libsql:// here
└── worker/
    ├── index.mjs       # JSPI host: D1 + outbound fetch bridges
    └── d1_schema.sql   # applied once with `wrangler d1 execute`
```

## How the switch works under the hood

`src/setup.zig`:

```zig
const url = am.env.get(alloc, "DATABASE_URL") orelse default;
const database = try am.db.openForContract(alloc, Contract, url);
```

`am.db.open` inspects the URL prefix:

| prefix | backend | available on |
|---|---|---|
| `file:`     | SQLite (sqlite3.c linked in) | native |
| `libsql://` / `https://` / `http://` | Turso/libsql via Hrana v3 HTTP | both |
| `d1:`       | Cloudflare D1 binding via JSPI | Workers |

Workers asynchronicity is bridged by JSPI: `new WebAssembly.Suspending(fn)`
wraps every async import (D1 and `fetch`), and `WebAssembly.promising(handle_fetch)`
wraps the wasm entry. The Zig side just calls them as ordinary synchronous
functions.

See `docs/en/db-backends.md` for the full picture.

## Learning path

This is the database/validation/provider-contract reference. For ordinary-function
HTTP handlers start with [Getting Started](../../docs/en/quickstart.md) and the
[compiled DX fixture](../../tests/dx_application_fixture.zig). For Queue/Realtime/Storage
owner wiring use [device_messaging](../device_messaging/README.md). Both Native and
Workers artifacts are built in CI; offline fixtures do not certify live resources.
