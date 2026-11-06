# v0.2.1 — Performance & Reliability

Release commit: `2714af09fb6c910581a8397c0cb69ebe6a4eccda`. Validated with 23 CI jobs and Linux/macOS ThreadSanitizer.

## Highlights

- Monotonic DB Pool acquisition deadlines, nonblocking acquisition, explicit close
  and cooperative borrower/waiter shutdown, with existing acquire behavior retained.
- Opt-in bounded-cardinality Threaded connection/lifecycle and request-phase metrics.
- Correct buffered HTTP request-tail handling and owned idle-shutdown notification.
- SQLite prepared-handle cleanup on statement-wrapper allocation failure.
- Typed enum/tagged-union/error wire schemas shared by OpenAPI and generated clients.
- Storage download headers now remain valid after reader cleanup, including HEAD
  and buffered Workers responses. A Consumer firmware HEAD crash exposed this bug.
- Safer CLI version compatibility and fail-closed handling of unsupported deploy flags.

Native production remains Threaded. Reactor remains parked/fail-closed. Existing
competitive/DB benchmark data is retained; no new performance win is asserted here.

## Compatibility and migration

Existing App/Context, handlers, DB, Pool, Store and provider interfaces remain.
No database schema migration is introduced by the framework update. Consumer
configuration and SQL migration state still require separate validation.

Regenerated TypeScript enums are narrower than arbitrary strings, and void union
payloads use closed empty objects rather than permissive `{}`. Narrow caller input
and fix invalid payloads; this is a generated-source compatibility consideration,
not a changed JSON wire format for valid requests. Dotted route identifiers are
now emitted as valid TypeScript names; inspect regenerated caller references.

Use the matching CLI. `akamata deploy --dry-run` is unsupported and now safely
errors before build/migration/deployment instead of falling through. Use explicit
`wrangler deploy --dry-run --config PATH` after reviewing the configuration.
Unknown deploy options also fail fast. Update/sync preserve app-owned files and
refuse unreviewed edits to managed glue. Custom glue remains app-owned.

## Known limitations

Workers streaming still uses the documented buffered response ABI; staging success
for these applications does not certify all adapters or every Cloudflare capability.
No production provider, hardware-client or production JWT-secret configuration
certification was performed. Named-environment migration and custom glue limitations
remain documented. No Reactor promotion, automatic production resource creation,
production DB switch or exactly-once Queue claim is included.


## Zig 0.17 fetch-cache note

If a build reports an `N-V-...` hash after a bare `zig fetch`, use `zig fetch --save=akamata https://github.com/moribit/Akamata/archive/refs/tags/v0.2.1.tar.gz` from the Consumer project, then rebuild. This works around a reproduced Zig 0.17 archive-root recompression/cache issue. The immutable release hash remains `akamata-0.2.1-uJIoI3crPQE12CxtQ0Iv_d0wHvo0M3USWct-sZKaIc1_`; never weaken hash checking or replace it with the naked-package hash.

Published: https://github.com/moribit/Akamata/releases/tag/v0.2.1
