# Native SQLite性能調査の結論

開始mainは`dd50c00`です。[詳細レポート](final-report.md)と
[全セル比較](before-after.md)、[raw data](raw/http-candidate.json)を保存しています。

- prepareは1スレッドで約910 ns、wrapper確保は約23 nsでした。
- 同じpthreadゲートでC API直接実行とDb facadeを比較した差は約2.7%です。
  過去のHTTP競合差の原因割合を示すものではありません。
- 32/128スレッドではPool取得・返却の待ち時間が大きく、wall-stackでも
  ulock/futex待機を確認しました。CPU使用率の内訳とは解釈していません。
- wrapper削除は24 bytes・1 alloc/freeを除きますが、32接続DBは
  147,976→144,771 req/s（−2.17%）、P99は1.467→1.528 msでした。
  +10%の目標は未達で、候補は戻しました。候補の数値を最終実装の性能としません。
- 本番へ残す修正は、wrapper確保失敗時のSQLite Statement finalizeです。
  通常処理の高速化やAllocation削減とは主張しません。
- DB・Plaintext・JSON・Echo 1KiB、1/8/32/128/512/1024接続で
  ABBAを2サイクル、計192ケース実行しました。warmup 2秒・測定5秒の
  exploratory screenです。以前の競合matrixの10/30/5条件とは別です。
- 成功req/s、P95/P99、CPU、RSS、thread数、client errorをすべて残しました。
  別の時間帯の競合数値と直接順位付けしません。
- SQLite内部mallocの正確な回数、CPU内訳、過去の競合差の説明割合は未確定です。
- Threaded default、Reactor fail-closed、Workers/D1/Turso、既存DB/Pool APIと
  FULLMUTEX、deadline/close/generationの契約を維持します。

次は、同じcaller admissionでPoolのmutex再取得・Condition待機・schedulerを
分けて調べることを推奨します。cacheや新schedulerを先に導入しません。
core修正`ccd7662`ではCI 23/23 jobs、Linux/macOS TSan 2/2 jobsが成功しました。
最終テストとrevision付きCI結果は英語詳細レポートのValidationに集約しています。
