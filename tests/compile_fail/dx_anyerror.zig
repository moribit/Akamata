const ak = @import("akamata");
fn call() anyerror!void {}
test {
    _ = ak.App(.{ .routes = .{ak.get("/users", call)} });
}
