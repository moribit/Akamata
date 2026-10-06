const am = @import("akamata");
comptime {
    am.capability.Contract("test application", &.{.database}, &.{.{ .capability = .database, .provider = .sqlite }}).validate(.workers);
}
test {}
