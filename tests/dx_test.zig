const std = @import("std");
const ak = @import("akamata");
test "README source executes through the in-process client" {
    try @import("docs/minimal.zig").contract(std.testing.allocator);
}

test "test storage owner asserts effects without changing Store" {
    var store = ak.testing.MemoryStore.init(std.testing.allocator);
    try std.testing.expectError(error.MissingExpectedObject, store.expectExists("objects/test"));
    const Empty = struct {
        fn read(_: *anyopaque, _: []u8) ak.stream.Error!usize {
            return 0;
        }
        fn close(_: *anyopaque) void {}
    };
    var source: u8 = 0;
    _ = try store.store().put("objects/test", .{ .ptr = &source, .read_fn = Empty.read, .close_fn = Empty.close }, .{});
    try store.expectExists("objects/test");
    try store.store().delete("objects/test");
    try std.testing.expectError(error.MissingExpectedObject, store.expectExists("objects/test"));
}

test "request failure releases staged test-client allocations" {
    var app = try Application.init(std.testing.allocator);
    defer app.deinit();
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{});
    var client = app.client(failing.allocator());
    const request = client.post("/users").json(.{ .name = "Alice" });
    failing.fail_index = failing.alloc_index;
    try std.testing.expectError(error.OutOfMemory, request.send());
    try std.testing.expectEqual(failing.allocated_bytes, failing.freed_bytes);
}
fn hello() []const u8 {
    return "Hello, Akamata!";
}
const User = struct { id: u64, name: []const u8 };
fn show(id: ak.Path(u64, "id"), q: ak.Query(?[]const u8, "name")) error{NotFound}!User {
    if (id.value == 0) return error.NotFound;
    return .{ .id = id.value, .name = q.value orelse "Alice" };
}
const Input = struct {
    name: []const u8,
    pub const __schema = .{ .validates = .{ .name = .{ak.model.rule.min_len(1)} } };
};
fn create(body: ak.Json(Input)) ak.Result(User, 201) {
    return ak.created(User{ .id = 42, .name = body.value.name });
}
const Application = ak.App(.{ .routes = .{
    ak.get("/", hello),
    ak.endpoint(.{ .method = .GET, .path = "/users/:id", .handler = show, .errors = .{ .NotFound = .not_found } }),
    ak.post("/users", create),
} });
test "ordinary functions use shared routing binding validation and responses" {
    var app = try Application.init(std.testing.allocator);
    defer app.deinit();
    var client = app.client(std.testing.allocator);
    var response = try client.get("/").send();
    defer response.deinit();
    try response.expectStatus(200);
    try std.testing.expectEqualStrings("Hello, Akamata!", response.body);
    var user = try client.get("/users/42?name=Bob").send();
    defer user.deinit();
    try user.expectStatus(200);
    try std.testing.expectEqualStrings("Bob", (try user.json(User)).name);
    var missing = try client.get("/users/0").send();
    defer missing.deinit();
    try missing.expectStatus(404);
    var invalid = try client.get("/users/nope").send();
    defer invalid.deinit();
    try invalid.expectStatus(400);
    var created = try client.post("/users").json(.{ .name = "Alice" }).send();
    defer created.deinit();
    try created.expectStatus(201);
    var validation = try client.post("/users").json(.{ .name = "" }).send();
    defer validation.deinit();
    try validation.expectStatus(422);
}

const State = struct { message: []const u8 };
fn manual(c: *ak.Context(State)) void {
    c.status(202);
}
fn stateful(c: *ak.Context(State)) []const u8 {
    return c.state().message;
}
test "Context and existing App(State) remain explicit compatible escape hatches" {
    const Advanced = ak.App(.{ .State = State, .routes = .{ ak.get("/state", stateful), ak.get("/manual", manual) } });
    var app = try Advanced.initWithState(std.testing.allocator, .{ .message = "state" });
    defer app.deinit();
    var client = app.client(std.testing.allocator);
    var state = try client.get("/state").send();
    defer state.deinit();
    try std.testing.expectEqualStrings("state", state.body);
    var response = try client.get("/manual").send();
    defer response.deinit();
    try response.expectStatus(202);
    var legacy = ak.App(State).init(std.testing.allocator, .{ .message = "legacy" });
    defer legacy.deinit();
    const Legacy = struct {
        fn handle(c: *ak.Context(State)) anyerror!void {
            manual(c);
        }
    };
    _ = try legacy.get("/manual", Legacy.handle);
    var legacy_client = ak.testing.Client(@TypeOf(legacy)).init(std.testing.allocator, &legacy);
    var legacy_response = try legacy_client.get("/manual").send();
    defer legacy_response.deinit();
    try legacy_response.expectStatus(202);
}

