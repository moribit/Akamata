const std = @import("std");
const diffComponentSchemas = @import("api.zig").diffComponentSchemas;
const fileExists = @import("../project/files.zig").fileExists;
const migrateGenerate = @import("migrate.zig").migrateGenerate;
const readFileAlloc = @import("../project/files.zig").readFileAlloc;
const removeFileIfExists = @import("../project/files.zig").removeFileIfExists;
const writeFileBytes = @import("../project/files.zig").writeFileBytes;

pub fn cmdGenerate(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    if (args.len < 2 or !std.mem.eql(u8, std.mem.sliceTo(args[0], 0), "resource")) return error.UsageError;
    try resourceGenerate(alloc, std.mem.sliceTo(args[1], 0), args[2..]);
}

pub fn resourceGenerate(alloc: std.mem.Allocator, name: []const u8, args: []const [:0]const u8) !void {
    if (!validIdentifier(name)) return error.InvalidResourceName;
    var pretend = false;
    var fields: std.ArrayList([]const u8) = .empty;
    defer fields.deinit(alloc);
    for (args) |raw| {
        const arg = std.mem.sliceTo(raw, 0);
        if (std.mem.eql(u8, arg, "--pretend")) pretend = true else try fields.append(alloc, arg);
    }
    if (fields.items.len == 0) try fields.appendSlice(alloc, &.{ "name:[]const u8", "created_at:?i64" });
    var body: std.ArrayList(u8) = .empty;
    defer body.deinit(alloc);
    var aw: std.Io.Writer.Allocating = .fromArrayList(alloc, &body);
    defer body = aw.toArrayList();
    try aw.writer.print("const am = @import(\"akamata\");\n\npub const {s} = struct {{\n    id: ?i64 = null,\n", .{name});
    for (fields.items) |field| {
        const colon = std.mem.indexOfScalar(u8, field, ':') orelse return error.InvalidField;
        if (!validIdentifier(field[0..colon]) or colon + 1 == field.len) return error.InvalidField;
        try aw.writer.print("    {s}: {s},\n", .{ field[0..colon], field[colon + 1 ..] });
    }
    try aw.writer.print(
        "\n    pub const __schema = .{{ .table = \"{s}s\", .primary_key = \"id\" }};\n}};\n\npub const Repo = am.model.repo({s});\n\n" ++
            "/// Typed CRUD endpoints. Instantiate with your application State and call register.\n" ++
            "pub fn Routes(comptime State: type) type {{\n" ++
            "    return struct {{\n" ++
            "        const Ctx = am.Context(State);\n" ++
            "        fn list(c: *Ctx) !void {{\n" ++
            "            const rows = try Repo.all(c.db(), c.arena);\n" ++
            "            try c.json(.{{ .items = rows }}, 200);\n" ++
            "        }}\n" ++
            "        fn create(c: *Ctx) !void {{\n" ++
            "            const input = (try c.input({s})) orelse return;\n" ++
            "            try c.json(try Repo.create(c.db(), c.arena, input), 201);\n" ++
            "        }}\n" ++
            "        const List = am.contract.Endpoint(.GET, \"/{s}s\", list, .{{\n" ++
            "            .response = []const {s}, .operation_id = \"list_{s}s\", .tags = &.{{\"{s}s\"}},\n" ++
            "        }});\n" ++
            "        const Create = am.contract.Endpoint(.POST, \"/{s}s\", create, .{{\n" ++
            "            .request = {s}, .response = {s}, .success_status = 201,\n" ++
            "            .operation_id = \"create_{s}\", .tags = &.{{\"{s}s\"}},\n" ++
            "        }});\n" ++
            "        pub fn register(app: *am.App(State)) !void {{ try List.register(app); try Create.register(app); }}\n" ++
            "    }};\n" ++
            "}}\n",
        .{ name, name, name, name, name, name, name, name, name, name, name, name },
    );
    try aw.writer.flush();
    const model_path = try std.fmt.allocPrint(alloc, "src/{s}.zig", .{name});
    defer alloc.free(model_path);
    const test_path = try std.fmt.allocPrint(alloc, "src/{s}_test.zig", .{name});
    defer alloc.free(test_path);
    const test_body = try std.fmt.allocPrint(alloc, "const std = @import(\"std\");\nconst Resource = @import(\"{s}.zig\").{s};\n\ntest \"{s} factory\" {{\n    const value = @import(\"akamata\").testing.factory(Resource, .{{}}).build();\n    try std.testing.expect(value.id == null);\n}}\n", .{ name, name, name });
    defer alloc.free(test_body);
    if (pretend) {
        std.debug.print("create {s}\ncreate {s}\ncreate migrations/<timestamp>_create_{s}s.sql\n", .{ model_path, test_path, name });
        return;
    }
    if (fileExists(model_path) or fileExists(test_path)) return error.ResourceAlreadyExists;
    try writeFileBytes(model_path, aw.writer.buffered());
    try writeFileBytes(test_path, test_body);
    const migration_name = try std.fmt.allocPrint(alloc, "create_{s}s", .{name});
    defer alloc.free(migration_name);
    const generated_args = [_][:0]const u8{try alloc.dupeSentinel(u8, migration_name, 0)};
    defer alloc.free(generated_args[0]);
    try migrateGenerate(alloc, &generated_args);
    std.debug.print("generated resource `{s}`; import it from your app and register its routes\n", .{name});
}

pub fn cmdDestroy(alloc: std.mem.Allocator, args: []const [:0]const u8) !void {
    if (args.len < 2 or !std.mem.eql(u8, std.mem.sliceTo(args[0], 0), "resource")) return error.UsageError;
    const name = std.mem.sliceTo(args[1], 0);
    if (!validIdentifier(name)) return error.InvalidResourceName;
    var force = false;
    for (args[2..]) |raw| {
        if (std.mem.eql(u8, std.mem.sliceTo(raw, 0), "--force")) force = true else return error.UsageError;
    }
    if (!force) {
        std.debug.print("destroy is destructive; repeat with --force\n", .{});
        return error.ConfirmationRequired;
    }
    const model_path = try std.fmt.allocPrint(alloc, "src/{s}.zig", .{name});
    defer alloc.free(model_path);
    const test_path = try std.fmt.allocPrint(alloc, "src/{s}_test.zig", .{name});
    defer alloc.free(test_path);
    try removeFileIfExists(alloc, model_path);
    try removeFileIfExists(alloc, test_path);
    std.debug.print("removed generated source files for `{s}`; migrations are retained for data safety\n", .{name});
}

pub fn validIdentifier(value: []const u8) bool {
    if (value.len == 0 or !(std.ascii.isAlphabetic(value[0]) or value[0] == '_')) return false;
    for (value[1..]) |c| if (!(std.ascii.isAlphanumeric(c) or c == '_')) return false;
    return true;
}
