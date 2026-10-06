const am = @import("akamata");
const C = am.capability.Contract("test application", &.{ .database, .object_storage }, &.{
    .{ .capability = .database, .provider = .d1, .binding = "RESOURCE" },
    .{ .capability = .object_storage, .provider = .r2, .binding = "RESOURCE" },
});
comptime {
    C.validate(.workers);
}
test {}
