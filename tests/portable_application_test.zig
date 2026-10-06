const std = @import("std");
const am = @import("akamata");
const fixture = @import("portable_application_fixture.zig");
test "portable application effects, typed HTTP and generated contract" {
    try fixture.run(std.testing.allocator);
}
test "filesystem and in-memory storage satisfy the same provider contract" {
    var temporary = std.testing.tmpDir(.{});
    defer temporary.cleanup();
    var filesystem = am.storage.filesystem.FileStore.init(std.testing.allocator, std.testing.io, temporary.dir);
    try fixture.storageContract(std.testing.allocator, filesystem.store());
}

fn pageAllocationFailure(allocator: std.mem.Allocator) !void {
    var memory = am.testing.MemoryStore.init(std.testing.allocator);
    // Use the shared contract to populate and exercise metadata snapshots.
    fixture.paginationContract(allocator, memory.store()) catch |err| {
        if (err == error.Unavailable) return error.OutOfMemory;
        return err;
    };
}

test "owned storage pages clean up every allocation failure" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, pageAllocationFailure, .{});
}
