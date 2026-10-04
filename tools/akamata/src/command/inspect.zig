const defaultConfigPath = @import("../cloudflare/config.zig").defaultConfigPath;
const client_tui = @import("../client_tui.zig");
const std = @import("std");
const VERSION = @import("../release.zig").VERSION;
const captureCmd = @import("../process.zig").captureCmd;
const countSqlMigrations = @import("../project/files.zig").countSqlMigrations;
const directoryExists = @import("../project/files.zig").directoryExists;
const fileExists = @import("../project/files.zig").fileExists;
const isHttpMethod = @import("api.zig").isHttpMethod;
const readFileAlloc = @import("../project/files.zig").readFileAlloc;
const runChild = @import("../process.zig").runChild;

// ---- project intelligence / generators ----
pub fn cmdCheck(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    var quick = false;
    for (args) |raw| {
        const arg = std.mem.sliceTo(raw, 0);
        if (std.mem.eql(u8, arg, "--quick")) quick = true else return error.UsageError;
    }
    var failures: usize = 0;
    const required = [_][]const u8{ "build.zig", "build.zig.zon", "src" };
    for (required) |path| {
        const exists = fileExists(path) or directoryExists(path);
        std.debug.print("{s} {s}\n", .{ if (exists) "ok " else "ERR", path });
        if (!exists) failures += 1;
    }
    if (failures != 0) return error.ProjectCheckFailed;
    if (!quick) try runChild(alloc, &.{ "zig", "build", "test" }, null);
    std.debug.print("check: project is healthy\n", .{});
}

pub fn cmdInspect(_: std.mem.Allocator, args: []const [:0]const u8) !void {
    var json = false;
    for (args) |raw| {
        const arg = std.mem.sliceTo(raw, 0);
        if (std.mem.eql(u8, arg, "--json")) json = true else return error.UsageError;
    }
    const native = fileExists("build.zig");
    const workers = defaultConfigPath() != null;
    const containers = fileExists("deploy/Dockerfile") or fileExists("Dockerfile");
    const migrations = countSqlMigrations("migrations");
    const dotenv = fileExists(".env");
    if (json) {
        std.debug.print("{{\"akamata\":\"{s}\",\"targets\":{{\"native\":{},\"workers\":{},\"containers\":{}}},\"migrations\":{},\"dotenv\":{}}}\n", .{ VERSION, native, workers, containers, migrations, dotenv });
    } else {
        std.debug.print("Akamata {s}\ntargets: native={s}, workers={s}, containers={s}\nmigrations: {d}\n.env: {s}\n", .{ VERSION, yesNo(native), yesNo(workers), yesNo(containers), migrations, yesNo(dotenv) });
    }
}

pub fn cmdRoutes(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    var json = false;
    var explain_method: ?[]const u8 = null;
    var explain_path: ?[]const u8 = null;
    if (args.len > 0 and std.mem.eql(u8, std.mem.sliceTo(args[0], 0), "explain")) {
        if (args.len != 3) return error.UsageError;
        explain_method = std.mem.sliceTo(args[1], 0);
        explain_path = std.mem.sliceTo(args[2], 0);
    } else for (args) |raw| {
        const arg = std.mem.sliceTo(raw, 0);
        if (std.mem.eql(u8, arg, "--json")) json = true else return error.UsageError;
    }
    const main_source_owned = readFileAlloc(alloc, "src/main.zig", 2 * 1024 * 1024) catch null;
    defer {
        if (main_source_owned) |source| alloc.free(source);
    }
    const main_source = main_source_owned orelse "";
    if (std.mem.indexOf(u8, main_source, "akamata-openapi") == null) {
        var arena_state: std.heap.ArenaAllocator = .init(alloc);
        defer arena_state.deinit();
        const routes = try client_tui.discoverForTooling(arena_state.allocator());
        if (explain_method) |method| {
            for (routes) |route| if (std.ascii.eqlIgnoreCase(@tagName(route.method), method) and std.mem.eql(u8, route.path, explain_path.?)) {
                std.debug.print("{s} {s}\n  source        {s}\n  streaming     {}\n", .{ method, route.path, route.summary, route.streaming });
                return;
            };
            return error.RouteNotFound;
        }
        if (json) {
            var aw: std.Io.Writer.Allocating = .init(arena_state.allocator());
            try std.json.Stringify.value(routes, .{}, &aw.writer);
            std.debug.print("{s}\n", .{aw.written()});
            return;
        }
        for (routes) |route| std.debug.print("{s: <7} {s} {s}\n", .{ @tagName(route.method), route.path, route.summary });
        std.debug.print("routes: {d} operation(s)\n", .{routes.len});
        return;
    }
    const bytes = try captureCmd(alloc, &.{ "zig", "build", "run", "--", "akamata-openapi" });
    defer alloc.free(bytes);
    if (json) {
        std.debug.print("{s}\n", .{std.mem.trim(u8, bytes, " \t\r\n")});
        return;
    }
    var parsed = try std.json.parseFromSlice(std.json.Value, alloc, bytes, .{});
    defer parsed.deinit();
    const paths = if (parsed.value == .object) parsed.value.object.get("paths") else null;
    if (paths == null or paths.? != .object) return error.InvalidOpenApi;
    if (explain_method) |wanted_method| {
        const wanted_path = explain_path.?;
        const path = paths.?.object.get(wanted_path) orelse return error.RouteNotFound;
        if (path != .object) return error.InvalidOpenApi;
        var lower_buf: [16]u8 = undefined;
        if (wanted_method.len > lower_buf.len) return error.InvalidMethod;
        for (wanted_method, 0..) |c, i| lower_buf[i] = std.ascii.toLower(c);
        const operation = path.object.get(lower_buf[0..wanted_method.len]) orelse return error.RouteNotFound;
        if (operation != .object) return error.InvalidOpenApi;
        std.debug.print("{s} {s}\n", .{ wanted_method, wanted_path });
        if (operation.object.get("operationId")) |v| if (v == .string) std.debug.print("  operation     {s}\n", .{v.string});
        if (operation.object.get("summary")) |v| if (v == .string) std.debug.print("  summary       {s}\n", .{v.string});
        if (operation.object.get("x-akamata-middleware")) |v| if (v == .array) {
            std.debug.print("  middleware    ", .{});
            for (v.array.items, 0..) |item, i| if (item == .string) std.debug.print("{s}{s}", .{ if (i == 0) "" else " -> ", item.string });
            std.debug.print("\n", .{});
        };
        if (operation.object.get("x-akamata-limits")) |v| if (v == .object) {
            std.debug.print("  budgets       ", .{});
            var limits = v.object.iterator();
            while (limits.next()) |entry| std.debug.print("{s} ", .{entry.key_ptr.*});
            std.debug.print("\n", .{});
        };
        return;
    }
    var count: usize = 0;
    var path_it = paths.?.object.iterator();
    while (path_it.next()) |path| {
        if (path.value_ptr.* != .object) continue;
        var method_it = path.value_ptr.*.object.iterator();
        while (method_it.next()) |method| {
            if (!isHttpMethod(method.key_ptr.*)) continue;
            const summary = if (method.value_ptr.* == .object)
                if (method.value_ptr.*.object.get("summary")) |v| if (v == .string) v.string else "" else ""
            else
                "";
            std.debug.print("{s: <7} {s} {s}\n", .{ method.key_ptr.*, path.key_ptr.*, summary });
            count += 1;
        }
    }
    std.debug.print("routes: {d} operation(s)\n", .{count});
}

