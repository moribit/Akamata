//! Same in-process application semantic suite on Native and Workers WASM.
//! Effects use explicit test providers; live adapter tests remain separate.
const std = @import("std");
const am = @import("akamata");
const target: am.capability.Target = if (am.backend == .workers) .workers else .native;
const Payload = struct { text: []const u8 };
const Protocol = am.events.Protocol(union(enum) { created: Payload }, 2);
const Created = Protocol.descriptor(.created);
const Requirements = &.{ am.capability.Application.database, .object_storage, .queue, .realtime };
const C = am.capability.Contract("portable application fixture", Requirements, &.{
    .{ .capability = .database, .provider = am.capability.defaultProvider(.database, target), .binding = if (target == .workers) "DB" else null },
    .{ .capability = .object_storage, .provider = am.capability.defaultProvider(.object_storage, target), .binding = if (target == .workers) "FILES" else null },
    .{ .capability = .queue, .provider = am.capability.defaultProvider(.queue, target), .binding = if (target == .workers) "EVENTS" else null },
    .{ .capability = .realtime, .provider = am.capability.defaultProvider(.realtime, target), .binding = if (target == .workers) "ROOMS" else null },
});
comptime {
    C.validate(target);
    if (target == .workers) am.binding.validateContract(struct {
        db: am.binding.D1("DB"),
        files: am.binding.R2("FILES"),
        events: am.binding.Queue("EVENTS"),
        rooms: am.binding.DurableObject("ROOMS"),
    }, C, target);
}
const State = struct {
    pub const application_contract = C;
    db: am.db.Db,
    store: am.storage.Store,
    queue: am.queue.Producer,
    realtime: am.realtime.Service,
};
const Source = struct {
    bytes: []const u8,
    position: usize = 0,
    fn read(ptr: *anyopaque, out: []u8) am.stream.Error!usize {
        const self: *@This() = @ptrCast(@alignCast(ptr));
        const n = @min(out.len, self.bytes.len - self.position);
        @memcpy(out[0..n], self.bytes[self.position..][0..n]);
        self.position += n;
        return n;
    }
    fn close(_: *anyopaque) void {}
    fn reader(self: *@This()) am.stream.Reader {
        return .{ .ptr = self, .read_fn = read, .close_fn = close };
    }
};
const DatabaseEffect = struct {
    calls: usize = 0,
    fn exec(ptr: *anyopaque, sql: []const u8) anyerror!void {
        const self: *@This() = @ptrCast(@alignCast(ptr));
        if (!std.mem.eql(u8, sql, "INSERT INTO effects DEFAULT VALUES")) return error.UnexpectedSql;
        self.calls += 1;
    }
    fn prepare(_: *anyopaque, _: []const u8) anyerror!am.db.Stmt {
        return error.UnsupportedTestOperation;
    }
    fn close(_: *anyopaque) void {}
    const vtable: am.db.VTable = .{ .exec = exec, .prepare = prepare, .close = close };
    fn database(self: *@This()) am.db.Db {
        return .{ .ptr = self, .vt = &vtable };
    }
};
const Sink = struct {
    bytes: [512]u8 = undefined,
    len: usize = 0,
    calls: usize = 0,
    fn send(ptr: ?*anyopaque, bytes: []const u8) am.realtime.Error!void {
        const self: *@This() = @ptrCast(@alignCast(ptr.?));
        if (bytes.len > self.bytes.len) return error.Backpressure;
        @memcpy(self.bytes[0..bytes.len], bytes);
        self.len = bytes.len;
        self.calls += 1;
    }
};
fn create(c: *am.Context(State), input: struct { body: am.contract.Json(Payload) }) error{ InvalidMessage, EffectFailure }!struct { accepted: bool } {
    const message = input.body.value;
    if (message.text.len == 0 or message.text.len > 64) return error.InvalidMessage;
    c.db().exec("INSERT INTO effects DEFAULT VALUES") catch return error.EffectFailure;
    var source = Source{ .bytes = message.text };
    _ = c.storage().put("messages/latest", source.reader(), .{ .content_type = "text/plain" }) catch return error.EffectFailure;
    c.queue().dispatchDescriptor(c.arena, Created, message, .{ .event_id = "evt-1", .correlation_id = "request-1", .idempotency_key = "message:1", .attempt = 2, .max_attempts = 7 }) catch return error.EffectFailure;
    _ = c.realtime().room(Protocol, "messages").broadcast(c.arena, .{ .created = message }) catch return error.EffectFailure;
    return .{ .accepted = true };
}
const Endpoint = am.capability.Uses(am.contract.TypedEndpoint(State, .POST, "/messages", create, .{ .InvalidMessage = am.Status.bad_request, .EffectFailure = am.Status.service_unavailable }, .{ .operation_id = "createMessage", .success_status = 201 }), Requirements);
fn expect(ok: bool) !void {
    if (!ok) return error.ContractAssertionFailed;
}
fn inputError(err: anyerror, c: *am.Context(State)) !void {
    // Explicit application policy for input decoding errors. The framework's
    // default unhandled-error behavior remains unchanged.
    switch (err) {
        error.SyntaxError, error.UnexpectedToken, error.MissingField => try c.json(.{ .error_kind = "invalid_input" }, 400),
        else => return err,
    }
}

