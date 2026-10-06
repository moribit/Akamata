const am = @import("akamata");
comptime {
    am.capability.Contract("test application", &.{.database}, &.{}).validate(.native);
}
test {}
