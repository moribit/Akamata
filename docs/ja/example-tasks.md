# Tasks: effects・配送・in-process testing

typed HTTP、validation、repository、schema生成は先に
[guestbook](../../examples/guestbook/README.md)で学びます。tasksはQueue effectsと
明示的なowner lifetimeが主題で、全機能を詰め込むstarterではありません。

## Production codeを読む順番

1. [contract.zig](../../examples/tasks/src/contract.zig): route、typed event、
   Native/Workersのproviderとbinding。
2. [setup.zig](../../examples/tasks/src/setup.zig): **一つのApplication graph**。
   recover/request IDと、明示的なdevelopment migrationだけを設定します。
3. [handlers.zig](../../examples/tasks/src/handlers.zig): typed requestからDBへ
   保存し、`Context.queue()`でeventをpublishします。
4. [main.zig](../../examples/tasks/src/main.zig): checked DB / jobs.Providerの
   owner、借用facade、workerのstart・stop/join・逆順cleanup。
5. [worker.zig](../../examples/tasks/src/worker.zig): D1 / QueueOwnerはisolate所有。
   consumer登録は初期化成功後に行います。
6. [integration_test.zig](../../examples/tasks/src/integration_test.zig): 同じgraphを
   QueueRecorderで検証し、ConsumerのDB effectと実Native jobs配送も別に検証します。

## 起動とテスト

repository rootでZig 0.17を使います。

```sh
zig build -Dexample=tasks
./zig-out/bin/tasks
zig build tasks-test
zig build tasks-test -Doptimize=ReleaseSafe
zig build -Dexample=tasks -Dbackend=workers
```

request、binding/schema設定、platform差、lifecycleは
[example README](../../examples/tasks/README.md)を参照してください。Native SSEは
boundedかつlossyなUI通知で、Workersの`/events`は501です。Queue配送はportableな
at-least-onceです。DB保存と外部Queue送信は別effectで、送信失敗でもtaskは残ります。
本番で両者の確実な連携が必要ならoutbox/reconciliationを設計します。

QueueRecorderが証明するのはpublish metadataで、durabilityではありません。
Consumerと実jobs ownerのテストが配送behaviorを別に検証します。application testに
socketやworker threadは不要で、実Native engineも有限の`worker.tick()`で確認します。
Workers build / host fixture成功はlive Cloudflare保証とは区別します。

次は[chat](../../examples/chat/README.md)で長寿命transportのownership、
[device messaging](../../examples/device_messaging/README.md)でPrincipal、production
providers、明示versioned migrationを学びます。
