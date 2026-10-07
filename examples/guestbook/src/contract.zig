//! Shared application requirements, endpoint schema and deployment wiring.
const am = @import("akamata");
const h = @import("handlers.zig");

pub const DatabaseBinding = am.binding.D1("DB");
pub const WorkerBindings = struct { database: DatabaseBinding };

pub fn For(comptime target: am.capability.Target) type {
    const C = am.capability.Contract("guestbook", &.{.database}, &.{.{
        .capability = .database,
        .provider = am.capability.defaultProvider(.database, target),
        .binding = if (target == .workers) DatabaseBinding.binding_name else null,
    }});
    comptime if (target == .workers) am.binding.validateContract(WorkerBindings, C, target) else C.validate(target);
    return C;
}

// One declaration feeds static routing, capability diagnostics and generators.
pub const routes = .{
    am.endpoint(.{ .method = .GET, .path = "/", .handler = h.index, .operation_id = "index", .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .GET, .path = "/health", .handler = h.health, .operation_id = "health", .capabilities = &.{.database}, .errors = .{ .DatabaseUnavailable = .service_unavailable } }),
    am.endpoint(.{ .method = .GET, .path = "/entries", .handler = h.listEntries, .operation_id = "listEntries", .capabilities = &.{.database}, .errors = .{ .InvalidLimit = .bad_request }, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .POST, .path = "/entries", .handler = h.createEntry, .operation_id = "createEntry", .capabilities = &.{.database}, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .GET, .path = "/entries/:id", .handler = h.showEntry, .operation_id = "showEntry", .capabilities = &.{.database}, .errors = .{ .InvalidId = .bad_request, .NotFound = .not_found }, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .DELETE, .path = "/entries/:id", .handler = h.deleteEntry, .operation_id = "deleteEntry", .capabilities = &.{.database}, .errors = .{ .InvalidId = .bad_request, .NotFound = .not_found }, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .GET, .path = "/openapi.json", .handler = h.openapi, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .GET, .path = "/client.ts", .handler = h.client, .fallback = .internal_server_error }),
};
pub const endpoints = blk: {
    @setEvalBranchQuota(50_000);
    var result: [routes.len]type = undefined;
    for (routes, 0..) |R, i| result[i] = R.For(@import("app.zig").App);
    break :blk result;
};
