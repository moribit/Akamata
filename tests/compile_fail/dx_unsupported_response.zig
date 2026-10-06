const ak = @import("akamata");
fn call() *const u8 {
    return undefined;
}
test {
    _ = ak.App(.{ .routes = .{ak.get("/users", call)} });
}
