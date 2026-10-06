# {{NAME}}

Start with one ordinary function in `src/main.zig`; no database or provider is initialized.

```sh
zig build run
curl http://127.0.0.1:8080/
zig build -Dbackend=workers
```

`PORT` configures the Native port. Workers uses `src/worker.zig` and generated managed glue. Resource creation is explicit; deploy configuration does not certify remote readiness.

The dependency is pinned to v0.2.0, including the ordinary-function typed API. For framework development, use `zig build --fork=/path/to/Akamata run`. Existing explicit App/Context handlers remain supported.

For the DB/validation/migration tutorial instead, create a separate project with `akamata init <name> --template=notes`. Existing projects keep their source files during update/sync.
Test the same Hello application without sockets with `akamata test` or `zig build test`.
