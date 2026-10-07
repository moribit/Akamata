const am = @import("akamata");
const h = @import("handlers.zig");
pub const Send = struct { text: am.BoundedString(1024) };
pub const Message = struct { id: i64, room_id: i64, user: am.BoundedString(64), text: am.BoundedString(1024), created_at: i64 };
pub const Event = union(enum) { send: Send, message: Message };
pub const Protocol = am.events.Protocol(Event, 1);
pub const WorkerBindings = struct { database: am.binding.D1("DB"), rooms: am.binding.DurableObject("AKAMATA_REALTIME") };
pub fn For(comptime target: am.capability.Target) type {
    const C = am.capability.Contract("chat", &.{ .database, .realtime }, &.{
        .{ .capability = .database, .provider = am.capability.defaultProvider(.database, target), .binding = if (target == .workers) "DB" else null },
        .{ .capability = .realtime, .provider = am.capability.defaultProvider(.realtime, target), .binding = if (target == .workers) "AKAMATA_REALTIME" else null },
    });
    comptime if (target == .workers) am.binding.validateContract(WorkerBindings, C, target) else C.validate(target);
    return C;
}
pub const routes = .{
    am.endpoint(.{ .method = .GET, .path = "/", .handler = h.index, .fallback = .internal_server_error }),
    am.get("/health", h.health),
    am.endpoint(.{ .method = .GET, .path = "/rooms", .handler = h.listRooms, .capabilities = &.{.database}, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .POST, .path = "/rooms", .handler = h.createRoom, .capabilities = &.{.database}, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .GET, .path = "/rooms/:id/messages", .handler = h.listMessages, .capabilities = &.{.database}, .errors = .{ .NotFound = .not_found }, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .POST, .path = "/rooms/:id/messages", .handler = h.postMessage, .capabilities = &.{ .database, .realtime }, .errors = .{ .NotFound = .not_found }, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .GET, .path = "/realtime/:resource", .handler = h.wsRoom, .capabilities = &.{ .database, .realtime }, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .POST, .path = "/__akamata/realtime/authorize", .handler = h.authorizeRealtime, .capabilities = &.{.database}, .fallback = .internal_server_error }),
    am.endpoint(.{ .method = .POST, .path = "/realtime/message", .handler = h.realtimeMessage, .capabilities = &.{ .database, .realtime }, .fallback = .internal_server_error }),
};
