//! End-to-end tests for the tasks example, exercised through
//! `am.testing.Client` — no port binding, no thread shenanigans, just
//! direct `app.dispatch` invocations against a real (in-memory) DB.

const std = @import("std");
const am = @import("akamata");
const App = @import("app.zig").App;
const EventChannel = @import("app.zig").EventChannel;
const h = @import("handlers.zig");
const models = @import("models.zig");

const setup = @import("setup.zig");
const Fixture = struct {
    db: am.db.Db,
    recorder: am.testing.QueueRecorder,
    app: ?setup.Application = null,
    fn create(alloc: std.mem.Allocator) !*@This() {
        const self = try alloc.create(@This());
        errdefer alloc.destroy(self);
        self.* = .{ .db = try am.db.openForContract(alloc, App.application_contract, "file::memory:"), .recorder = .init(alloc) };
        errdefer self.db.close();
        errdefer self.recorder.deinit();
        try setup.migrateDevelopment(alloc, self.db);
        self.app = try setup.Application.initWithState(alloc, .{ .db = self.db, .queue = self.recorder.producer() });
        return self;
    }
    fn deinit(self: *@This(), alloc: std.mem.Allocator) void {
        self.app.?.deinit();
        self.recorder.deinit();
        self.db.close();
        alloc.destroy(self);
    }
};

test "POST /tasks creates a task" {
    const alloc = std.testing.allocator;
    const fixture = try Fixture.create(alloc);
    defer fixture.deinit(alloc);
    var client = fixture.app.?.client(alloc);
    defer client.deinit();

    var resp = try client.post("/tasks").json(.{ .title = "buy milk" }).send();
    defer resp.deinit();

    try std.testing.expectEqual(@as(u16, 201), resp.status);

    const Out = struct { id: i64, title: []const u8, done: bool };
    const created = try resp.json(Out);
    try std.testing.expectEqualStrings("buy milk", created.title);
    try std.testing.expect(created.id > 0);
    try std.testing.expect(!created.done);
}

test "POST /tasks rejects missing title with 422" {
    const alloc = std.testing.allocator;
    const fixture = try Fixture.create(alloc);
    defer fixture.deinit(alloc);
    var client = fixture.app.?.client(alloc);
    defer client.deinit();

    // Empty title fails both `required` and `min_len(1)`.
    var resp = try client.post("/tasks").json(.{ .title = "" }).send();
    defer resp.deinit();

    try std.testing.expectEqual(@as(u16, 422), resp.status);
    try std.testing.expect(std.mem.indexOf(u8, resp.body, "\"field\":\"title\"") != null);
}

test "GET /tasks/:id returns 404 for unknown id" {
    const alloc = std.testing.allocator;
    const fixture = try Fixture.create(alloc);
    defer fixture.deinit(alloc);
    var client = fixture.app.?.client(alloc);
    defer client.deinit();

    var resp = try client.get("/tasks/9999").send();
    defer resp.deinit();
    try std.testing.expectEqual(@as(u16, 404), resp.status);
}

test "PATCH /tasks/:id flips done" {
    const alloc = std.testing.allocator;
    const fixture = try Fixture.create(alloc);
    defer fixture.deinit(alloc);
    var client = fixture.app.?.client(alloc);
    defer client.deinit();

    // Create.
    var created_resp = try client.post("/tasks").json(.{ .title = "ship release" }).send();
    const id = blk: {
        const Out = struct { id: i64 };
        const created = try created_resp.json(Out);
        break :blk created.id;
    };
    created_resp.deinit();

    // Toggle done. `patchf` allocates the path via the gpa and tracks it
    // for cleanup, so no `defer alloc.free(...)` is needed.
    var patch_resp = try client.patchf("/tasks/{d}", .{id}).json(.{ .done = true }).send();
    defer patch_resp.deinit();

    try std.testing.expectEqual(@as(u16, 200), patch_resp.status);
    try std.testing.expect(std.mem.indexOf(u8, patch_resp.body, "\"done\":true") != null);
}

test "DELETE /tasks/:id removes the row" {
    const alloc = std.testing.allocator;
    const fixture = try Fixture.create(alloc);
    defer fixture.deinit(alloc);
    var client = fixture.app.?.client(alloc);
    defer client.deinit();

    var c1 = try client.post("/tasks").json(.{ .title = "x" }).send();
    const id = (try c1.json(struct { id: i64 })).id;
    c1.deinit();

    var del = try client.deletef("/tasks/{d}", .{id}).send();
    defer del.deinit();
    try std.testing.expectEqual(@as(u16, 200), del.status);

    var miss = try client.getf("/tasks/{d}", .{id}).send();
    defer miss.deinit();
    try std.testing.expectEqual(@as(u16, 404), miss.status);
}

