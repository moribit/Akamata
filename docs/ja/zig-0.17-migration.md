# Zig 0.17への移行（Akamata v0.1.5）

Akamata v0.1.5はZig 0.17.0を必須とします。v0.1.4のZig 0.16向けコードから、NativeとWorkersの両backend、CLI、生成プロジェクトを移行しました。Zig 0.16との互換性は維持していません。

## 変更内容

| 対象 | 旧実装 | v0.1.5 |
| --- | --- | --- |
| Cヘッダー | `@cImport` / `@cInclude` | `build.zig`でCヘッダーを変換し、名前付きmoduleをimport |
| 配列反復 | `[_]u8{0} ** N` | `@as([N]u8, @splat(0))` |
| 型情報 | `.fields`、関数の`.params`、従来のerror set表現 | 名前・型・属性の配列、`.param_types`、`.error_names` |
| tuple型 | `std.meta.Tuple(types)` | `@Tuple(types)` |
| sentinel文字列 | `dupeZ` / `bufPrintZ` | `dupeSentinel` / `bufPrintSentinel`にsentinel `0`を明示 |
| buildの実行引数 | `b.args` | `run.addPassthruArgs()` |
| ツールチェーン | Zig 0.16.0 | Zig 0.17.0（manifest、CI、Docker） |

SQLiteのヘッダー変換はNativeで実行し、OpenSSLはNativeの`-Dopenssl=true`時だけ取り込みます。Workers向けにはこれらのNative依存を追加しません。0.17で利用可能な`std.Build.addTranslateC`を使用しています。このAPI自体は非推奨のため、今後のZig更新では公式の外部translate-c packageへの移行を検討します。

`src/reflection.zig`は0.17の並列配列から共通のfield表現を構成します。これにより、model、JSON、OpenAPI、contract、event/protocol生成がfield名・型・enum値・default値を共有できます。入力projectionの生成にも新しい構造体属性型とsentinel付きfield名を使用します。

ReleaseSafeの検証では、`Value.fromAny`が値渡しの配列parameterをsliceとして返す寿命問題を検出しました。変換を型ごとのinline関数にし、optionalやpointerの変換も含めて呼び出し元で処理します。byte bufferは引き続き借用するため、保持する間は元のbufferを有効にしてください。SQLiteの回帰テストは長さに加えて保存された内容も検証します。

## 既存アプリの移行手順

1. `zig version`が`0.17.0`であることを確認します。
2. v0.1.5のcheckoutで`zig build cli -Doptimize=ReleaseSafe`を実行し、生成された`zig-out/bin/akamata`を使用します。
3. アプリの`build.zig.zon`の`.minimum_zig_version`を`"0.17.0"`に更新します。
4. アプリの`build.zig`に残る引数転送を、以下のように更新します。

```zig
const run = b.addRunArtifact(exe);
run.addPassthruArgs();
b.step("run", "run the app (native)").dependOn(&run.step);
```

5. アプリ独自の旧API使用箇所も先に更新したうえで、アプリのディレクトリで新しいCLIから`akamata update --to=v0.1.5 --sync`を実行します。依存先を更新し、Native・Workersのbuildを検証します。managed Workers glueに独自変更がある場合はdiffを確認し、必要な変更を保存してからsyncしてください。
6. アプリ自身に`**`、`@cImport`、旧型情報APIなどがある場合は、上表に従って更新します。`update --sync`はアプリの`build.zig`や任意のアプリsourceを自動変換しません。
7. Nativeのテストとbuild、Workersのbuildを実行します。OpenSSLを使う場合は、その設定でもbuildしてください。

新しいCLIの`akamata init`はZig 0.17向けのbuild設定とv0.1.5の依存先を生成します。開発checkoutを試す場合は、通常のrelease依存を維持したまま`zig build --fork=/absolute/path/to/Akamata`で上書きできます。

## 検証

移行時にmacOS上のZig 0.17.0で以下を確認しました。

- 単体テスト140件（DebugとReleaseSafe）
- HTTP統合テスト、tasksテスト、13件のcompile-fail診断
- Workers realtime/同時WASM dispatchのNode.jsテスト6件
- chat、guestbook、bench、tasks、device_messagingのNative buildと、提供されるWorkers entrypointのbuild
- CLI、OpenSSL有効時、Linux x86_64 musl向けクロスbuild、router benchmarkとportable benchmark
- local scaffoldのNative/Workers build、SQL migration、生成buildと公開build helperの引数転送
- 既存プロジェクトのupdate/syncとD1・R2・Queue・Realtimeを含むWorkers capabilityの保持

CIも0.17.0へ更新しました。local scaffoldとupdate/syncのテストは、このcheckoutを`--fork`で指定し、公開済みの旧releaseを誤って検証しないようにしています。上記のローカル検証はCloudflareへの実deployや全release targetでの実行を含みません。

## 参考

- [Zig 0.17.0 release notes](https://ziglang.org/download/0.17.0/release-notes.html)
- [Akamata v0.1.5 release notes](../releases/v0.1.5.md)
- [Quick Start](quickstart.md)
