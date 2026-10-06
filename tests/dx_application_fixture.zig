//! Shared executable documentation/application contract: Native and Workers WASM.
const std = @import("std");
const ak = @import("akamata");
const User = struct { id: u64, name: []const u8 };
const Body = struct {
    name: []const u8,
    count: ?i32 = null,
    pub const validation = .{
        .name = .{ak.model.rule.min_len(1)},
        .count = .{ak.model.rule.range(0, 10)},
    };
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
fn secureCreate(body: ak.Json(Body), principal: ak.Principal(Identity)) User {
    return .{ .id = principal.value.id, .name = body.value.name };
}
pub const Application = ak.App(.{ .State = State, .middleware = .{.{ .call = authenticate }}, .routes = .{
    ak.get("/", hello),
    ak.endpoint(.{ .method = .GET, .path = "/users/:id", .handler = user, .errors = .{ .NotFound = .not_found } }),
    ak.post("/users", create),
    ak.get("/profile", profile),
    ak.post("/secure", secureCreate),
} });
fn expect(ok: bool) !void {
    if (!ok) return error.DeveloperContractFailed;
}
pub fn run(allocator: std.mem.Allocator) !void {
    var metadata: Application.Metadata = .{};
    const document = try ak.openapi.generate(Application.Metadata, &metadata, allocator, .{ .title = "DX fixture", .version = "1" });
    defer allocator.free(document);
    if (std.mem.indexOf(u8, document, "text/plain") == null) return error.MissingEndpointMetadata;
    const parsed_document = try std.json.parseFromSlice(std.json.Value, allocator, document, .{});
    defer parsed_document.deinit();
    const count_schema = parsed_document.value.object.get("components").?.object.get("schemas").?.object.get("Body").?.object.get("properties").?.object.get("count").?;
    const constraints = count_schema.object.get("allOf").?.array.items[1].object;
    try expect(constraints.get("minimum").?.integer == 0 and constraints.get("maximum").?.integer == 10);
    try expect(constraints.get("type") == null); // numeric keywords preserve nullable input
    const create_responses = parsed_document.value.object.get("paths").?.object.get("/users").?.object.get("post").?.object.get("responses").?.object;
    try expect(create_responses.get("400") != null and create_responses.get("422") != null);
    try @import("docs/minimal.zig").contract(allocator);
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
    try created.expectStatus(.created);
    try expect(created.status == 201);
    var validation = try client.post("/users").json(.{ .name = "" }).send();
    defer validation.deinit();
    try expect(validation.status == 422);
    var out_of_range = try client.post("/users").json(.{ .name = "Alice", .count = 11 }).send();
    defer out_of_range.deinit();
    try out_of_range.expectStatus(.unprocessable_entity);
    var nullable = try client.post("/users").json(.{ .name = "Alice", .count = @as(?i32, null) }).send();
    defer nullable.deinit();
    try nullable.expectStatus(.created);
    var absent = try client.get("/profile").send();
    defer absent.deinit();
    try expect(absent.status == 401);
    var unauthorized_body = try client.post("/secure").body("application/json", "malformed JSON").send();
    defer unauthorized_body.deinit();
    try unauthorized_body.expectStatus(.unauthorized);
    var injected = try client.get("/profile").as(Identity{ .id = 7 }).send();
    defer injected.deinit();
    try injected.expectStatus(.ok);
    try expect((try injected.json(Identity)).id == 7);
    app.core.state_value.authenticated = true;
    var authenticated = try client.get("/profile").send();
    defer authenticated.deinit();
    try expect(authenticated.status == 200 and (try authenticated.json(Identity)).id == 42);
}
