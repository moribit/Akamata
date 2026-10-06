//! Compile-time declarations for portable Workers/native application envs.
const reflection = @import("reflection.zig");
const capability = @import("capability.zig");
const std = @import("std");

pub const Kind = enum { d1, r2, durable_object, queue, secret, variable };

fn Marker(comptime kind_value: Kind, comptime declared_name: []const u8) type {
    if (declared_name.len == 0) @compileError("binding name must not be empty");
    return struct {
        pub const binding_kind = kind_value;
        pub const binding_name = declared_name;
        handle: ?*anyopaque = null,
    };
}

pub fn D1(comptime name: []const u8) type {
    return Marker(.d1, name);
}
pub fn R2(comptime name: []const u8) type {
    return Marker(.r2, name);
}
pub fn DurableObject(comptime name: []const u8) type {
    return Marker(.durable_object, name);
}
pub fn Queue(comptime name: []const u8) type {
    return Marker(.queue, name);
}
pub fn Var(comptime name: []const u8) type {
    return Marker(.variable, name);
}

pub fn Secret(comptime name: []const u8) type {
    const Base = Marker(.secret, name);
    return struct {
        pub const binding_kind = Base.binding_kind;
        pub const binding_name = Base.binding_name;
        value: []const u8,

        pub fn reveal(self: @This()) []const u8 {
            return self.value;
        }
        pub fn format(_: @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
            try writer.writeAll("[REDACTED]");
        }
    };
}

pub fn validate(comptime Env: type, comptime target: capability.Target) void {
    const info = @typeInfo(Env);
    if (info != .@"struct") @compileError("binding environment must be a struct");
    inline for (reflection.fields(info.@"struct"), 0..) |field, i| {
        if (!@hasDecl(field.type, "binding_kind") or !@hasDecl(field.type, "binding_name"))
            @compileError("environment field " ++ field.name ++ " is not an Akamata binding declaration");
        inline for (reflection.fields(info.@"struct")[0..i]) |previous| {
            if (comptime @hasDecl(previous.type, "binding_name") and
                std.mem.eql(u8, @field(previous.type, "binding_name"), @field(field.type, "binding_name")))
                @compileError("duplicate binding name: " ++ @field(field.type, "binding_name"));
        }
        const needed: capability.Kind = switch (@field(field.type, "binding_kind")) {
            .d1 => .d1,
            .r2 => .r2,
            .durable_object => .durable_objects,
            .queue => .queues,
            .secret, .variable => continue,
        };
        capability.requireKinds("binding " ++ @field(field.type, "binding_name"), &.{needed}, target);
    }
}

/// Checks provider-to-binding edges. This is wiring validation, not remote
/// resource provisioning or deployment readiness.
pub fn validateContract(comptime Env: type, comptime Contract: type, comptime target: capability.Target) void {
    validate(Env, target);
    Contract.validate(target);
    inline for (Contract.providers) |provision| {
        const expected: ?Kind = switch (provision.provider) {
            .d1 => .d1,
            .r2 => .r2,
            .workers_queue => .queue,
            .durable_objects => .durable_object,
            else => null,
        };
        if (expected) |kind| {
            const name = provision.binding orelse @compileError(Contract.name ++ " capability " ++ @tagName(provision.capability) ++ " provider " ++ @tagName(provision.provider) ++ ": missing Workers binding name");
            comptime var found = false;
            inline for (reflection.fields(@typeInfo(Env).@"struct")) |field| {
                if (std.mem.eql(u8, field.type.binding_name, name)) {
                    if (field.type.binding_kind != kind) @compileError(Contract.name ++ " binding " ++ name ++ ": wrong binding kind for " ++ @tagName(provision.provider));
                    found = true;
                }
            }
            if (!found) @compileError(Contract.name ++ " capability " ++ @tagName(provision.capability) ++ ": binding " ++ name ++ " absent from environment for target " ++ @tagName(target));
        } else if (provision.binding != null) @compileError(Contract.name ++ ": provider " ++ @tagName(provision.provider) ++ " does not use a resource binding");
    }
}

test "worker binding declarations validate" {
    const Env = struct { db: D1("DB"), files: R2("FILES"), events: Queue("EVENTS"), rooms: DurableObject("ROOMS"), token: Secret("TOKEN") };
    comptime validate(Env, .workers);
}

test "portable requirements resolve to declared Workers bindings" {
    const Env = struct { database: D1("DB"), storage: R2("FILES"), rooms: DurableObject("ROOMS"), jobs: Queue("JOBS") };
    const C = capability.Contract("portable fixture", &.{ .database, .object_storage, .realtime, .queue }, &.{
        .{ .capability = .database, .provider = .d1, .binding = "DB" },
        .{ .capability = .object_storage, .provider = .r2, .binding = "FILES" },
        .{ .capability = .realtime, .provider = .durable_objects, .binding = "ROOMS" },
        .{ .capability = .queue, .provider = .workers_queue, .binding = "JOBS" },
    });
    comptime validateContract(Env, C, .workers);
}

test "secret formatting is always redacted" {
    const S = Secret("TOKEN");
    var aw: std.Io.Writer.Allocating = .init(std.testing.allocator);
    defer aw.deinit();
    try aw.writer.print("{f}", .{S{ .value = "never-log-this" }});
    try std.testing.expectEqualStrings("[REDACTED]", aw.written());
}
