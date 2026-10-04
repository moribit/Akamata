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
  cat > build.zig <<'HELPER_BUILD'
const std = @import("std");
const helper = @import("build_helper.zig");
pub fn build(b: *std.Build) void {
    helper.app(b, .{ .name = "smokeapp", .root_source_file = "src/main.zig" });
}
HELPER_BUILD
  build_app run -- migrate-up
fi

echo "scaffold smoke test: OK"
