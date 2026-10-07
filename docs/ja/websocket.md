# WebSocket

HTTP ルートから upgrade する httpz スタイル。WS 専用リスナを建てない。

## ハンドラ

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

ルートは `app.ws("/path", handler)` で宣言する。内部的には `GET` メソッドの `RouteKind.ws` だが、ハンドラ側で `am.ws.upgrade()` を呼び、明示的に接続をアップグレードする。

## Portable broadcastとownership

`realtime.Service.room(Protocol, room_id)`でtyped effectを送ります。
[chat reference](../../examples/chat/README.md)はNative backendを安定したaddressに
置き、borrowしたtransport callbackとconnection teardownを明示gateで直列化します。
frameごとのallocationをconnection全期間のrequest arenaへ積み上げず、
MessageArenaを毎frame resetします。

## 制御フレーム

`Conn.readMessage` 内部で:
- `ping` → 同じペイロードで `pong` を自動返信
- `pong` → 無視
- `close` → `ReadError.ClosedByPeer`

明示的にクローズしたい場合: `conn.close(1000, "bye")`。

## Workers transport

managed gatewayはapplication authorization後に`/realtime/:resource`を
`AkamataRealtimeRoom`へ渡します。DOがsocket/attachmentを所有し、named service
bindingのZig handlerが共通domainを呼び、bounded effectを返します。Nativeのstack
ConnをDOへ移植する設計ではありません。[chat](../../examples/chat/README.md)と
[検証済みPrincipalのproduction wiring](../../examples/device_messaging/README.md)を参照してください。
旧chat専用Hub/ChatRoom経路はcanonicalではありません。
