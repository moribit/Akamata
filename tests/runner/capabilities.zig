const std = @import("std");
const s = @import("support.zig");
const declaration =
    \\{"version":1,"application":"fixture","target":"workers","requirements":["database","object_storage"],"providers":[{"capability":"database","provider":"d1","binding":"DB"},{"capability":"object_storage","provider":"r2","binding":"FILES"}],"routes":[{"method":"POST","path":"/files","capabilities":["object_storage"]}]}
;
const legacy = "[[d1_databases]]\nbinding = \"DB\"\n[[r2_buckets]]\nbinding = \"FILES\"\n";
const production = "[[env.production.d1_databases]]\nbinding=\"DB\"\ndatabase_id=\"11111111-1111-1111-1111-111111111111\"\n[[env.production.r2_buckets]]\nbinding=\"FILES\"\nbucket_name=\"test-files\"\n[env.production.vars]\nDATABASE_URL=\"d1:DB\"\n";
const Probe = struct {
    h: s.H,
    cli: []const u8,
    cwd: []const u8,
    config: []const u8,
    manifest: []const u8,
    fn invoke(p: Probe, verb: []const []const u8, args: []const []const u8, expected: u8) !std.process.RunResult {
        var command: std.ArrayList([]const u8) = .empty;
        try command.append(p.h.a, p.cli);
        try command.appendSlice(p.h.a, verb);
        try command.appendSlice(p.h.a, args);
        const result = try p.h.command(command.items, p.cwd, null);
        try s.check(result.term == .exited and result.term.exited == expected, result.stderr);
        return result;
    }
    fn inspect(p: Probe, data: []const u8, expected: u8, extra: []const []const u8) !std.process.RunResult {
        try p.h.write(p.manifest, data);
        const before = try p.h.read(p.config);
        var args: std.ArrayList([]const u8) = .empty;
        try args.appendSlice(p.h.a, &.{ "--target=workers", "--json", try p.h.fmt("--manifest={s}", .{p.manifest}), try p.h.fmt("--config={s}", .{p.config}) });
        try args.appendSlice(p.h.a, extra);
        const result = try p.invoke(&.{ "inspect", "capabilities" }, args.items, expected);
        try s.eq(try p.h.read(p.config), before);
        return result;
    }
};
fn ready(h: s.H, text: []const u8, status: []const u8) !void {
    const providers = try s.field(try h.json(std.mem.trim(u8, text, " \r\n\t")), "providers");
    for (providers.array.items) |provider| try s.eq((try s.field(provider, "readiness")).string, status);
}
pub fn run(h: s.H, cli_path: []const u8) !void {
    const cli = try h.absolute(cli_path);
    const temp = try h.temp();
    defer temp.deinit();
    var p: Probe = .{ .h = h, .cli = cli, .cwd = temp.path, .config = try temp.file("wrangler.toml"), .manifest = try temp.file("contract.json") };
    try h.write(p.config, legacy);
    var result = try p.inspect(declaration, 0, &.{});
    const parsed = try h.json(std.mem.trim(u8, result.stderr, " \r\n"));
    for ((try s.field(parsed, "providers")).array.items) |provider| try s.eq((try s.field(provider, "status")).string, "binding_configured");
    try ready(h, result.stderr, "configured");
    try s.check(std.mem.indexOf(u8, result.stderr, "ready") == null, "offline inspection cannot assert remote readiness");
    result = try p.inspect(declaration, 1, &.{"--strict"});
    try s.contains(result.stderr, "ProviderConfigurationDrift");
    const deploy = try p.invoke(&.{ "deploy", "--workers" }, &.{ try h.fmt("--manifest={s}", .{p.manifest}), try h.fmt("--config={s}", .{p.config}) }, 1);
    try s.contains(deploy.stderr, "ProviderConfigurationDrift");
    try s.check(std.mem.indexOf(u8, deploy.stderr, "building wasm") == null and std.mem.indexOf(u8, deploy.stderr, "wrangler deploy") == null, "preflight before side effects");
    try h.write(p.config, production);
    result = try p.inspect(declaration, 0, &.{ "--environment=production", "--strict" });
    try s.eq((try s.field(try h.json(std.mem.trim(u8, result.stderr, " \r\n")), "environment")).string, "production");
    try ready(h, result.stderr, "validated");
    try s.contains((try p.inspect(declaration, 1, &.{"--environment=preview"})).stderr, "MissingCapabilityBinding");
    const toml = p.config;
    p.config = try temp.file("wrangler.jsonc");
    try h.write(p.config,
        \\{
        \\ // Root must not satisfy a named environment.
        \\ "r2_buckets":[{"binding":"FILES","bucket_name":"root"}],
        \\ "env":{"production":{
        \\ "d1_databases":[{"binding":"DB","database_id":"11111111-1111-1111-1111-111111111111"}],
        \\ "r2_buckets":[{"binding":"FILES","bucket_name":"production",}],
        \\ "vars":{"DATABASE_URL":"d1:DB",},
        \\ },},}
    );
    try ready(h, (try p.inspect(declaration, 0, &.{ "--environment=production", "--strict" })).stderr, "validated");
    try s.contains((try p.inspect(declaration, 1, &.{"--environment=preview"})).stderr, "MissingCapabilityBinding");
    try h.write(p.config, "{\"r2_buckets\":false}");
    try s.contains((try p.inspect(declaration, 1, &.{})).stderr, "InvalidDeploymentConfig");
    p.config = toml;
    try h.write(p.config, try s.replace(h, production, "DATABASE_URL=\"d1:DB\"", "DATABASE_URL=\"https://redacted.invalid\""));
    result = try p.inspect(declaration, 1, &.{"--environment=production"});
    try s.contains(result.stderr, "ProviderConfigurationDrift");
    try s.check(std.mem.indexOf(u8, result.stderr, "redacted.invalid") == null, "provider diagnostics redact URL");
    const realtime = "{\"version\":1,\"application\":\"fixture\",\"target\":\"workers\",\"requirements\":[\"realtime\"],\"providers\":[{\"capability\":\"realtime\",\"provider\":\"durable_objects\",\"binding\":\"ROOMS\"}],\"routes\":[]}";
    const room = "[[durable_objects.bindings]]\nname=\"ROOMS\"\nclass_name=\"Room\"\n";
    try h.write(p.config, room);
    try s.contains((try p.inspect(realtime, 1, &.{})).stderr, "ProviderConfigurationDrift");
    try h.write(p.config, room ++ "[vars]\nAKAMATA_REALTIME_BINDING=\"ROOMS\"\n");
    try ready(h, (try p.inspect(realtime, 0, &.{"--strict"})).stderr, "validated");
    try h.write(p.config, legacy);
    for ([_]struct { []const u8, []const u8 }{
        .{ "\"requirements\":[\"database\",\"object_storage\"]", "\"requirements\":[\"database\",\"database\",\"object_storage\"]" },
        .{ "\"provider\":\"r2\",\"binding\":\"FILES\"", "\"provider\":\"r2\",\"binding\":\"DB\"" },
        .{ "\"capabilities\":[\"object_storage\"]", "\"capabilities\":[\"realtime\"]" },
    }) |mutation| try s.contains((try p.inspect(try s.replace(h, declaration, mutation[0], mutation[1]), 1, &.{})).stderr, "InvalidCapabilityManifest");
    try h.write(p.config, "# [[r2_buckets]]\n# binding=\"FILES\"\n[[d1_databases]]\nbinding=\"DB\"\n");
    try s.contains((try p.inspect(declaration, 1, &.{})).stderr, "MissingCapabilityBinding");
    try h.write(p.config, legacy);
    try s.contains((try p.inspect(try s.replace(h, declaration, "\"target\":\"workers\"", "\"target\":\"native\""), 1, &.{})).stderr, "CapabilityTargetMismatch");
    for ([_][]const u8{ "sqlite", "turso" }) |provider| {
        var invalid = try h.json(declaration);
        try invalid.object.put(h.a, "providers", try h.json(try h.fmt("[{{\"capability\":\"database\",\"provider\":\"{s}\",\"binding\":null}}]", .{provider})));
        try s.contains((try p.inspect(try h.encode(invalid), 1, &.{})).stderr, "InvalidCapabilityManifest");
    }
    try std.Io.Dir.cwd().createDirPath(h.io, try temp.file("src"));
    try h.write(try temp.file("build.zig"), "");
    try h.write(try temp.file("build.zig.zon"), "");
    try h.write(p.manifest, declaration);
    result = try p.invoke(&.{ "check", "--quick", "--capabilities", "--target=workers" }, &.{ try h.fmt("--manifest={s}", .{p.manifest}), try h.fmt("--config={s}", .{p.config}) }, 0);
    try s.contains(result.stderr, "POST /files");
    try h.write(try temp.file("src/main.zig"), "pub fn main() void {}");
    try s.contains((try p.invoke(&.{ "inspect", "capabilities" }, &.{}, 1)).stderr, "ApplicationContractNotDeclared");
    result = try p.invoke(&.{ "deploy", "--workers", "--environment=production" }, &.{try h.fmt("--config={s}", .{p.config})}, 1);
    try s.contains(result.stderr, "ApplicationContractNotDeclared");
    try s.check(std.mem.indexOf(u8, result.stderr, "building wasm") == null, "no build before declaration");
    result = try p.invoke(&.{ "deploy", "--containers" }, &.{try h.fmt("--manifest={s}", .{p.manifest})}, 1);
    try s.contains(result.stderr, "CapabilityTargetMismatch");
    try s.check(std.mem.indexOf(u8, result.stderr, "docker build") == null, "no container before validation");
    std.debug.print("CLI capability contracts passed\n", .{});
}
