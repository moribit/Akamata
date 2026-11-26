# Measurement provenance

- Baseline application source: `107ad5dbd1ada61cd26314e09aac837b9ce8ee2e`.
- Initial application candidate: `487561e506102a1b928eea2a282da1b8c4bc5f22`.
- Intermediate helper: `45081e0` (adds empty/single-byte fast returns).
- Final application helper: `09a18f9d8fd6362715b6863964af3373615ff678` (bounded suffix traversal).
- Failure-diagnostic collector: `9d12de4ec18e529c0936d5c3631a400d29469fd4`; application code unchanged.
- Final decision: `6c1280fa839d73035fa2af893b5402bbb88346c8` restores baseline HTTP/MIME source. No runtime candidate is adopted. All "final" measurements below refer to the last evaluated candidate, not this restored implementation.
- Local compiler: Zig 0.17.1; CI compiler: Zig 0.17.0.

| Files/directory | Scope |
| --- | --- |
| `baseline-build-fast.log`, `baseline-micro-*.log` | Original stock benchmark output; exploratory timing, not used for adoption claims |
| root `fast-*.jsonl`, `safe-*.jsonl`, `summary-*.csv` | First kernel matrix: 800 retained cases per independent process; JSON, scanning, masks, three Form variants |
| `followup/` | Initial exact application predicate, and four Form variants (includes direct scalar output); 480 cases per process; detects empty/1-byte setup regression |
| `pilot-final-fast.log` | Warmup plus one exploratory final-helper process; not included in final statistics |
| `followup-final/` | Intermediate helper, adds sizes 2..6, four Form variants; 600 cases per independent process; historical directory name |
| `followup-v3/` | Authoritative final exact helper, 600 cases per independent process |
| root `http-*.json`, `.rss`, `http-summary.csv` | Initial helper application E2E, 160 independent server runs; retained to document the iteration |
| `final-http/` | Final helper application E2E; authoritative application acceptance dataset |
| `linux-x86-64/`, `macos-ci/` | Initial CI native execution: complete raw data, hardware/OS and summaries; source `487561e` |
| `ci-d3/` | Intermediate helper, all three CI OS/CPU environments, both modes, root 800-case and exact 600-case matrices |
| `ci-final/` | Last evaluated helper `09a18f9`, Linux EPYC x86-64, Linux Neoverse-N2 ARM64, macOS M1 Virtual; complete ten-process matrices in both modes |
| `ci-metadata/` | GitHub run/job/artifact metadata with tested source SHAs; artifact URLs are GitHub API endpoints, not expiring signed download URLs |
| `portable/` | Ten alternating baseline/candidate processes per mode; identical checksum/mode instrumentation; unchanged-path control |
| `workers-baseline-*.json`, `workers-candidate-*.json` | Existing seven-case exact-body Workers ABI host checks; first-call times are not performance evidence |
| `wasm-probe-local.json` | Local Node standalone kernels with and without SIMD128; JS boundary included |
| `workerd-probe.json`, `local-workerd-config.jsonc` | Local workerd correctness only; both configurations passed 116,359 checks |
| `*-fast.s`, `aarch64-safe.s` | Target-specific instruction probes; cross-builds are not execution evidence |
| `production-field-neon.s`, `baseline-field-native.s` | Initial actual candidate helper and original inlined Native session disassembly |

The `.jsonl` kernel files retain the original `SIMD ` log prefix on each line;
the Zig collector strips it when parsing. Summaries exclude round 0, require
ten independent processes per group, check the complete matrix count and
require matching per-operation checksums across implementations. CSV time
reduction is relative to scalar/byte within each workload. In particular,
`mask-fused` uses **fused byte XOR** as its reference; total improvement against
the original copy-then-byte-XOR requires a separate cross-workload comparison.

Local workerd used installed Wrangler 4.120.0. Its bundled runtime supports
compatibility dates only through 2026-08-08, so the probe temporarily uses that
date. The application's 2026-08-17 setting was not changed. The initial attempt
at the application's date failed before execution. This limits compatibility
claims about the installed runtime; it does not establish live Cloudflare
behavior. No dependencies were installed or upgraded and no deployment ran.
