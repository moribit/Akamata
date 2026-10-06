// Explicit opt-in; never provisions resources. Requires dedicated deployment
// attestation, target health marker and expiring local test-resource manifest.
import assert from "node:assert/strict";
import crypto from "node:crypto";
import tls from "node:tls";
import { readFileSync, writeFileSync } from "node:fs";
const base = process.env.AKAMATA_LIVE_BASE_URL?.replace(/\/$/, "");
const subject = process.env.AKAMATA_LIVE_SUBJECT;
const credential = process.env.AKAMATA_LIVE_LOGIN_SECRET;
const manifestPath = process.env.AKAMATA_LIVE_RESOURCE_MANIFEST;
if (!base || !subject || !credential || !manifestPath || process.env.AKAMATA_LIVE_ISOLATED !== "1") {
  console.error("Live provider contract is opt-in: require isolated test deployment, resource manifest, base URL, subject and login secret.");
  process.exit(2);
}
const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
const target = new URL(base);
assert.equal(target.protocol, "https:");
assert.equal(target.hostname, manifest.host, "target host differs from dedicated manifest");
assert.match(manifest.deployment, /^akamata-contract-[a-z0-9-]+$/);
assert.match(manifest.source_sha, /^[0-9a-f]{40}$/);
assert.match(manifest.binary_sha, /^[0-9a-f]{64}$/);
assert.ok(subject.startsWith("akamata-contract-"), "test principal must be isolated");
assert.ok(Date.parse(manifest.expires_at) > Date.now() && Date.parse(manifest.expires_at) < Date.now() + 24 * 60 * 60 * 1000, "manifest must expire within 24 hours");
for (const kind of ["d1", "r2", "queue", "worker"]) assert.ok(manifest.resources?.[kind]?.startsWith("akamata-contract-"), `resource ${kind} is not a dedicated test name`);
assert.equal(manifest.resources.worker, manifest.deployment);
assert.equal(manifest.resources.durable_objects?.script, manifest.deployment, "DO namespace must belong to the dedicated Worker");
const request = (path, options = {}) => fetch(`${base}${path}`, { ...options, redirect: "error", signal: AbortSignal.timeout(10_000) });
const health = await request("/health");
assert.equal(health.status, 200);
assert.equal((await health.json()).test_deployment, manifest.deployment, "target did not attest dedicated deployment before writes");
const login = await request("/login", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ subject, credential }) });
assert.equal(login.status, 200);
const { access_token: token } = await login.json();
assert.ok(token);
const auth = { authorization: `Bearer ${token}` };
const cleanup = [];
const sockets = [];
const result = { evidence: "Live Provider Contract", deployment: manifest.deployment, runner_source_sha: process.env.AKAMATA_LIVE_SOURCE_SHA ?? "unknown", deployment_source_sha: manifest.source_sha, binary_sha: manifest.binary_sha, artifact_identity: "operator-attested manifest", started_at: new Date().toISOString(), checks: {}, cleanup: [] };
let failure;
try {
  const record = await request("/records", { method: "POST", headers: { ...auth, "content-type": "application/json" }, body: JSON.stringify({ body: `live-${crypto.randomUUID()}` }) });
  assert.equal(record.status, 201);
  const recordId = (await record.json()).id;
  assert.ok(Number.isSafeInteger(recordId) && recordId > 0);
  cleanup.push(`/records/${recordId}`);
  assert.equal((await request("/records", { headers: auth })).status, 200);
  result.checks.d1 = "passed";
  const objectKey = `live/${crypto.randomUUID()}.bin`;
  // Register exact cleanup path before upload, including ambiguous failures.
  cleanup.push(`/objects/${objectKey}`);
  assert.equal((await request(`/objects/${objectKey}`, { method: "PUT", headers: { ...auth, "content-type": "application/octet-stream" }, body: new TextEncoder().encode("0123456789") })).status, 201);
  const ranged = await request(`/objects/${objectKey}`, { headers: { ...auth, range: "bytes=3-6" } });
  assert.equal(ranged.status, 206); assert.equal(await ranged.text(), "3456"); assert.equal(ranged.headers.get("content-range"), "bytes 3-6/10");
  result.checks.r2_range = "passed";
  const report = await request("/reports", { method: "POST", headers: { ...auth, "content-type": "application/json" }, body: JSON.stringify({ firmware_version: "live-contract", uptime_seconds: 1 }) });
  assert.equal(report.status, 201);
  const reportId = (await report.json()).id;
  assert.ok(Number.isSafeInteger(reportId) && reportId > 0);
  cleanup.push(`/reports/${reportId}`);
  const deadline = Date.now() + 30_000;
  let delivered = false;
  while (Date.now() < deadline) {
    const response = await request(`/reports/${reportId}/delivery`, { headers: auth });
    assert.equal(response.status, 200);
    if ((await response.json()).delivered) { delivered = true; break; }
    await new Promise(resolve => setTimeout(resolve, 250));
  }
  assert.ok(delivered, "Queue did not dispatch the typed consumer before deadline");
  result.checks.queue_consumer = "passed";
  const wsUrl = base.replace(/^http/, "ws") + "/realtime/default";
  const first = await websocket(wsUrl, `Bearer ${token}`); sockets.push(first);
  const second = await websocket(wsUrl, `Bearer ${token}`); sockets.push(second);
  first.send(JSON.stringify({ protocol_version: 1, event_type: "signal", payload: { session_id: "live", value: 7 } }));
  const relayed = JSON.parse(await second.receive());
  assert.equal(relayed.event_type, "signal"); assert.equal(relayed.payload.value, 7);
  result.checks.durable_object_websocket = "passed";
  for (const path of ["/realtime/message", "/__akamata/realtime/authorize", "/__akamata/provider/realtime"]) assert.equal((await request(path, { method: "POST" })).status, 404);
  result.checks.private_routes = "blocked";
} catch (error) { failure = error; result.failure = error.message; }
finally {
  for (const socket of sockets) socket.close();
  for (const path of cleanup.reverse()) {
    try {
      const response = await request(path, { method: "DELETE", headers: auth });
      assert.ok([204, 404].includes(response.status), `cleanup ${path}: HTTP ${response.status}`);
      result.cleanup.push({ path, status: response.status });
    } catch (error) { result.cleanup.push({ path, error: error.message }); failure ??= error; }
  }
  result.finished_at = new Date().toISOString();
  if (process.env.AKAMATA_LIVE_OUTPUT) writeFileSync(process.env.AKAMATA_LIVE_OUTPUT, JSON.stringify(result, null, 2));
  console.log(JSON.stringify(result));
}
if (failure) throw failure;

