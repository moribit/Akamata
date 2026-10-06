const ak = @import("akamata");
fn hello() []const u8 {
    return "Hello";
}
comptime {
    _ = ak.App(.{ .routes = .{ak.endpoint(.{ .method = .GET, .path = "/", .handler = hello, .success_status = 204 })} });
}
