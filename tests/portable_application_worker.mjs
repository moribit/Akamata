import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const module = new WebAssembly.Module(readFileSync(process.argv[2]));
let memory;
const decode = (ptr, len) => new TextDecoder().decode(new Uint8Array(memory.buffer, ptr, len));
const statements = new Map();
const selectedBindings = [];
let nextStatement = 1;
const d1 = {};
for (const item of WebAssembly.Module.imports(module).filter(item => item.module === "akamata_d1")) {
  d1[item.name] = () => { throw new Error(`unexpected D1 test operation: ${item.name}`); };
}
Object.assign(d1, {
  d1_exec_named(bp, bl, sp, sl) {
    selectedBindings.push(decode(bp, bl));
    assert.equal(decode(sp, sl), "INSERT INTO effects DEFAULT VALUES");
    return 0;
  },
  d1_exec(sp, sl) {
    selectedBindings.push("DB");
    assert.equal(decode(sp, sl), "INSERT INTO effects DEFAULT VALUES");
    return 0;
  },
  d1_prepare_named(bp, bl, sp, sl) {
    selectedBindings.push(decode(bp, bl));
    assert.equal(decode(sp, sl), "SELECT ?");
    const id = nextStatement++;
    statements.set(id, { value: 0n, cursor: 0 });
    return id;
  },
  d1_bind_int64(id, index, value) { assert.equal(index, 1); statements.get(id).value = value; return 0; },
  d1_run(id) { assert.ok(statements.has(id)); return 1; },
  d1_step(id) { return statements.get(id).cursor++ === 0 ? 1 : 0; },
  d1_column_int64(id, index) { assert.equal(index, 0); return statements.get(id).value; },
  d1_finalize(id) { assert.ok(statements.delete(id)); },
});
const imports = {
  akamata_env: {
    akamata_monotonic_ns: () => process.hrtime.bigint(),
    akamata_unix_micros: () => BigInt(Date.now()) * 1000n,
  },
  akamata_d1: d1,
  // Allocation-failure paths can keep the URL factory's Turso branch linked.
  // Linking is allowed; performing an outbound effect in this fixture is not.
  akamata_http: { akamata_fetch() { throw new Error("unexpected outbound HTTP in D1 adapter contract"); } },
};
const objects = new Map(), handles = new Map();
let nextHandle = 1;
const handle = value => { const id = nextHandle++; handles.set(id, value); return id; };
const bytes = (ptr, len) => new Uint8Array(memory.buffer, ptr, len);
const copy = (value, ptr, len) => { const data = typeof value === "string" ? new TextEncoder().encode(value) : value; assert.ok(data.length <= len); bytes(ptr, data.length).set(data); return data.length; };
const bindingKey = (bp, bl, kp, kl) => { assert.equal(decode(bp, bl), "FILES"); return decode(kp, kl); };
imports.akamata_r2 = {
  akamata_r2_put_begin(bp, bl, kp, kl, op, ol) { return handle({ key: bindingKey(bp, bl, kp, kl), options: JSON.parse(decode(op, ol)), chunks: [] }); },
  akamata_r2_put_write(id, ptr, len) { handles.get(id).chunks.push(bytes(ptr, len).slice()); return 0; },
  akamata_r2_put_finish(id) { const item = handles.get(id); objects.set(item.key, { bytes: Buffer.concat(item.chunks), type: item.options.content_type, etag: '"test-etag"' }); handles.delete(id); return 0; },
  akamata_r2_put_abort(id) { handles.delete(id); },
  akamata_r2_get_begin(bp, bl, kp, kl, offset, length, ranged, op, ol) {
    const item = objects.get(bindingKey(bp, bl, kp, kl)); if (!item) return -1;
    if (JSON.parse(decode(op, ol)).if_none_match === item.etag) return -3;
    return handle({ ...item, bytes: ranged ? item.bytes.subarray(Number(offset), length === 0n ? undefined : Number(offset + length)) : item.bytes, cursor: 0 });
  },
  akamata_r2_get_size(id) { return BigInt(handles.get(id).bytes.length); },
  akamata_r2_get_etag(id, ptr, len) { return copy(handles.get(id).etag, ptr, len); },
  akamata_r2_get_content_type(id, ptr, len) { return copy(handles.get(id).type, ptr, len); },
  akamata_r2_get_custom_metadata() { return 0; },
  akamata_r2_get_read(id, ptr, len) { const item = handles.get(id), part = item.bytes.subarray(item.cursor, item.cursor + len); item.cursor += part.length; return copy(part, ptr, len); },
  akamata_r2_get_close(id) { assert.ok(handles.delete(id)); },
  akamata_r2_delete(bp, bl, kp, kl) { objects.delete(bindingKey(bp, bl, kp, kl)); return 0; },
  akamata_r2_head(bp, bl, kp, kl) { return BigInt(objects.get(bindingKey(bp, bl, kp, kl))?.bytes.length ?? -1); },
  akamata_r2_list_begin(bp, bl, pp, pl, cp, cl, limit) {
    assert.equal(decode(bp, bl), "FILES"); assert.equal(decode(cp, cl), "");
    return handle(new TextEncoder().encode(JSON.stringify([...objects].filter(([key]) => key.startsWith(decode(pp, pl))).slice(0, limit).map(([key, item]) => ({ key, size: item.bytes.length, etag: item.etag })))));
  },
  akamata_r2_list_len(id) { return handles.get(id).length; },
  akamata_r2_list_copy(id, ptr, len) { return copy(handles.get(id), ptr, len); },
  akamata_r2_list_close(id) { assert.ok(handles.delete(id)); },
};
imports.akamata_queue = { akamata_queue_send(bp, bl, mp, ml, pp, pl) {
  assert.equal(decode(bp, bl), "EVENTS");
  const meta = JSON.parse(decode(mp, ml));
  assert.equal(meta.protocol_version, 2); assert.equal(meta.event_type, "created");
  assert.equal(meta.event_id, "event-1"); assert.equal(meta.correlation_id, "request-1");
  assert.equal(meta.idempotency_key, "message:1"); assert.equal(meta.attempt, 2); assert.equal(meta.max_attempts, 7);
  assert.deepEqual(JSON.parse(decode(pp, pl)), { text: "hello" }); return 0;
} };
for (const item of WebAssembly.Module.imports(module)) {
  assert.equal(typeof imports[item.module]?.[item.name], "function", `unexpected external effect: ${item.module}.${item.name}`);
}
const { exports } = new WebAssembly.Instance(module, imports);
memory = exports.memory;
assert.equal(exports.run_database_adapter_contract(), 0);
assert.deepEqual(selectedBindings, ["REPORTS", "REPORTS", "DB", "REPORTS"]);
assert.equal(statements.size, 0, "D1 statement handle leak");
let warmedMemory;
for (let i = 0; i < 10; i++) {
  const result = exports.run_contract();
  const error = new TextDecoder().decode(new Uint8Array(exports.memory.buffer, exports.error_ptr(), exports.error_len()));
  assert.equal(result, 0, error);
  assert.equal(exports.run_platform_adapter_contract(), 0, decode(exports.error_ptr(), exports.error_len()));
  assert.equal(handles.size, 0, "R2 handle leak");
  assert.equal(objects.size, 0);
  if (i === 2) warmedMemory = exports.memory.buffer.byteLength;
}
assert.equal(exports.memory.buffer.byteLength, warmedMemory, "test providers/application leak WASM pages after warmup");
console.log("Workers WASM: shared routing, typed input/validation/errors, DB effects, storage, queue, realtime/event schema and capability contract passed (10 runs; test providers)");
