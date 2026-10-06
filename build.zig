const std = @import("std");

pub const Backend = enum { native, workers };
pub const Example = enum { chat, guestbook, bench, tasks, device_messaging };
pub const BenchRouter = enum { runtime, static };
pub const BenchRouteKind = enum { static, parameter, wildcard };

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const backend = b.option(Backend, "backend", "deployment backend (native | workers)") orelse .native;
    const example = b.option(Example, "example", "which example to build (chat | guestbook | bench | tasks | device_messaging)") orelse .chat;
    // OpenSSL is opt-in and only needed for FCM RS256 signing. The HTTPS
    // client and Turso path now use std.crypto.tls — no OpenSSL needed.
    // Enable with `-Dopenssl=true` if you build the FCM push example.
    const with_openssl = b.option(bool, "openssl", "link OpenSSL (only needed for FCM RS256 signing)") orelse false;
    const bench_route_count = b.option(usize, "bench-routes", "router benchmark route count") orelse 100;
    const bench_router = b.option(BenchRouter, "bench-router", "router benchmark implementation") orelse .runtime;
    const bench_route_kind = b.option(BenchRouteKind, "bench-route-kind", "router benchmark route kind") orelse .static;
    const bench_middleware_count = b.option(usize, "bench-middlewares", "router benchmark middleware count") orelse 0;
    // Register before lazy package discovery can return and restart configure.
    const runtime_tsan = b.option(bool, "runtime-tsan", "instrument only the private runtime Contract fixture with ThreadSanitizer") orelse false;
    const runtime_cost = b.option(bool, "runtime-cost", "private Native runtime cost attribution (not performance benchmark)") orelse false;

    const native_target = b.standardTargetOptions(.{});
    const target = switch (backend) {
        .native => native_target,
        .workers => b.resolveTargetQuery(.{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
        }),
    };

    // Publish as a named module so downstream consumers can do
    // `dep.module("akamata")` from their own build.zig.
    const am_mod = b.addModule("akamata", .{
        .root_source_file = b.path("src/akamata.zig"),
        .target = target,
        .optimize = optimize,
    });

    const documentation_step = b.step("documentation-test", "compile README source and run documentation application contracts");
    const documentation_links = b.addSystemCommand(&.{ "python3", "tests/documentation_links.py" });
    documentation_step.dependOn(&documentation_links.step);
    const opts = b.addOptions();
    opts.addOption(Backend, "backend", backend);
    opts.addOption(bool, "with_openssl", with_openssl);
    opts.addOption(bool, "runtime_cost", runtime_cost);
    am_mod.addOptions("build_options", opts);

    const sqlite_flags = &[_][]const u8{
        "-DSQLITE_THREADSAFE=1",
        "-DSQLITE_DQS=0",
        "-DSQLITE_OMIT_LOAD_EXTENSION",
        "-DSQLITE_DEFAULT_FOREIGN_KEYS=1",
        "-DSQLITE_USE_URI=1",
        "-std=c99",
    };
    if (backend == .native) {
        am_mod.addCSourceFile(.{
            .file = b.path("third_party/sqlite/sqlite3.c"),
            .flags = sqlite_flags,
        });
        am_mod.addCSourceFile(.{
            .file = b.path("third_party/sqlite/akamata_sqlite_shim.c"),
            .flags = sqlite_flags,
        });
        am_mod.addIncludePath(b.path("third_party/sqlite"));
        const Translator = (b.lazyImport(@This(), "translate_c") orelse return).Translator;
        const translate_c = b.lazyDependency("translate_c", .{}) orelse return;
        const sqlite_bindings: Translator = .init(translate_c, .{
            .c_source_file = b.path("third_party/sqlite/sqlite3.h"),
            .target = target,
            .optimize = optimize,
        });
        am_mod.addImport("sqlite3", sqlite_bindings.mod);
        am_mod.link_libc = true;
        if (with_openssl) {
            const openssl_bindings: Translator = .init(translate_c, .{
                .link_system_libs = &.{ .{ .name = "ssl" }, .{ .name = "crypto" } },
                .c_source_file = b.path("src/crypto/openssl.h"),
                .target = target,
                .optimize = optimize,
            });
            am_mod.addImport("openssl", openssl_bindings.mod);
            am_mod.linkSystemLibrary("ssl", .{});
            am_mod.linkSystemLibrary("crypto", .{});
        }
    }

    // === Example targets ===
    const example_root = switch (example) {
        .chat => switch (backend) {
            .native => "examples/chat/src/main.zig",
            .workers => "examples/chat/src/worker.zig",
        },
        .guestbook => switch (backend) {
            .native => "examples/guestbook/src/main.zig",
            .workers => "examples/guestbook/src/worker.zig",
        },
        .bench => "examples/bench/src/main.zig",
        .tasks => "examples/tasks/src/main.zig",
        .device_messaging => if (backend == .workers) "examples/device_messaging/src/worker.zig" else "examples/device_messaging/src/main.zig",
    };
    const example_name = switch (example) {
        .chat => if (backend == .workers) "chat_worker" else "chat",
        .guestbook => if (backend == .workers) "guestbook_worker" else "guestbook",
        .bench => "bench",
        .tasks => "tasks",
        .device_messaging => if (backend == .workers) "device_messaging_worker" else "device_messaging",
    };

    const exe = b.addExecutable(.{
        .name = example_name,
        .root_module = b.createModule(.{
            .root_source_file = b.path(example_root),
            .target = target,
            .optimize = if (backend == .workers) .ReleaseSmall else optimize,
            .imports = &.{.{ .name = "akamata", .module = am_mod }},
        }),
    });
    if (example == .bench) exe.root_module.addImport("bench_stats", b.createModule(.{
        .root_source_file = b.path("src/runtime_bench_stats.zig"),
        .target = target,
        .optimize = optimize,
    }));

    if (backend == .workers) {
        exe.entry = .disabled;
        exe.rdynamic = true;
        // Stable deployment alias: the selected Workers example supplies the
        // application WASM without coupling the JS bridge to `chat`.
        b.getInstallStep().dependOn(&b.addInstallFileWithDir(exe.getEmittedBin(), .bin, "akamata_worker.wasm").step);
    }
    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    run.addPassthruArgs();
    b.step("run", "run the selected example (native)").dependOn(&run.step);

    // The identical in-process application suite also runs as Workers WASM.
    // Test providers isolate application semantics from live Cloudflare APIs.
    if (backend == .workers) {
        const fixture_module = b.createModule(.{
            .root_source_file = b.path("tests/portable_application_worker.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "akamata", .module = am_mod }},
        });
        const fixture = b.addExecutable(.{ .name = "portable-application-worker", .root_module = fixture_module });
        fixture.entry = .disabled;
        fixture.rdynamic = true;
        const contract_runner = b.addSystemCommand(&.{ "node", "tests/portable_application_worker.mjs" });
        contract_runner.addArtifactArg(fixture);
        const binding_bridge = b.addSystemCommand(&.{ "node", "tests/d1_binding_bridge.mjs" });
        contract_runner.step.dependOn(&binding_bridge.step);
        const provider_bridge = b.addSystemCommand(&.{ "node", "tests/workers_provider_bridge_test.mjs" });
        contract_runner.step.dependOn(&provider_bridge.step);
        documentation_step.dependOn(&contract_runner.step);
        b.step("portable-application-test", "run shared application semantics inside Workers WASM with test providers").dependOn(&contract_runner.step);
    }

    // === akamata-cli ===
    const cli_module = b.createModule(.{
        .root_source_file = b.path("tools/akamata/src/main.zig"),
        .target = native_target,
        .optimize = optimize,
        .imports = &.{.{ .name = "akamata", .module = am_mod }},
    });
    cli_module.link_libc = true;
    const cli_exe = b.addExecutable(.{
        .name = "akamata",
        .root_module = cli_module,
    });
    const install_cli = b.addInstallArtifact(cli_exe, .{});
    b.step("cli", "build the akamata CLI binary").dependOn(&install_cli.step);

    // Compile-time/runtime router scaling benchmark. Kept separate from the
    // example selector so its specialization matrix is explicit in CI/scripts.
    const router_bench_opts = b.addOptions();
    router_bench_opts.addOption(usize, "route_count", bench_route_count);
    router_bench_opts.addOption(BenchRouter, "router", bench_router);
    router_bench_opts.addOption(BenchRouteKind, "route_kind", bench_route_kind);
    router_bench_opts.addOption(usize, "middleware_count", bench_middleware_count);
    const router_bench_mod = b.createModule(.{
        .root_source_file = b.path("examples/router_bench/src/main.zig"),
        .target = native_target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "akamata", .module = am_mod },
            .{ .name = "router_bench_options", .module = router_bench_opts.createModule() },
        },
    });
    const router_bench_exe = b.addExecutable(.{ .name = "router-bench", .root_module = router_bench_mod });
    const install_router_bench = b.addInstallArtifact(router_bench_exe, .{});
    b.step("router-bench", "build the route/middleware scaling benchmark").dependOn(&install_router_bench.step);

    const portable_bench_mod = b.createModule(.{
        .root_source_file = b.path("benchmark/portable.zig"),
        .target = native_target,
        .optimize = .ReleaseFast,
        .imports = &.{.{ .name = "akamata", .module = am_mod }},
    });
    portable_bench_mod.link_libc = true;
    const portable_bench_exe = b.addExecutable(.{ .name = "portable-bench", .root_module = portable_bench_mod });
    const run_portable_bench = b.addRunArtifact(portable_bench_exe);
    b.step("portable-bench", "benchmark typed events and realtime fan-out").dependOn(&run_portable_bench.step);

    // End-to-end scaffold regression test. Kept as an explicit step because
    // the default scaffold resolves its commit-pinned dependency over HTTPS.
    const scaffold_smoke = b.addSystemCommand(&.{ "sh", "tests/scaffold_smoke.sh" });
    scaffold_smoke.addArtifactArg(cli_exe);
    const scaffold_step = b.step("scaffold-test", "generate and build portable scaffolds against the pinned release");
    scaffold_step.dependOn(&scaffold_smoke.step);
    const minimal_release = b.addSystemCommand(&.{ "python3", "tests/minimal_scaffold.py" });
    minimal_release.addArtifactArg(cli_exe);
    scaffold_step.dependOn(&minimal_release.step);
    const scaffold_local = b.addSystemCommand(&.{ "sh", "tests/scaffold_smoke.sh" });
    scaffold_local.addArtifactArg(cli_exe);
    scaffold_local.addDirectoryArg2(b.path("."), .{});
    const scaffold_local_step = b.step("scaffold-local-test", "generate and build a scaffold against this checkout");
    const public_journey = b.addSystemCommand(&.{ "python3", "tests/public_journey.py" });
    public_journey.addArtifactArg(cli_exe);
    public_journey.addDirectoryArg2(b.path("."), .{});
    b.step("public-journey-test", "verify the published init/dev/test and typed Native/Workers journey").dependOn(&public_journey.step);
    scaffold_local_step.dependOn(&scaffold_local.step);
    const minimal_scaffold = b.addSystemCommand(&.{ "python3", "tests/minimal_scaffold.py" });
    minimal_scaffold.addArtifactArg(cli_exe);
    minimal_scaffold.addDirectoryArg2(b.path("."), .{});
    scaffold_local_step.dependOn(&minimal_scaffold.step);
    const project_update_sync = b.addSystemCommand(&.{ "sh", "tests/project_update_sync.sh" });
    project_update_sync.addArtifactArg(cli_exe);
    b.step("project-update-test", "upgrade and sync a legacy Native/Workers project safely").dependOn(&project_update_sync.step);
    const workers_capability_sync = b.addSystemCommand(&.{ "sh", "tests/workers_capability_sync.sh" });
    workers_capability_sync.addArtifactArg(cli_exe);
    b.step("workers-capability-sync-test", "preserve Workers capabilities while regenerating managed glue").dependOn(&workers_capability_sync.step);

    const cli_operations = b.addSystemCommand(&.{ "python3", "tests/cli_operations_smoke.py" });
    cli_operations.addArtifactArg(cli_exe);
    b.step("cli-operations-test", "verify external CLI contracts without deployment").dependOn(&cli_operations.step);
    const cli_capabilities = b.addSystemCommand(&.{ "python3", "tests/cli_capabilities_smoke.py" });
    cli_capabilities.addArtifactArg(cli_exe);
    b.step("cli-capabilities-test", "validate portable capability inspection without external services").dependOn(&cli_capabilities.step);

    // === Tests ===
    const test_step = b.step("test", "run unit tests");
    if (backend == .native) b.step("portable-application-test", "run shared application semantics on Native").dependOn(test_step);
    const compile_fail_command = b.addSystemCommand(&.{ "bash", "tests/compile_fail.sh" });
    const compile_fail_step = b.step("compile-fail-test", "verify compile-time diagnostics");
    compile_fail_step.dependOn(&compile_fail_command.step);
    const workers_realtime_command = b.addSystemCommand(&.{ "node", "--test", "tests/workers_realtime_test.mjs" });
    const workers_realtime_step = b.step("workers-realtime-test", "run Durable Object realtime contract tests");
    workers_realtime_step.dependOn(&workers_realtime_command.step);
    const live_guard_command = b.addSystemCommand(&.{ "node", "--test", "tests/cloudflare_live_guard_test.mjs" });
    workers_realtime_step.dependOn(&live_guard_command.step);
    const workers_wasm_dispatch_command = b.addSystemCommand(&.{ "node", "--test", "tests/workers_wasm_dispatch_test.mjs" });
    const workers_wasm_dispatch_step = b.step("workers-wasm-dispatch-test", "run concurrent Workers WASM dispatch regression tests");
    workers_wasm_dispatch_step.dependOn(&workers_wasm_dispatch_command.step);
    const cloudflare_live_command = b.addSystemCommand(&.{ "node", "tests/cloudflare_live.mjs" });
    const cloudflare_live_step = b.step("cloudflare-live-test", "run opt-in live D1/R2 smoke tests");
    cloudflare_live_step.dependOn(&cloudflare_live_command.step);
    const test_targets = [_][]const u8{
        "tests/http_parser_test.zig",
        "tests/dx_test.zig",
        "tests/ws_frame_test.zig",
        "tests/db_sqlite_test.zig",
        "tests/d1_mock_test.zig",
        "tests/jwt_test.zig",
        "tests/bcrypt_test.zig",
        "tests/mq_test.zig",
        "tests/app_test.zig",
        "tests/db_factory_test.zig",
        "tests/model_schema_test.zig",
        "tests/model_internal_test.zig",
        "tests/openapi_test.zig",
        "tests/testing_client_test.zig",
        "tests/negotiate_test.zig",
        "tests/etag_test.zig",
        "tests/client_gen_test.zig",
        "tests/jobs_test.zig",
        "tests/observability_test.zig",
        "tests/security_middleware_test.zig",
        "tests/docs_examples_test.zig",
        "tests/comptime_framework_test.zig",
        "tests/portable_application_test.zig",
        "examples/device_messaging/src/integration_test.zig",
        "tests/mimoc_parts_improvements_test.zig",
        "src/storage.zig",
        "src/events.zig",
        "src/realtime.zig",
        "src/protocol_gen.zig",
    };

    const integration_step = b.step("integration", "build integration test (manual run)");
    const integration_targets = [_][]const u8{
        "tests/integration_http_test.zig",
    };

    // Tests for the `tasks` example. Compiled / run with `zig build tasks-test`.
    // Kept separate from the main suite so we don't pollute it with example-
    // specific paths, and so the example can be removed cleanly if needed.
    const tasks_test_step = b.step("tasks-test", "run tests for examples/tasks");

    if (backend == .native) {
        for ([_]bool{ false, true }) |reactor_bench| {
            const group_bench_mod = b.createModule(.{
                .root_source_file = b.path("src/runtime_group_bench.zig"),
                .target = native_target,
                .optimize = optimize,
            });
            group_bench_mod.addOptions("build_options", opts);
            const bench_kind = b.addOptions();
            bench_kind.addOption(bool, "reactor", reactor_bench);
            group_bench_mod.addOptions("bench_kind", bench_kind);
            group_bench_mod.addImport("sqlite3", am_mod.import_table.get("sqlite3").?);
            group_bench_mod.link_libc = true;
            group_bench_mod.addIncludePath(b.path("third_party/sqlite"));
            group_bench_mod.addCSourceFile(.{ .file = b.path("third_party/sqlite/sqlite3.c"), .flags = sqlite_flags });
            group_bench_mod.addCSourceFile(.{ .file = b.path("third_party/sqlite/akamata_sqlite_shim.c"), .flags = sqlite_flags });
            const name = if (reactor_bench) "runtime-reactor-bench" else "runtime-group-bench";
            const group_bench = b.addExecutable(.{ .name = name, .root_module = group_bench_mod });
            b.step(name, "build private runtime evaluation benchmark").dependOn(&b.addInstallArtifact(group_bench, .{}).step);
        }
        // Private fixture shares source imports without adding a public runtime
        // selection API. The same black-box suite exercises each host adapter.
        const contract_mod = b.createModule(.{
            .root_source_file = b.path("src/runtime_contract_server.zig"),
            .target = native_target,
            .optimize = optimize,
            .sanitize_thread = runtime_tsan,
        });
        contract_mod.link_libc = true;
        contract_mod.addOptions("build_options", opts);
        contract_mod.addImport("sqlite3", am_mod.import_table.get("sqlite3").?);
        contract_mod.addIncludePath(b.path("third_party/sqlite"));
        contract_mod.addCSourceFile(.{ .file = b.path("third_party/sqlite/sqlite3.c"), .flags = sqlite_flags });
        contract_mod.addCSourceFile(.{ .file = b.path("third_party/sqlite/akamata_sqlite_shim.c"), .flags = sqlite_flags });
        const contract_server = b.addExecutable(.{ .name = "runtime-contract-server", .root_module = contract_mod });
        b.step("runtime-certify-fixture", "build private incremental session certification fixture").dependOn(&b.addInstallArtifact(contract_server, .{}).step);
        const contract = b.addSystemCommand(&.{ "python3", "tests/transport_contract.py" });
        contract.addArtifactArg(contract_server);
        b.step("transport-contract-test", "run shared socket Contract on Threaded and host multiplexed Reactor").dependOn(&contract.step);
        b.step("transport-contract-build", "compile private Transport Contract fixture").dependOn(&contract_server.step);
        const poc_step = b.step("runtime-poc-test", "evaluate isolated Io.Group lifecycle and socket contract");
        const poc_unit = b.addTest(.{ .root_module = contract_mod });
        poc_step.dependOn(&b.addRunArtifact(poc_unit).step);
        b.step("runtime-contract-unit", "run lifecycle, allocation and bounded-output fault tests").dependOn(&b.addRunArtifact(poc_unit).step);
        const stress = b.addSystemCommand(&.{ "python3", "tools/bench/runtime_stress.py" });
        stress.addArtifactArg(contract_server);
        stress.addArgs(&.{ "--quick", "--output", ".zig-cache/runtime-stress.json" });
        b.step("runtime-stress-test", "run bounded CI stress and production-gate evidence").dependOn(&stress.step);
        const stress_full = b.addSystemCommand(&.{ "python3", "tools/bench/runtime_stress.py" });
        stress_full.addArtifactArg(contract_server);
        stress_full.addArgs(&.{ "--output", ".zig-cache/runtime-stress-full.json" });
        b.step("runtime-stress-full", "run full local runtime stress matrix").dependOn(&stress_full.step);
        const isolation = b.addSystemCommand(&.{ "python3", "tools/bench/runtime_application_isolation.py" });
        isolation.addArtifactArg(contract_server);
        isolation.addArgs(&.{ "--output", ".zig-cache/runtime-application-isolation.json" });
        b.step("runtime-isolation-test", "require HTTP isolation from long-lived application execution (Phase 6 gate)").dependOn(&isolation.step);
        const session_validation = b.addSystemCommand(&.{ "python3", "tools/bench/runtime_certify.py" });
        session_validation.addArtifactArg(contract_server);
        session_validation.addArgs(&.{ "--idle-levels", "100", "--mixed-idle", "20", "--soak-seconds", "5", "--session-rounds", "10", "--output", ".zig-cache/runtime-session-validation.json" });
        b.step("runtime-session-test", "run bounded incremental stream/frame performance and lifecycle race validation (not long soak)").dependOn(&session_validation.step);
        const isolation_evaluation = b.addSystemCommand(&.{ "python3", "tools/bench/runtime_application_isolation.py" });
        isolation_evaluation.addArtifactArg(contract_server);
        isolation_evaluation.addArgs(&.{ "--record-blockers", "--output", ".zig-cache/runtime-application-isolation.json" });
        b.step("runtime-isolation-evaluate", "record incomplete Phase 6 isolation and bounded admission without certification").dependOn(&isolation_evaluation.step);
        const poc_contract = b.addSystemCommand(&.{ "python3", "tests/transport_contract.py" });
        poc_contract.addArtifactArg(contract_server);
        poc_contract.addArgs(&.{ "--group", "--only-group" });
        poc_step.dependOn(&poc_contract.step);
        const minimal = b.addExecutable(.{ .name = "documentation-minimal", .root_module = b.createModule(.{
            .root_source_file = b.path("tests/docs/minimal.zig"),
            .target = native_target,
            .optimize = optimize,
            .imports = &.{.{ .name = "akamata", .module = am_mod }},
        }) });
        documentation_step.dependOn(&minimal.step);
        inline for (test_targets) |tf| {
            const t_mod = b.createModule(.{
                .root_source_file = b.path(tf),
                .target = native_target,
                .optimize = optimize,
                .imports = &.{.{ .name = "akamata", .module = am_mod }},
            });
            const t = b.addTest(.{ .root_module = t_mod });
            // Standalone src tests can import synchronization/cost directly,
            // outside the akamata module's dependency namespace.
            t_mod.addOptions("build_options", opts);
            const run_test = b.addRunArtifact(t);
            test_step.dependOn(&run_test.step);
            if (comptime std.mem.eql(u8, tf, "tests/dx_test.zig")) {
                b.step("dx-test", "run developer API and documentation source contracts").dependOn(&run_test.step);
                documentation_step.dependOn(&run_test.step);
            }
        }
        // CLI tests (parsing wrangler.toml, UUID extraction)
        const cli_test_mod = b.createModule(.{
            .root_source_file = b.path("tools/akamata/src/main.zig"),
            .target = native_target,
            .optimize = optimize,
            .imports = &.{.{ .name = "akamata", .module = am_mod }},
        });
        cli_test_mod.link_libc = true;
        const cli_t = b.addTest(.{ .root_module = cli_test_mod });
        test_step.dependOn(&b.addRunArtifact(cli_t).step);

        inline for (integration_targets) |tf| {
            const t_mod = b.createModule(.{
                .root_source_file = b.path(tf),
                .target = native_target,
                .optimize = optimize,
                .imports = &.{.{ .name = "akamata", .module = am_mod }},
            });
            const t = b.addTest(.{ .root_module = t_mod });
            integration_step.dependOn(&b.addRunArtifact(t).step);
        }

        // tasks example tests live alongside the example source so relative
        // `@import("app.zig")` resolves inside the module's source tree.
        const tasks_test_mod = b.createModule(.{
            .root_source_file = b.path("examples/tasks/src/integration_test.zig"),
            .target = native_target,
            .optimize = optimize,
            .imports = &.{.{ .name = "akamata", .module = am_mod }},
        });
        const tasks_test = b.addTest(.{ .root_module = tasks_test_mod });
        tasks_test_step.dependOn(&b.addRunArtifact(tasks_test).step);
    }
}
