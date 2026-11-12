//! Share compilation of the same test modules without replacing their cases.
const std = @import("std");
comptime {
    @setEvalBranchQuota(100_000);
    // Zig requires literal @import operands. Check the explicit import ledger
    // against the build catalog so neither compilation layout loses a suite.
    for (@import("unit_catalog.zig").paths) |path| {
        if (std.mem.startsWith(u8, path, "tests/")) {
            if (std.mem.indexOf(u8, @embedFile("unit_all.zig"), "@import(\"" ++ path["tests/".len..] ++ "\")") == null) @compileError("grouped test missing from unit catalog: " ++ path);
        }
    }
    _ = @import("http_parser_test.zig");
    _ = @import("dx_test.zig");
    _ = @import("ws_frame_test.zig");
    _ = @import("db_sqlite_test.zig");
    _ = @import("d1_mock_test.zig");
    _ = @import("jwt_test.zig");
    _ = @import("bcrypt_test.zig");
    _ = @import("mq_test.zig");
    _ = @import("app_test.zig");
    _ = @import("db_factory_test.zig");
    _ = @import("model_schema_test.zig");
    _ = @import("model_internal_test.zig");
    _ = @import("openapi_test.zig");
    _ = @import("testing_client_test.zig");
    _ = @import("negotiate_test.zig");
    _ = @import("etag_test.zig");
    _ = @import("client_gen_test.zig");
    _ = @import("jobs_test.zig");
    _ = @import("observability_test.zig");
    _ = @import("security_middleware_test.zig");
    _ = @import("docs_examples_test.zig");
    _ = @import("comptime_framework_test.zig");
    _ = @import("portable_application_test.zig");
    _ = @import("mimoc_parts_improvements_test.zig");
}
