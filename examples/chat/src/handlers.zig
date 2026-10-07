//! Portable domain/HTTP semantics; socket ownership is an explicit escape hatch.
const std = @import("std");
const am = @import("akamata");
const State = @import("app.zig").App;
const Ctx = am.Context(State);
const contracts = @import("contract.zig");
pub const CreateRoom = struct {
    name: []const u8,
    pub const validation = .{ .name = .{ am.model.rule.min_len(1), am.model.rule.max_len(100) } };
};
pub const PostMessage = struct {
    user: []const u8,
    text: []const u8,
    pub const validation = .{
        .user = .{ am.model.rule.min_len(1), am.model.rule.max_len(64) },
        .text = .{ am.model.rule.min_len(1), am.model.rule.max_len(1024) },
    };
};
pub const Room = struct { id: i64, name: []const u8, created_at: i64 };
pub const MessageRow = struct { id: i64, user: []const u8, text: []const u8, created_at: i64 };
pub fn index(c: *Ctx) !void {
    try c.html(@embedFile("index.html"));
}
pub fn health() []const u8 {
    return "ok";
}
pub fn listRooms(c: *Ctx) !struct { rooms: []const Room } {
    return .{ .rooms = try am.model.repo(Room).queryRaw(c.db(), c.arena, "SELECT id, name, created_at FROM rooms ORDER BY id LIMIT 100", .{}) };
}
pub fn createRoom(c: *Ctx, body: am.Json(CreateRoom)) !am.Result(Room, 201) {
    var stmt = try c.db().prepare("INSERT INTO rooms(name) VALUES(?) RETURNING id, name, created_at");
    defer stmt.deinit();
    try stmt.bindAll(.{body.value.name});
    const row = try stmt.fetchOne(Room);
    // Statement memory is not a response lifetime.
    return am.created(Room{ .id = row.id, .name = try c.arena.dupe(u8, row.name), .created_at = row.created_at });
}
pub fn requireRoom(db: am.db.Db, id: i64) !void {
    if (id <= 0) return error.NotFound;
    var stmt = try db.prepare("SELECT id FROM rooms WHERE id = ?");
    defer stmt.deinit();
    try stmt.bindAll(.{id});
    if (try stmt.step() != .row) return error.NotFound;
}
pub fn listMessages(c: *Ctx, id: am.Path(i64, "id")) !struct { messages: []const MessageRow } {
    try requireRoom(c.db(), id.value);
    return .{ .messages = try am.model.repo(MessageRow).queryRaw(c.db(), c.arena, "SELECT id, user, text, created_at FROM messages WHERE room_id = ? ORDER BY id DESC LIMIT 100", .{id.value}) };
}
/// Both Native frames and Workers DO events use this ordinary domain function.
pub fn persistMessage(db: am.db.Db, room_id: i64, user: []const u8, text: []const u8) !contracts.Message {
    try requireRoom(db, room_id);
    const bounded_user = try am.BoundedString(64).init(user);
    const bounded_text = try am.BoundedString(1024).init(text);
    if (bounded_user.len == 0 or bounded_text.len == 0) return error.EmptyMessage;
    var stmt = try db.prepare("INSERT INTO messages(room_id,user,text) VALUES(?,?,?) RETURNING id,created_at");
    defer stmt.deinit();
    try stmt.bindAll(.{ room_id, user, text });
    const row = try stmt.fetchOne(struct { id: i64, created_at: i64 });
    return .{ .id = row.id, .room_id = room_id, .user = bounded_user, .text = bounded_text, .created_at = row.created_at };
}
fn publish(state: *State, allocator: std.mem.Allocator, event: contracts.Message) !void {
    // Serialize every callback with transport teardown. Native's Service borrows
    // callback contexts; it does not own the stack-allocated WebSocket Conn.
    if (state.native_transport_gate) |gate| gate.lock();
    defer if (state.native_transport_gate) |gate| gate.unlock();
    const room = try std.fmt.allocPrint(allocator, "room:{d}", .{event.room_id});
    _ = try state.realtime.room(contracts.Protocol, room).broadcast(allocator, .{ .message = event });
}
pub fn postMessage(c: *Ctx, id: am.Path(i64, "id"), body: am.Json(PostMessage)) !am.Result(contracts.Message, 201) {
    const event = try persistMessage(c.db(), id.value, body.value.user, body.value.text);
    try publish(c.state(), c.arena, event);
    return am.created(event);
}

