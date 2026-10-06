const ak = @import("akamata");
fn call() error{NotFound}!void {
    return error.NotFound;
}
test {
    _ = ak.App(.{ .routes = .{ak.get("/users", call)} });
}
