import assert from "node:assert/strict";
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { spawnSync } from "node:child_process";

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
  akamata_r2_list_page_begin(bp, bl, pp, pl, cp, cl, limit) {
    assert.equal(decode(bp, bl), "FILES");
    const token = decode(cp, cl);
    const offset = token ? Number(token.slice(5)) : 0;
    if (token && !/^page:[0-9]+$/.test(token)) return -6;
    const all = [...objects].filter(([key]) => key.startsWith(decode(pp, pl))).sort(([a], [b]) => a.localeCompare(b));
    const selected = all.slice(offset, offset + limit);
    return handle(new TextEncoder().encode(JSON.stringify({ objects: selected.map(([key, item]) => ({ key, size: item.bytes.length, etag: item.etag, content_type: item.type })), cursor: offset + limit < all.length ? `page:${offset + limit}` : null })));
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
imports.akamata_realtime = { akamata_realtime_operation(bp, bl, rp, rl, ap, al) {
  assert.equal(decode(bp, bl), "ROOMS"); assert.equal(decode(rp, rl), "room-1");
  const action = JSON.parse(decode(ap, al));
  if (action.kind === "presence") return (2n << 32n) | 1n;
  if (action.kind === "broadcast") return 2n;
  assert.equal(action.connection, "18446744073709551615");
  return 1n;
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
  assert.equal(exports.run_developer_contract(), 0, decode(exports.error_ptr(), exports.error_len()));
  const result = exports.run_contract();
  const error = new TextDecoder().decode(new Uint8Array(exports.memory.buffer, exports.error_ptr(), exports.error_len()));
  assert.equal(result, 0, error);
  assert.equal(exports.run_platform_adapter_contract(), 0, decode(exports.error_ptr(), exports.error_len()));
  assert.equal(handles.size, 0, "R2 handle leak");
  assert.equal(objects.size, 0);
  if (i === 2) warmedMemory = exports.memory.buffer.byteLength;
}
assert.equal(exports.memory.buffer.byteLength, warmedMemory, "test providers/application leak WASM pages after warmup");
assert.equal(exports.prepare_developer_client(), 0, decode(exports.error_ptr(), exports.error_len()));
const developerSource = decode(exports.developer_client_ptr(), exports.developer_client_len());
exports.release_developer_client();
if (process.env.AKAMATA_DX_TSC) {
  const directory = mkdtempSync(join(tmpdir(), "akamata-dx-client-"));
  try {
    writeFileSync(join(directory, "client.ts"), developerSource);
    writeFileSync(join(directory, "usage.ts"), `
import { createClient, is_getUsersByIdError } from "./client";
const api = createClient({ baseUrl: "https://fixture.test" });
const user: Promise<{ id: number; name: string }> = api.getUsersById(42, { name: "Bob" });
const hello: Promise<string> = api.get();
api.postUsers({ name: "Alice" });
// @ts-expect-error: path id is numeric
api.getUsersById("bad", {});
// @ts-expect-error: request body requires name
api.postUsers({});
const unknownError: unknown = null;
if (is_getUsersByIdError(unknownError)) {
  const status: 404 = unknownError.status;
  const discriminator: "NotFound" = unknownError.body.error_kind;
}
`);
    const checked = spawnSync(process.execPath, [process.env.AKAMATA_DX_TSC, "--noEmit", "--strict", "--target", "ES2022", "--module", "ESNext", "--moduleResolution", "bundler", "--lib", "ES2022,DOM", join(directory, "usage.ts")], { encoding: "utf8", timeout: 30000 });
    assert.equal(checked.status, 0, checked.stdout + checked.stderr + (checked.error?.message ?? ""));
    console.log("generated DX client: TypeScript strict static checks and expected type errors passed");
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}
// Syntax transformation is additional evidence when supported by the host
// Node version, not a substitute for TypeScript's static type checker.
const { stripTypeScriptTypes } = await import("node:module");
if (typeof stripTypeScriptTypes === "function") {
  const source = stripTypeScriptTypes(developerSource, { mode: "transform" });
  const generated = await import(`data:text/javascript;base64,${Buffer.from(source).toString("base64")}`);
  const api = generated.createClient({ baseUrl: "https://fixture.test", fetch: async url => {
    const request = new URL(url);
    if (request.pathname === "/") return new Response("Hello, Akamata!");
    if (request.pathname === "/users/0") return new Response(JSON.stringify({ error_kind: "NotFound" }), { status: 404 });
    assert.equal(request.searchParams.get("name"), "Bob");
    return new Response(JSON.stringify({ id: 42, name: "Bob" }));
  } });
  assert.equal(await api.get(), "Hello, Akamata!");
  assert.deepEqual(await api.getUsersById(42, { name: "Bob" }), { id: 42, name: "Bob" });
  await assert.rejects(api.getUsersById(0), error => generated.is_getUsersByIdError(error) && error.status === 404 && error.body.error_kind === "NotFound");
  assert.equal(generated.is_getUsersByIdError(new Error("unrelated")), false);
  console.log("generated DX client: TypeScript syntax transform and mocked HTTP text/query/error semantics passed");
} else {
  console.log("generated DX client syntax transform skipped: host Node lacks stripTypeScriptTypes");
}
console.log("Workers WASM: shared routing, typed input/validation/errors, DB effects, storage, queue, realtime/event schema and capability contract passed (10 runs; test providers)");
