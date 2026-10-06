# {{NAME}}

An Akamata web app.

Framework upgrades update both the Zig dependency and generated Workers glue:

```bash
akamata update --sync --dry-run
akamata update --sync
```

`wrangler.toml` and application source are user-owned and are never replaced
by `akamata sync`; generated hashes live in `.akamata/managed-files.json`.

## Usage

```bash
# Run locally
zig build run
# or
akamata dev

# Create and apply a versioned SQLite migration
akamata migrate generate add_widgets
# Edit migrations/<timestamp>_add_widgets.sql, then:
akamata migrate up

# Build for Cloudflare Workers (WASM)
akamata build --workers

# Build a static binary for Cloudflare Containers
akamata build --containers

# Deploy
akamata deploy --workers       # requires npx wrangler login
akamata deploy --containers    # requires docker
```

`build.zig.zon` pins a release-compatible Akamata revision and Zig content
hash. To develop against a local Akamata checkout temporarily, run
`zig build --fork=/path/to/Akamata`.

## Portable requirements

With a framework revision that exports `capability.Application`, the scaffold
declares a database requirement and adds route-level requirements. Existing
release dependencies keep their original registration behavior; capability
inspection then reports `FrameworkUpgradeRequired` until upgraded.

```bash
akamata inspect capabilities --target=native
akamata inspect capabilities --target=workers --config=deploy/wrangler.toml
akamata check --quick --capabilities --target=workers --config=deploy/wrangler.toml
```

Workers database deployments require a D1 binding (`akamata init ... --d1`
or explicitly configure `DB`). Inspection does not create resources. Provider
declarations must match explicit runtime wiring, including any Turso URL
override. Queue/Realtime owners and lifecycle remain application-controlled.
