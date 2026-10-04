const std = @import("std");

pub fn isHelpArg(arg: []const u8) bool {
    return std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h");
}

pub const known_commands = [_][]const u8{
    "init", "build", "dev", "deploy", "sync", "update", "sync-glue", "db", "migrate", "check", "inspect", "routes", "doctor", "config", "test", "runner", "generate", "destroy", "api", "client", "help", "version",
};

/// Lightweight nearest-match — if the user typed something within 2 edits
/// of a known command, suggest it. Avoids pulling in a real Levenshtein
/// library for what's a developer-experience nicety.
pub fn suggestCommand(input: []const u8) ?[]const u8 {
    var best: ?[]const u8 = null;
    var best_d: usize = 3; // require ≤ 2 edits to suggest
    for (known_commands) |cmd| {
        const d = editDistance(input, cmd);
        if (d < best_d) {
            best_d = d;
            best = cmd;
        }
    }
    return best;
}

pub fn editDistance(a: []const u8, b: []const u8) usize {
    // Plain Wagner-Fischer with two rolling rows. O(len(a) * len(b)) time.
    if (a.len == 0) return b.len;
    if (b.len == 0) return a.len;
    if (a.len > 64 or b.len > 64) return @max(a.len, b.len);
    var prev: [65]usize = undefined;
    var curr: [65]usize = undefined;
    var j: usize = 0;
    while (j <= b.len) : (j += 1) prev[j] = j;
    var i: usize = 1;
    while (i <= a.len) : (i += 1) {
        curr[0] = i;
        var k: usize = 1;
        while (k <= b.len) : (k += 1) {
            const cost: usize = if (a[i - 1] == b[k - 1]) 0 else 1;
            const ins = curr[k - 1] + 1;
            const del = prev[k] + 1;
            const sub = prev[k - 1] + cost;
            curr[k] = @min(@min(ins, del), sub);
        }
        @memcpy(prev[0 .. b.len + 1], curr[0 .. b.len + 1]);
    }
    return prev[b.len];
}

pub fn usage() !void {
    const msg =
        \\Usage: akamata <command> [args]
        \\Version: akamata 0.1.5 (use `akamata --version` for the version)
        \\
        \\Commands:
        \\  init <name> [--target=native|workers|containers|both] [--d1] [--r2] [--queue] [--realtime]
        \\      Scaffold a new Akamata app.
        \\  build [--workers|--containers] [--optimize=MODE]
        \\      Build the current app (native by default).
        \\  dev [--no-watch]
        \\      Run the app natively with hot reload: watches ./src (and
        \\      build.zig, .env), rebuilds and restarts on change. Ctrl-C to
        \\      stop. --no-watch does a one-shot `zig build run`.
        \\  deploy [--workers|--containers] [--config=PATH] [--migrate=SQL] [--optimize=MODE]
        \\      Build and deploy. For --workers:
        \\        * --config=PATH      wrangler.toml location
        \\                             (default: deploy/wrangler.toml, then wrangler.toml)
        \\        * --optimize=MODE    wasm optimize mode (default: ReleaseFast).
        \\                             ReleaseSmall for the smallest bundle.
        \\        * --migrate=SQL      apply the SQL file to the remote D1 before deploy.
        \\                             If the D1 in wrangler.toml has the placeholder
        \\                             database_id, it is auto-created and the ID is
        \\                             written back into the config.
        \\  sync-glue [--config=PATH] [--force]
        \\      Deprecated alias for the safe managed-file `sync` command.
        \\  sync [--force] [--dry-run] [--config=PATH]
        \\      Synchronize framework-managed Workers files without changing
        \\      wrangler.toml or application source.
        \\  update [--to=vX.Y.Z] [--sync] [--force] [--dry-run]
        \\      Update the Akamata dependency, optionally sync managed files,
        \\      then validate Native and Workers builds.
        \\  db <sql-file> [--local|--remote] [--config=PATH]
        \\      Run a SQL migration against the D1 binding `DB`.
        \\  migrate generate <name> [--dir=migrations]
        \\      Create a new migration file `<timestamp>_<name>.sql` in
        \\      <dir> (default: ./migrations).
        \\  migrate up [--dir=migrations] [--target=VERSION]
        \\      Apply all pending migrations against the active database.
        \\      Reads DATABASE_URL from env/.env (same as your app). Records
        \\      each applied version in the `schema_migrations` table.
        \\  check [--quick]
        \\      Validate project structure and run the full test suite.
        \\  inspect [--json]
        \\      Print targets, migrations, environment, and project health.
        \\  routes [--json]
        \\      Print the application's OpenAPI route graph.
        \\  doctor [--json]
        \\      Diagnose the local project and deployment toolchain.
        \\  config <show|check>
        \\      Inspect configuration keys without exposing secret values.
        \\  test [--watch]
        \\      Run the application test suite once or continuously.
        \\  runner <command> [args]
        \\      Execute an application-defined typed management command.
        \\  generate resource <name> [field:type ...] [--pretend]
        \\      Generate a typed model/handler/test plus SQL migration.
        \\  destroy resource <name> [--force]
        \\      Remove files previously created by the resource generator.
        \\  api diff <before.json> <after.json>
        \\      Detect removed OpenAPI paths and operations (non-zero on breakage).
        \\  client [--tui] | [METHOD] <path-or-url> [options]
        \\      Explore and call an Akamata API. No arguments opens the TUI.
        \\  api call <operation-id> [options]
        \\      Resolve an operation from /openapi.json and call it.
        \\
    ;
    std.debug.print("{s}", .{msg});
}

