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

fn DatabaseEndpoint(comptime method: am.Method, comptime path: []const u8, comptime handler: anytype, comptime operation: []const u8) type {
    return am.capability.Uses(am.contract.Endpoint(method, path, handler, .{ .operation_id = operation }), &.{.database});
}

pub const endpoints = .{
    am.contract.Endpoint(.GET, "/", h.index, .{ .operation_id = "index" }),
    DatabaseEndpoint(.GET, "/health", h.health, "health"),
    DatabaseEndpoint(.GET, "/entries", h.listEntries, "listEntries"),
    DatabaseEndpoint(.POST, "/entries", h.createEntry, "createEntry"),
    DatabaseEndpoint(.GET, "/entries/:id", h.showEntry, "showEntry"),
    DatabaseEndpoint(.DELETE, "/entries/:id", h.deleteEntry, "deleteEntry"),
};
