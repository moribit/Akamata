# Code generation

Probe: `src/simd_codegen.zig`; reproducible commands in `implementation.md`.
Assembly is retained in `raw/*-fast.s` and `raw/aarch64-safe.s`. Probes use LLVM
and strip debug information. These are kernel probes, not whole-server profiles.

| Target | Observation | Executed on target? |
| --- | --- | --- |
| macOS AArch64 | NEON `ldr q`, `eor.16b`, `cmhi.16b`, `cmeq.16b`, `uminv.16b` | Yes, native candidate benchmarks |
| Linux AArch64 baseline | NEON comparisons, reduction and XOR | No; cross-build only |
| Linux x86-64 baseline | SSE `movups`, `xorps`; no AVX2 requirement | No; cross-build only |
| Linux x86-64 v3 | AVX-family output permitted by explicit v3 CPU | No; cross-build only |
| Wasm baseline | Explicit vectors lower to scalar operations; no v128 instructions | Codegen only |
| Wasm baseline + simd128 | `v128.load`, `v128.xor`, `v128.store`, lane comparisons | Codegen only pending local runtime check |

The scalar mask loop does not necessarily auto-vectorize: on this macOS AArch64
probe, its repeated mask indexing remains unrolled byte loads/stores. Explicit
vector processing emits native vector XOR. The u64 candidate emits word XOR;
this distinction is measured separately from copy fusion.

The standard-library `std.mem.indexOfScalar` probe already generates vector
comparisons and reductions. Source inspected under Zig 0.17.1:
`lib/std/mem.zig` (`findScalarPos`, `eqlBytes`, `findPos`) and `lib/std/simd.zig`
(`suggestVectorLength`). The latter selects NEON, x86 feature-dependent widths,
and Wasm128 only when the target CPU features contain simd128.

Current application Workers target in `build.zig` uses wasm32-freestanding
without explicitly adding simd128. No application CPU feature is changed by
these experiments. The existing Workers HTTP ABI passes serialized HTTP bytes
through `serve.zig:serveWorkers` to `parser.parseRequest`; parser improvements
can therefore be reachable in Workers. Native WebSocket mask processing is
not counted as Workers performance improvement; the JS/DO realtime path owns
WebSocket events there.