test "queue publication and retry-safe consumer effects use the same application" {
    const alloc = std.testing.allocator;
    const fixture = try Fixture.create(alloc);
    defer fixture.deinit(alloc);
    var client = fixture.app.?.client(alloc);
    defer client.deinit();
    var response = try client.post("/tasks").json(.{ .title = "notify" }).send();
    defer response.deinit();
    try response.expectStatus(.created);
    const D = @import("contract.zig").TaskCreatedDescriptor;
    try fixture.recorder.expectPublished(D);
    const item = fixture.recorder.items.items[0];
    var effects: h.Effects = .{ .db = fixture.db };
    const consumer: am.queue.Consumer(D.Payload) = .{ .context = &effects, .handler_with_context = h.consumeCreated };
    try consumer.consumeEnvelope(alloc, D, item.meta, item.payload);
    try consumer.consumeEnvelope(alloc, D, item.meta, item.payload);
    var count = try fixture.db.prepare("SELECT count(*) FROM task_deliveries");
    defer count.deinit();
    try std.testing.expectEqual(am.db.StepResult.row, try count.step());
    try std.testing.expectEqual(@as(i64, 1), try count.columnInt(0));
    var spec = try client.get("/openapi.json").send();
    defer spec.deinit();
    try spec.expectStatus(.ok);
}
test "SSE snapshots survive ring eviction and reject oversized events" {
    var channel = EventChannel.init(std.testing.allocator);
    defer channel.deinit();
    try channel.publish("original");
    const snapshot = channel.pollAfter(0).?;
    for (0..65) |_| try channel.publish("replacement");
    try std.testing.expectEqualStrings("original", snapshot.bytes[0..snapshot.len]);
    try std.testing.expectError(error.EventTooLarge, channel.publish(&@as([4097]u8, @splat('x'))));
}

test "real Native queue owner delivers finite work and borrows DB" {
    const alloc = std.testing.allocator;
    const db = try am.db.openForContract(alloc, App.application_contract, "file::memory:");
    defer db.close();
    try setup.migrateDevelopment(alloc, db);
    var effects: h.Effects = .{ .db = db };
    const D = @import("contract.zig").TaskCreatedDescriptor;
    const owner = try am.jobs.Provider(D).createForContract(alloc, App.application_contract, db, .{ .context = &effects, .handler_with_context = h.consumeCreated }, .{});
    defer owner.deinit();
    try owner.producer().dispatchDescriptor(alloc, D, .{ .task_id = 7 }, .{ .event_id = "task:7", .idempotency_key = "task:7" });
    var worker = owner.worker();
    try worker.tick();
    var stmt = try db.prepare("SELECT task_id, attempt FROM task_deliveries WHERE event_id = 'task:7'");
    defer stmt.deinit();
    try std.testing.expectEqual(am.db.StepResult.row, try stmt.step());
    try std.testing.expectEqual(@as(i64, 7), try stmt.columnInt(0));
    try std.testing.expectEqual(@as(i64, 1), try stmt.columnInt(1));
    worker.stop();
    try std.testing.expectError(error.Unavailable, owner.producer().dispatchDescriptor(alloc, D, .{ .task_id = 8 }, .{ .event_id = "task:8" }));
}
test "queue rejection does not pretend to roll back the DB effect" {
    const alloc = std.testing.allocator;
    const fixture = try Fixture.create(alloc);
    defer fixture.deinit(alloc);
    fixture.recorder.limit = 0;
    var client = fixture.app.?.client(alloc);
    defer client.deinit();
    var response = try client.post("/tasks").json(.{ .title = "persisted before rejection" }).send();
    defer response.deinit();
    try response.expectStatus(.internal_server_error);
    var stmt = try fixture.db.prepare("SELECT count(*) FROM tasks");
    defer stmt.deinit();
    try std.testing.expectEqual(am.db.StepResult.row, try stmt.step());
    try std.testing.expectEqual(@as(i64, 1), try stmt.columnInt(0));
    try std.testing.expectEqual(@as(usize, 0), fixture.recorder.items.items.len);
}
