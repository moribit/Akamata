const std = @import("std");
const s = @import("support.zig");
const Case = struct { []const u8, []const u8 };
const cases = [_]Case{
    .{ "duplicate_routes", "duplicate endpoint in contract graph" },
    .{ "ambiguous_routes", "ambiguous endpoint in contract graph" },
    .{ "duplicate_operation_id", "duplicate operation_id in contract graph" },
    .{ "invalid_wildcard", "wildcard must be the final path segment" },
    .{ "missing_path_input", "is not present in route" },
    .{ "duplicate_json_body", "duplicate typed input `body`" },
    .{ "incomplete_error_map", "missing HTTP mapping for handler error Unavailable" },
    .{ "unsupported_capability", "target workers does not provide it" },
    .{ "di_missing", "missing dependency provider" },
    .{ "di_cycle", "dependency cycle includes" },
    .{ "native_r2_binding", "target native does not provide it" },
    .{ "untagged_protocol", "realtime protocols must be tagged unions" },
    .{ "unsupported_db_bind", "Value.fromAny: only [N]u8 arrays are supported" },
    .{ "missing_portable_provider", "requires database: missing explicit provider" },
    .{ "wrong_portable_target", "provider sqlite unavailable on target workers" },
    .{ "missing_portable_binding", "binding FILES absent from environment for target workers" },
    .{ "wrong_portable_binding", "wrong binding kind for r2" },
    .{ "undeclared_route_service", "route POST /files requires object_storage, absent from application contract" },
    .{ "missing_portable_service", "State missing borrowed service field store" },
    .{ "missing_provider_binding", "missing Workers binding name for target workers" },
    .{ "duplicate_provider_binding", "duplicate resource binding RESOURCE for d1 and r2 on target workers" },
    .{ "duplicate_portable_requirement", "duplicate requirement database" },
    .{ "dx_missing_path", "requires Path binding for id" },
    .{ "dx_duplicate_body", "may bind only one JSON body" },
    .{ "dx_unsupported_parameter", "unsupported Akamata handler parameter" },
    .{ "dx_unmapped_error", "missing HTTP mapping for handler error NotFound" },
    .{ "dx_anyerror", "anyerror handler requires an explicit .fallback" },
    .{ "dx_unsupported_response", "handler response cannot contain owning/raw pointers" },
    .{ "dx_invalid_validation", "DTO validation references unknown field typo" },
    .{ "dx_invalid_error_status", "application error mapping must use a 4xx or 5xx HTTP status" },
    .{ "dx_bodyless_status", "204/205 responses cannot return a body" },
    .{ "dx_unknown_option", "unknown Akamata endpoint option sucess_status" },
    .{ "dx_untagged_union", "JSON response requires a tagged union" },
};
pub fn run(h: s.H) !void {
    const temp = try h.temp();
    defer temp.deinit();
    for (cases) |case| {
        const result = try h.command(&.{ h.env.get("ZIG") orelse "zig", "test", "--dep", "akamata", try h.fmt("-Mroot=tests/compile_fail/{s}.zig", .{case[0]}), "--dep", "build_options", "-Makamata=src/akamata.zig", "-Mbuild_options=tests/compile_fail/build_options.zig", "--cache-dir", ".zig-cache", "--global-cache-dir", temp.path }, null, h.env);
        try s.check(!s.success(result.term), "invalid application must fail compilation");
        try s.contains(try h.fmt("{s}{s}", .{ result.stdout, result.stderr }), case[1]);
        std.debug.print("ok compile-fail: {s}\n", .{case[0]});
    }
}
