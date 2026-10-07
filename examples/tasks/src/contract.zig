const am = @import("akamata");
const h = @import("handlers.zig");
pub const TaskCreated = struct { task_id: i64 };
pub const TaskCreatedDescriptor = am.events.Descriptor(TaskCreated, .{ .name = "task_created", .version = 1 });
pub const WorkerBindings = struct { database: am.binding.D1("DB"), events: am.binding.Queue("EVENTS") };
pub fn For(comptime target: am.capability.Target) type {
    const C = am.capability.Contract("tasks", &.{ .database, .queue }, &.{
        .{ .capability = .database, .provider = am.capability.defaultProvider(.database, target), .binding = if (target == .workers) "DB" else null },
        .{ .capability = .queue, .provider = am.capability.defaultProvider(.queue, target), .binding = if (target == .workers) "EVENTS" else null },
    });
    comptime if (target == .workers) am.binding.validateContract(WorkerBindings, C, target) else C.validate(target);
    return C;
}
pub const routes = .{
    am.endpoint(.{ .method = .GET, .path = "/tasks", .handler = h.listTasks, .capabilities = &.{.database}, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .POST, .path = "/tasks", .handler = h.createTask, .capabilities = &.{ .database, .queue }, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .GET, .path = "/tasks/:id", .handler = h.showTask, .capabilities = &.{.database}, .errors = .{ .NotFound = .not_found }, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .PATCH, .path = "/tasks/:id", .handler = h.updateTask, .capabilities = &.{.database}, .errors = .{ .NotFound = .not_found }, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .DELETE, .path = "/tasks/:id", .handler = h.deleteTask, .capabilities = &.{.database}, .errors = .{ .NotFound = .not_found }, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .GET, .path = "/events", .handler = h.streamEvents, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .GET, .path = "/openapi.json", .handler = h.openapiSpec, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .GET, .path = "/client.ts", .handler = h.typescriptClient, .fallback = .internal_server_error }),
    am.get("/health", h.health),
};