/// Anonymous demo identity, NOT an authentication mechanism. The managed
/// gateway requires Authorization; replace this policy for authenticated apps.
pub fn authorizeRealtime(c: *Ctx) !void {
    const credential = am.identity.bearer(c.req.header("authorization")) catch return c.unauthorized("demo identity required");
    const name = switch (credential) {
        .bearer => |v| v,
        else => unreachable,
    };
    if (name.len == 0 or name.len > 64) return c.badRequest("nickname exceeds bound");
    const resource = c.req.query("resource") orelse return c.badRequest("room required");
    const id = std.fmt.parseInt(i64, resource, 10) catch return c.badRequest("invalid room");
    requireRoom(c.db(), id) catch return c.notFound();
    try c.json(.{ .room = try std.fmt.allocPrint(c.arena, "room:{d}", .{id}), .logical_identity = name, .principal = .{ .nickname = name }, .metadata = .{ .room_id = id, .protocol_version = contracts.Protocol.protocol_version } }, 200);
}
const WorkerInbound = struct {
    context: struct { identity: []const u8, metadata: []const u8 },
    envelope: std.json.Value,
};
pub fn realtimeMessage(c: *Ctx) !void {
    const input = c.req.json(WorkerInbound) catch return c.badRequest("malformed event");
    var metadata = std.json.parseFromSlice(struct { room_id: i64 }, c.arena, input.context.metadata, .{ .ignore_unknown_fields = true }) catch return c.badRequest("missing room context");
    defer metadata.deinit();
    const bytes = try std.json.Stringify.valueAlloc(c.arena, input.envelope, .{});
    const event = contracts.Protocol.decode(c.arena, bytes) catch |err| switch (err) {
        error.UnsupportedVersion => return c.json(.{ .error_kind = "unsupported_protocol_version" }, 426),
        else => return c.badRequest("malformed event"),
    };
    const send = switch (event) {
        .send => |value| value,
        .message => return c.forbidden("server event"),
    };
    const message = try persistMessage(c.db(), metadata.value.room_id, input.context.identity, send.text.slice());
    const output = try contracts.Protocol.encode(c.arena, .{ .message = message }, .{});
    // The DO owns its WebSockets and applies this bounded action; don't call
    // back into the same DO from its inbound handler.
    try c.header("content-type", "application/json");
    try c.body("[{\"kind\":\"broadcast\",\"envelope\":");
    try c.body(output);
    try c.body("}]");
}
var next_connection_id: std.atomic.Value(u64) = .init(1);
pub fn wsRoom(c: *Ctx, resource: am.Path(i64, "resource")) !void {
    if (comptime am.backend != .native) return c.json(.{ .error_kind = "durable_object_gateway_required" }, 501);
    try requireRoom(c.db(), resource.value);
    const nickname = c.req.query("user") orelse "anon";
    _ = try am.BoundedString(64).init(nickname);
    const room = try std.fmt.allocPrint(c.arena, "room:{d}", .{resource.value});
    const gate = c.state().native_transport_gate orelse return error.MissingTransportOwner;
    var connection = try am.ws.upgrade(Ctx, c, .{ .max_message_bytes = 4096 });
    const native: *am.realtime.Native = @ptrCast(@alignCast(c.realtime().backend.ptr));
    const id = next_connection_id.fetchAdd(1, .monotonic);
    var attached = false;
    defer {
        gate.lock();
        if (attached) native.detach(id);
        connection.deinit();
        gate.unlock();
    }
    try native.connectTransport(room, id, nickname, &connection, Transport.send, Transport.close);
    attached = true;
    var arena = am.realtime.MessageArena.init(c.app().?.gpa);
    defer arena.deinit();
    while (true) {
        arena.reset();
        const message = connection.readMessage(arena.allocator()) catch |err| switch (err) {
            error.ClosedByPeer => return,
            else => return err,
        };
        if (message.opcode != .text) {
            connection.close(1003, "text protocol required");
            return;
        }
        const event = contracts.Protocol.decode(arena.allocator(), message.payload) catch {
            connection.close(1007, "invalid protocol event");
            return;
        };
        const send = switch (event) {
            .send => |value| value,
            .message => {
                connection.close(4003, "server event");
                return;
            },
        };
        const saved = try persistMessage(c.db(), resource.value, nickname, send.text.slice());
        try publish(c.state(), arena.allocator(), saved);
    }
}
const Transport = struct {
    fn send(raw: ?*anyopaque, bytes: []const u8) am.realtime.Error!void {
        const conn: *am.ws.Conn = @ptrCast(@alignCast(raw.?));
        conn.sendText(bytes) catch return error.Closed;
    }
    fn close(raw: ?*anyopaque, details: am.realtime.Close) void {
        const conn: *am.ws.Conn = @ptrCast(@alignCast(raw.?));
        conn.close(details.code, details.reason);
    }
};
