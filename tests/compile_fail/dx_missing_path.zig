const ak = @import("akamata");
fn call() []const u8 {
    return "ok";
}
test {
    _ = ak.App(.{ .routes = .{ak.get("/users/:id", call)} });
}
