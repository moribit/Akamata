# Environment-aware deployment validation

Use existing commands, not a new deployment tool:

```sh
akamata inspect capabilities --target=workers --environment=production --strict
akamata check --quick --capabilities --target=workers --environment=production --strict
akamata deploy --workers --environment=production --preflight
```

Contract-aware projects with the existing akamata-capabilities metadata hook preflight automatically before migrations, build or deploy. Legacy projects can opt in with --preflight or --manifest=PATH. A supplied manifest must be generated from the application being deployed; it is not cryptographically tied to the binary. Inspection/check only read local files. No remote probe happens implicitly.

Named Wrangler environments resolve only their own non-inheritable bindings and vars. Root D1/R2/Queue/DO bindings never satisfy a named environment. Environment names supported by the local TOML reader are alphanumeric/underscore/hyphen identifiers; quoted/dotted names are explicitly unsupported. This is a limitation of local config parsing, not a forced development/staging/production naming policy. JSONC and complex TOML forms remain unsupported; do not mistake missing parsed bindings for remote absence.

## Readiness evidence

The old status fields declared / binding_configured / missing_binding remain compatible. The new readiness field is separate:

- declared: Contract/provider resolution exists.
- configured: a matching local environment binding exists.
- validated: provider/target/binding match and required local resource identifier/class is present and non-placeholder, with D1 UUID syntax checked and duplicate binding declarations rejected.
- reachable: reserved for an explicit successful remote probe; local inspection never emits it.
- ready: reserved for application smoke evidence; neither local configuration nor WASM host simulation establishes it.

Validated is local deployment metadata evidence, not proof of remote existence, credentials, migrations, DO exports or consumer registration. Queues may be producer-only; declaring a Queue binding does not imply that this Worker consumes it. Native/Container providers without deployment bindings remain declared until application acquisition/smoke is observed.

## Drift and diagnostics

Missing/wrong binding, target/provider mismatch, duplicate resource binding and an explicit environment DATABASE_URL selecting another provider or D1 binding fail. DATABASE_URL values are redacted. Secret-supplied URLs cannot be checked offline; use db.openForContract to verify actual runtime selection before acquisition. Strict mode additionally rejects absent/placeholder resource identifiers and absent DO class metadata. Missing bindings print environment, provider, binding, problem and requiring routes. JSON retains the route capability graph alongside per-provider status/readiness.

Generated glue uses dynamic binding names selected by checked owners. Keep managed JS in sync when using the additive R2 page and Realtime ABI. CLI managed-file protections still apply; preflight does not overwrite protected glue. Local validation cannot attest arbitrary user-edited glue or detect whether a custom queue dispatcher actually calls its owner. Optional adapter/application smoke is the next evidence level.

## Compatibility and provisioning

Deploy now rejects placeholder D1 IDs instead of automatically creating/updating resources. This is an intentional CLI behavior change: resource creation must be an explicitly invoked platform action, separate from Contract declaration, check and deploy. Existing Db/Store/Queue/Realtime manual APIs are preserved. Existing non-placeholder deploy argv and migrations remain unchanged.

--environment is passed to Wrangler deployment, not just displayed by inspection. Combining named-environment deployment with --migrate currently fails closed with EnvironmentMigrationUnsupported rather than applying SQL to the root environment database. Run explicit environment-aware platform migrations separately. Threaded remains Native default; Reactor remains parked/fail-closed.
