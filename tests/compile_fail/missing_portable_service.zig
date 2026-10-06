const am = @import("akamata");
const C = am.capability.Contract("test application", &.{.object_storage}, &.{.{ .capability = .object_storage, .provider = .filesystem }});
comptime {
    C.validateState(struct {});
}
test {}
