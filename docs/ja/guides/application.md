# Applicationとownership

`ak.App(.{ .routes = ... })`は明示allocatorでruntime初期化する型です。既存のstatic route graphをmountし登録をfreezeします。動的登録には従来の`ak.App(State)`を使用します。

Contextはrequest中だけState/provider facadeをborrowします。decode inputとserialized responseはrequest arenaに属します。DTOはrequest-local dataを参照できますが、失効したstack bufferを参照してはいけません。testingのparsed JSONはResponseをborrowするため、parsed valueを先にdeinitします。

provider ownerはContextの外で明示作成し、安定したaddressを維持します。順に初期化しerrdeferでpartial failureをcleanup、background workをdrain/stopしてから依存resourceを破棄します。borrowしているAppをproviderより先にdeinitします。App.deinitは任意State resourceをcloseしません。`.configure`はmount前の一時App上で実行されるため、そのaddressの保持やborrowするtaskの開始は禁止です。

Endpoint metadataは既存route graph、capability検証、OpenAPI、clientへ接続します。Capabilityはrequirement、Provisionはprovider選択、Bindingはplatform resourceです。validationはprovisioningではなく、offline証拠はlive readinessではありません。Helloには不要です。stateful applicationでは[Portable Application Contract](../portable-application-contract.md)、[Provider lifecycle (English)](../../en/provider-lifecycle.md)を参照します。

platform extensionは明示的に維持します。Native production defaultはThreaded、ReactorはPark/fail-closedです。新scheduler、DI container、service locatorは導入しません。
