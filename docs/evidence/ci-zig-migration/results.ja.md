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

`4ccebf7/cli-timing/` のhostedコマンド記録では、scaffoldは159.72秒、
うちReleaseSafeビルド104.76秒、Debugビルド15.31秒。
minimalは148.42秒、うちReleaseSafe build 77.20秒、test build/run 68.71秒。
ドライバのassertion処理だけをZigへ移しても、このコンパイル時間は消えない。
macOS livingの主な区間はReleaseSafe graph 320.36秒、Debug graph 111.72秒、
SQLite host build 40.82秒（同じディレクトリのliving原記録）。
残る主要コストはapplication/translatorのコンパイルである。

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
| 43228855537 / 0958306 | 23成功、依存cache初回 | 719 | 5229 | 579 | 681 | 293 | 353 |
| 43231952334 / 2d6ab98 | 23成功、依存cache warm | 674 | 5309 | 614 | 673 | 223 | 509 |

rawは隣接する `ci-*-jobs.json`。最終のcold実行ではOpenSSLは基準2実行より
22.5〜25.1%、CLI smokeは17.5〜32.1%短縮した。総ジョブ秒は5.8〜12.9%減少。
一方spanは最短基準より5.9%長く、遅い基準より37.9%短い。
全体の安定した高速化を証明したとは扱わない。
`4ccebf7` ではCodeberg取得エラーがあり、テスト前の失敗も残る。

warm実行は最短基準679秒とほぼ同等（674秒、0.7%短縮）。総ジョブ秒は
5550→5309（4.3%減）、OpenSSLは391→223秒（43.0%減）。一方Linux livingは
554→614秒、CLI smokeは428→509秒と遅い。別の基準実行との比較ではこれらも
短いが、runner差・queue・外部取得を含む少数実行なので、一律の改善率にはしない。
初回/warmの2実行とも23成功で、source cache対象16/16ジョブのヒットをログで
確認した（`source-cache-warm.json`）。cache stepは0〜2秒。
初回ヘルパーにはZig標準ライブラリのコンパイルが含まれるため、約100→2秒という
step差をそのまま全体の短縮とは扱わない。CLI build全体は109→124秒だった。

## 検証範囲と限界

ローカルの統合実行は60/60 build steps、89/89 Zig testsに成功。
別途170 transport cases、24 quick stress、15 session/race/mixed、12 isolation、
33 compile-fail、CLI/scaffold/update/sync、5 Workers binding構成を検証した。
Linuxへのrunner cross-compileも成功。5秒のmixed runを長時間soakと呼ばない。
手動Python測定ツールの任意の中断安全性まで新ドライバのテストで保証しない。

`0958306` の [通常CI](https://github.com/moribit/Akamata/actions/runs/43228855537)
は23/23成功、[TSan](https://github.com/moribit/Akamata/actions/runs/43228878885)
はLinux/macOSの2/2成功。DB専用の追加回帰ドライバも同じ6コマンドに成功
（`db-regression-local.json`）。全ジョブ名と検証条件を維持している。
依存source cacheはLinux 603,068 bytes、macOS 605,303 bytes。
初回取得は約100秒かかる例があり、warm hitでの確認と分けて記録する。

最新コード `2d6ab98` の[通常CI](https://github.com/moribit/Akamata/actions/runs/43231952334)
も23/23成功。TSan検証済みのframework/runtimeコードは同一で、追加変更は手動
DB回帰ドライバのZig移行。ローカルの同ドライバでもDB Pool TSanを含む6構成が成功。

## 判断と残る改善候補

テストドライバのZig統一、同一unit caseのまとめコンパイル、livingのbuild graph
統合を採用した。ローカルCPU/wallとhosted OpenSSLに効果を確認し、全体の最短
時間は維持した。source cacheは小容量で外部取得障害を減らすが、全体の速度向上を
単独では証明していない。以前の巨大compiler cacheは引き続き不採用。

次の候補は、Zigドライバ自体とSQLite hostのコンパイル時間を分離して計測し、
重いReleaseSafeコンパイルをさらに共有できるか調べること。テスト/OS/モードを
減らしたり、source cacheへcompiler結果を混ぜたりして速く見せない。

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
