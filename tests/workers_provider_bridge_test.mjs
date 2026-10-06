import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

// Test actual managed source with injected host resources; no Cloudflare calls.
for (const path of ["tools/akamata/src/templates/worker_index.mjs.tpl", "deploy/worker/index.mjs"]) {
  const source = readFileSync(path, "utf8");
  const start = source.indexOf("  const queueBridge = {");
  const end = source.indexOf("  const imports = {", start);
  assert.ok(start >= 0 && end > start);
  const strings = ["FILES", "objects/test", JSON.stringify({ content_type: "text/plain" }), "EVENTS",
    JSON.stringify({ protocol_version: 2, event_type: "created", event_id: "event-1", attempt: 2, max_attempts: 7, idempotency_key: "message:1" }), JSON.stringify({ text: "hello" })];
  const writes = new Map(), lists = new Map(), messages = [];
  let failCondition = false;
  let encodedPage;
  const create = new Function("env", "readString", "readBytes", "writeBytes", "suspending", "r2ops", "r2lists",
    `let nextR2Id = 1;\n${source.slice(start, end)}\nreturn { queueBridge, r2Bridge };`);
  const { queueBridge: queue, r2Bridge: r2 } = create({
    FILES: { async list(options) {
      assert.equal(options.cursor, "opaque-token");
      assert.deepEqual(options.include, ["httpMetadata", "customMetadata"]);
      return { objects: [{ key: "objects/test", size: 3, httpEtag: '"etag"', httpMetadata: { contentType: "text/plain" }, customMetadata: { owner: "test" } }], truncated: true, cursor: "next-token" };
    }, async put(key, bytes, options) {
      assert.equal(key, "objects/test"); assert.equal(bytes.length, 3);
      assert.equal(options.httpMetadata.contentType, "text/plain");
      return failCondition ? null : { etag: "etag" };
    } },
    EVENTS: { async send(message) { messages.push(message); } },
  }, ptr => strings[ptr], () => new Uint8Array([1, 2, 3]), (_ptr, bytes) => { encodedPage = bytes; }, fn => fn, writes, lists);
  strings.push("opaque-token");
  const pageId = await r2.akamata_r2_list_page_begin(0, 5, 1, 12, 6, 12, 1);
  assert.ok(pageId > 0);
  r2.akamata_r2_list_copy(pageId, 0, r2.akamata_r2_list_len(pageId));
  const page = JSON.parse(new TextDecoder().decode(encodedPage));
  assert.equal(page.cursor, "next-token");
  assert.equal(page.objects[0].content_type, "text/plain");
  assert.deepEqual(JSON.parse(page.objects[0].custom_json), { owner: "test" });
  r2.akamata_r2_list_close(pageId);
  assert.equal(lists.size, 0);
  let id = await r2.akamata_r2_put_begin(0, 5, 1, 12, 2, 29);
  assert.equal(await r2.akamata_r2_put_write(id, 0, 3), 0);
  assert.equal(await r2.akamata_r2_put_finish(id), 0);
  assert.equal(writes.size, 0);
  id = await r2.akamata_r2_put_begin(0, 5, 1, 12, 2, 29);
  assert.equal(await r2.akamata_r2_put_write(id, 0, 8 * 1024 * 1024 + 1), -5);
  r2.akamata_r2_put_abort(id); r2.akamata_r2_put_abort(id);
  assert.equal(writes.size, 0, "aborted write retained host buffers");
  failCondition = true;
  id = await r2.akamata_r2_put_begin(0, 5, 1, 12, 2, 29);
  assert.equal(await r2.akamata_r2_put_write(id, 0, 3), 0);
  assert.equal(await r2.akamata_r2_put_finish(id), -3);
  assert.equal(writes.size, 0);
  assert.equal(await queue.akamata_queue_send(3, 6, 4, 1, 5, 1), 0);
  assert.deepEqual(messages, [{ ...JSON.parse(strings[4]), payload: { text: "hello" } }]);
}
console.log("managed R2/Queue bridge: bounded write abort, conditional failure, envelope metadata passed");
