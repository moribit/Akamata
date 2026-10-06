const am = @import("akamata");

pub const App = struct {
    pub const application_contract = @import("contract.zig").For(if (am.backend == .workers) .workers else .native);
    db: am.db.Db,
};
