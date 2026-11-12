# Pythonテスト移行とCI高速化

## 変更内容

基準は `9f6d645`。Python製のテスト・検証ドライバを `tests/runner/` の
Zig実装へ移した。元のケースと移行先は [対応表](coverage.md)、元の一覧は
`python-inventory.json` に保存している。JS/WASMホスト、TypeScript型チェック、
protocolのCコンパイルは実際の実行環境で検証する。手動ベンチマーク計測・
運用ツールのPythonまで廃止した、という意味ではない。

- 通常push/PRとも同じ23ジョブ。required check名、OS、最適化モードを維持。
- unit testの同一203ケースをまとめてコンパイル。既存の独立実行方式も維持。
- living examplesのNative Debug/ReleaseSafeは、それぞれ4バイナリと
  3アプリのテストを一つのbuild graphで実行。59コマンドを51へ統合した。
  8 Native成果物、4 Workers成果物/ホスト、5 TS型チェックは削っていない。
- テスト成功結果は通常キャッシュしない。コンパイルがcachedでも本体は実行。
- CLI/Dockerの不要な `needs: build` 削除は既に基準commitへ含まれている。
  今回の移行だけの成果として重複計上しない。
- 巨大なコンパイルキャッシュは以前の比較で安定した効果がなく、不採用を維持。
  小さい固定依存ソースのキャッシュはネットワーク障害対策として別に評価する。

Native production defaultはThreaded。Reactorのproduction gateは変更していない。
frameworkのHTTP/DB/Workers公開APIを変更する作業ではない。

## ローカル実測

Zig 0.17.0、Apple M2 / 8 CPU / 16 GiB、macOS 27.0.1、ReleaseSafe。
同じglobal cacheと、異なる空のlocal cacheを使用し、順番に計測した。
hosted runnerのcold buildや統計的な反復比較ではない。

| unit layout | wall | user | system | 最大RSS |
|---|---:|---:|---:|---:|
| isolated | 117.08秒 | 359.72秒 | 10.87秒 | 1,040,564,224 bytes |
| grouped | 68.92秒 | 143.13秒 | 3.91秒 | 1,306,640,384 bytes |

wallは41.1%短縮、最大RSSは25.6%増加。両方とも202成功・1既存skipで、
OpenSSL無効時のRS256テストがskipする。OpenSSL有効ジョブで別途検証する。
原記録は `isolated-local.time` と `grouped-local.time`。

## GitHub Actionsでの比較

ジョブ開始から完了までの時刻差を合計する。spanは最初のジョブ開始から最後の
ジョブ完了までで、runner待ちを含む。総ジョブ秒は課金額そのものではない。
外部取得障害がある実行を、成功実行の高速化率へ混ぜない。

| run / source | 成否 | span秒 | 総ジョブ秒 | Linux living秒 | macOS living秒 | OpenSSL秒 | CLI smoke秒 |
|---|---|---:|---:|---:|---:|---:|---:|
| 42236457517 / 9e2b233 | 23成功 | 679 | 5550 | 554 | 678 | 391 | 428 |
| 42238765448 / 9f6d645 | 23成功 | 1158 | 6000 | 722 | 806 | 378 | 520 |
| 43211221165 / d3aa062 | 23成功、移行途中 | 838 | 5815 | 593 | 746 | 271 | 574 |
| 43218854054 / 4ccebf7 | 22成功、依存取得1失敗 | 909 | 8474 | 651 | 809 | 523 | 791 |

rawは隣接する `ci-*-jobs.json`。中間成功実行ではOpenSSLジョブの短縮を
観測したが、全体の安定した高速化をまだ証明したとは扱わない。
`4ccebf7` ではCodeberg取得エラーがあり、テスト前の失敗も残る。

## 検証範囲と限界

ローカルの統合実行は60/60 build steps、89/89 Zig testsに成功。
別途170 transport cases、24 quick stress、15 session/race/mixed、12 isolation、
33 compile-fail、CLI/scaffold/update/sync、5 Workers binding構成を検証した。
Linuxへのrunner cross-compileも成功。5秒のmixed runを長時間soakと呼ばない。
手動Python測定ツールの任意の中断安全性まで新ドライバのテストで保証しない。

失敗ログ、途中のJSON、成果物hash、子プロセス状態は保存する。
Linux/macOSの実行時間差、外部取得、queue待ちとテスト自体の時間を分ける。
テスト縮小を伴うPR専用構成は今回は採用しない。

## 再現

```sh
zig build ci-runner
./zig-out/bin/akamata-tests support
./zig-out/bin/akamata-tests reporting
zig build test -Dtest-layout=grouped -Doptimize=ReleaseSafe --summary all
zig build living-examples-test
```

Node 24、TypeScript 5.9.3、Zig 0.17.0を使用する。
`AKAMATA_DX_TSC` に `tsc.js` を設定する（CIでは未設定なら失敗）。
Actionsの `jobs` APIで `started_at` / `completed_at` とstep時刻を保存すれば、
上表を再計算できる。compiler cacheと依存ソースcacheを同一の指標にしない。
