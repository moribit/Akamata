# Correctness and safety

Final adoption decision: no runtime candidate is enabled. Commit `6c1280f`
restored HTTP/MIME source to baseline; the private helper remains testable as
an experiment. The semantic/candidate validation below describes the evaluated
source `09a18f9`, not an adopted production replacement.

No public API, ABI, error enum, output format or allocation policy is changed by
the HTTP/MIME candidate. Only the existing field-value forbidden-byte predicate
is moved to a private helper. CR, LF, NUL and DEL remain forbidden; TAB and bytes
>= 0x80 remain permitted. Request framing, target validation, Content-Length,
Transfer-Encoding and Host handling are unchanged.

## Differential tests

`zig build simd-evaluation-test -Doptimize=ReleaseSafe` and ReleaseFast both
passed 10/10 tests on the local Apple M2. This includes imported JSON/reflection
tests, in addition to the following explicit candidate checks:

- Scan predicates: all 256 byte values, every position in lengths 0..129,
  32 input alignments, and empty input.
- Production HTTP/MIME helper: exhaustive scalar comparison over the same
  byte/position/length/alignment space.
- Mask kernels: six implementations, copy and fused variants, four mask
  phases, lengths 0..257, 32 unaligned source/destination arrangements; original
  input compared after all transformations.
- JSON: lengths 0..513 with arbitrary byte values (including invalid UTF-8),
  byte equality between scalar, vector and actual production serialization,
  and propagation of `WriteFailed` from a capacity-zero fixed Writer.
- Form: 10,000 deterministic random inputs, differential valid output/error
  checks for four implementations, incomplete/invalid escapes and initial
  allocation failure. Arena cleanup is exercised with the testing allocator.
- POSIX guard pages: mmap two pages, protect the second with PROT_NONE, place
  source and destination ends directly against it, and exercise lengths 0..257
  through all scan/mask implementations, production field validation and JSON.
  Every vector read/write is bounded; no permitted padding is assumed.

The standalone local Node/Wasm probe also checks all 256 bytes, unaligned
inputs, exact scan and masking results and tails at linear-memory end, with
SIMD128 enabled and disabled. It passed in both feature configurations.

## Existing contracts

The pre-candidate ReleaseSafe regression command is retained in
`raw/regression-safe.log`: 59/59 build steps succeeded, 217 tests passed and one
was skipped. Transport contracts passed 136/136 cases across Threaded, kqueue,
sharded and incremental modes. It covered:

```sh
zig build test compile-fail-test documentation-test portable-application-test workers-realtime-test workers-wasm-dispatch-test transport-contract-test runtime-session-test -Doptimize=ReleaseSafe -Dtest-layout=grouped --summary all
```

Candidate regressions and the unchanged Linux/macOS sanitizer suites are also
run through the existing CI workflow. Final job states and tested source SHA
are retained separately in `raw/`; the pre-candidate verdict above must not be
mistaken for the candidate CI verdict.

Final application source `09a18f9d8fd6362715b6863964af3373615ff678` passed
[CI: 26/26 jobs](https://github.com/moribit/Akamata/actions/runs/45646492481)
including native kernel execution on Linux x86-64, Linux ARM64 and macOS, and
[Linux/macOS TSan: 2/2 jobs](https://github.com/moribit/Akamata/actions/runs/45646495583).
The later failure-logging-only collector commit `9d12de4` also passed
[mandatory CI](https://github.com/moribit/Akamata/actions/runs/45743683827).
No shared-CI absolute timing threshold was added.

## Limits

Masking and Form candidates are experiments, not replacements of their public
decoders. Their kernel tests do not establish every frame/form API allocation
failure contract; these replacements are not adopted. No custom JSON parser is
introduced. CPU feature selection is compile-time only: x86 baseline uses
supported SSE2, NEON is used when available, and absent SIMD capability falls
back to the original scalar field predicate. No AVX2 runtime dispatch exists.
