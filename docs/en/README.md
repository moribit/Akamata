# Akamata Documentation

Documentation for Zig 0.17.x. Start with Getting Started. Ordinary-function APIs are available on main; v0.1.5 retains the explicit App/Context API. Each guide identifies the development API where relevant.

**Release status:** v0.1.5 is the current public 0.x release. The `main` branch
is development-oriented; pin a tagged release for reproducible builds.

[日本語](../ja/README.md) · [Project README](../../README.md)

## Getting started

- [Quick Start](quickstart.md) — install the CLI, generate the current scaffold, and run it
- [Tutorial](tutorial.md) — build an application step by step
- [Handbook](handbook.md) — concise tour of models, repositories, migrations, and deployment
- [Tasks example](example-tasks.md) — guided example application
- [Upgrade guide](upgrading.md) — behavior changes after v0.0.1
- [Developer experience](developer-experience.md) — contracts, typed inputs/DI, project inspection, generators, API diff, and migration workflow
- [CLI API client](cli-client.md) — direct and OpenAPI operation-based requests from `akamata`

- [Zig 0.17 migration](zig-0.17-migration.md) — v0.1.5 changes, upgrade steps, and validation

- [Typed handlers](guides/typed-handlers.md) — ordinary functions, explicit parameter binding and optional Context (main)
- [Request validation](guides/validation.md) — DTO rules and compatibility
- [Application errors](guides/errors.md) — finite error mapping, OpenAPI and client guards
- [Application testing](guides/testing.md) — typed responses, principal injection and bounded provider effects

## Guides

- [Application building blocks](application-building-blocks.md) — queries, validation, sessions/CSRF, typed config, storage, testing, idempotency, and D1 atomic patterns
- [Portable Backend and Realtime Architecture](portable-backend.md)

- [Cloudflare Workers and Containers](cloudflare.md)
- [SQLite, D1, and Turso](db-backends.md)
- [WebSocket](websocket.md)
- [Observability](observability.md)
- [Security](security.md)
- [Release process](releasing.md)

- [Portable Application Contract](portable-application-contract.md) — requirements, explicit providers, bindings, borrowed services and application tests (main development API)

## API reference

- [Handler API](handler-api.md) — `App`, `Context`, request/response helpers, middleware, database, model/repository, HTTP client, authentication, WebSocket, and SSE


## Developer journey

| Learn | Guide |
|---|---|
| Routing / typed handlers / request data / responses | [Typed handlers](guides/typed-handlers.md), [Handler reference](handler-api.md) |
| Validation / error mapping | [Validation](guides/validation.md), [Errors](guides/errors.md) |
| Authentication / roles / scopes | [Security](security.md), [Principal binding](guides/typed-handlers.md) |
| Database | [SQLite / D1 / Turso](db-backends.md) |
| Storage | [Storage pagination](storage-pagination.md), [Application building blocks](application-building-blocks.md) |
| Background jobs / queue | [Queue providers](queue-providers.md) |
| Realtime | [Realtime developer guide](guides/realtime.md), [Realtime owners](realtime-providers.md) |
| Testing | [In-process testing](guides/testing.md) |
| OpenAPI / generated HTTP client | [Developer tooling](developer-experience.md), [Typed errors / clients](guides/errors.md) |
| Configuration / deployment preflight | [Deployment validation](deployment-validation.md) |
| Native / Workers / Containers | [Portable backend](portable-backend.md), [Cloudflare deployment](cloudflare.md) |
| Observability | [Existing observability](observability.md) |

## Concepts

[Application and lifetime](guides/application.md) · [Portable Application Contract](portable-application-contract.md) · [Portable Production Contract](portable-production-contract.md) · [Provider lifecycle](provider-lifecycle.md)

## Reference

[Handler API](handler-api.md) · [CLI and generated artifacts](developer-experience.md) · [Configuration / readiness](deployment-validation.md) · [Capability/provider matrix](portable-production-contract.md) · [Error formats](guides/errors.md)

## Examples

[Executable minimal](../../tests/docs/minimal.zig) → ordinary function; [guestbook](../../examples/guestbook/README.md) → DB and validation; [device_messaging](../../examples/device_messaging/README.md) → portable provider owners; [chat](../../examples/chat/README.md) → explicit realtime transport.

## Production and performance

- [2026-08-17 performance regression report](benchmarks-2026-08-17.md) — same-machine A/B of the current revision and its pre-change baseline
- [Benchmarks](benchmarks.md)
- [Long-run benchmarks](benchmarks-long-run.md)
- [Performance follow-ups](perf-followups.md)
- [Reactor design](perf-reactor-design.md)
- [Native runtime and Transport Contract](runtime-transport.md) — shared protocol, Zig 0.17 Io audit, isolated Group experiment and regression measurements

Benchmark numbers are snapshots of the recorded environment, commands, and Akamata revision; they are not performance guarantees for another machine or workload.

## Architecture and design history

- [Compile-time architecture](comptime-architecture.md) — static route graphs, typed contracts, capabilities, DI, and specialization trade-offs
- [Compile-time routing benchmark](comptime-benchmarks-2026-08-17.md) — route/middleware scaling and artifact-size comparison
- [Architecture](architecture.md)
- [v0.2 design record](v0.2-design.md)

Design records describe the reasoning at a point in time and may contain superseded examples. Use the [Handler API](handler-api.md) and current source for the supported interface.

- [v0.2 Phase 1](v0.2-phase1.md)
