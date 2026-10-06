# Realtime developer guide

既存`events.Protocol`でtyped event、`realtime.Service`と`Room(Protocol)`でapplication effectを表現します。protocol_genでTS/C clientを生成でき、HTTP DTO schemaとは独立しています。新channel router/backendは追加しません。

HTTP handshake routeで既存auth middlewareを使います。Authorizerは信頼できるapplication stateからroom/logical identityを導出し、任意clientのroom指定をそのまま信頼しません。InboundHandlerがtyped eventを受け、Responderが明示direct/broadcastを行います。ContextはServiceをborrowし、Native/Workers ownerが明示初期化・cleanupします。

`ak.channel`の共通shorthandは見送ります。Native App.wsのsocket ownershipとWorkers DO gatewayのidentity/authorizationは同じroute登録操作ではなく、隠すと保証できないsemanticsを暗示するためです。protocol/room effectを共通化し、transport entrypointは明示します。[Provider wiring (English)](../../en/realtime-providers.md)、[WebSocket](../websocket.md)、[device_messaging](../../../examples/device_messaging/README.md)を参照してください。

[chat](../../../examples/chat/README.md)は従来の明示HTTP/WS hub APIを示すexampleで、DO provider ownerのproduction certificationではありません。WASM simulationとlive証拠を区別してください。Native defaultはThreaded、ReactorはParkです。
