import assert from "node:assert/strict";
import test from "node:test";
import { AkamataRealtimeRoom } from "../deploy/worker/realtime_object.mjs";
import { REALTIME_MESSAGE_PATH, rejectPublicInternalRoute, realtimeNamespace } from "../deploy/worker/internal_routes.mjs";

test("gateway namespace uses explicit binding configuration with legacy default", () => {
  const selected = {};
  assert.equal(realtimeNamespace({ ROOMS: selected, AKAMATA_REALTIME_BINDING: "ROOMS" }), selected);
  assert.equal(realtimeNamespace({ AKAMATA_REALTIME: selected }), selected);
  assert.equal(realtimeNamespace({ ROOMS: selected }), undefined);
});

function socket(attachment) {
  return {
    attachment, sent: [], closed: null,
    deserializeAttachment() { return this.attachment; },
    send(value) { this.sent.push(value); },
    close(code, reason) { this.closed = { code, reason }; },
  };
}

function room(handler) {
  const sockets = [];
  const ctx = {
    storage: { sql: { exec() { return { toArray: () => [] }; } } },
    blockConcurrencyWhile(fn) { return fn(); },
    getWebSockets() { return sockets; },
  };
  return { value: new AkamataRealtimeRoom(ctx, { AKAMATA_REALTIME_HANDLER: { fetch: handler } }), sockets };
}

test("internal realtime handlers are not public HTTP routes", async () => {
  assert.equal(rejectPublicInternalRoute(new Request("https://public.example/__akamata/provider/realtime")).status, 404);
  const message = rejectPublicInternalRoute(new Request(`https://public.example${REALTIME_MESSAGE_PATH}`, { method: "POST" }));
  assert.equal(message.status, 404);
  const authorize = rejectPublicInternalRoute(new Request("https://public.example/__akamata/realtime/authorize", { method: "POST" }));
  assert.equal(authorize.status, 404);
  assert.equal(rejectPublicInternalRoute(new Request("https://public.example/health")), null);
});

test("portable control uses lossless u64 identities without changing UUID extensions", async () => {
  const { value, sockets } = room(async () => Response.json([]));
  const first = socket({ connectionId: "legacy-uuid", portableConnectionId: "18446744073709551615", identity: "user" });
  const second = socket({ connectionId: "another-uuid", portableConnectionId: "1", identity: "user" });
  sockets.push(first, second);
  const call = action => value.fetch(new Request("https://internal/__akamata/provider/realtime", { method: "POST", headers: { "X-Akamata-Provider-Control": "1" }, body: JSON.stringify(action) }));
  assert.equal((await call({ kind: "direct", connection: "18446744073709551615", envelope: "event" })).status, 200);
  assert.deepEqual(first.sent, ["event"]);
  const response = await call({ kind: "broadcast", excluded: "18446744073709551615", envelope: "others" });
  assert.equal((await response.json()).delivered, 1);
  assert.deepEqual(second.sent, ["others"]);
  assert.deepEqual(await (await call({ kind: "presence" })).json(), { connections: 2, members: 1 });
  assert.equal((await call({ kind: "direct", connection: "18446744073709551616", envelope: "event" })).status, 400);
  assert.equal((await call({ kind: "direct", connection: "2", envelope: "event" })).status, 404);
  assert.equal((await call({ kind: "disconnect", connection: "1", code: 1000, reason: "done" })).status, 200);
  assert.deepEqual(second.closed, { code: 1000, reason: "done" });
  assert.equal(await value.send("legacy-uuid", "extension"), true);
  assert.equal((await value.fetch(new Request("https://internal/__akamata/provider/realtime", { method: "POST", body: "{}" }))).status, 403);
});

test("inbound event is never implicitly broadcast", async () => {
  const { value, sockets } = room(async () => Response.json([]));
  const sender = socket({ connectionId: "a", identity: "device:1", principal: "{}" });
  const peer = socket({ connectionId: "b", identity: "device:2", principal: "{}" });
  sockets.push(sender, peer);
  await value.webSocketMessage(sender, JSON.stringify({ protocol_version: 1, event_type: "signal", payload: { value: 1 } }));
  assert.deepEqual(sender.sent, []);
  assert.deepEqual(peer.sent, []);
});

test("application explicitly controls broadcast except sender", async () => {
  const envelope = { protocol_version: 1, event_type: "accepted", payload: {} };
  const { value, sockets } = room(async () => Response.json([{ kind: "broadcast_except_sender", envelope }]));
  const sender = socket({ connectionId: "a", identity: "device:1", principal: "{}" });
  const peer = socket({ connectionId: "b", identity: "device:1", principal: "{}" });
  sockets.push(sender, peer);
  await value.webSocketMessage(sender, JSON.stringify({ protocol_version: 1, event_type: "signal", payload: {} }));
  assert.equal(sender.sent.length, 0);
  assert.equal(peer.sent.length, 1);
  assert.deepEqual(JSON.parse(peer.sent[0]), envelope);
});

test("malformed, oversized and unsupported messages close predictably", async () => {
  const { value } = room(async () => new Response(null, { status: 426 }));
  const malformed = socket({ connectionId: "a" });
  await value.webSocketMessage(malformed, "{");
  assert.equal(malformed.closed.code, 1007);
  const oversized = socket({ connectionId: "b" });
  await value.webSocketMessage(oversized, "x".repeat(64 * 1024 + 1));
  assert.equal(oversized.closed.code, 1009);
  const version = socket({ connectionId: "c" });
  await value.webSocketMessage(version, JSON.stringify({ protocol_version: 999, event_type: "signal", payload: {} }));
  assert.equal(version.closed.code, 4002);
});
