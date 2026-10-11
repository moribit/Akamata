const ak = @import("akamata");
fn value() union { n: u32, flag: bool } {
    return .{ .n = 1 };
}
test {
    _ = ak.App(.{ .routes = .{ak.get("/", value)} });
}
