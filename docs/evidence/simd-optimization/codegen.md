# Code generation

These are evaluated candidates. The final branch restores baseline HTTP/MIME
call sites; no explicit SIMD is enabled in the public library by this work.

Probe: `src/simd_codegen.zig`; reproducible commands in `implementation.md`.
Assembly is retained in `raw/*-fast.s` and `raw/aarch64-safe.s`. Probes use LLVM
and strip debug information. These are kernel probes, not whole-server profiles.

| Target | Observation | Executed on target? |
| --- | --- | --- |
| macOS AArch64 | NEON `ldr q`, `eor.16b`, `cmhi.16b`, `cmeq.16b`, `uminv.16b` | Yes, native candidate benchmarks |
| Linux AArch64 baseline | NEON comparisons, reduction and XOR | No; cross-build only |
| Linux x86-64 baseline | SSE `movups`, `xorps`; no AVX2 requirement | No; cross-build only |
| Linux x86-64 v3 | AVX-family output permitted by explicit v3 CPU | No; cross-build only |
| Wasm baseline | Explicit vectors lower to scalar operations; no v128 instructions | Yes, local Node probe |
| Wasm baseline + simd128 | `v128.load`, `v128.xor`, `v128.store`, lane comparisons | Yes, local Node probe |

The Linux assembly rows describe cross-compiled probes, not execution of those
exact probe objects. Separate native CI kernel runs on Linux x86-64 and ARM64
are retained under `raw/ci-final/`; they provide real execution measurements.

The scalar mask loop does not necessarily auto-vectorize: on this macOS AArch64
probe, its repeated mask indexing remains unrolled byte loads/stores. Explicit
vector processing emits native vector XOR. The u64 candidate emits word XOR;
this distinction is measured separately from copy fusion.

The standard-library `std.mem.indexOfScalar` probe already generates vector
comparisons and reductions. Source inspected under Zig 0.17.1:
`lib/std/mem.zig` (`findScalarPos`, `eqlBytes`, `findPos`) and `lib/std/simd.zig`
(`suggestVectorLength`). The latter selects NEON, x86 feature-dependent widths,
and Wasm128 only when the target CPU features contain simd128.

The actual candidate Native server was also disassembled with Homebrew LLVM
objdump. `raw/production-field-neon.s` shows `http.parser.validFieldValue` using
bounded `ldr q`, three byte comparisons with constants 32, TAB and DEL,
`bic`/`orr`, and `umaxv`. In the original server that check was inlined into
`http.session.Session.next`; its full disassembly is retained in
`raw/baseline-field-native.s`. Existing standard-library vector searches in the
original server must not be attributed to this optimization.

Current application Workers target in `build.zig` uses wasm32-freestanding
without explicitly adding simd128. No application CPU feature is changed by
these experiments. The existing Workers HTTP ABI passes serialized HTTP bytes
through `serve.zig:serveWorkers` to `parser.parseRequest`; parser improvements
can therefore be reachable in Workers. Native WebSocket mask processing is
not counted as Workers performance improvement; the JS/DO realtime path owns
WebSocket events there.

Both standalone Wasm feature configurations loaded and executed successfully in
local Node v24.19.0. Exact scan/mask output checks include all 256 bytes,
unaligned input and reads ending exactly at linear-memory end. See
`raw/wasm-probe-local.json` (1,232 timed rows including warmups). This host probe
is neither workerd nor a Cloudflare deployment. Its measured call times include
the JS/Wasm boundary; no Workers CPU-time claim is derived from them.

Standalone stripped probe sizes: baseline features 3,418 bytes; SIMD128 3,163
bytes (-255 bytes). These are probe sizes, not the application Wasm size delta.

ReleaseSafe standalone probes are 7,735 / 7,476 bytes (-259). Both optimization
modes also passed local workerd checks (116,359 per feature configuration),
subject to the temporary compatibility-date limitation in `raw/provenance.md`.
Final application Wasm is 1,172,873 bytes Fast (+384 from baseline) and
1,084,895 Safe (+388); its default target features remain unchanged. Actual
application ABI/response checks are retained in `raw/workers-final-*.json`.
