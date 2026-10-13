const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const dep = b.dependency("zap", .{ .target = target, .optimize = optimize });
    const module = b.createModule(.{ .root_source_file = b.path("main.zig"), .target = target, .optimize = optimize });
    module.addImport("zap", dep.module("zap"));
    module.addObjectFile(.{ .cwd_relative = "../fixtures/libcompetitive_sqlite.a" });
    module.link_libc = true;
    b.installArtifact(b.addExecutable(.{ .name = "competitive-zap", .root_module = module }));
}