pub fn commandUsage(command: []const u8) !void {
    const msg = if (std.mem.eql(u8, command, "init"))
        \\Usage: akamata init <name> [options]
        \\
        \\Scaffold a new Akamata application.
        \\
        \\Options:
        \\  --target=native|workers|containers|both  Generated deployment targets (default: native)
        \\  --d1 --r2 --queue --realtime             Select Workers capabilities and generated glue
        \\  -h, --help                               Show this help
        \\
    else if (std.mem.eql(u8, command, "build"))
        \\Usage: akamata build [options]
        \\
        \\Build the current application.
        \\
        \\Options:
        \\  --workers                 Build the Workers wasm target
        \\  --containers              Build a static Linux container target
        \\  --optimize=MODE           Zig optimize mode
        \\  -h, --help                Show this help
        \\
    else if (std.mem.eql(u8, command, "deploy"))
        \\Usage: akamata deploy [options]
        \\
        \\Build and deploy the current application.
        \\
        \\Options:
        \\  --workers                 Deploy to Cloudflare Workers (default)
        \\  --containers              Build the Cloudflare Containers image
        \\  --config=PATH             Wrangler config path
        \\  --migrate=SQL             Apply a SQL file to remote D1 before deploy
        \\  --optimize=MODE           Workers optimize mode
        \\  -h, --help                Show this help without deploying
        \\
    else if (std.mem.eql(u8, command, "sync"))
        \\Usage: akamata sync [options]
        \\
        \\Synchronize framework-managed generated files. User-owned source,
        \\build.zig, and wrangler.toml are never changed.
        \\
        \\Options:
        \\  --config=PATH             Wrangler config used to resolve paths/name
        \\  --dry-run                 Show changes without writing files
        \\  --force                   Replace locally modified managed files
        \\  -h, --help                Show this help
        \\
    else if (std.mem.eql(u8, command, "update"))
        \\Usage: akamata update [options]
        \\
        \\Update the .akamata dependency in build.zig.zon and validate builds.
        \\
        \\Options:
        \\  --to=vX.Y.Z               Target release (default: bundled latest stable)
        \\  --sync                    Also synchronize framework-managed files
        \\  --dry-run                 Show changes without writing or building
        \\  --force                   Allow --sync to replace local managed edits
        \\  --config=PATH             Wrangler config passed to --sync
        \\  -h, --help                Show this help
        \\
    else if (std.mem.eql(u8, command, "db"))
        \\Usage: akamata db <sql-file> [options]
        \\
        \\Apply a SQL file to the configured D1 database.
        \\
        \\Options:
        \\  --local                   Apply to local D1 (default)
        \\  --remote                  Apply to remote D1
        \\  --config=PATH             Wrangler config path
        \\  -h, --help                Show this help
        \\
    else if (std.mem.eql(u8, command, "migrate"))
        \\Usage: akamata migrate <generate|up|status|plan|rollback|redo> [options]
        \\
        \\Commands:
        \\  generate <name>           Create a timestamped SQL migration
        \\  up                        Apply pending migrations through the generated app runner
        \\  status                    Show applied/pending state for every migration
        \\  plan                      Preview migrations that `up` would apply
        \\  rollback                  Revert the latest migration using its down section
        \\  redo                      Roll back and reapply the latest migration
        \\
        \\Options:
        \\  --dir=PATH                Migration directory (default: migrations)
        \\  --target=VERSION          Stop after VERSION when applying
        \\  -h, --help                Show this help
        \\
    else if (std.mem.eql(u8, command, "check"))
        \\Usage: akamata check [--quick]
        \\Validate build files and source layout; without --quick also run `zig build test`.
        \\
    else if (std.mem.eql(u8, command, "inspect"))
        \\Usage: akamata inspect [--json]
        \\Show a deterministic project summary suitable for humans or tooling.
        \\
    else if (std.mem.eql(u8, command, "routes"))
        \\Usage: akamata routes [--json]
        \\       akamata routes explain METHOD /path
        \\Inspect routes, effective middleware, and endpoint budgets.
        \\
    else if (std.mem.eql(u8, command, "doctor"))
        \\Usage: akamata doctor [--json]
        \\Check project manifests, entry point, deployment files, and migrations.
        \\
    else if (std.mem.eql(u8, command, "config"))
        \\Usage: akamata config <show|check>
        \\Print configuration keys and presence without revealing values.
        \\
    else if (std.mem.eql(u8, command, "test"))
        \\Usage: akamata test [--watch]
        \\Run `zig build test`, optionally in watch mode.
        \\
    else if (std.mem.eql(u8, command, "runner"))
        \\Usage: akamata runner <command> [args]
        \\Delegate to the application's typed management-command runner.
        \\
    else if (std.mem.eql(u8, command, "generate") or std.mem.eql(u8, command, "destroy"))
        \\Usage: akamata generate resource <name> [field:type ...] [--pretend]
        \\       akamata destroy resource <name> [--force]
        \\
    else if (std.mem.eql(u8, command, "api"))
        \\Usage: akamata api diff <before.json> <after.json>
        \\       akamata api call <operation-id> [client options] [--spec=PATH]
        \\Diff reports removed paths and operations. Call resolves method/path from OpenAPI.
        \\
    else if (std.mem.eql(u8, command, "client"))
        \\Usage: akamata client [--tui] [--base-url=URL]
        \\       akamata client [METHOD] <path-or-url> [options]
        \\
        \\With no request arguments, opens the full-screen endpoint explorer.
        \\Routes are inspected from the application runner without exposing an HTTP route.
        \\
        \\Options:
        \\  --base-url=URL           Base for relative paths (default: http://127.0.0.1:8080)
        \\  --header=NAME:VALUE      Add a request header (repeatable; -H= is an alias)
        \\  --bearer=TOKEN           Add an Authorization Bearer header
        \\  --query=NAME=VALUE       Add a percent-encoded query parameter (repeatable)
        \\  --param=NAME=VALUE       Fill an OpenAPI {path} parameter for `api call`
        \\  --json=JSON              JSON body and content-type (validated before sending)
        \\                           Prefix with @ to read JSON from a file
        \\  --data=TEXT              Raw request body; @PATH reads from a file
        \\  --include                Print status and response headers
        \\  --raw                    Do not pretty-print JSON responses
        \\  --fail                   Return non-zero for HTTP 4xx/5xx
        \\  --max-bytes=N            Response limit (default: 4 MiB; maximum: 64 MiB)
        \\
    else {
        std.debug.print("akamata: unknown help topic `{s}`\n\n", .{command});
        try usage();
        return;
    };
    std.debug.print("{s}", .{msg});
}

// ---- init ----

test "suggestCommand: 'deplyo' -> 'deploy'" {
    const got = suggestCommand("deplyo") orelse return error.TestExpectedSuggestion;
    try std.testing.expectEqualStrings("deploy", got);
}

test "suggestCommand: 'migrtae' -> 'migrate'" {
    const got = suggestCommand("migrtae") orelse return error.TestExpectedSuggestion;
    try std.testing.expectEqualStrings("migrate", got);
}

test "suggestCommand: completely different input returns null" {
    try std.testing.expect(suggestCommand("xyz") == null);
}

test "help flags are recognized before command execution" {
    try std.testing.expect(isHelpArg("--help"));
    try std.testing.expect(isHelpArg("-h"));
    try std.testing.expect(!isHelpArg("--workers"));
}
