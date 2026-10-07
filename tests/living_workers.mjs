// Actual example WASM + current managed JSPI source + dedicated offline hosts.
// No Cloudflare credential, network, provisioning or live readiness claim.
import assert from "node:assert/strict";
import { readFileSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { REALTIME_AUTHORIZE_PATH, REALTIME_MESSAGE_PATH, rejectPublicInternalRoute, realtimeNamespace } from "../deploy/worker/internal_routes.mjs";
import { WasmDispatchQueue } from "../deploy/worker/wasm_dispatch.mjs";

assert.equal(typeof WebAssembly.Suspending, "function", "run Node 24 with --experimental-wasm-jspi");
const [name, artifact, schemaFile] = process.argv.slice(2);
assert.ok(["guestbook", "tasks", "chat", "device_messaging"].includes(name));
const directory = mkdtempSync(join(tmpdir(), "akamata-example-host-"));
const database = join(directory, "isolated.sqlite");
const sql = (request) => {
  const result = spawnSync(process.env.PYTHON ?? "python3", [resolve("tests/living_sqlite.py"), database], {
    input: JSON.stringify(request), encoding: "utf8", timeout: 10_000,
  });
  assert.equal(result.status, 0, result.stderr);
  return JSON.parse(result.stdout);
};
try {
  sql({ schema: readFileSync(schemaFile, "utf8") });
  const admitted = [], rooms = [], objects = new Map();
  const env = {
    DB: { prepare(text) {
      let args = [];
      return {
        bind(...values) { args = values; return this; },
        async raw(options) {
          assert.equal(options.columnNames, true);
          const result = sql({ sql: text, args });
          return [result.columns, ...result.results.map(row => result.columns.map(column => row[column]))];
        },
        async run() { return sql({ sql: text, args }); },
      };
    } },
    EVENTS: { async send(body) { assert.ok(admitted.length < 64); admitted.push(body); } },
    JWT_SECRET: "offline-contract-secret",
    LOGIN_SECRET: "offline-login-secret",
    AKAMATA_REALTIME: {
      idFromName(room) { rooms.push(room); return room; },
      get() { return { async fetch(request) {
        assert.equal(request.headers.get("X-Akamata-Provider-Control"), "1");
        const operation = await request.json();
        assert.ok(["broadcast", "presence", "direct", "disconnect"].includes(operation.kind));
        return Response.json({ delivered: 0, connections: 0, members: 0 });
      } }; },
    },
    FILES: {
      async put(key, value, options) {
        assert.ok(objects.size < 16);
        const bytes = new Uint8Array(value);
        assert.ok(bytes.byteLength <= 4096);
        const item = { bytes, httpMetadata: options.httpMetadata, customMetadata: options.customMetadata, size: bytes.length, etag: "offline-etag", httpEtag: '"offline-etag"' };
        objects.set(key, item);
        return item;
      },
      async get(key) {
        const item = objects.get(key);
        if (!item) return null;
        return { ...item, body: new ReadableStream({ start(controller) { controller.enqueue(item.bytes); controller.close(); } }) };
      },
      async head(key) { return objects.get(key) ?? null; },
      async delete(key) { objects.delete(key); },
    },
  };
  // Evaluate the unchanged managed bridge, injecting only its platform imports.
  // We do not maintain another request/response or D1 bridge implementation.
  const source = readFileSync("deploy/worker/index.mjs", "utf8")
    .replace(/^import .*;\n/gm, "")
    .replace("export default {", "const worker = {")
    .replace("export class AkamataRealtimeApplication", "class AkamataRealtimeApplication")
    .replace(/^export \{.*\}.*;$/gm, "");
  class WorkerEntrypoint { constructor(environment) { this.env = environment; } }
  const create = new Function("wasm", "WorkerEntrypoint", "REALTIME_AUTHORIZE_PATH", "REALTIME_MESSAGE_PATH", "rejectPublicInternalRoute", "realtimeNamespace", "WasmDispatchQueue",
    `${source}\nreturn { worker, application: new AkamataRealtimeApplication(arguments[7]) };`);
  const module = new WebAssembly.Module(readFileSync(artifact));
  const exports = WebAssembly.Module.exports(module).map(item => item.name);
  assert.ok(exports.includes("handle_fetch"));
  assert.ok(exports.includes("akamata_init"));
  if (["tasks", "device_messaging"].includes(name)) assert.ok(exports.includes("handle_queue"));
  const { worker, application } = create(module, WorkerEntrypoint, REALTIME_AUTHORIZE_PATH, REALTIME_MESSAGE_PATH, rejectPublicInternalRoute, realtimeNamespace, WasmDispatchQueue, env);
  const request = async (method, path, body, authorization) => {
    const headers = new Headers();
    if (body !== undefined) headers.set("content-type", "application/json");
    if (authorization) headers.set("authorization", authorization);
    return worker.fetch(new Request(`https://offline.example${path}`, { method, headers,
      body: body === undefined ? undefined : JSON.stringify(body) }), env, {});
  };
  let checks = 0;
  const expect = (response, status) => { assert.equal(response.status, status); checks++; };
  const drainQueue = async (attempt) => {
    let acked = 0;
    await worker.queue({ messages: admitted.map((body, index) => ({ body, id: `host-${index}`, attempts: attempt,
      timestamp: new Date(), ack() { acked++; }, retry() { throw new Error("unexpected retry"); } })) }, env, {});
    assert.equal(acked, admitted.length); checks++;
  };
  if (name === "guestbook") {
    expect(await request("POST", "/entries", { name: "", message: "invalid" }), 422);
    const created = await request("POST", "/entries", { name: "Alice", message: "hello" }); expect(created, 201);
    const entry = await created.json(); assert.ok(entry.id > 0);
    const fetched = await request("GET", `/entries/${entry.id}`); expect(fetched, 200);
    assert.equal((await fetched.json()).name, "Alice");
    expect(await request("GET", "/entries/not-an-id"), 400);
    expect(await request("GET", "/entries?limit=101"), 400);
    expect(await request("DELETE", `/entries/${entry.id}`), 200);
    expect(await request("GET", `/entries/${entry.id}`), 404);
  } else if (name === "tasks") {
    expect(await request("POST", "/tasks", { title: "" }), 422);
    const response = await request("POST", "/tasks", { title: "effect" }); expect(response, 201);
    const task = await response.json(); assert.equal(admitted[0].event_type, "task_created");
    assert.equal(admitted[0].payload.task_id, task.id);
    assert.equal(admitted[0].event_id, admitted[0].idempotency_key);
    await drainQueue(1); await drainQueue(2);
    assert.equal(sql({ sql: "SELECT count(*) AS count FROM task_deliveries", args: [] }).results[0].count, 1);
    expect(await request("GET", "/events"), 501);
    expect(await request("PATCH", `/tasks/${task.id}`, { done: true }), 200);
    const filtered = await request("GET", "/tasks?done=true"); expect(filtered, 200);
    assert.equal((await filtered.json()).tasks.length, 1);
    expect(await request("DELETE", `/tasks/${task.id}`), 200);
  } else if (name === "chat") {
    expect(await request("POST", "/rooms", { name: "" }), 422);
    const response = await request("POST", "/rooms", { name: "general" }); expect(response, 201);
    const room = await response.json();
    const posted = await request("POST", `/rooms/${room.id}/messages`, { user: "alice", text: "hello" }); expect(posted, 201);
    assert.equal((await posted.json()).text, "hello");
    assert.equal(rooms[0], `room:${room.id}`);
    expect(await request("POST", "/realtime/message", {}), 404);
    const inbound = await application.fetch(new Request("https://offline.example/realtime/message", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({
      context: { identity: "bob", metadata: JSON.stringify({ room_id: room.id }) },
      envelope: { protocol_version: 1, event_type: "send", payload: { text: "from DO" } },
    }) }));
    expect(inbound, 200);
    const action = (await inbound.json())[0]; assert.equal(action.kind, "broadcast");
    assert.equal(action.envelope.payload.text, "from DO");
    assert.equal(action.envelope.payload.user, "bob");
    const history = await request("GET", `/rooms/${room.id}/messages`); expect(history, 200);
    assert.equal((await history.json()).messages.length, 2);
  } else {
    expect(await request("POST", "/records", { body: "denied" }), 401);
    const login = await request("POST", "/login", { subject: "device-1", credential: env.LOGIN_SECRET }); expect(login, 200);
    const authorization = `Bearer ${(await login.json()).access_token}`;
    expect(await request("POST", "/records", { body: "" }, authorization), 422);
    expect(await request("POST", "/records", { body: "typed principal" }, authorization), 201);
    const put = await worker.fetch(new Request("https://offline.example/objects/reference", { method: "PUT", headers: { authorization, "content-type": "text/plain" }, body: "portable object" }), env, {});
    expect(put, 201);
    const object = await request("GET", "/objects/reference", undefined, authorization); expect(object, 200);
    assert.equal(await object.text(), "portable object");
    expect(await request("DELETE", "/objects/reference", undefined, authorization), 204);
    expect(await request("GET", "/objects/reference", undefined, authorization), 404);
    const created = await request("POST", "/reports", { firmware_version: "contract", uptime_seconds: 1 }, authorization); expect(created, 201);
    const report = await created.json(); assert.equal(admitted[0].event_type, "report_created");
    await drainQueue(1); await drainQueue(2);
    const delivered = await request("GET", `/reports/${report.id}/delivery`, undefined, authorization); expect(delivered, 200);
    assert.equal((await delivered.json()).attempt, 2);
    expect(await request("DELETE", `/reports/${report.id}`, undefined, authorization), 204);
    await drainQueue(3);
    assert.equal(sql({ sql: "SELECT count(*) AS count FROM report_deliveries", args: [] }).results[0].count, 0);
  }
  console.log(JSON.stringify({ example: name, evidence: "actual WASM + managed JSPI + offline host", checks, queue_messages: admitted.length, remote_requests: 0 }));
} finally { rmSync(directory, { recursive: true, force: true }); }
