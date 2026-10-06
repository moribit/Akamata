# Public developer journey audit

Baseline: `a7605ba8a66e0eef9aefe83e563761e8745b4e6c`, clean main at start,
Zig 0.17.0. The latest published tag/release was actually checked through Git
and GitHub Releases: v0.1.5, published 2026-10-03. This record distinguishes
historical evidence from current presentation claims.

## Positioning and proof

**A portable Zig backend framework for Native and Cloudflare Workers.**
Short explanation: ordinary Zig functions become typed APIs, with explicit
allocator and service ownership. Avoid “Run anywhere”: supported Native OSes
are Linux/macOS, Workers has platform limits, Windows is not certified.

| Strength | Evidence/source |
|---|---|
| Ordinary function, explicit typed binding and DTO validation | contract/handler.zig, dx_application_fixture, compile-fail suite |
| Response/error/Principal, shared OpenAPI and TS metadata | dx-test, Workers DX fixture, strict TypeScript generation tests |
| Portable DB/Storage/Queue/Realtime effects | portable application/provider contract fixtures, adapter suites |
| Explicit owner/lifecycle/environment/preflight | Portable Production Contract, provider cleanup tests, CLI capability/operations tests |
| In-process application tests and provider assertions | testing.Client, MemoryStore, QueueRecorder, documentation-test |
| Native performance | fresh public-presentation/threaded-main.json and environment.json |

No whole-framework zero-allocation claim, “fastest” ranking, complete platform
identity, Cloudflare certification or production-ready Reactor claim is made.
Bounded static matcher/trace/registry claims remain scoped to those components.

## Old PDF page decisions (both languages)

Every original page was extracted and rendered for visual inspection. Both PDFs
had eight pages. The HTML said Zig 0.17/v0.1.5 while PDFs still said Zig 0.16/v0.0.1.

| Old page | Decision | Reason/new destination |
|---:|---|---|
| 1 Hero | Update | Preserve green/amber ASCII branding, remove production-ready claim and feature list |
| 2 Three runtimes | Update | Container is Native process; simplify application/Native/Workers diagram |
| 3 Context Hello | Replace | Show compiled ordinary-function minimal source |
| 4 DB cards | Integrate | DB plus Storage/Queue/Realtime mapping on new pages 6/12 |
| 5 Observability timing | Remove from introduction | Unattributed numeric example, details remain in observability guide |
| 6 Building-block list | Integrate | Progressive disclosure and typed HTTP contract, no feature dump |
| 7 Install/scaffold | Replace | Minimal default, dev/test workflow, no automatic notes/D1 story |
| 8 Generic closing | Replace | Real Getting Started/Guides/GitHub links and version-aware startup |

## New story (same 13 pages in English/Japanese)

1. Akamata hero / portable Zig backend
2. Application and target choice
3. Ordinary-function code from compiled minimal fixture
4. Zig input/result types and explicit metadata to router/OpenAPI/client/tests
5. Progressive growth with advanced Context/provider escape hatches
6. Native/Workers provider mapping
7. Fresh Native Threaded numbers with full local measurement conditions
8. Shared edge application semantics with explicit target bindings
9. Real in-process test API and bounded testing owners
10. init/dev/test/check/deploy workflow
11. Requirement/provider/binding/owner/deployment validation
12. Native/Workers/Container matrix and platform differences
13. First commands and direct documentation/GitHub links

Native uses Threaded, SQLite/Turso, filesystem, jobs.Queue and native realtime.
Workers uses WASM/fetch, D1/Turso, R2, Queues and DO gateway ownership. Container
uses Native providers and needs a durability strategy for DB/files. Queue retry,
streaming and WebSocket transport ownership are not identical implementation
semantics. The reference apps and provider matrix explain their limits.

## Public surface corrections

- README strengths now lead with ordinary functions, typed contracts, portable
  services, tooling/testing and measured Threaded performance.
- Getting Started uses init/dev and the published v0.2.0 dependency; local
  checkout overrides are reserved for framework development. Install was exercised into an isolated temporary prefix.
- Tutorial/handbook are explicitly advanced App/Context/model guides and select
  `--template=notes`; they no longer describe notes as the minimal default.
- Deploy no longer claims automatic D1 creation/config rewrite. Production table
  DROP is removed as a troubleshooting shortcut. Creation responses are 201.
- Cloudflare guide distinguishes local Container build from platform publication,
  starts Workers with resource-free Hello, and links current platform documentation.
  Official sources reviewed: [Containers](https://developers.cloudflare.com/containers/)
  and [Wrangler configuration](https://developers.cloudflare.com/workers/wrangler/configuration/).
- Unsupported live D1 latency numbers and JSPI timing claims are removed. Old
  benchmark records retain truthful Zig 0.16 conditions with historical labels.
- Current pthread reference points to the Zig 0.17 Io audit instead of using a
  removed-0.16-type explanation as its only rationale.
- Existing examples keep their learning roles: compiled minimal, guestbook typed
  DB/validation, device_messaging portable owners, chat realtime/WS.

## Journey tests and PDF verification

The generated project lacked a `test` build step. This was the only functional
journey blocker fixed: Native application test step plus a socket-free Hello test.
Pinned-release and current-checkout scaffold tests now run it. The public journey
runner explicitly owns a temporary project, adds a real typed JSON route, then
executes CLI test/check, Workers ReleaseSafe build, dev HTTP 201 and bounded dev
shutdown. It never edits user projects or provisions remote resources.

```sh
zig build public-journey-test -Doptimize=ReleaseSafe
zig build documentation-test -Doptimize=ReleaseSafe
zig build documentation-test -Dbackend=workers -Doptimize=ReleaseSafe
python3 tests/documentation_links.py
node tools/docgen/build_slides.mjs
# Headless Chrome, existing HTML pipeline:
node tools/docgen/html_to_pdf.mjs tools/docgen/slides.html docs/en/slides.pdf
node tools/docgen/html_to_pdf.mjs tools/docgen/slides.ja.html docs/ja/slides.pdf
# In a venv with pypdf==6.19.0:
python tests/public_slides.py
pdftoppm -scale-to 1280 -png docs/en/slides.pdf /tmp/akamata-en
pdftoppm -scale-to 1280 -png docs/ja/slides.pdf /tmp/akamata-ja
```

Both decks have 13 nonblank 16:9 pages and five distinct valid URI targets.
Fonts are embedded with Unicode mapping, checked with pdffonts. All pages were
visually inspected; long minimal code, Japanese heading and workflow layout
were corrected before delivery. CI checks deterministic HTML, documentation
links, committed PDF structure/links and executable source examples. It cannot
replace visual inspection. QR codes were not needed.

## Release assessment

Policy in docs/en/releasing.md uses `0.x.0` for larger features/API changes.
v0.1.6 would understate new Typed Handler and portable contracts, removed Legacy
APIs, expanded Storage Error set, Principal safety, scaffold and deploy changes.
**v0.2.0 is the appropriate pre-1.0 minor feature/breaking release.** Zig 0.17
support already shipped in v0.1.5 and is retained, not newly invented here.
Release preparation, gate results, tag and final archive hash are recorded
separately in release notes/evidence. Never move an existing tag.

Cloudflare live tests were not executed and no production certification is
claimed. Existing policy does not require live resource creation for a 0.x
release. Offline test evidence remains labelled. Named-environment migration,
arbitrary custom glue behavioral proof and Reactor production remain fail-closed.

Recommended next public DX work: a reproducible application walkthrough with
explicit custom-glue smoke proof and opt-in live provider evidence, followed by
safe environment-aware migration resource selection. No new runtime, provider
engine or scheduler is needed for this presentation.
