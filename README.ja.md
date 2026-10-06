# Akamata

![Akamata ASCIIアート](assets/branding/akamata-ascii-hero.png)

[English](README.md) | 日本語

Native / Cloudflare Workers向けportable Zig backend frameworkです。普通の関数から始め、typed JSON API、認証、DB、Storage、Queue、Realtimeへ既存application contractと明示provider ownerを利用して成長できます。Native productionはThreaded、ReactorはParkを維持します。Workers host simulationとopt-in live Cloudflare検証の証拠は区別します。

最新release: **v0.1.5** · 必須Zig: **0.17.x** · [Release notes](CHANGELOG.md)

```zig
const std = @import("std");
const ak = @import("akamata");

fn hello() []const u8 {
    return "Hello, Akamata!";
}

pub const Application = ak.App(.{ .routes = .{ak.get("/", hello)} });

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    var app = try Application.init(gpa.allocator());
    defer app.deinit();
    try app.serve(.{ .port = 8080 });
}
```

以下の普通の関数APIは最新main向けです。v0.1.5の既存App(State)も維持します。[同じsource](tests/docs/minimal.zig)を `zig build documentation-test -Doptimize=ReleaseSafe` でcompile/testし、Workers WASMでもapplication contractを検証します。初期化の所有権は明示し、Hello WorldにContextは不要です。

## Why Akamata?

- **1つのコードベース、複数のruntime** — handlerをnative server、Workers、
  Containersで共有できます。runtime固有のentry pointは明示的に分離されます。
- **統一DB API** — ローカルSQLite、Cloudflare D1、Tursoで同じ`Db`/`Stmt`と
  model repository APIを利用できます。
- **Zigらしい開発体験** — 型付きの`App(State)`、`Context(State)`、入力検証、
  middleware、model schema、repositoryを提供します。
- **本番向けobservability** — request、DB、outbound HTTP、独自spanの時間を、
  Prometheus metrics、structured log、`Server-Timing`から確認できます。

## クイックスタート

CLI installerはリポジトリに含まれるため、最初にcloneします。

```bash
git clone https://github.com/appleuser634/Akamata.git
cd Akamata
./scripts/install.sh

# $HOME/.local/binへPATHを通した後、任意のdirectoryで生成できます。
cd ~/projects
akamata init myapp --target=both
cd myapp
zig build run
```

別のterminalから確認します。

```bash
curl -sS http://127.0.0.1:8080/
```

default projectはDBやproviderを初期化せず、Hello responseを返します。
`--target=both`はWorkersとContainerのdeploy fileを追加します。
従来のSQLite CRUD・validation・migration tutorialは`--template=notes`で生成できます。
依存はv0.1.5に固定されます。新しいtyped APIにはlocal checkout overrideを使用します。
両方の手順は[Getting Started](docs/ja/quickstart.md)を参照してください。

CLI自体を開発する場合は、installせず直接buildできます。

```bash
zig build cli
./zig-out/bin/akamata help
```

## 要件と対応環境

| 対象 | 要件 |
|---|---|
| 基本開発環境 | Zig 0.17.x、macOSまたはLinux、libc |
| native DB | 同梱SQLite amalgamation。system SQLiteのinstallは不要 |
| Workers | Node.js、Wrangler、Cloudflare account。D1は任意 |
| Containers | Docker。Cloudflare Containersには対応planが必要 |
| Turso / HTTPS client | Zig標準ライブラリのTLSとOS trust store |
| FCM RS256署名のみ | OpenSSL build flag (`-Dopenssl=true`)が任意で必要 |

Windows nativeはdocument/test対象外です。対応済みのLinux workflowにはWSL2を使用してください。
SSEとnative WebSocket connectionは現在nativeのみです。WorkersのWebSocketは、提供される
Workers/Durable Object integration patternを使用します。

## ドキュメント

| 目的 | 日本語 | English |
|---|---|---|
| まず動かす | [クイックスタート](docs/ja/quickstart.md) | [Quick Start](docs/en/quickstart.md) |
| 順番に学ぶ | [チュートリアル](docs/ja/tutorial.md) | [Tutorial](docs/en/tutorial.md) |
| 全体を把握する | [ハンドブック](docs/ja/handbook.md) | [Handbook](docs/en/handbook.md) |
| v0.0.1から移行する | [アップグレードガイド](docs/ja/upgrading.md) | [Upgrade guide](docs/en/upgrading.md) |
| 目的別に探す | [ドキュメントホーム](docs/ja/README.md) | [Documentation home](docs/en/README.md) |
| Akamataを紹介する | [スライド (PDF)](docs/ja/slides.pdf) | [Slides (PDF)](docs/en/slides.pdf) |

## 主な機能

- runtime route builder、path parameter、route group、middleware
- JSON、form、multipart、cookie、validation、型付きmodel repository
- SQLite、JSPI経由のD1、Turso/libsql Hrana
- native WebSocket、SSE、static file、compression、security middleware
- JWT、bcrypt、session、CSRF、rate limit、bearer authentication
- native/Workers outbound HTTP、MQTT QoS 0、任意のFCM support
- request ID、access log、Prometheus metrics、軽量span、`Server-Timing`
- OpenAPI生成、typed client生成、testing client、job、cron
- comptime型付きhandler binding、lifecycle hook、route単位resource budget、
  route inspection、project doctor、schema-aware API diff

backend対応状況とAPI詳細は、[Handler API](docs/ja/handler-api.md)、
[DBバックエンド](docs/ja/db-backends.md)、[WebSocketガイド](docs/ja/websocket.md)を参照してください。

HTTP APIは`App → Context → endpoint/middleware → runtime`の単一系統です。
`am.App(State)`、`am.Context(State)`、`app.serve()`を利用してください。
削除したAPIは[v0.2 Phase 1変更内容](docs/ja/v0.2-phase1.md)を参照してください。

## Examples

- [`examples/chat/`](examples/chat/) — SQLiteを使うREST + native WebSocket chat
- [`examples/guestbook/`](examples/guestbook/) — SQLite、D1、Turso向けmodel/repository guestbook
- [`examples/tasks/`](examples/tasks/) — validation、OpenAPI、SSE、session、security middleware、
  job、testを扱うreference REST API
- [`examples/bench/`](examples/bench/) — 再現可能なframework benchmark

## ライセンス

MIT
