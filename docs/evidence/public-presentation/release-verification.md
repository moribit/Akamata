# v0.2.0 public release verification

## Baseline and decision

Started from clean `a7605ba8a66e0eef9aefe83e563761e8745b4e6c`.
Release/tag candidate: `ba579098f40c62fc2562ce6afd309a642db656fe`.
Version policy selects 0.x.0 for substantial features/API changes. v0.2.0
therefore covers Typed Handler, portable application/production contracts and
pre-1.0 compatibility changes; v0.1.6 would understate the scope.

## Successful remote gates

- [Full Linux/macOS CI](https://github.com/moribit/Akamata/actions/runs/37494605804): all jobs successful, including Native/Workers examples, ReleaseSafe, OpenSSL,
  Threaded/kqueue/epoll Contracts, stress/fault/isolation/session, generated
  TypeScript, documentation, CLI scaffold/update/sync, public journey and Container.
- [Linux/macOS TSan](https://github.com/moribit/Akamata/actions/runs/37494605787): both successful.
- [Release binaries](https://github.com/moribit/Akamata/actions/runs/37497028261): all four Linux/macOS architecture builds successful.

The immutable tag points to the verified candidate. Main's subsequent commit
updates only the published dependency pin and documentation/release references.
Its local gates include actual v0.2.0 archive scaffold builds, application tests,
Native HTTP/shutdown, Workers ReleaseSafe and CLI public journey.

## Archive and installation

URL: https://github.com/moribit/Akamata/archive/refs/tags/v0.2.0.tar.gz

Zig package hash: `akamata-0.2.0-uJIoI5q4OgFWiDgjeemHhRKrz22T9j6WdfVIWxIPfpUt`.

The tag's CLI bootstrap pins v0.1.5 because its own archive hash cannot be
embedded recursively. Main pins the exact v0.2.0 archive. Users of the tagged
CLI should run `akamata update --to=v0.2.0` after init before copying typed API
examples. Source installation from current main uses the updated pin.
Release binary archives contain chat executables, not the CLI.

A local Zig 0.17 `fetch` cache artifact contained an extra archive root and
caused a hash mismatch on later build reads. The cache file was backed up,
not the tag changed; normal `zig build` downloaded and cached the same public
archive correctly. No cache workaround or weakened verification was introduced
into framework code. The raw downloaded archive and repeated fetch agreed
on the package hash.

## Public material and evidence

[Audit](audit.md) records each old slide decision, claims, story and code sources.
Both rebuilt PDFs contain 13 nonblank 16:9 pages, embedded Unicode fonts and
five distinct checked URI targets. Every page was visually reviewed; only page
13 changed after release publication, and it was rendered/reviewed again.
README, Getting Started and guide navigation links pass the 30-document check.
Native and Workers compile/test the actual minimal/DX code.

[Native performance](../../en/public-performance.md): all three rounds averaged
for each workload: hello 164,610, echo 163,790, DB 86,793 req/s. macOS M2, Zig
0.17.0, ReleaseFast, oha 1.15.0, 32 keep-alive connections, 3 x 3 seconds, IPv4
loopback. Raw JSON, environment and binary SHA are preserved beside this report.
This is a local regression snapshot, not controlled performance certification
or comparison with other frameworks.

## Scope and compatibility

Threaded remains Native production default. Reactor stays parked/fail-closed.
Offline adapter/WASM host success is not Cloudflare live certification; no live
resources were created or tested. Named-environment migration and arbitrary
custom-glue behavioral proof retain their documented limits.

Legacy APIs are removed; App(State)/Context/manual Response/provider ownership
remain. Principal must use setPrincipal, Storage exhaustive switches need new
errors, listPage owns results, deploy requires real configured resources.
See [release notes](../../releases/v0.2.0.md) and both-language upgrading guides.

Next recommended public DX work: a reproducible full application walkthrough,
explicit custom-glue smoke proof and opt-in live provider evidence; no runtime
restart or new abstraction is needed.
