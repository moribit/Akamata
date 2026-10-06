const std = @import("std");

// ---- init ----
const InitOpts = @import("../project/scaffold.zig").InitOpts;
const generate = @import("../project/scaffold.zig").generate;
const validAppName = @import("../project/scaffold.zig").validAppName;

pub fn cmdInit(parent_alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    if (args.len == 0) {
        std.debug.print("init: missing app name\n", .{});
        return error.UsageError;
    }
    var arena_state: std.heap.ArenaAllocator = .init(parent_alloc);
    defer arena_state.deinit();
    const alloc = arena_state.allocator();

    var opts: InitOpts = .{ .name = std.mem.sliceTo(args[0], 0) };
    if (!validAppName(opts.name)) {
        std.debug.print("init: app name must contain only ASCII letters, digits, '-' or '_'\n", .{});
        return error.UsageError;
    }
    for (args[1..]) |raw| {
        const a = std.mem.sliceTo(raw, 0);
        if (std.mem.startsWith(u8, a, "--target=")) {
            const v = a[9..];
            if (std.mem.eql(u8, v, "native")) opts.target = .native else if (std.mem.eql(u8, v, "workers")) opts.target = .workers else if (std.mem.eql(u8, v, "containers")) opts.target = .containers else if (std.mem.eql(u8, v, "both")) opts.target = .both else {
                std.debug.print("unknown --target value: {s}\n", .{v});
                return error.UsageError;
            }
        } else if (std.mem.startsWith(u8, a, "--template=")) {
            const value = a[11..];
            if (std.mem.eql(u8, value, "minimal")) opts.template = .minimal else if (std.mem.eql(u8, value, "notes")) opts.template = .notes else return error.UsageError;
        } else if (std.mem.eql(u8, a, "--d1")) opts.capabilities.d1 = true else if (std.mem.eql(u8, a, "--r2")) opts.capabilities.r2 = true else if (std.mem.eql(u8, a, "--queue")) opts.capabilities.queue = true else if (std.mem.eql(u8, a, "--realtime")) opts.capabilities.realtime = true;
    }

    try generate(alloc, opts);
}
