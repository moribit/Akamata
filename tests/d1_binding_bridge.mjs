import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

// Execute the actual managed bridge source, not a second implementation. JSPI
// is deliberately replaced by an identity wrapper: this tests binding/statement
// ownership and async D1 behavior independently of the WASM ABI fixture.
for (const path of ["tools/akamata/src/templates/worker_index.mjs.tpl", "deploy/worker/index.mjs"]) {
  const source = readFileSync(path, "utf8");
  const start = source.indexOf("  async function executeD1(");
  const end = source.indexOf("  // --- akamata_http:", start);
  assert.ok(start >= 0 && end > start, `${path}: managed D1 bridge not found`);
  const strings = ["REPORTS", "SELECT ?", "INSERT INTO effects DEFAULT VALUES", "MISSING"];
  const calls = [];
  const database = name => ({
    prepare(sql) {
      calls.push([name, sql]);
      return {
        bind(value) { assert.equal(value, 42); return this; },
        async raw() { return [["value"], [42]]; },
        async run() { return { meta: { changes: 1, last_row_id: 7 } }; },
      };
    },
  });
  const statements = new Map();
  let next = 1;
  const create = new Function("env", "readString", "readBytes", "writeBytes", "suspending", "d1stmts", "stmtRegistryAlloc",
    `let lastD1Meta = { changes: 0, lastRowId: -1 };\n${source.slice(start, end)}\nreturn d1Bridge;`);
  const bridge = create({ DB: database("DB"), REPORTS: database("REPORTS") }, ptr => strings[ptr],
    () => new Uint8Array(), () => {}, fn => fn, statements, entry => { const id = next++; statements.set(id, entry); return id; });
  const handle = bridge.d1_prepare_named(0, 7, 1, 8);
  assert.ok(handle > 0);
  assert.equal(bridge.d1_bind_int64(handle, 1, 42n), 0);
  assert.equal(await bridge.d1_run(handle), 1);
  assert.equal(bridge.d1_step(handle), 1);
  assert.equal(bridge.d1_column_int64(handle, 0), 42n);
  bridge.d1_finalize(handle);
  assert.equal(statements.size, 0);
  assert.equal(await bridge.d1_exec_named(0, 7, 2, 34), 0);
  assert.equal(await bridge.d1_exec(2, 34), 0);
  assert.equal(bridge.d1_affected_rows(), 1n);
  assert.equal(bridge.d1_last_insert_id(), 7n);
  assert.equal(bridge.d1_prepare_named(3, 7, 1, 8), -2);
  assert.equal(await bridge.d1_exec_named(3, 7, 2, 34), -2);
  assert.deepEqual(calls.map(([name]) => name), ["REPORTS", "REPORTS", "DB"]);
}
console.log("managed D1 bridge: named/default bindings, async statements, metadata and missing binding passed");
