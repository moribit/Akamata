// Copy this file and the two probe Wasm files into a temporary local project.
// No production bindings, remote resources or deployment are required.
import scalar from './scalar.wasm';
import simd from './simd.wasm';

export default {
  fetch() {
    const results = [scalar, simd].map((module, index) => {
      const e = new WebAssembly.Instance(module, {}).exports;
      const base = e.memory.buffer.byteLength;
      e.memory.grow(8);
      const bytes = new Uint8Array(e.memory.buffer);
      let checks = 0;
      const expect = (a, b) => { if (a !== b) throw new Error(`Wasm differential mismatch: ${a} != ${b}`); checks++; };
      for (let len = 0; len <= 257; len++) {
        const p = bytes.length - len;
        bytes.fill(120, p);
        expect(e.json_vector(p, len), len);
        expect(e.field_vector(p, len), len);
        for (const operation of ['mask_byte', 'mask_word', 'mask_vector']) {
          e[operation](base, p, len);
          for (let i = 0; i < len; i++) expect(bytes[base + i], bytes[p + i] ^ [17, 99, 128, 255][i & 3]);
        }
      }
      for (let alignment = 0; alignment < 32; alignment++) {
        const p = base + alignment;
        bytes.fill(120, p, p + 65);
        for (let c = 0; c < 256; c++) {
          bytes[p + 32] = c;
          expect(e.json_vector(p, 65), c < 32 || c === 34 || c === 92 ? 32 : 65);
          expect(e.field_vector(p, 65), c < 32 && c !== 9 || c === 127 ? 32 : 65);
        }
      }
      return {features: index ? 'simd128' : 'baseline', checks, passed: true};
    });
    return Response.json({scope: 'local workerd; not live Cloudflare performance', results});
  },
};
