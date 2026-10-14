// Offline ABI/D1 host simulation. Timings are local wall time, never CF CPU.
import assert from 'node:assert/strict';
import { readFileSync, writeFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import app from './hono.mjs';

const [binary, output] = process.argv.slice(2);
if (!binary || !output) throw new Error('usage: node wasm-host.mjs WASM OUTPUT.json');
const content = readFileSync(binary);
const compilationStart = performance.now();
const module = new WebAssembly.Module(content);
const compileMs = performance.now() - compilationStart;
let memory;
const decode = (p, l) => new TextDecoder().decode(new Uint8Array(memory.buffer, p, l));
const copy = (text, p, cap) => {
  const bytes = new TextEncoder().encode(text);
  assert.ok(bytes.length <= cap);
  new Uint8Array(memory.buffer, p, bytes.length).set(bytes);
  return bytes.length;
};
const statements = new Map();
let nextStatement = 1;
const imports = {};
for (const {module: group, name, kind} of WebAssembly.Module.imports(module)) {
  assert.equal(kind, 'function');
  (imports[group] ??= {})[name] = () => { throw new Error(`unexpected host operation ${group}.${name}`); };
}
Object.assign(imports.akamata_env ??= {}, {
  akamata_monotonic_ns: () => process.hrtime.bigint(),
  akamata_unix_micros: () => BigInt(Date.now()) * 1000n,
});
Object.assign(imports.akamata_d1 ??= {}, {
  d1_prepare(sp, sl) {
    assert.equal(decode(sp, sl), 'SELECT id, name, weight FROM items WHERE id = ?');
    const id = nextStatement++;
    statements.set(id, { step: 0 });
    return id;
  },
  d1_prepare_named(bp, bl, sp, sl) {
    assert.equal(decode(bp, bl), 'DB');
    assert.equal(decode(sp, sl), 'SELECT id, name, weight FROM items WHERE id = ?');
    const id = nextStatement++;
    statements.set(id, { step: 0 });
    return id;
  },
  d1_bind_int64(id, index, value) { assert.ok(statements.has(id)); assert.equal(index, 1); assert.equal(value, 1n); return 0; },
  d1_run(id) { assert.ok(statements.has(id)); return 1; },
  d1_step(id) { return statements.get(id).step++ === 0 ? 1 : 0; },
  d1_column_int64(id, index) { assert.ok(statements.has(id)); assert.equal(index, 0); return 1n; },
  d1_column_double(id, index) { assert.ok(statements.has(id)); assert.equal(index, 2); return 1.5; },
  d1_column_text_len(id, index) { assert.ok(statements.has(id)); assert.equal(index, 1); return 5; },
  d1_column_text_copy(id, index, ptr, len) { assert.ok(statements.has(id)); assert.equal(index, 1); return copy('alpha', ptr, len); },
  d1_column_is_null(id) { assert.ok(statements.has(id)); return 0; },
  d1_column_count() { return 3; },
  d1_finalize(id) { assert.ok(statements.delete(id)); },
});
const initializationStart = performance.now();
const instance = new WebAssembly.Instance(module, imports);
memory = instance.exports.memory;
instance.exports.akamata_init();
const initializationMs = performance.now() - initializationStart;
const cases = [
  ['plaintext', 'GET', '/plaintext', null, 'text/plain; charset=utf-8', 'Hello, World!'],
  ['json', 'GET', '/json', null, 'application/json', '{"message":"Hello, World!"}'],
  ['routing', 'GET', '/users/123/posts/456', null, 'application/json', '{"user":123,"post":456}'],
  ['db', 'GET', '/db/1', null, 'application/json', '{"id":1,"name":"alpha","weight":1.5}'],
  ...[64, 1024, 65536].map(n => [`echo-${n}`, 'POST', '/echo', 'x'.repeat(n), 'application/octet-stream', 'x'.repeat(n)]),
];
function wasmRequest(method, path, body) {
  const bytes = Buffer.from(`${method} ${path} HTTP/1.1\r\nHost: fixture.test\r\nConnection: close\r\n${body === null ? '' : `Content-Type: application/octet-stream\r\nContent-Length: ${Buffer.byteLength(body)}\r\n`}\r\n${body ?? ''}`);
  const p = instance.exports.alloc(bytes.length);
  assert.notEqual(p, 0);
  let responsePtr = 0, responseLen = 0;
  try {
    new Uint8Array(memory.buffer, p, bytes.length).set(bytes);
    responsePtr = instance.exports.handle_fetch(p, bytes.length);
    responseLen = instance.exports.last_response_length();
    assert.notEqual(responsePtr, 0, decode(instance.exports.last_error_ptr(), instance.exports.last_error_length()));
    return Buffer.from(new Uint8Array(memory.buffer, responsePtr, responseLen));
  } finally {
    instance.exports.dealloc(p, bytes.length);
    if (responsePtr) instance.exports.dealloc(responsePtr, responseLen);
  }
}
const fakeD1 = { prepare(sql) {
  assert.equal(sql, 'SELECT id, name, weight FROM items WHERE id = ?');
  return { bind(id) { assert.equal(id, 1); return { async first() { return { id: 1, name: 'alpha', weight: 1.5 }; } }; } };
} };
const result = {
  classification: 'offline-host-simulation', source_sha: execFileSync('git', ['rev-parse', 'HEAD'], {encoding:'utf8'}).trim(),
  command: process.argv, node: process.version, os: process.platform, arch: process.arch,
  wasm_bytes: content.length, wasm_sha256: createHash('sha256').update(content).digest('hex'),
  compile_ms: compileMs, instantiate_and_initialize_ms: initializationMs,
  scope: 'WASM ABI and fake D1; no JSPI await, remote D1, Workers CPU/cold start or edge network. No performance ranking.', completed: false, runs: [],
};
try {
  for (const [name, method, path, body, type, expected] of cases) {
    const started = performance.now();
    const response = wasmRequest(method, path, body).toString();
    const firstMs = performance.now() - started;
    const split = response.indexOf('\r\n\r\n');
    assert.ok(response.startsWith('HTTP/1.1 200 '));
    assert.ok(response.slice(0, split).toLowerCase().includes(`content-type: ${type}`));
    assert.equal(response.slice(split + 4), expected);
    const hono = await app.fetch(new Request('https://fixture.test' + path, {method, ...(body === null ? {} : {body})}), {DB:fakeD1});
    assert.equal(hono.status, 200); assert.equal(hono.headers.get('content-type'), type); assert.equal(await hono.text(), expected);
    assert.equal(statements.size, 0);
    result.runs.push({workload:name, wire_match:true, first_local_wasm_request_ms:firstMs});
  }
  assert.equal(statements.size, 0);
  result.completed = true;
} catch (error) {
  result.failure = String(error);
  throw error;
} finally {
  instance.exports.benchmark_deinit();
  writeFileSync(output, JSON.stringify(result, null, 2) + '\n');
}
console.log('Akamata WASM / Hono: 7 exact-body host checks passed; not live Cloudflare evidence');
