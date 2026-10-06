const am = @import("akamata");
const C = am.capability.Contract("test application", &.{}, &.{});
comptime {
    C.validateRequirement("route POST /files", &.{.object_storage}, .workers);
}
test {}
