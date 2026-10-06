const std = @import("std");
const STABLE_HASH = @import("../release.zig").STABLE_HASH;

pub const tmpl_build_zig = @embedFile("../templates/build.zig.tpl");

pub const tmpl_build_zon = @embedFile("../templates/build.zig.zon.tpl");

pub const tmpl_main = @embedFile("../templates/main.zig.tpl");
pub const tmpl_minimal_main = @embedFile("../templates/minimal_main.zig.tpl");
pub const tmpl_minimal_worker = @embedFile("../templates/minimal_worker.zig.tpl");
pub const tmpl_minimal_readme = @embedFile("../templates/minimal_README.md.tpl");

pub const tmpl_worker = @embedFile("../templates/worker.zig.tpl");

pub const tmpl_gitignore = @embedFile("../templates/.gitignore.tpl");

pub const tmpl_readme = @embedFile("../templates/README.md.tpl");

pub const tmpl_wrangler = @embedFile("../templates/wrangler.toml.tpl");

// Both `init` and `sync` pass this full bridge template through the same
// capability-aware renderer below.
pub const tmpl_worker_index = @embedFile("../templates/worker_index.mjs.tpl");

pub const tmpl_dockerfile = @embedFile("../templates/Dockerfile.tpl");

pub const tmpl_wasm_dispatch = @embedFile("../templates/wasm_dispatch.mjs.tpl");

pub const tmpl_internal_routes = @embedFile("../templates/internal_routes.mjs.tpl");

pub const tmpl_realtime_object = @embedFile("../templates/realtime_object.mjs.tpl");

test "scaffold dependency is remote, pinned, and locally overridable" {
    try std.testing.expect(std.mem.indexOf(u8, tmpl_build_zon, ".url = \"https://github.com/moribit/Akamata/archive/") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_build_zon, ".hash = \"akamata-") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_build_zon, "../Akamata") == null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_build_zon, "zig build --fork=") != null);
}

test "scaffold dependency tracks the current stable release" {
    try std.testing.expect(std.mem.indexOf(u8, tmpl_build_zon, "archive/refs/tags/v0.2.0.tar.gz") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_build_zon, STABLE_HASH) != null);
}

test "Workers scaffold guards zero-length wasm memory access" {
    try std.testing.expect(std.mem.indexOf(u8, tmpl_worker_index, "len === 0 ? new Uint8Array(0)") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_worker_index, "if (bytes.length > 0) new Uint8Array(memory.buffer") != null);
}

test "Workers scaffold serializes the complete JSPI wasm dispatch" {
    try std.testing.expect(std.mem.indexOf(u8, tmpl_worker_index, "./wasm_dispatch.mjs") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_worker_index, "wasmDispatchQueue.run(() => dispatchWasmUnlocked(request))") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_worker_index, "const respLen = exports_ref.last_response_length()") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_wasm_dispatch, "await previous") != null);
}

test "Workers scaffold includes current observability clock imports" {
    try std.testing.expect(std.mem.indexOf(u8, tmpl_worker_index, "akamata_monotonic_ns") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_worker_index, "performance.now()") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_worker_index, "akamata_unix_micros") != null);
}

test "generated app exposes the migration runner expected by the CLI" {
    try std.testing.expect(std.mem.indexOf(u8, tmpl_main, "\"migrate-up\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_main, "am.model.migrate.Migrator") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_main, "loadMigrationsFromDir") != null);
}

test "generated app exposes typed management runner protocol" {
    try std.testing.expect(std.mem.indexOf(u8, tmpl_main, "akamata-runner") != null);
    try std.testing.expect(std.mem.indexOf(u8, tmpl_main, "runnerCommand") != null);
}
