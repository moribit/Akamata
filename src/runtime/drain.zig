//! Socket ownership registry. shutdown interrupts I/O; only the owner closes.
const std = @import("std");
const Mutex = @import("../sync.zig").Mutex;
pub const Registry = struct {
    mutex: Mutex,
    head: ?*Node = null,
    forced: bool = false,
    next_watch_ns: u64 = 0,
    pub fn attach(self: *Registry, node: *Node, fd: c_int) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        node.* = .{ .registry = self, .fd = fd, .next = self.head };
        self.head = node;
        if (self.forced) _ = std.c.shutdown(fd, std.c.SHUT.RDWR);
    }
    pub fn force(self: *Registry) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        self.forced = true;
        var node = self.head;
        while (node) |n| : (node = n.next) {
            if (n.fd >= 0) _ = std.c.shutdown(n.fd, std.c.SHUT.RDWR);
        }
    }
    pub fn expireWrites(self: *Registry, now: u64) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        if (now < self.next_watch_ns) return;
        self.next_watch_ns = now +| 50 * std.time.ns_per_ms;
        var node = self.head;
        while (node) |n| : (node = n.next) {
            const deadline = n.write_deadline_ns.load(.acquire);
            if (n.fd >= 0 and deadline != 0 and now >= deadline) _ = std.c.shutdown(n.fd, std.c.SHUT.RDWR);
        }
    }
};
pub const Node = struct {
    registry: *Registry,
    fd: c_int,
    next: ?*Node,
    write_deadline_ns: std.atomic.Value(u64) = .init(0),
    pub fn clearWriteDeadline(self: *Node) void {
        self.registry.mutex.lock();
        defer self.registry.mutex.unlock();
        self.write_deadline_ns.store(0, .release);
    }
    pub fn close(self: *Node) void {
        self.registry.mutex.lock();
        defer self.registry.mutex.unlock();
        if (self.fd >= 0) {
            _ = std.c.close(self.fd);
            self.fd = -1;
        }
    }
    pub fn detach(self: *Node) void {
        self.close();
        self.registry.mutex.lock();
        defer self.registry.mutex.unlock();
        var slot = &self.registry.head;
        while (slot.*) |n| {
            if (n == self) {
                slot.* = n.next;
                return;
            }
            slot = &n.next;
        }
        unreachable;
    }
};
