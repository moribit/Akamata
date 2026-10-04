const std = @import("std");
const WorkerCapabilities = @import("../cloudflare/config.zig").WorkerCapabilities;

// Both `init` and `sync` pass this full bridge template through the same
// capability-aware renderer below.
const tmpl_worker_index = @import("templates.zig").tmpl_worker_index;

pub fn removeSpan(alloc: std.mem.Allocator, bytes: []const u8, start_marker: []const u8, end_marker: []const u8) ![]u8 {
    const start = std.mem.indexOf(u8, bytes, start_marker) orelse return try alloc.dupe(u8, bytes);
    const end_start = std.mem.indexOfPos(u8, bytes, start + start_marker.len, end_marker) orelse return error.InvalidWorkerTemplate;
    return std.mem.concat(alloc, u8, &.{ bytes[0..start], bytes[end_start..] });
}

pub fn renderWorkerIndex(alloc: std.mem.Allocator, name: []const u8, caps: WorkerCapabilities) ![]u8 {
    const wasm_name = try std.fmt.allocPrint(alloc, "../../zig-out/bin/{s}_worker.wasm", .{name});
    var rendered = try std.mem.replaceOwned(u8, alloc, tmpl_worker_index, "../../zig-out/bin/akamata_worker.wasm", wasm_name);
    if (!caps.realtime) {
        rendered = try std.mem.replaceOwned(u8, alloc, rendered, "import { WorkerEntrypoint } from \"cloudflare:workers\";\n", "");
        rendered = try std.mem.replaceOwned(u8, alloc, rendered, "import { REALTIME_AUTHORIZE_PATH, REALTIME_MESSAGE_PATH, rejectPublicInternalRoute } from \"./internal_routes.mjs\";\n", "");
        rendered = try removeSpan(alloc, rendered, "    const url = new URL(request.url);\n    // These handlers", "    return dispatchWasm(request);\n");
        rendered = try removeSpan(alloc, rendered, "/// Service-binding-only control-plane entrypoint.", "async function dispatchWasm(request)");
        rendered = try std.mem.replaceOwned(u8, alloc, rendered, "export { AkamataRealtimeRoom } from \"./realtime_object.mjs\";\n", "");
    }
    return rendered;
}
