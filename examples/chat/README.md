# Chat — portable realtime, explicit transport ownership

## What you will learn

One typed `events.Protocol`, one DB/domain operation and one HTTP graph run on
Native or Workers. A `realtime.Service` is portable; a WebSocket's ownership is
platform-specific and stays visible.

## Why this example exists

[Guestbook](../guestbook/) teaches typed HTTP; [tasks](../tasks/) teaches finite
queue effects. Chat teaches long-lived transport ownership, bounded messages,
room identity and the distinction between domain events and transport adapters.
This is an **anonymous chat tutorial**, not an authentication reference.

## Run Native

From the repository root with Zig 0.17:

```sh
zig build -Dexample=chat
./zig-out/bin/chat
curl -H 'content-type: application/json' -d '{"name":"general"}' http://localhost:8080/rooms
```

Open `http://localhost:8080/`, choose the returned room ID and join.
`DATABASE_URL` defaults to `file:chat.db`; `PORT` defaults to `8080`.
Native tutorial startup applies `src/schema.sql`. Production uses explicit
versioned migrations before traffic; Workers never applies DDL in a request.

The Native browser UI connects to `/realtime/1?user=alice`. Its ordinary HTTP
POST persists the message and broadcasts the typed `message` event. A frame
client may send `{"protocol_version":1,"event_type":"send","payload":{"text":"hello"}}`.
Only the server may publish `message`. Text is bounded to 1024 bytes, nicknames
to 64 bytes, Native frames to 4096 bytes. Histories return at most 100 messages.

## Run / Build Workers

```sh
zig build -Dexample=chat -Dbackend=workers
```

[deploy/wrangler.toml](../../deploy/wrangler.toml) is a **configuration template**:
D1 `DB`, DO `AKAMATA_REALTIME`, and a named self-service binding
`AKAMATA_REALTIME_HANDLER`. Replace the placeholder resource ID for your selected
environment and apply [schema.sql](src/schema.sql) before deployment. The current
managed JS bridge is used verbatim; no chat-specific JavaScript domain engine
or room database competes with the shared Zig application.

The Workers gateway requires an `Authorization: Bearer alice` header when
connecting to `/realtime/1`. In this anonymous demo that value is a bounded
**nickname, not a verified credential**. The gateway calls the shared room
policy, maps `room:1` to the DO, and forwards trusted connection context through
the named application entrypoint. Public access to internal handlers is rejected
by the bridge. A header-capable WebSocket client can exercise this path; the
Native browser demo does not pretend browser WebSocket can set that header.
For authenticated browser applications use an explicit credential transport
policy and [device_messaging](../device_messaging/), not this nickname policy.

Building WASM proves compilation. Adapter/host tests are separate evidence from
live Cloudflare testing; no remote resources are provisioned by this example.
See [Workers deployment](../../docs/en/cloudflare.md).

## Test

```sh
zig build chat-test
zig build chat-test -Doptimize=ReleaseSafe
zig build workers-realtime-test workers-wasm-dispatch-test
```

The application test uses the production graph, real SQLite, and an explicit
Native send capture. It verifies typed JSON validation, persistence, protocol
broadcast, Workers inbound context/action semantics and unsupported versions.
The DO tests independently verify gateway isolation, hibernated attachment
handling and explicit effects. These are offline contracts, not live proof.

## Architecture

```text
contract.routes + Protocol → setup.Application → shared persistMessage()
                                      │
                 ┌────────────────────┴────────────────────┐
             Native                                     Workers
       realtime.Native owner                    RealtimeOwner + DO
       stack-owned WS Conn                      DO owns WebSockets
       MessageArena reset per frame             named Zig handler
       transport gate before detach             bounded action response
```

Native owners retain stable addresses until `serve` drains. Context borrows DB
and Service. The transport gate serializes callbacks with detach/connection
cleanup; no send can reference a destroyed stack Conn. It also means a slow
Native peer can delay other realtime sends: this is a correctness-first tutorial
on the production Threaded runtime, not a high-fanout scalability claim.
Workers stores connection identity/room metadata in DO attachments; the inbound
handler returns an action instead of synchronously calling back into its own DO.
Both sides reset operation memory and use the same versioned Protocol/domain
function. DB insert and broadcast are separate effects, not an atomic guarantee.

### Compatibility note

The tutorial's old Hub, duplicate route graph, untyped echo frames and
`/rooms/:id/ws` endpoint were removed. Use `/realtime/:resource` and the versioned
Protocol. HTTP room/history routes remain; POST now returns the typed message.
The repository's Workers configuration is for a **new test deployment**. Existing
Cloudflare deployments with `ChatRoom` require an explicit migration/resource
retirement plan; do not overwrite their migration history with this template.
The frontend source is now only `src/index.html`.

## Next

Read [Realtime](../../docs/en/guides/realtime.md), then
[device_messaging](../device_messaging/) for verified Principal, production
providers, migration and deployment validation.
