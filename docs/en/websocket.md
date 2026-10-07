# WebSocket

httpz style to upgrade from HTTP route. Do not build a WS-specific listener.

## Handler

```zig
const Ctx = am.Context(App);

fn wsRoom(ctx: *Ctx) !void {
    var conn = try am.ws.upgrade(Ctx, ctx, .{ .max_message_bytes = 64 * 1024 });
    defer conn.deinit();

    var message_arena = am.realtime.MessageArena.init(ctx.app().?.gpa);
    defer message_arena.deinit();
    while (true) {
        message_arena.reset();
        const msg = conn.readMessage(message_arena.allocator()) catch |e| switch (e) {
            error.ClosedByPeer => return,
            else => return e,
        };
        if (msg.opcode == .text) try conn.sendText(msg.payload);
    }
}
```

The route is declared with `app.ws("/path", handler)`. Internally, it is a `GET` route with `RouteKind.ws`, and the handler explicitly upgrades the connection with `am.ws.upgrade()`.

## Portable broadcast and ownership

Use `realtime.Service.room(Protocol, room_id)` for typed effects. The
[chat reference](../../examples/chat/README.md) keeps the Native backend at a
stable address and explicitly guards borrowed transport callbacks against
connection teardown. A shared request arena must not retain every frame for
the connection lifetime; reset MessageArena after each frame.

## Control frame

Inside `Conn.readMessage`:
- `ping` → Automatically reply `pong` with the same payload
- `pong` → ignore
- `close` → `ReadError.ClosedByPeer`

If you want to close it explicitly: `conn.close(1000, "bye")`.

## Workers transport

The managed gateway routes `/realtime/:resource` to `AkamataRealtimeRoom` after
application authorization. The Durable Object owns sockets/attachments; its
named service-binding handler invokes the shared Zig domain code and returns
explicit bounded effects. Native stack Conn ownership is not transplanted into
a DO. See [chat](../../examples/chat/README.md) and
[verified Principal production wiring](../../examples/device_messaging/README.md).
The old chat-only Hub/ChatRoom path is no longer canonical.
