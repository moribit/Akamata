import assert from 'node:assert/strict';
import app from './hono.mjs';
const db = { prepare(sql) { assert.equal(sql, 'SELECT id, name, weight FROM items WHERE id = ?'); return { bind(id) { assert.equal(id, 1); return { async first() { return { id: 1, name: 'alpha', weight: 1.5 }; } }; } }; } };
for (const [path, type, body] of [
  ['/plaintext', 'text/plain; charset=utf-8', 'Hello, World!'],
  ['/json', 'application/json', '{"message":"Hello, World!"}'],
  ['/users/123/posts/456', 'application/json', '{"user":123,"post":456}'],
  ['/db/1', 'application/json', '{"id":1,"name":"alpha","weight":1.5}'],
]) {
  const response = await app.fetch(new Request('https://fixture.test' + path), { DB: db });
  assert.equal(response.status, 200); assert.equal(response.headers.get('content-type'), type); assert.equal(await response.text(), body);
}
for (const size of [64, 1024, 65536]) {
  const body = new Uint8Array(size).fill(120);
  const response = await app.fetch(new Request('https://fixture.test/echo', { method: 'POST', body }));
  assert.equal(response.status, 200); assert.deepEqual(new Uint8Array(await response.arrayBuffer()), body);
}
console.log('Hono host fixture: 7 wire checks passed; fake D1, no live CPU/performance certification');