function websocket(url, authorization) {
  return new Promise((resolve, reject) => {
    const target = new URL(url);
    const key = crypto.randomBytes(16).toString("base64");
    const socket = tls.connect({ host: target.hostname, port: Number(target.port || 443), servername: target.hostname });
    let buffered = Buffer.alloc(0);
    const readers = [];
    function drain() {
      while (readers.length && buffered.length >= readers[0].length) {
        const reader = readers.shift();
        const value = buffered.subarray(0, reader.length);
        buffered = buffered.subarray(reader.length);
        reader.resolve(value);
      }
    }
    socket.setTimeout(15_000, () => socket.destroy(new Error("WebSocket timeout")));
    socket.on("error", error => { reject(error); for (const reader of readers.splice(0)) reader.reject(error); });
    socket.on("close", () => { for (const reader of readers.splice(0)) reader.reject(new Error("socket closed")); });
    const read = length => new Promise((readResolve, readReject) => {
      readers.push({ length, resolve: readResolve, reject: readReject }); drain();
    });
    socket.once("secureConnect", () => socket.write([
      `GET ${target.pathname}${target.search} HTTP/1.1`, `Host: ${target.host}`,
      "Connection: Upgrade", "Upgrade: websocket", `Sec-WebSocket-Key: ${key}`,
      "Sec-WebSocket-Version: 13", `Authorization: ${authorization}`, "", "",
    ].join("\r\n")));
    const onHandshake = chunk => {
      if (buffered.length + chunk.length > 8192) { socket.destroy(new Error("handshake too large")); return; }
      buffered = Buffer.concat([buffered, chunk]);
      const end = buffered.indexOf("\r\n\r\n");
      if (end < 0) return;
      socket.off("data", onHandshake);
      const head = buffered.subarray(0, end).toString("utf8");
      buffered = buffered.subarray(end + 4);
      assert.match(head, /^HTTP\/1\.1 101 /);
      const expected = crypto.createHash("sha1").update(key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11").digest("base64");
      const acceptLine = head.split("\r\n").find(line => line.toLowerCase().startsWith("sec-websocket-accept:"));
      assert.equal(acceptLine?.slice(acceptLine.indexOf(":") + 1).trim(), expected);
      socket.on("data", data => { if (buffered.length + data.length > 256 * 1024) { socket.destroy(new Error("WebSocket buffer overflow")); return; } buffered = Buffer.concat([buffered, data]); drain(); });
      resolve({
        send(value) {
          const payload = Buffer.from(value);
          assert.ok(payload.length < 126);
          const mask = crypto.randomBytes(4);
          const frame = Buffer.alloc(2 + 4 + payload.length);
          frame[0] = 0x81; frame[1] = 0x80 | payload.length; mask.copy(frame, 2);
          for (let i = 0; i < payload.length; i++) frame[6 + i] = payload[i] ^ mask[i % 4];
          socket.write(frame);
        },
        async receive() {
          const headBytes = await read(2);
          const opcode = headBytes[0] & 0x0f;
          let length = headBytes[1] & 0x7f;
          if (length === 126) length = (await read(2)).readUInt16BE();
          else if (length === 127) length = Number((await read(8)).readBigUInt64BE());
          assert.ok(length <= 64 * 1024, "WebSocket frame exceeds contract limit");
          const payload = await read(length);
          assert.equal(opcode, 1, "expected text WebSocket frame");
          return payload.toString("utf8");
        },
        close() { socket.destroy(); },
      });
    };
    socket.on("data", onHandshake);
  });
}
