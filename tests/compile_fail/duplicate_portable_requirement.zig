const am = @import("akamata");
const C = am.capability.Contract("test application", &.{ .database, .database }, &.{.{ .capability = .database, .provider = .sqlite }});
comptime {
    C.validate(.native);
}
test {}
