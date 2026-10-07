# Realtime developer guide

Reuse `events.Protocol` for typed events and `realtime.Service` / `Room(Protocol)` for application effects. Protocol metadata already generates TS/C clients through protocol_gen; HTTP DTO schemas remain separate. There is no new channel router or backend.

Use an HTTP handshake route with existing authentication middleware. Derive room and logical identity in an Authorizer from trusted application state, not arbitrary client room claims. InboundHandler receives typed events; Responder explicitly performs direct/broadcast effects. Borrow Service through Context; Native and Workers owners have distinct explicit initialization and cleanup.

A universal `ak.channel` shorthand is deliberately deferred: Native App.ws socket ownership and Workers Durable Object gateway identity/authorization are not interchangeable route registration operations. A shorthand that hid that distinction would claim semantics it could not enforce. Keep portable protocol/room effects shared and transport entrypoints explicit. See [Realtime provider wiring](../realtime-providers.md), [WebSocket](../websocket.md) and [device_messaging reference](../../../examples/device_messaging/README.md).

The [chat example](../../../examples/chat/README.md) uses a shared typed Protocol
and domain function with explicit Native socket / Workers DO owners. Its anonymous
nickname policy is tutorial-only. [Device messaging](../../../examples/device_messaging/README.md)
shows verified Principal and production provider wiring. Native Threaded remains
default; Reactor is parked. Offline contracts do not establish live readiness.
