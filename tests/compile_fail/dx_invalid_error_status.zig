const ak = @import("akamata");
fn fail() error{NotFound}!void {
    return error.NotFound;
}
const Application = ak.App(.{ .routes = .{ak.endpoint(.{ .method = .GET, .path = "/", .handler = fail, .errors = .{ .NotFound = .ok } })} });
comptime {
    _ = Application;
}
