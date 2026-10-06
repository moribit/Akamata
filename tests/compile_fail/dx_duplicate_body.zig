const ak = @import("akamata");
fn call(_: ak.Json(struct { id: u64 }), _: ak.Json(struct { name: []const u8 })) void {}
test {
    _ = ak.App(.{ .routes = .{ak.post("/users", call)} });
}
