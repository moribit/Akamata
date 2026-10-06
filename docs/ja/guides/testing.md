# Socketなしのapplication test

同じapplicationをtest allocatorとprovider stateで初期化し、`app.client(allocator)`を使います。listener/threadは不要です。`client.post("/users").json(.{ .name = "Alice" }).send()`、`response.expectStatus(.created)`、`response.json(User)`でtyped JSON APIを検証できます。

responseはarena・headers・requestの確保済みdataを所有するため、`defer response.deinit()`が必要です。decode結果はresponseのlifetimeへborrowします。sendはbuilderをconsumeします。send後の再利用/copyは避けてください。raw body/headerの参照はsend完了まで維持してください。sendが失敗した場合もstaged allocationをcleanupします。

`client.get("/profile").as(UserIdentity{ ... }).send()`でidentityを注入できます。値はshallow copyされ、request arenaの通常setPrincipal経路で添付します。middlewareは実行され、拒否・置換も可能です。credential backendの検証は `.bearer(token)` などを使ってください。production認証を省略する仕組みではありません。

既存test ownerの `MemoryStore.expectExists(key)` と `QueueRecorder.expectPublished(Descriptor)` で副作用を確認できます。Queue assertionはevent名・version・payload decodeを検証し、delivery/retry/durabilityを保証しません。MemoryStoreは16object、QueueRecorderはdefault64eventにboundedです。ownerはtest/application stateが保持し、Contextはproduction facadeをborrowします。

[DX tests](../../../tests/dx_test.zig)で注入済みPrincipalの拒否とOOM cleanupを検証し、[共通fixture](../../../tests/dx_application_fixture.zig)でNative/Workers双方を実行します。[英語Guide](../../en/guides/testing.md)も参照してください。
