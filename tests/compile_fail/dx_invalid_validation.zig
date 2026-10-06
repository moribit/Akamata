const ak = @import("akamata");
const Body = struct {
    name: []const u8,
    pub const validation = .{ .typo = .{ak.model.rule.required} };
};
fn create(_: ak.Json(Body)) void {}
const Application = ak.App(.{ .routes = .{ak.post("/", create)} });
comptime {
    _ = Application;
}
