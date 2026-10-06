const std = @import("std");
const ak = @import("akamata");

fn hello() []const u8 {
    return "Hello, Akamata!";
}

pub const Application = ak.App(.{ .routes = .{ak.get("/", hello)} });

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    var app = try Application.init(gpa.allocator());
    defer app.deinit();
    try app.serve(.{ .port = 8080 });
}

pub fn contract(allocator: std.mem.Allocator) !void {
    var app = try Application.init(allocator);
    defer app.deinit();
    var client = app.client(allocator);
    var response = try client.get("/").send();
    defer response.deinit();
    if (response.status != 200 or !std.mem.eql(u8, response.body, "Hello, Akamata!")) return error.DocumentationContractFailed;
}
