//! Facades are borrowed; the entrypoint owns DB and realtime backend.
const am = @import("akamata");
pub const App = struct {
    pub const application_contract = @import("contract.zig").For(if (am.backend == .native) .native else .workers);
    db: am.db.Db,
    realtime: am.realtime.Service,
    /// Native transport lifetime guard: sends cannot outlive detach + close.
    /// Workers owns transports in the Durable Object instead.
    native_transport_gate: ?*am.sync.Mutex = null,
};
