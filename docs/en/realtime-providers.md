# Realtime provider ownership

Native already has an explicit owner: realtime.Native owns its connection registry, room/identity strings and synchronization. Application startup initializes it; State stores owner.service(); Context borrows Service. The HTTP/WebSocket transport owns sockets and supplies send/close callbacks. Stop HTTP admission, drain/close transports, join connection callbacks, then deinit the realtime owner. Native.deinit frees registry state and is not a socket drain or worker join.

Workers RealtimeOwner.create(allocator, binding) owns a copied namespace binding name and a stable portable Service adapter. It acquires no remote resource on creation. Each operation resolves room identity through namespace.idFromName(room) and sends a private control request to the existing DO class. Deinit releases local owner memory only: it never deletes remote rooms, storage or sockets. The application stops dispatch before destroying the borrowed Service owner. Host-managed isolate termination is not a reliable application deinit callback.

## Identity and authorization

The existing gateway authorizes before connecting; client X-Akamata headers are not trusted. DO attachment keeps the existing UUID connectionId for platform extensions and adds portableConnectionId as a nonzero decimal u64 string. IDs are generated in the DO, checked against current room attachments, persisted across hibernation, and never converted to JS Number. Portable Service direct/disconnect and broadcast-except use this additional identity. Inbound handler attachment context contains both fields; convert portableConnectionId with checked u64 parsing. Historical attachments lacking the portable field retain UUID operations, but cannot be targeted through the portable u64 facade until reconnecting.

Room name maps deterministically to a DO ID within the selected namespace. Connection identity is room-scoped; logical identity remains application authorization metadata. Broadcast sends a versioned protocol envelope; no inbound event is implicitly broadcast. Presence counts current host sockets and distinct logical identities. Durable Object storage/RPC-specific features and legacy UUID direct calls remain explicit platform extensions.

The private /__akamata/provider/realtime control route is rejected by the public Worker HTTP gateway and requires the trusted-control header on DO requests. Possession of the namespace binding remains the platform authority. It is not an Internet endpoint or an authentication bypass for WebSocket admission. The legacy fetch control plane is retained; no RPC superclass migration is required for existing projects. New isolated RPC-only implementations may use the built-in DurableObject class independently.

## Failure and lifecycle boundaries

Owner operations serialize a bounded 128 KiB control envelope, free it after host completion, and map missing connections, missing bindings, overflow and host failure to existing realtime errors. The synchronous-looking WASM call suspends through JSPI; the managed isolate dispatch queue retains request ownership. Portable presence() predates this adapter and cannot return an error; on failure it returns zero counts. Readiness and applications requiring failure evidence must use the explicit presenceChecked(room) extension, never infer remote health from zero portable presence.

## Evidence

WASM host simulation verifies copied binding ownership, typed broadcast/direct/disconnect and lossless maximum u64. Actual managed JS bridge tests verify deterministic namespace routing and presence packing. DO adapter tests verify UUID compatibility, portable direct/exclusion/disconnect, missing IDs, malformed IDs and public route rejection. These are offline adapter/host-simulation evidence, not live Durable Object certification.

References: https://developers.cloudflare.com/durable-objects/best-practices/create-durable-object-stubs-and-send-requests/ and https://developers.cloudflare.com/durable-objects/best-practices/websockets/

Custom namespace bindings require an explicit environment variable `AKAMATA_REALTIME_BINDING="ROOMS"` (replace ROOMS with the Contract binding). The gateway retains AKAMATA_REALTIME as its legacy default. CLI validation rejects disagreement between this selector and Provision; it never guesses a namespace or rewrites configuration. Named environments need their own variable and binding.
