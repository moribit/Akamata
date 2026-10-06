# Cloudflare deployment

Akamata shares application contracts between Native and **Cloudflare Workers (WASM)**.
Start with [Getting Started](quickstart.md); provider ownership and bindings stay explicit.
Adapter contracts and WASM host simulation are offline evidence, not live certification.

## Cloudflare Containers

Containers run the Native Linux process and providers. Akamata's `--containers`
path builds a binary and local Docker image; it does not provision or publish a
Cloudflare Container deployment. Configure that separate platform control plane
using the [current Cloudflare Containers guide](https://developers.cloudflare.com/containers/).

```bash
zig build -Dexample=chat -Dbackend=native -Dtarget=x86_64-linux-musl -Doptimize=ReleaseFast
docker build -f deploy/Dockerfile -t akamata-chat .
```

Filesystem and SQLite persistence need an explicitly durable volume/storage
strategy. Akamata does not translate a local SQLite file into D1 or DO storage.
Platform instance limits and APIs change; consult the linked platform documentation.

## Cloudflare Workers (WASM)

The JS thin wrapper loads `akamata_worker.wasm`, a stable alias produced for
the Workers example selected by `-Dexample=...`, and dispatches the request.

```bash
# In a generated --target=workers/both project (Hello requires no D1):
zig build -Dbackend=workers -Doptimize=ReleaseSafe
cd deploy
wrangler dev --local
```

Deploy:

```bash
# Return to the generated project root after local development:
cd ..
akamata deploy --workers
```

### D1

For applications requiring D1, explicitly create/select a dedicated resource,
configure its binding and real UUID, and apply reviewed migrations. Deploy refuses
placeholder resources. [Deployment validation](deployment-validation.md) covers
JSONC/TOML, environments and fail-closed named-environment migration. Validation
never creates resources. Use [guestbook](../../examples/guestbook/README.md) for
the model-backed example; do not apply its schema to the minimal Hello project.

### Durable Object: WebSocket

WS connection (`/rooms/:id/ws`) detects `request.headers.get("Upgrade")` on JS side and routes directly to `CHAT_ROOM` DO. Retain WS session within DO + persist to DO built-in SQLite. The Zig side WS handler is not called in Workers mode.

For the portable realtime API use `/realtime/:resource`. `:resource` is not a
trusted room id. The Worker requires an `Authorization` header and calls the
shared Zig `POST /__akamata/realtime/authorize` handler. That handler returns a
Principal-derived room/logical identity only after application authorization.
The gateway discards client `X-Akamata-*` headers before forwarding the trusted
context to `AKAMATA_REALTIME`.

Inbound messages are never automatically relayed. The hibernating Durable
Object enforces 64 KiB/text/JSON-envelope bounds and invokes the application
through `AKAMATA_REALTIME_HANDLER`. Only explicit direct/broadcast/
broadcast-except/disconnect actions are applied. Configure the service binding:

```toml
[[services]]
binding = "AKAMATA_REALTIME_HANDLER"
service = "akamata-realtime-handler"
entrypoint = "AkamataRealtimeApplication"
```

Deploy `worker/realtime_handler.mjs` separately with
`wrangler.realtime-handler.toml`, then set `service` to that Worker. Its default
entrypoint always returns 404; only the named Service Binding can reach the
control plane. Do not self-bind the public gateway. Never log Authorization,
source credentials, or payload bodies.

### R2 streaming

`am.platform.workers.R2Store` implements the portable Store using JSPI. The
current generic HTTP-to-WASM bridge calls `request.arrayBuffer()` first and R2
uploads are capped at the application limit, so they are bounded but not
zero-copy. Downloads support byte ranges; the current response ABI reads in
64 KiB chunks but accumulates the final response in WASM memory.
`get` propagates ETag, Content-Type and custom metadata. Prefer caller-owned
`listPage` with explicit cleanup and opaque pagination cursor over legacy `list`.
The legacy `head` bridge exposes size only on R2; use
`serveDownload`/`get` when conditional metadata is required.

Run the deployed D1/R2 opt-in smoke test with:

```bash
AKAMATA_LIVE_BASE_URL=https://example.workers.dev \
AKAMATA_LIVE_SUBJECT=test-client \
AKAMATA_LIVE_LOGIN_SECRET='...' \
zig build cloudflare-live-test
```

The opt-in test covers D1 write/read, R2 put/Range 206, an authenticated
two-connection Durable Object WebSocket relay, and public-route isolation.
Native WebSocket loops should use `am.realtime.MessageArena` and reset it after
each handled frame so decoded message allocations do not live with the socket.

## Main points of wrangler.toml

```toml
name = "akamata-chat"
main = "worker/index.mjs"
compatibility_date = "2026-01-15"

[[d1_databases]]
binding = "DB"
database_name = "akamata"
database_id = "<your-d1-id>"

[[durable_objects.bindings]]
name = "CHAT_ROOM"
class_name = "ChatRoom"

[[migrations]]
tag = "v1"
new_sqlite_classes = ["ChatRoom"]
```
