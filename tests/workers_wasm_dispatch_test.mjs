import { readFileSync } from "node:fs";
import assert from "node:assert/strict";
import test from "node:test";
import { WasmDispatchQueue } from "../deploy/worker/wasm_dispatch.mjs";

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

test("JSPI-suspended fetches keep response length, buffer, allocator, and request state isolated", async () => {
  const queue = new WasmDispatchQueue();
  const shared = { active: 0, response: null, responseLength: 0, allocations: new Set() };
  let peakActive = 0;

  async function dispatchHttp(request) {
    const id = Number(new URL(request.url).pathname.slice(1));
    shared.active++;
    peakActive = Math.max(peakActive, shared.active);
    const requestAllocation = `request:${id}`;
    shared.allocations.add(requestAllocation);
    try {
      // Models handle_fetch parked in a D1/fetch WebAssembly.Suspending import.
      await delay(id % 7);
      const bytes = new TextEncoder().encode(`HTTP/1.1 200 OK\r\ncontent-length: ${String(id).length}\r\n\r\n${id}`);
      shared.response = bytes;
      shared.responseLength = bytes.length;
      await Promise.resolve();
      const raw = new TextDecoder().decode(shared.response.slice(0, shared.responseLength));
      return new Response(raw.split("\r\n\r\n")[1], { status: Number(raw.split(" ")[1]) });
    } finally {
      shared.allocations.delete(requestAllocation);
      shared.active--;
    }
  }

  const count = 256;
  const requests = Array.from({ length: count }, (_, id) => new Request(`https://worker.test/${id}`));
  const responses = await Promise.all(requests.map((request) =>
    queue.run(() => dispatchHttp(request))
  ));

  assert.equal(peakActive, 1);
  assert.equal(shared.allocations.size, 0);
  for (let id = 0; id < count; id++) {
    assert.equal(responses[id].status, 200);
    assert.equal(await responses[id].text(), String(id));
  }
});

test("a rejected dispatch releases the isolate queue", async () => {
  const queue = new WasmDispatchQueue();
  await assert.rejects(queue.run(async () => { throw new Error("boom"); }), /boom/);
  assert.equal(await queue.run(async () => 200), 200);
});

for (const source of ["../deploy/worker/index.mjs", "../tools/akamata/src/templates/worker_index.mjs.tpl"]) {
  test(`${source}: bodyless HTTP statuses produce a valid Fetch response`, async () => {
    const text = readFileSync(new URL(source, import.meta.url), "utf8");
    const start = text.indexOf("function parseHttpResponse(bytes)");
    const parser = new Function(text.slice(start, text.indexOf("export {", start)) + "; return parseHttpResponse;")();
    for (const status of [204, 205, 304]) {
      const response = parser(new TextEncoder().encode(`HTTP/1.1 ${status} Test\r\nx-test: preserved\r\n\r\n`));
      assert.equal(response.status, status);
      assert.equal(response.body, null);
      assert.equal(response.headers.get("x-test"), "preserved");
    }
    assert.equal(await parser(new TextEncoder().encode("HTTP/1.1 200 OK\r\n\r\nhello")).text(), "hello");
  });
}
