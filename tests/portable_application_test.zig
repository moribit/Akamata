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
