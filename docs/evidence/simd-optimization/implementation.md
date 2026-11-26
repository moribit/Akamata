# Candidate design and reproduction

Final decision: experiments only. After measurement, commit `6c1280f` restored
the original HTTP/MIME call sites because small-input rejection and tail-latency
criteria were not met. The candidate descriptions below document the evaluated
implementation, not a currently adopted public-library optimization.

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
  A fourth control reserves the same capacity and writes directly into the
  ArrayList backing slice, isolating per-byte ArrayList overhead.
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

The `json-utf8` fixture repeats the bytes of `東京🙂` and truncates to each exact
input length. Lengths 16, 256 and 65,536 end on complete code points and include
both Japanese and emoji; other lengths can intentionally end inside a code
point. Such tails test the existing opaque-byte contract, not UTF-8 validation.
The existing competitive-micro nested-object fixture also uses valid Japanese.

## HTTP/MIME application candidate

`src/internal/byte_ops.zig:containsFieldControl` is shared by HTTP field-value
validation and Multipart header-value validation. It uses 16-byte unsigned
comparisons and an OR reduction only when `std.simd.suggestVectorLength(u8)`
reports native SIMD support. Short tails and unsupported targets use the exact
original scalar predicate. Other HTTP/MIME validation/search logic is untouched.

Full-server comparison uses the original compiled main binaries and candidate
binaries with identical optimization settings. `akamata-tests simd-http`
alternates AB/BA across ten independent server pairs, each with a 1s warmup and
5s measured load, eight keep-alive connections, the existing `/json` endpoint,
and Cookie value lengths 0 and 4,096. It runs Threaded and Reactor in ReleaseFast
and ReleaseSafe, records complete oha request/latency/error reports and a
post-load RSS snapshot, verifies the exact response before load, and requires
all measured requests to return HTTP 200 with no errors. Network and client
costs are present here, unlike in the kernel benchmark. SQLite is initialized
for fixture parity, but the timed endpoint performs no DB work or TLS.

```sh
# Baseline binaries were copied before application changes; build them from
# baseline 107ad5d in a separate worktree with the same compiler/CPU settings.
zig build competitive-bench ci-runner -Doptimize=ReleaseFast -p /tmp/akamata-final-fast
zig build competitive-bench -Doptimize=ReleaseSafe -p /tmp/akamata-final-safe
/tmp/akamata-final-fast/bin/akamata-tests simd-http /tmp/akamata-baseline-server-fast /tmp/akamata-final-fast/bin/competitive-akamata /tmp/akamata-baseline-server-safe /tmp/akamata-final-safe/bin/competitive-akamata docs/evidence/simd-optimization/raw/new-http
/tmp/akamata-final-fast/bin/akamata-tests simd-http-summary docs/evidence/simd-optimization/raw/new-http

zig build simd-followup-build -Doptimize=ReleaseFast -p /tmp/akamata-followup-fast
zig build simd-followup-build -Doptimize=ReleaseSafe -p /tmp/akamata-followup-safe
/tmp/akamata-final-fast/bin/akamata-tests simd /tmp/akamata-followup-fast/bin/simd-followup /tmp/akamata-followup-safe/bin/simd-followup docs/evidence/simd-optimization/raw/new-followup 600
```

`http-summary.csv` reports median throughput/latency/RSS across ten independent
processes and a paired mean throughput-gain 95% Student-t interval (9 degrees of
freedom). This interval describes local paired samples, not all deployments.
RSS snapshots are explicitly not peak RSS or allocated-byte accounting. Final
collection additionally uses OS wait4 process usage on graceful server exit,
recording peak RSS and user+system CPU in `.process.json`. CPU/request includes
all successful preflight, warmup and measured requests. This excludes oha CPU.
Failed load output is preserved with unique `.failed-*` names. Completion markers
are written only after all validations succeed; see the final results for the
two failed baseline attempts and complete-pair repetition policy.

The authoritative local final datasets are `raw/followup-v3/` and
`raw/final-http/`; older directory names containing "final" are intermediate
iterations (see `raw/provenance.md`). Last evaluated candidate source is
`09a18f9`; restored application source is `6c1280f`.
Dispatching CI with `simd_evidence=true` runs both kernel matrices, both modes,
on Linux x86-64, Linux ARM64 and macOS and uploads all samples. Mandatory CI
does not use absolute performance gates.
