# Candidate design and reproduction

Experiments live in `src/simd_candidates.zig`, isolated from the public library.
`src/simd_evaluation.zig` compares the candidates and the production JSON emitter.
`tests/runner/simd.zig` extends the existing Zig harness; no Python orchestrator,
new dependency, runtime CPU dispatch, or public SIMD setting is introduced.

## Comparisons

- JSON: the production emitter versus a 16-byte special-character scan followed
  by exactly the existing escape spelling. Ordinary bytes are copied in runs.
  Both emit surrounding quotes. Invalid UTF-8 remains opaque bytes.
- Field validation: scalar versus 16-byte scanning of `(c < 32 && c != TAB) ||
  c == 127`. The same predicate occurs in Multipart. Finding a forbidden byte
  and returning `length` when none exists is the internal experimental interface.
- WebSocket: byte, u32, u64, four-byte unrolled scalar, vector16, vector32.
  Each has a copy-then-XOR and fused-copy-XOR version. Word loads use byte-array
  bitcasts, so unaligned access and endian representation preserve byte order.
  The mask phase is `(offset + index) & 3`; tail accesses remain within slices.
  Vector32 on ARM is an experiment compiled as multiple native vectors, not a
  claim of a 256-bit ARM instruction or an AVX2 requirement.
- Form: original byte-appending loop, scalar special-character search plus
  appendSlice, and vector search plus appendSlice. The latter two isolate the
  benefits of bulk copying/ArrayList operation reduction from SIMD searching.
  Initial capacity and toOwnedSlice behavior match the existing implementation.
- Boundary search: retain std.mem; its existing vector search is inspected in
  the code-generation probe. No unmeasured replacement is adopted.

Explicit vector candidates are callable on non-SIMD targets for code-generation
experiments (the compiler lowers them to scalar instructions). They are not a
production fallback selection policy. Any adopted implementation must use
compile-time target feature selection, with the original scalar path available.

## Reproduction

```sh
zig build competitive-micro-build competitive-bench http-allocation-profile portable-bench -Doptimize=ReleaseFast
zig-out/bin/competitive-micro
zig build competitive-micro-build competitive-bench http-allocation-profile portable-bench -Doptimize=ReleaseSafe
zig-out/bin/competitive-micro
zig build competitive-worker-build -Dbackend=workers -Doptimize=ReleaseSafe
node benchmark/competitive/workers/wasm-host.mjs zig-out/bin/competitive-worker.wasm /tmp/workers-host.json

zig build simd-evaluation-test -Doptimize=ReleaseSafe
zig build simd-evaluation-build ci-runner -Doptimize=ReleaseFast -p /tmp/akamata-simd-fast-install
zig build simd-evaluation-build -Doptimize=ReleaseSafe -p /tmp/akamata-simd-safe-install
/tmp/akamata-simd-fast-install/bin/akamata-tests simd /tmp/akamata-simd-fast-install/bin/simd-evaluation /tmp/akamata-simd-safe-install/bin/simd-evaluation docs/evidence/simd-optimization/raw

zig build simd-codegen -Doptimize=ReleaseFast -p /tmp/akamata-codegen-aarch64
zig build simd-codegen -Doptimize=ReleaseFast -Dtarget=x86_64-linux-musl -Dcpu=baseline -p /tmp/akamata-codegen-x86-baseline
zig build simd-codegen -Doptimize=ReleaseFast -Dtarget=x86_64-linux-musl -Dcpu=x86_64_v3 -p /tmp/akamata-codegen-x86-avx2
zig build simd-codegen -Doptimize=ReleaseFast -Dtarget=aarch64-linux-musl -Dcpu=baseline -p /tmp/akamata-codegen-linux-aarch64
zig build simd-codegen -Doptimize=ReleaseFast -Dtarget=wasm32-freestanding -Dcpu=baseline -p /tmp/akamata-codegen-wasm-scalar
zig build simd-codegen -Doptimize=ReleaseFast -Dtarget=wasm32-freestanding -Dcpu=baseline+simd128 -p /tmp/akamata-codegen-wasm-simd
```

The harness runs 10 independent processes per optimization mode. Each process
warms every case (round 0), retains round 1, alternates candidate order between
processes, and runs each timed batch for at least 10ms. Iteration counts grow in
batches; report ns/op from actual count, not requested initial count. Raw logs
include warmups and checksums. The summary excludes warmups, checks normalized
checksums across implementations and checks the complete 800-case matrix for
each process. It reports the median and minimum/maximum of 10 process samples.
These are batch timings, not individual request P95/P99 latency distributions.
Existing complete raw files are reused on resume; use a fresh output directory
when changing binaries or measurement conditions.
