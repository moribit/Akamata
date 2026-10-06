#!/bin/sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "usage: scaffold_smoke.sh /path/to/akamata [local-akamata-checkout]" >&2
  exit 2
fi

cli=$1
local_checkout=${2:-}
if [ -n "$local_checkout" ]; then
  local_checkout=$(cd "$local_checkout" && pwd)
fi
case "$cli" in
  /*) ;;
  *) cli="$(cd "$(dirname "$cli")" && pwd)/$(basename "$cli")" ;;
esac
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/akamata-scaffold-test.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

cd "$tmp_dir"
"$cli" init smokeapp --target=both
cd smokeapp

test ! -e ../Akamata
if grep -F '../Akamata' build.zig.zon >/dev/null; then
  echo "generated build.zig.zon still depends on ../Akamata" >&2
  exit 1
fi
grep -F '.url = "https://github.com/moribit/Akamata/archive/' build.zig.zon >/dev/null
grep -F '.hash = "akamata-' build.zig.zon >/dev/null
grep -F 'len === 0 ? new Uint8Array(0)' deploy/worker/index.mjs >/dev/null
grep -F 'if (bytes.length > 0) new Uint8Array(memory.buffer' deploy/worker/index.mjs >/dev/null
grep -F 'wasmDispatchQueue.run(() => dispatchWasmUnlocked(request))' deploy/worker/index.mjs >/dev/null
grep -F 'await previous' deploy/worker/wasm_dispatch.mjs >/dev/null
grep -F 'deploy/worker/index.mjs' .akamata/managed-files.json >/dev/null
if grep -F 'deploy/worker/realtime_object.mjs' .akamata/managed-files.json >/dev/null; then
  echo "default scaffold unexpectedly manages Realtime glue" >&2
  exit 1
fi
test ! -e deploy/worker/realtime_object.mjs
grep -F 'if (lower === "host" || lower === "content-length") continue' deploy/worker/index.mjs >/dev/null

build_app() {
  if [ -n "$local_checkout" ]; then
    zig build --fork="$local_checkout" "$@"
  else
    zig build "$@"
  fi
}
migrate_up() {
  if [ -n "$local_checkout" ]; then
    build_app run -- migrate-up
  else
    "$cli" migrate up
  fi
}
build_app
build_app -Dbackend=workers -Doptimize=ReleaseSmall
build_app -Doptimize=ReleaseSafe
build_app -Dbackend=workers -Doptimize=ReleaseSafe
migrate_up
"$cli" migrate generate create_smoke
migration_file=$(find migrations -type f -name '*_create_smoke.sql' -print | head -n 1)
test -n "$migration_file"
printf '%s\n' 'CREATE TABLE IF NOT EXISTS smoke_items (id INTEGER PRIMARY KEY);' >> "$migration_file"
migrate_up
migrate_up

if [ -n "$local_checkout" ]; then
  # Exercise the public helper as well as the independently generated build.
  cp "$local_checkout/src/build_helpers/akamata_build.zig" build_helper.zig
  cp build.zig build.zig.generated
  cat > build.zig <<'HELPER_BUILD'
const std = @import("std");
const helper = @import("build_helper.zig");
pub fn build(b: *std.Build) void {
    helper.app(b, .{ .name = "smokeapp", .root_source_file = "src/main.zig" });
}
HELPER_BUILD
  build_app run -- migrate-up
  # Restore the generated build's dedicated worker.zig entry for Workers tests.
  cp build.zig.generated build.zig
  # The same metadata must survive a named binding and an explicit Turso
  # provider. Tooling runs before DB initialization, so no services are opened.
  cp src/main.zig src/main.zig.default
  python3 - <<'PY'
from pathlib import Path
p = Path("src/main.zig")
source = p.read_text()
assert 'const DatabaseBinding = am.binding.D1("DB")' in source
p.write_text(source.replace('const DatabaseBinding = am.binding.D1("DB")', 'const DatabaseBinding = am.binding.D1("REPORTS")'))
PY
  build_app run -- akamata-capabilities workers > named-contract.json
  python3 -c 'import json; d=json.load(open("named-contract.json")); assert d["providers"][0]["binding"] == "REPORTS"'
  build_app -Dbackend=workers -Doptimize=ReleaseSafe
  python3 - <<'PY'
from pathlib import Path
p = Path("src/main.zig")
source = p.read_text()
assert '.provider = am.capability.defaultProvider(.database, target)' in source
p.write_text(source.replace('.provider = am.capability.defaultProvider(.database, target)', '.provider = .turso').replace('.binding = if (target == .workers) DatabaseBinding.binding_name else null', '.binding = null'))
PY
  build_app run -- akamata-capabilities workers > turso-contract.json
  python3 -c 'import json; d=json.load(open("turso-contract.json")); assert d["providers"][0]["provider"] == "turso" and d["providers"][0]["binding"] is None'
  build_app -Dbackend=workers -Doptimize=ReleaseSafe
fi

echo "scaffold smoke test: OK"
