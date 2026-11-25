// Standalone local Node/Wasm kernel probe. Never live Workers CPU evidence.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const paths = process.argv.slice(2);
assert.equal(paths.length, 2, 'usage: node simd-probe.mjs SCALAR.wasm SIMD.wasm');
const modules = paths.map(path => {
  const bytes = readFileSync(path);
  const started = performance.now();
  const instance = new WebAssembly.Instance(new WebAssembly.Module(bytes), {});
  const compileAndInstantiateMs = performance.now() - started;
  const exports = instance.exports;
  const base = exports.memory.buffer.byteLength;
  exports.memory.grow(8);
  return {exports, bytes: bytes.length, compileAndInstantiateMs, base};
});
const special = (kind, c) => kind === 'json' ? c < 32 || c === 34 || c === 92 : c < 32 && c !== 9 || c === 127;
for (const {exports: e, base} of modules) {
  const memory = new Uint8Array(e.memory.buffer);
  // End of linear memory acts as an actual read boundary for every tail size.
  for (let len = 0; len <= 257; len++) {
    const p = memory.length - len;
    memory.fill(120, p);
    for (const kind of ['json', 'field']) {
      assert.equal(e[`${kind}_scalar`](p, len), len);
      assert.equal(e[`${kind}_vector`](p, len), len);
    }
    for (const mode of ['byte', 'word', 'vector']) {
      e[`mask_${mode}`](base, p, len);
      for (let i = 0; i < len; i++) assert.equal(memory[base + i], memory[p + i] ^ [17, 99, 128, 255][i & 3]);
    }
  }
  for (const len of [1, 7, 8, 15, 16, 17, 31, 32, 33, 63, 64, 65, 128, 256, 512, 1024]) {
    for (let alignment = 0; alignment < 32; alignment++) {
      const p = base + alignment;
      memory.fill(120, p, p + len);
      for (let byte = 0; byte < 256; byte++) {
        for (const pos of [0, len >> 1, len - 1]) {
          memory[p + pos] = byte;
          for (const kind of ['json', 'field']) {
            const expected = special(kind, byte) ? pos : len;
            assert.equal(e[`${kind}_scalar`](p, len), expected);
            assert.equal(e[`${kind}_vector`](p, len), expected);
          }
          memory[p + pos] = 120;
        }
      }
    }
  }
}
const runs = [];
for (const size of [0, 8, 16, 32, 64, 1024, 4096, 65536]) {
  for (let round = 0; round <= 10; round++) {
    for (const index of round % 2 ? [1, 0] : [0, 1]) {
      const {exports: e, base} = modules[index];
      const p = base + 1, dst = base + 65569;
      new Uint8Array(e.memory.buffer).fill(120, p, p + size);
      for (const operation of ['json_scalar', 'json_vector', 'field_scalar', 'field_vector', 'mask_byte', 'mask_word', 'mask_vector']) {
        let iterations = 0, checksum = 0;
        const start = performance.now();
        do {
          for (let j = 0; j < 1024; j++) {
            if (operation.startsWith('mask_')) {
              e[operation](dst, p, size);
              if (size) checksum += new Uint8Array(e.memory.buffer)[dst + size - 1];
            } else checksum += e[operation](p, size);
          }
          iterations += 1024;
        } while (performance.now() - start < 10);
        runs.push({module: index === 0 ? 'baseline-features' : 'simd128', operation, size, round, iterations, elapsed_ns: (performance.now() - start) * 1e6, checksum});
      }
    }
  }
}
console.log(JSON.stringify({scope: 'local Node/Wasm; includes JS/Wasm call overhead; not Cloudflare CPU', node: process.version, architecture: process.arch, modules: modules.map(({bytes, compileAndInstantiateMs}) => ({bytes, compileAndInstantiateMs})), correctness: 'passed', runs}));
