//! Shared executable documentation/application contract: Native and Workers WASM.
const std = @import("std");
const ak = @import("akamata");
const User = struct { id: u64, name: []const u8 };
const Body = struct {
    name: []const u8,
    pub const __schema = .{ .validates = .{ .name = .{ak.model.rule.min_len(1)} } };
};
fn hello() []const u8 {
    return "Hello, Akamata!";
}
fn user(id: ak.Path(u64, "id"), name: ak.Query(?[]const u8, "name")) error{NotFound}!User {
    if (id.value == 0) return error.NotFound;
    return .{ .id = id.value, .name = name.value orelse "Alice" };
}
fn create(body: ak.Json(Body)) ak.Result(User, 201) {
    return ak.created(User{ .id = 42, .name = body.value.name });
}
const Identity = struct { id: u64 };
const State = struct { authenticated: bool = false };
fn authenticate(c: *ak.Context(State), next: ak.Next(State)) !void {
    if (c.state().authenticated) try c.setPrincipal(Identity{ .id = 42 });
    try next.run(c);
}
fn profile(principal: ak.Principal(Identity)) Identity {
    return principal.value.*;
}
pub const Application = ak.App(.{ .State = State, .middleware = .{.{ .call = authenticate }}, .routes = .{
    ak.get("/", hello),
    ak.endpoint(.{ .method = .GET, .path = "/users/:id", .handler = user, .errors = .{ .NotFound = .not_found } }),
    ak.post("/users", create),
    ak.get("/profile", profile),
} });
fn expect(ok: bool) !void {
    if (!ok) return error.DeveloperContractFailed;
}
pub fn run(allocator: std.mem.Allocator) !void {
    var app = try Application.init(allocator);
    defer app.deinit();
    var client = app.client(allocator);
    var text = try client.get("/").send();
    defer text.deinit();
    try expect(text.status == 200 and std.mem.eql(u8, text.body, "Hello, Akamata!"));
    var found = try client.get("/users/42?name=Bob").send();
    defer found.deinit();
    const value = try found.json(User);
    try expect(found.status == 200 and value.id == 42 and std.mem.eql(u8, value.name, "Bob"));
    var missing = try client.get("/users/0").send();
    defer missing.deinit();
    try expect(missing.status == 404);
    var invalid = try client.get("/users/nope").send();
    defer invalid.deinit();
    try expect(invalid.status == 400);
    var created = try client.post("/users").json(.{ .name = "Alice" }).send();
    defer created.deinit();
    try expect(created.status == 201);
    var validation = try client.post("/users").json(.{ .name = "" }).send();
    defer validation.deinit();
    try expect(validation.status == 422);
    var absent = try client.get("/profile").send();
    defer absent.deinit();
    try expect(absent.status == 401);
    app.core.state_value.authenticated = true;
    var authenticated = try client.get("/profile").send();
    defer authenticated.deinit();
    try expect(authenticated.status == 200 and (try authenticated.json(Identity)).id == 42);
}
