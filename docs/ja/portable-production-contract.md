# Portable Production Contract

Application Contract / Provision / Binding / Contextの既存設計を維持し、宣言から実adapter、owner、deployment設定まで追跡します。Native productionはThreadedです。ReactorはPark / fail-closedを維持します。

- DB: `openForContract`でproviderとURLを照合してから既存Dbを開きます。
- Storage: `listPage`がentries・metadata・opaque cursorを所有し、`deinit`で解放します。従来の`list`は維持します。
- Queue: Nativeは既存`jobs.Queue`のowner、Workersはbindingを保持するtyped ownerからProducer/Consumerへ接続します。at-least-onceであり、exactly-onceではありません。
- Realtime: Native registryとWorkers DO control planeに明示ownerを置きます。Contextは借用のみです。
- 起動失敗: acquisition直後のerrdeferと逆順cleanupを検証します。shutdownでは先にborrowerを停止・joinします。
- Deployment: named environmentのbinding・resource識別子・DB URL・Realtime namespace選択を照合します。validationからresourceを自動作成しません。
- Readiness: declared / configured / validatedはlocal証拠です。reachable / readyやCloudflare production成功をoffline testから推定しません。

[詳細なprovider / owner / lifecycle / evidence matrix](../en/portable-production-contract.md)、[reference application](../../examples/device_messaging/README.md)、[専用resourceに限定したlive検証](../en/live-provider-contract.md)を参照してください。

互換性:既存facadeとmanual factoryは維持します。新しいStorage Errorの追加はexhaustive switchへの追従が必要です。deploy時のplaceholder D1暗黙作成を廃止し、明示provisionを分離しました。JSONC、custom glueの静的証明、named environment migrationは未対応です。
