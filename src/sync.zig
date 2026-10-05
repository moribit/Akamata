// Process-local synchronization for APIs that do not own/pass an Io instance
// (SQLite pool, websocket hub, model cache). Zig 0.17 Io.Mutex/Condition require
// Io; retrofitting that context is a separate API/lifecycle change. Conn and
// runtime queues do have Io, but retain these shared uncancelable primitives
// for borrow joins and explicit abort/wakeup. This is lifecycle policy, not a
// claim that 0.17 lacks uncancelable synchronization. Use std.c target ABI types.

const std = @import("std");
const builtin = @import("builtin");

const is_posix = switch (builtin.os.tag) {
    .linux, .macos, .ios, .tvos, .watchos, .visionos, .freebsd, .netbsd, .openbsd, .dragonfly => true,
    else => false,
};

const PthreadMutex = if (is_posix) std.c.pthread_mutex_t else extern struct {};
const PthreadCond = if (is_posix) std.c.pthread_cond_t else extern struct {};

extern "c" fn pthread_mutex_init(m: *PthreadMutex, attr: ?*anyopaque) c_int;
extern "c" fn pthread_mutex_destroy(m: *PthreadMutex) c_int;
extern "c" fn pthread_mutex_lock(m: *PthreadMutex) c_int;
extern "c" fn pthread_mutex_unlock(m: *PthreadMutex) c_int;

/// Lightweight mutex. Initialise with `Mutex.init`; pointer-stable from then
/// on. Caller must call `deinit` before discarding the storage. Lock/unlock
/// are cheap pthread calls — on contended hot paths consider an
/// atomic-RW-lock or sharding instead, but for "rare writer / many readers"
/// this is fine.
pub const Mutex = struct {
    raw: PthreadMutex = .{},
    initialized: bool = false,

    pub fn init() Mutex {
        if (!is_posix) return .{};
        var m: Mutex = .{};
        _ = pthread_mutex_init(&m.raw, null);
        m.initialized = true;
        return m;
    }

    pub fn deinit(self: *Mutex) void {
        if (!is_posix or !self.initialized) return;
        _ = pthread_mutex_destroy(&self.raw);
        self.initialized = false;
    }

    pub fn lock(self: *Mutex) void {
        if (!is_posix) return;
        if (!self.initialized) {
            _ = pthread_mutex_init(&self.raw, null);
            self.initialized = true;
        }
        _ = pthread_mutex_lock(&self.raw);
    }

    pub fn unlock(self: *Mutex) void {
        if (!is_posix or !self.initialized) return;
        _ = pthread_mutex_unlock(&self.raw);
    }
};

// === Condition variable ===
//
// Used by db/pool.zig. No obsolete reactor queue dependency remains.
// std.Io.Condition cannot replace this without threading Io through Db APIs.

extern "c" fn pthread_cond_init(c: *PthreadCond, attr: ?*anyopaque) c_int;
extern "c" fn pthread_cond_destroy(c: *PthreadCond) c_int;
extern "c" fn pthread_cond_wait(c: *PthreadCond, m: *PthreadMutex) c_int;
extern "c" fn pthread_cond_signal(c: *PthreadCond) c_int;
extern "c" fn pthread_cond_broadcast(c: *PthreadCond) c_int;

/// Condition variable bound to a `Mutex`. Standard usage:
///
///     mu.lock();
///     while (!ready) cond.wait(&mu);
///     // ... act on `ready` ...
///     mu.unlock();
///
/// And from the other side:
///
///     mu.lock();
///     ready = true;
///     mu.unlock();
///     cond.signal();
pub const Condition = struct {
    raw: PthreadCond = .{},
    initialized: bool = false,

    pub fn init() Condition {
        if (!is_posix) return .{};
        var c: Condition = .{};
        _ = pthread_cond_init(&c.raw, null);
        c.initialized = true;
        return c;
    }

    pub fn deinit(self: *Condition) void {
        if (!is_posix or !self.initialized) return;
        _ = pthread_cond_destroy(&self.raw);
        self.initialized = false;
    }

    pub fn wait(self: *Condition, mu: *Mutex) void {
        if (!is_posix) return;
        if (!self.initialized) {
            _ = pthread_cond_init(&self.raw, null);
            self.initialized = true;
        }
        _ = pthread_cond_wait(&self.raw, &mu.raw);
    }

    pub fn signal(self: *Condition) void {
        if (!is_posix or !self.initialized) return;
        _ = pthread_cond_signal(&self.raw);
    }

    pub fn broadcast(self: *Condition) void {
        if (!is_posix or !self.initialized) return;
        _ = pthread_cond_broadcast(&self.raw);
    }
};

test "Condition wait + signal" {
    if (!is_posix) return error.SkipZigTest;
    var m = Mutex.init();
    defer m.deinit();
    var c = Condition.init();
    defer c.deinit();
    // basic API smoke — signal with no waiter is a no-op.
    c.signal();
    c.broadcast();
}

test "Mutex basic lock/unlock" {
    if (!is_posix) return error.SkipZigTest;
    var m = Mutex.init();
    defer m.deinit();
    m.lock();
    m.unlock();
    m.lock();
    m.unlock();
}
