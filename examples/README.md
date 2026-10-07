# Akamata living examples

Start with ordinary Zig, then add effects and explicit platform ownership.
Run commands from the repository root with Zig 0.17.0.

| Reference | What you learn | Level |
|---|---|---|
| [Minimal scaffold](../docs/en/quickstart.md) / [compiled Hello](../tests/docs/minimal.zig) | An ordinary function becomes an HTTP endpoint | 0 |
| [guestbook](guestbook/README.md) | Typed HTTP, DTO validation, DB, endpoint metadata, OpenAPI/client and testing | 1 |
| [tasks](tasks/README.md) | Queue, background work, observable effects and shared application tests | 2 |
| [chat](chat/README.md) | Shared typed realtime protocol; explicit Native socket / Workers DO ownership | 2 |
| [device_messaging](device_messaging/README.md) | Portable Production Contract, authentication and multiple provider lifetimes | 3 |

The scaffold is the canonical minimal project; we do not maintain a second
Hello project with a separate build/dependency configuration. Its source and
commands are covered by documentation/scaffold/public-journey tests.

Native production uses Threaded. Reactor is parked/fail-closed and is not part
of this learning path. Workers builds and host fixtures are offline evidence;
they do not certify a live Cloudflare deployment.

## Benchmark fixtures

`bench/` and `router_bench/` are measurement fixtures, not application tutorials.
Their paths remain stable for existing scripts and historical evidence. See
[current Native measurements](../docs/en/public-performance.md) before using
historical numbers. Benchmark-specific fast paths are not application advice.

## Reproduce the living reference

`python3 tests/living_examples.py` builds Native Debug/ReleaseSafe and Workers,
runs shared application tests, a Native WebSocket wire fixture and actual WASM
through managed JSPI glue with isolated offline providers. Node 24 is required;
set `AKAMATA_DX_TSC` to TypeScript 5.9.3 `tsc.js` for strict generated-client checks.
CI requires that check on Linux and macOS. Evidence is written under `.zig-cache`.
This runner does not deploy or contact Cloudflare.

## Next

[Getting Started](../docs/en/quickstart.md) ·
[日本語](../docs/ja/quickstart.md) ·
[Production contract](../docs/en/portable-production-contract.md)
