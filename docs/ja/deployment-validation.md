# Deployment validation / Configuration

`akamata inspect capabilities`、`akamata check --capabilities`、contract-aware deployで、target/provider/binding/environmentの一致を検証します。これはresource作成やlive readinessではありません。

```sh
akamata inspect capabilities --target=workers --environment=production --strict
akamata check --quick --capabilities --target=workers --environment=production --strict
akamata deploy --workers --environment=production --preflight
```

JSON/JSONCと既存の生成TOML subsetを利用できます。JSONCはstring外のcomment/trailing commaだけを除去し、Zig 0.17 std.jsonでtreeを検証します。binding/provider変数のcaller-owned metadata viewへ投影し、元fileは変更しません。malformed構造、duplicate key、既存借用readerで表現できないescape文字列は明示エラーです。完全なTOML parserではなく、複雑な形式は未対応です。

rootとnamed environmentのbinding/varsは独立しています。rootのresourceをnamed環境へ流用しません。named environment migrationはEnvironmentMigrationUnsupportedを維持します。現行migrationはrootの最初のD1を選択するため、environment-specific binding/resourceの証明なしに有効化できません。

readinessはdeclared/configured/validatedまでです。remote probeやapplication smokeを実行していないのでreachable/readyを表示しません。custom glueのsymbol存在だけではconsumer/gateway/R2 listPage ABIを証明できず、専用host smokeが必要です。managed glueは既存WASM simulationで検証します。

詳しい診断、limit、再現手順は[English reference](../en/deployment-validation.md)を参照してください。JSONCと非継承binding仕様は[公式Wrangler config](https://developers.cloudflare.com/workers/wrangler/configuration/)で2026-10-06に確認しました。offline証拠とlive認証を区別します。
