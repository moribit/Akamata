# {{NAME}}

Start with one ordinary function in `src/main.zig`; no database or provider is initialized.

```sh
zig build run
curl http://127.0.0.1:8080/
zig build -Dbackend=workers
```

`PORT` configures the Native port. Workers uses `src/worker.zig` and generated managed glue. Resource creation is explicit; deploy configuration does not certify remote readiness.

The dependency is pinned to the published release. To try the latest typed API with a local checkout, use `zig build --fork=/path/to/Akamata run`. The bootstrap preserves the same Hello response on the pinned release. When growing the application, use the typed-handler guides on latest main or the existing explicit App/Context API on the release.

For the DB/validation/migration tutorial instead, create a separate project with `akamata init <name> --template=notes`. Existing projects keep their source files during update/sync.
Test the same Hello application without sockets with `akamata test` or `zig build test`.
