const am = @import("akamata");
const C = am.capability.Contract("test application", &.{.object_storage}, &.{.{ .capability = .object_storage, .provider = .r2, .binding = "FILES" }});
comptime {
    am.binding.validateContract(struct { files: am.binding.D1("FILES") }, C, .workers);
}
test {}
