# Migrating to Zig 0.17 (Akamata v0.1.5)

Akamata v0.1.5 requires Zig 0.17.0. Native, Workers, the CLI, and generated projects have moved from the Zig 0.16 implementation in v0.1.4. Zig 0.16 compatibility is no longer maintained.

## Changes

| Area | Before | v0.1.5 |
| --- | --- | --- |
| C headers | `@cImport` / `@cInclude` | Build-time header translation and named module imports |
| Array repetition | `[_]u8{0} ** N` | `@as([N]u8, @splat(0))` |
| Reflection | `.fields`, function `.params`, old error-set representation | Parallel name/type/attribute arrays, `.param_types`, `.error_names` |
| Tuple types | `std.meta.Tuple(types)` | `@Tuple(types)` |
| Sentinel strings | `dupeZ` / `bufPrintZ` | `dupeSentinel` / `bufPrintSentinel` with explicit sentinel `0` |
| Build run arguments | `b.args` | `run.addPassthruArgs()` |
| Toolchain | Zig 0.16.0 | Zig 0.17.0 in manifests, CI, and Docker |

SQLite headers are translated for Native; OpenSSL headers are translated only for Native with `-Dopenssl=true`. Workers do not gain these Native dependencies. The implementation uses `std.Build.addTranslateC`, which remains available in 0.17 but is deprecated. A future toolchain migration should consider the official external translate-c package.

`src/reflection.zig` builds a shared field view from the new reflection arrays. Models, JSON, OpenAPI, contracts, and event/protocol generators retain names, types, enum values, and defaults. Input projections also use the new struct attribute type and sentinel field names.

ReleaseSafe testing exposed an array lifetime issue in `Value.fromAny`: returning a slice into a by-value parameter could lose its contents. Per-type inline conversion now keeps the conversion in the caller, including optional and pointer cases. Buffers remain borrowed and must outlive retained values. The SQLite regression checks both length and stored content.

## Upgrading an application

1. Confirm `zig version` reports `0.17.0`.
2. Build the v0.1.5 CLI with `zig build cli -Doptimize=ReleaseSafe` and use `zig-out/bin/akamata`.
3. Set the application's `.minimum_zig_version` to `"0.17.0"` in `build.zig.zon`.
4. Replace argument forwarding in the application's `build.zig`:

```zig
const run = b.addRunArtifact(exe);
run.addPassthruArgs();
b.step("run", "run the app (native)").dependOn(&run.step);
```

5. After migrating removed APIs in your own application code, from the application directory run the new CLI's `akamata update --to=v0.1.5 --sync`. It updates the dependency and validates Native and Workers builds. Review local managed-glue edits before syncing.
6. Migrate removed syntax and APIs in application code using the table above. `update --sync` does not automatically rewrite application sources or `build.zig`.
7. Run application tests and builds for Native and Workers, including OpenSSL configuration when applicable.

The new CLI's `akamata init` generates a Zig 0.17 build and a v0.1.5 dependency. For local development, retain the release pin and override it with `zig build --fork=/absolute/path/to/Akamata`.

## Validation

On macOS with Zig 0.17.0, migration validation covered:

- All 140 unit tests in Debug and ReleaseSafe; HTTP integration and tasks tests; 13 compile-fail diagnostics.
- Six Node.js realtime and concurrent Workers WASM dispatch tests.
- Native chat, guestbook, bench, tasks, and device_messaging examples; available Workers entrypoints.
- CLI, OpenSSL-enabled Native build, Linux x86_64 musl cross-builds, router and portable benchmarks.
- Generated Native/Workers applications, SQL migrations, and run-argument forwarding in generated builds and the public build helper.
- Project update/sync and D1, R2, Queue, and Realtime capability preservation.

CI now uses Zig 0.17.0. Checkout regression tests use `--fork` so they exercise the current source rather than an older published package. Local validation does not include Cloudflare deployments or runtime execution on every release target.

## References

- [Zig 0.17.0 release notes](https://ziglang.org/download/0.17.0/release-notes.html)
- [Akamata v0.1.5 release notes](../releases/v0.1.5.md)
- [Quick Start](quickstart.md)
