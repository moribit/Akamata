const std = @import("std");
const am = @import("akamata");
const setup = @import("setup.zig");
const Entry = @import("models.zig").Entry;

test "same typed graph validates input, maps errors and persists DB effects" {
    const allocator = std.testing.allocator;
    const database = try am.db.openForContract(allocator, @import("app.zig").App.application_contract, "file::memory:");
    defer database.close();
    try setup.migrateDevelopment(allocator, database);
    var app = try setup.Application.initWithState(allocator, .{ .db = database });
    defer app.deinit();
    var client = app.client(allocator);
    defer client.deinit();

    var bad = try client.post("/entries").json(.{ .name = "", .message = "hello" }).send();
    defer bad.deinit();
    try bad.expectStatus(.unprocessable_entity);
    var malformed = try client.get("/entries/nope").send();
    defer malformed.deinit();
    try malformed.expectStatus(.bad_request);
    var missing = try client.get("/entries/99").send();
    defer missing.deinit();
    try missing.expectStatus(.not_found);
    try std.testing.expect(std.mem.indexOf(u8, missing.body, "NotFound") != null);

    var created = try client.post("/entries").json(.{ .name = "Alice", .message = "ordinary Zig" }).send();
    defer created.deinit();
    try created.expectStatus(.created);
    const entry = try created.json(Entry);
    try std.testing.expect(entry.id.? > 0);
    var found = try client.getf("/entries/{d}", .{entry.id.?}).send();
    defer found.deinit();
    try std.testing.expectEqualStrings("Alice", (try found.json(Entry)).name);
    var listed = try client.get("/entries?limit=1").send();
    defer listed.deinit();
    try std.testing.expectEqual(@as(usize, 1), (try listed.json(@import("handlers.zig").EntryList)).entries.len);
    var invalid_limit = try client.get("/entries?limit=101").send();
    defer invalid_limit.deinit();
    try invalid_limit.expectStatus(.bad_request);

    var document = try client.get("/openapi.json").send();
    defer document.deinit();
    const parsed = try document.json(std.json.Value);
    const responses = parsed.object.get("paths").?.object.get("/entries").?.object.get("post").?.object.get("responses").?.object;
    try std.testing.expect(responses.get("201") != null and responses.get("422") != null);
    var generated = try client.get("/client.ts").send();
    defer generated.deinit();
    try std.testing.expect(std.mem.indexOf(u8, generated.body, "postEntries") != null);
    try std.testing.expect(std.mem.indexOf(u8, generated.body, "message") != null);

    var deleted = try client.deletef("/entries/{d}", .{entry.id.?}).send();
    defer deleted.deinit();
    try deleted.expectStatus(.ok);
    var gone = try client.getf("/entries/{d}", .{entry.id.?}).send();
    defer gone.deinit();
    try gone.expectStatus(.not_found);
}

fn buildGraph(allocator: std.mem.Allocator, database: am.db.Db) !void {
    var app = try setup.Application.initWithState(allocator, .{ .db = database });
    defer app.deinit();
}
test "partial graph allocation failure does not close or leak the borrowed DB" {
    const database = try am.db.open(std.testing.allocator, "file::memory:");
    defer database.close();
    try std.testing.checkAllAllocationFailures(std.testing.allocator, buildGraph, .{database});
    try database.exec("CREATE TABLE still_owned (id INTEGER)");
}
