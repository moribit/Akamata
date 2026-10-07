//! The production graph with owned SQLite and an explicit realtime backend.
const std = @import("std");
const am = @import("akamata");
const setup = @import("setup.zig");
const contracts = @import("contract.zig");
const h = @import("handlers.zig");
const State = @import("app.zig").App;
const Capture = struct {
    bytes: [4096]u8 = undefined,
    len: usize = 0,
    calls: usize = 0,
    fn send(raw: ?*anyopaque, bytes: []const u8) am.realtime.Error!void {
        const self: *@This() = @ptrCast(@alignCast(raw.?));
        if (bytes.len > self.bytes.len) return error.BackendFailure;
        @memcpy(self.bytes[0..bytes.len], bytes);
        self.len = bytes.len;
        self.calls += 1;
    }
};
test "shared chat graph persists HTTP and Workers inbound protocol events" {
    const alloc = std.testing.allocator;
    const db = try am.db.openForContract(alloc, State.application_contract, "file::memory:");
    defer db.close();
    try setup.migrateDevelopment(db);
    var backend = am.realtime.Native.initForContract(alloc, State.application_contract);
    defer backend.deinit();
    var gate = am.sync.Mutex.init();
    defer gate.deinit();
    var app = try setup.Application.initWithState(alloc, .{ .db = db, .realtime = backend.service(), .native_transport_gate = &gate });
    defer app.deinit();
    var client = app.client(alloc);
    defer client.deinit();
    var created = try client.post("/rooms").json(.{ .name = "general" }).send();
    defer created.deinit();
    try created.expectStatus(.created);
    const room = try created.json(h.Room);
    var capture: Capture = .{};
    const room_key = try std.fmt.allocPrint(alloc, "room:{d}", .{room.id});
    defer alloc.free(room_key);
    try backend.connect(room_key, 1, "alice", &capture, Capture.send);
    defer backend.detach(1);
    var posted = try client.postf("/rooms/{d}/messages", .{room.id}).json(.{ .user = "alice", .text = "hello" }).send();
    defer posted.deinit();
    try posted.expectStatus(.created);
    const message = try posted.json(contracts.Message);
    try std.testing.expectEqualStrings("hello", message.text.slice());
    try std.testing.expectEqual(@as(usize, 1), capture.calls);
    var arena: std.heap.ArenaAllocator = .init(alloc);
    defer arena.deinit();
    const event = try contracts.Protocol.decode(arena.allocator(), capture.bytes[0..capture.len]);
    try std.testing.expectEqualStrings("hello", event.message.text.slice());
    var invalid = try client.postf("/rooms/{d}/messages", .{room.id}).json(.{ .user = "alice", .text = "" }).send();
    defer invalid.deinit();
    try invalid.expectStatus(.unprocessable_entity);
    const metadata = try std.fmt.allocPrint(alloc, "{{\"room_id\":{d}}}", .{room.id});
    defer alloc.free(metadata);
    var inbound = try client.post("/realtime/message").json(.{
        .context = .{ .connectionId = "trusted-do-connection", .identity = "bob", .principal = "{}", .metadata = metadata },
        .envelope = .{ .protocol_version = 1, .event_type = "send", .payload = .{ .text = "from DO" } },
    }).send();
    defer inbound.deinit();
    try inbound.expectStatus(.ok);
    var actions = try std.json.parseFromSlice(std.json.Value, alloc, inbound.body, .{});
    defer actions.deinit();
    const action = actions.value.array.items[0];
    try std.testing.expectEqualStrings("broadcast", action.object.get("kind").?.string);
    const output = try std.json.Stringify.valueAlloc(alloc, action.object.get("envelope").?, .{});
    defer alloc.free(output);
    const accepted = try contracts.Protocol.decode(arena.allocator(), output);
    try std.testing.expectEqualStrings("bob", accepted.message.user.slice());
    try std.testing.expectEqualStrings("from DO", accepted.message.text.slice());
    // A DO returns actions, rather than re-entering its own transport service.
    try std.testing.expectEqual(@as(usize, 1), capture.calls);
    var history = try client.getf("/rooms/{d}/messages", .{room.id}).send();
    defer history.deinit();
    const list = try history.json(struct { messages: []h.MessageRow });
    try std.testing.expectEqual(@as(usize, 2), list.messages.len);
    var unsupported = try client.post("/realtime/message").json(.{
        .context = .{ .identity = "bob", .metadata = metadata },
        .envelope = .{ .protocol_version = 999, .event_type = "send", .payload = .{ .text = "bad" } },
    }).send();
    defer unsupported.deinit();
    try unsupported.expectStatus(@as(u16, 426));
}
test "chat protocol rejects client publication of server events and oversized text" {
    const alloc = std.testing.allocator;
    var arena: std.heap.ArenaAllocator = .init(alloc);
    defer arena.deinit();
    try std.testing.expectError(error.TooLong, am.BoundedString(1024).init(&@as([1025]u8, @splat('x'))));
    try std.testing.expectError(error.UnsupportedVersion, contracts.Protocol.decode(arena.allocator(), "{\"protocol_version\":2,\"event_type\":\"send\",\"payload\":{\"text\":\"hi\"}}"));
}