pub fn storageContract(allocator: std.mem.Allocator, store: am.storage.Store) !void {
    var source = Source{ .bytes = "0123456789" };
    _ = try store.put("objects/test", source.reader(), .{ .content_type = "text/plain" });
    var object = try store.get("objects/test", .{ .range = .{ .offset = 3, .length = 4 } });
    defer object.body.close();
    try expect(object.metadata.size == 4 and object.metadata.etag != null);
    try expect(std.mem.eql(u8, object.metadata.content_type.?, "text/plain"));
    var out: [8]u8 = undefined;
    const n = try object.body.read(&out);
    try expect(std.mem.eql(u8, out[0..n], "3456"));
    if (store.get("objects/test", .{ .if_none_match = object.metadata.etag })) |unexpected| {
        unexpected.body.close();
        return error.ContractAssertionFailed;
    } else |err| try expect(err == error.PreconditionFailed);
    const entries = try store.list(allocator, "objects/", null, 10);
    defer {
        for (entries) |entry| allocator.free(entry.key);
        allocator.free(entries);
    }
    try expect(entries.len == 1 and std.mem.eql(u8, entries[0].key, "objects/test"));
    try store.delete("objects/test");
    if (store.head("objects/test")) |_| return error.ContractAssertionFailed else |err| try expect(err == error.NotFound);
    if (store.head("../secret")) |_| return error.ContractAssertionFailed else |err| try expect(err == error.PermissionDenied);
}

pub fn run(allocator: std.mem.Allocator) !void {
    var db: DatabaseEffect = .{};
    var store = am.testing.MemoryStore.init(allocator);
    try storageContract(allocator, store.store());
    var queue = am.testing.QueueRecorder.init(allocator);
    defer queue.deinit();
    // Native hub is used explicitly as an in-memory realtime test provider on
    // both targets. This is not a claim that it replaces Durable Objects.
    var realtime = am.realtime.Native.init(allocator);
    defer realtime.deinit();
    var sink: Sink = .{};
    try realtime.connect("messages", 1, null, &sink, Sink.send);
    var app = am.App(State).init(allocator, .{ .db = db.database(), .store = store.store(), .queue = queue.producer(), .realtime = realtime.service() });
    defer app.deinit();
    try app.onError(inputError);
    try Endpoint.register(&app);
    var client = am.testing.Client(@TypeOf(app)).init(allocator, &app);
    var ok = try client.post("/messages").json(.{ .text = "hello" }).send();
    defer ok.deinit();
    try expect(ok.status == 201 and std.mem.indexOf(u8, ok.body, "true") != null);
    try expect(db.calls == 1 and queue.items.items.len == 1 and sink.calls == 1);
    const item = queue.items.items[0];
    try expect(item.meta.protocol_version == 2 and item.meta.attempt == 2 and item.meta.max_attempts == 7);
    try expect(std.mem.eql(u8, item.meta.event_type, Created.name) and std.mem.eql(u8, item.meta.idempotency_key.?, "message:1"));
    var event = try Created.decode(allocator, item.payload);
    defer event.deinit();
    try expect(std.mem.eql(u8, event.value.text, "hello"));
    const consumer: am.queue.Consumer(Payload) = .{ .handler = struct {
        fn accept(payload: Payload, delivery: am.queue.Delivery) !void {
            try expect(std.mem.eql(u8, payload.text, "hello") and delivery.attempt == 2 and delivery.max_attempts == 7);
            try expect(std.mem.eql(u8, delivery.correlation_id.?, "request-1") and std.mem.eql(u8, delivery.idempotency_key.?, "message:1"));
        }
    }.accept };
    try consumer.consumeEnvelope(allocator, Created, item.meta, item.payload);
    var unsupported = item.meta;
    unsupported.protocol_version = 99;
    if (consumer.consumeEnvelope(allocator, Created, unsupported, item.payload)) |_| return error.ContractAssertionFailed else |err| try expect(err == error.UnsupportedVersion);
    var message_arena: std.heap.ArenaAllocator = .init(allocator);
    defer message_arena.deinit();
    const realtime_event = try Protocol.decode(message_arena.allocator(), sink.bytes[0..sink.len]);
    try expect(std.mem.eql(u8, realtime_event.created.text, "hello"));
    var invalid = try client.post("/messages").json(.{ .text = "" }).send();
    defer invalid.deinit();
    try expect(invalid.status == 400 and db.calls == 1 and queue.items.items.len == 1);
    var malformed = try client.post("/messages").body("application/json", "{invalid}").send();
    defer malformed.deinit();
    try expect(malformed.status == 400 and db.calls == 1 and queue.items.items.len == 1);
    queue.limit = 1;
    var rejected = try client.post("/messages").json(.{ .text = "second" }).send();
    defer rejected.deinit();
    try expect(rejected.status == 503 and sink.calls == 1);
    var missing = try client.get("/missing").send();
    defer missing.deinit();
    try expect(missing.status == 404);
    const spec = try am.openapi.generate(@TypeOf(app), &app, allocator, .{});
    defer allocator.free(spec);
    try expect(std.mem.indexOf(u8, spec, "x-akamata-capabilities") != null and std.mem.indexOf(u8, spec, "InvalidMessage") != null);
    const client_source = try am.client_gen.generate(@TypeOf(app), &app, allocator, .{ .target = .typescript });
    defer allocator.free(client_source);
    try expect(std.mem.indexOf(u8, client_source, "postMessages") != null);
    const protocol_source = try am.protocol_gen.generateProtocol(Protocol, allocator, .{ .target = .typescript });
    defer allocator.free(protocol_source);
    try expect(std.mem.indexOf(u8, protocol_source, "protocol_version: 2") != null);
    var manifest: std.Io.Writer.Allocating = .init(allocator);
    defer manifest.deinit();
    try C.writeManifest(target, &manifest.writer, .{Endpoint});
    try expect(std.mem.indexOf(u8, manifest.written(), "createMessage") != null and std.mem.indexOf(u8, manifest.written(), "/messages") != null);
}
