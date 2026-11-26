# SIMD evaluation baseline

- Date: 2026-11-25 (Asia/Tokyo).
- Fetched `origin/main`; both starting HEAD and fetched main:
  `107ad5dbd1ada61cd26314e09aac837b9ce8ee2e`.
- Starting working tree: clean, on `main`; evaluation branch:
  `perf/simd-evaluation`.
- Local Zig: 0.17.1 (`/Users/mimoc/.zvm/0.17.1/zig`). CI pins 0.17.0.
- Host: Darwin 27.0.0, ARM64, Apple M2 (T8112). CPU name verified with
  `sysctl -n machdep.cpu.brand_string` outside the sandbox.
- Native target uses `standardTargetOptions`; no forced AVX/NEON options.
- Workers target: wasm32-freestanding, baseline CPU, no explicit SIMD128.
- No `@Vector`, `std.simd`, or named SWAR implementation found in `src`.
- JSON escaping scans each byte but already writes ordinary runs in bulk;
  all bytes >= 0x80 are passed through, including invalid UTF-8.
- WebSocket decode allocates, copies, then unmasks one byte at a time.
- HTTP field-value and Multipart control checks have identical predicates.
- Form decode reserves input length but appends each output byte individually.
- std.mem scalar search already uses suggested vector widths and firstTrue;
  std.mem byte equality uses SIMD or word processing. Do not replace blindly.
- Native HTTP session/application session is shared by threaded/reactor adapters.
  Workers dispatch and actual module reachability are assessed separately.

Baseline commands and their outputs are retained in `raw/`. Timing performed
under local machine load is not portable performance evidence. Cross compilation
must never be interpreted as execution on the target.

The original competitive-micro logs and initial build timings are exploratory:
some collection overlapped other compilation/test activity. They are retained
but are not used for before/after improvement claims. Adoption decisions use
the isolated alternating kernel samples and independently restarted A/B HTTP
server measurements. Initial build RSS/time and later cached build RSS/time
are also not a controlled size/time comparison.