pub fn cmdDoctor(_: std.mem.Allocator, args: []const [:0]const u8) !void {
    var json = false;
    for (args) |raw| {
        if (std.mem.eql(u8, std.mem.sliceTo(raw, 0), "--json")) json = true else return error.UsageError;
    }
    const build = fileExists("build.zig");
    const zon = fileExists("build.zig.zon");
    const source = fileExists("src/main.zig");
    const workspace_build = fileExists("../../build.zig") and fileExists("../../build.zig.zon");
    const workers = defaultConfigPath() != null;
    const containers = fileExists("deploy/Dockerfile") or fileExists("Dockerfile");
    const healthy = source and ((build and zon) or workspace_build);
    if (json) {
        std.debug.print("{{\"healthy\":{},\"build_zig\":{},\"build_zon\":{},\"workspace_build\":{},\"entrypoint\":{},\"workers\":{},\"containers\":{},\"migrations\":{}}}\n", .{ healthy, build, zon, workspace_build, source, workers, containers, countSqlMigrations("migrations") });
    } else {
        std.debug.print("{s} build.zig\n{s} build.zig.zon\n{s} src/main.zig\n{s} Workers config\n{s} Container config\ninfo migrations: {d}\n", .{ if (build) "ok " else "ERR", if (zon) "ok " else "ERR", if (source) "ok " else "ERR", if (workers) "ok " else "-- ", if (containers) "ok " else "-- ", countSqlMigrations("migrations") });
    }
    if (!healthy) return error.ProjectCheckFailed;
}

pub fn cmdConfig(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    if (args.len != 1) return error.UsageError;
    const sub = std.mem.sliceTo(args[0], 0);
    if (!std.mem.eql(u8, sub, "show") and !std.mem.eql(u8, sub, "check")) return error.UsageError;
    const bytes = readFileAlloc(alloc, ".env", 1024 * 1024) catch {
        if (std.mem.eql(u8, sub, "check")) return error.MissingEnvironmentFile;
        std.debug.print("configuration: no .env file\n", .{});
        return;
    };
    defer alloc.free(bytes);
    var lines = std.mem.splitScalar(u8, bytes, '\n');
    var count: usize = 0;
    while (lines.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0 or line[0] == '#') continue;
        const eq = std.mem.indexOfScalar(u8, line, '=') orelse continue;
        const key = std.mem.trim(u8, line[0..eq], " \t");
        const present = std.mem.trim(u8, line[eq + 1 ..], " \t").len != 0;
        std.debug.print("{s}: {s}\n", .{ key, if (present) "set" else "missing" });
        if (!present and std.mem.eql(u8, sub, "check")) return error.MissingConfigurationValue;
        count += 1;
    }
    std.debug.print("configuration: {d} key(s), values hidden\n", .{count});
}

pub fn cmdTest(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    if (args.len == 0) return runChild(alloc, &.{ "zig", "build", "test" }, null);
    if (args.len == 1 and std.mem.eql(u8, std.mem.sliceTo(args[0], 0), "--watch"))
        return runChild(alloc, &.{ "zig", "build", "--watch", "test" }, null);
    return error.UsageError;
}

pub fn cmdRunner(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    if (args.len == 0) return error.UsageError;
    var argv: std.ArrayList([]const u8) = .empty;
    defer argv.deinit(alloc);
    try argv.appendSlice(alloc, &.{ "zig", "build", "run", "--", "akamata-runner" });
    for (args) |arg| try argv.append(alloc, std.mem.sliceTo(arg, 0));
    return runChild(alloc, argv.items, null);
}

pub fn yesNo(value: bool) []const u8 {
    return if (value) "yes" else "no";
}
