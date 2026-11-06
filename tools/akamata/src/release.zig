const std = @import("std");

pub const STABLE_VERSION = "v0.2.1";

pub const STABLE_HASH = "akamata-0.2.1-uJIoI3crPQE12CxtQ0Iv_d0wHvo0M3USWct-sZKaIc1_";

pub const VERSION = "0.2.1";

// Scaffold bootstrap remains pinned to the last published immutable archive.
// Template compatibility is explicit and must not follow that bootstrap pin.
pub const CURRENT_TAG = "v" ++ VERSION;

pub fn supportsManagedTemplates(version: []const u8) bool {
    return std.mem.eql(u8, version, CURRENT_TAG) or std.mem.eql(u8, version, "v0.2.0");
}

test "managed template versions are independent from scaffold bootstrap" {
    try std.testing.expect(supportsManagedTemplates(CURRENT_TAG));
    try std.testing.expect(supportsManagedTemplates(STABLE_VERSION));
    try std.testing.expect(supportsManagedTemplates("v0.2.0"));
    try std.testing.expect(!supportsManagedTemplates("v0.1.5"));
    try std.testing.expect(!supportsManagedTemplates("v99.0.0"));
}
