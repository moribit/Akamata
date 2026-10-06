# Akamataドキュメント

Zig 0.17.x向けの入口です。Getting Startedから始めてください。ordinary-function APIはmainで利用可能です。v0.1.5では従来の明示App/Context APIを使用します。

**リリース状況:** v0.1.5は現在の公開0.x releaseです。`main`は開発向け
のため、再現可能な build が必要な場合はタグ付き release を固定してください。

[English](../en/README.md) · [プロジェクトREADME](../../README.ja.md)

## はじめに

- [クイックスタート](quickstart.md) — CLIをインストールし、現在のscaffoldを生成して起動します
- [Tutorial](tutorial.md) — アプリケーションを段階的に構築します
- [Handbook](handbook.md) — model、repository、migration、deployを短時間で確認します
- [Tasks example](example-tasks.md) — example applicationを題材に学びます
- [アップグレードガイド](upgrading.md) — v0.0.1以降の挙動変更
- [開発体験](developer-experience.md) — contract、型付きinput／DI、project検査、generator、API diff、migration workflow
- [CLI API client](cli-client.md) — `akamata`から直接またはOpenAPI operation単位でrequestを実行

- [Zig 0.17への移行](zig-0.17-migration.md) — v0.1.5の変更点、移行手順、検証結果

- [Typed handlers](guides/typed-handlers.md) — ordinary functions, explicit parameter binding and optional Context (main)
- [Request validation](guides/validation.md) — DTO rules and compatibility
- [Application errors](guides/errors.md) — finite error mapping, OpenAPI and client guards
- [Application testing](guides/testing.md) — typed responses, principal injection and bounded provider effects

## Guide

- [アプリケーション向けbuilding blocks](application-building-blocks.md) — query、validation、session／CSRF、typed config、storage、testing、idempotency、D1 atomic pattern
- [Portable Backend / Realtime アーキテクチャ](portable-backend.md)

- [Cloudflare Workers／Containers](cloudflare.md)
- [SQLite／D1／Turso](db-backends.md)
- [WebSocket](websocket.md)
- [Observability](observability.md)
- [Security](security.md)
- [Release process](releasing.md)

- [Portable Application Contract](portable-application-contract.md) — requirements, explicit providers, bindings, borrowed services and application tests (main development API)

## API reference

- [Handler API](handler-api.md) — `App`、`Context`、request／response helper、middleware、database、model／repository、HTTP client、認証、WebSocket、SSE


## Developer journey / 機能別guide

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

## 本番運用とperformance

- [2026-08-17 performance regression report](benchmarks-2026-08-17.md) — 現行revisionと変更前baselineの同一machine A/B測定
- [Benchmarks](benchmarks.md)
- [Long-run benchmarks](benchmarks-long-run.md)
- [Performance follow-ups](perf-followups.md)
- [Reactor design](perf-reactor-design.md)
- [Native runtime／Transport Contract](runtime-transport.md) — 共通protocol、Zig 0.17 Io調査、分離したGroup PoCと性能比較

benchmark値は、記載された環境、command、Akamata revisionでの測定結果です。別のmachineやworkloadで同じ性能を保証するものではありません。

## Architectureと設計資料

- [Compile-time architecture](comptime-architecture.md) — static route graph、typed contract、capability、DI、specializationのtrade-off
- [Compile-time routing benchmark](comptime-benchmarks-2026-08-17.md) — route/middleware scalingとartifact size比較
- [Architecture](architecture.md)
- [v0.2 design record](v0.2-design.md)

設計資料は特定時点の検討内容を記録したもので、現在は置き換えられた例を含む場合があります。対応中のinterfaceは[Handler API](handler-api.md)と現在のsource codeを確認してください。

- [v0.2 Phase 1](v0.2-phase1.md)