test "typed parameter metadata matches actual binding" {
    var app = try Application.init(std.testing.allocator);
    defer app.deinit();
    const document = try ak.openapi.generate(Application.Core, &app.core, std.testing.allocator, .{});
    defer std.testing.allocator.free(document);
    const parsed = try std.json.parseFromSlice(std.json.Value, std.testing.allocator, document, .{});
    defer parsed.deinit();
    const operation = parsed.value.object.get("paths").?.object.get("/users/{id}").?.object.get("get").?;
    const parameters = operation.object.get("parameters").?.array.items;
    try std.testing.expectEqual(@as(usize, 2), parameters.len);
    try std.testing.expectEqualStrings("integer", parameters[0].object.get("schema").?.object.get("type").?.string);
    try std.testing.expect(parameters[0].object.get("required").?.bool);
    try std.testing.expectEqualStrings("query", parameters[1].object.get("in").?.string);
    try std.testing.expect(!parameters[1].object.get("required").?.bool);
    const not_found = operation.object.get("responses").?.object.get("404").?;
    const error_schema = not_found.object.get("content").?.object.get("application/json").?.object.get("schema").?;
    const kinds = error_schema.object.get("properties").?.object.get("error_kind").?.object.get("enum").?.array.items;
    try std.testing.expectEqualStrings("NotFound", kinds[0].string);
}

const Identity = struct { id: u64 };
const AuthState = struct { authenticated: bool = false, wrong_type: bool = false, middleware_calls: usize = 0, deny: bool = false };
fn attachIdentity(c: *ak.Context(AuthState), next: ak.Next(AuthState)) !void {
    c.state().middleware_calls += 1;
    if (c.state().deny) return c.json(.{ .error_kind = "forbidden" }, 403);
    if (c.state().authenticated) {
        if (c.state().wrong_type) try c.setPrincipal(@as(u64, 42)) else try c.setPrincipal(Identity{ .id = 42 });
    }
    try next.run(c);
}
fn profile(principal: ak.Principal(Identity)) Identity {
    return principal.value.*;
}
test "principal binding uses middleware and rejects absent or incorrectly typed identity" {
    const AuthApp = ak.App(.{ .State = AuthState, .middleware = .{.{ .call = attachIdentity }}, .routes = .{ak.get("/profile", profile)} });
    var app = try AuthApp.init(std.testing.allocator);
    defer app.deinit();
    var client = app.client(std.testing.allocator);
    var absent = try client.get("/profile").send();
    defer absent.deinit();
    try absent.expectStatus(401);
    app.core.state_value.authenticated = true;
    var authenticated = try client.get("/profile").send();
    defer authenticated.deinit();
    try authenticated.expectStatus(200);
    try std.testing.expectEqual(@as(u64, 42), (try authenticated.json(Identity)).id);
    app.core.state_value.wrong_type = true;
    var wrong = try client.get("/profile").send();
    defer wrong.deinit();
    try wrong.expectStatus(401);
    app.core.state_value.authenticated = false;
    app.core.state_value.wrong_type = false;
    const before = app.core.state_value.middleware_calls;
    var injected = try client.get("/profile").as(Identity{ .id = 7 }).send();
    defer injected.deinit();
    try injected.expectStatus(.ok);
    try std.testing.expectEqual(@as(u64, 7), (try injected.json(Identity)).id);
    try std.testing.expectEqual(before + 1, app.core.state_value.middleware_calls);
    app.core.state_value.deny = true;
    var denied = try client.get("/profile").as(Identity{ .id = 7 }).send();
    defer denied.deinit();
    try denied.expectStatus(.forbidden);
}

test "shared Native Workers developer application contract" {
    try @import("dx_application_fixture.zig").run(std.testing.allocator);
}

fn search(term: ak.Query([]const u8, "term")) []const u8 {
    return term.value;
}
test "client derives scalar responses and typed path and required query from endpoint metadata" {
    const ClientApp = ak.App(.{ .routes = .{ ak.get("/", hello), ak.get("/search", search), ak.endpoint(.{ .method = .GET, .path = "/users/:id", .handler = show, .errors = .{ .NotFound = .not_found } }) } });
    var app = try ClientApp.init(std.testing.allocator);
    defer app.deinit();
    const ts = try ak.client_gen.generate(ClientApp.Core, &app.core, std.testing.allocator, .{ .target = .typescript });
    defer std.testing.allocator.free(ts);
    try std.testing.expect(std.mem.indexOf(u8, ts, "export type String = string;") != null);
    try std.testing.expect(std.mem.indexOf(u8, ts, "getUsersById: async (id: number, query:") != null);
    try std.testing.expect(std.mem.indexOf(u8, ts, "return res.text();") != null);
    try std.testing.expect(std.mem.indexOf(u8, ts, "\"term\": string;\n    }): Promise<String>") != null);
    try std.testing.expect(std.mem.indexOf(u8, ts, "\"name\"?: string;\n    } = {}") != null);
    try std.testing.expect(std.mem.indexOf(u8, ts, "getUsersByIdError = { status: 404; body: { error_kind: \"NotFound\" } }") != null);
    try std.testing.expect(std.mem.indexOf(u8, ts, "throw new HttpError(res.status, body, detail);") != null);
}
