const ak = @import("akamata");
fn call(_: u64) void {}
test {
    _ = ak.App(.{ .routes = .{ak.get("/users", call)} });
}
