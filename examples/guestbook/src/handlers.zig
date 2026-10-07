//! Ordinary handlers share DTOs and borrowed DB effects on Native and Workers.
const std = @import("std");
const am = @import("akamata");
const State = @import("app.zig").App;
const Entry = @import("models.zig").Entry;
const Ctx = am.Context(State);
const Entries = am.model.repo(Entry);

pub const CreateEntry = struct {
    name: []const u8,
    message: []const u8,
    pub const __schema = .{ .validates = Entry.__schema.validates };
};
pub const EntryList = struct { entries: []const Entry };
pub const Deleted = struct { deleted: i64 };
pub const Health = struct { status: []const u8, backend: []const u8 };

/// HTML/content negotiation is deliberately an explicit Context escape hatch.
pub fn index(c: *Ctx) !void {
    const accept = c.req.header("accept") orelse "";
    if (std.mem.indexOf(u8, accept, "text/html") != null) return c.html(@embedFile("index.html"));
    try c.json(.{ .name = "akamata guestbook", .backend = @tagName(am.backend), .documentation = "/openapi.json" }, 200);
}
pub fn health(c: *Ctx) error{DatabaseUnavailable}!Health {
    var stmt = c.db().prepare("SELECT 1") catch return error.DatabaseUnavailable;
    defer stmt.deinit();
    _ = stmt.step() catch return error.DatabaseUnavailable;
    return .{ .status = "ok", .backend = @tagName(am.backend) };
}
pub fn listEntries(c: *Ctx, limit: am.Query(?u16, "limit")) !EntryList {
    const count = limit.value orelse 100;
    if (count == 0 or count > 100) return error.InvalidLimit;
    const entries = try Entries.queryRaw(c.db(), c.arena, "SELECT id,name,message,created_at FROM guestbook ORDER BY id DESC LIMIT ?", .{count});
    return .{ .entries = entries };
}
pub fn createEntry(c: *Ctx, body: am.Json(CreateEntry)) !am.Result(Entry, 201) {
    return am.created(try Entries.create(c.db(), c.arena, .{ .name = body.value.name, .message = body.value.message }));
}
pub fn showEntry(c: *Ctx, id: am.Path(i64, "id")) !Entry {
    if (id.value <= 0) return error.InvalidId;
    return (try Entries.find(c.db(), c.arena, id.value)) orelse error.NotFound;
}
pub fn deleteEntry(c: *Ctx, id: am.Path(i64, "id")) !Deleted {
    if (id.value <= 0) return error.InvalidId;
    _ = (try Entries.find(c.db(), c.arena, id.value)) orelse return error.NotFound;
    try Entries.delete(c.db(), id.value);
    return .{ .deleted = id.value };
}
pub fn openapi(c: *Ctx) anyerror!void {
    var metadata: @import("setup.zig").Application.Metadata = .{};
    const bytes = try am.openapi.generate(@TypeOf(metadata), &metadata, c.arena, .{ .title = "Guestbook", .version = "1" });
    try c.header("content-type", "application/json");
    try c.body(bytes);
}
pub fn client(c: *Ctx) anyerror!void {
    var metadata: @import("setup.zig").Application.Metadata = .{};
    const bytes = try am.client_gen.generate(@TypeOf(metadata), &metadata, c.arena, .{ .target = .typescript });
    try c.header("content-type", "application/typescript");
    try c.body(bytes);
}
