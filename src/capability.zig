//! Package capability declarations checked against deployment targets.
pub const Target = enum { native, workers, containers };

/// Application semantics, distinct from the physical facilities in Kind.
/// Resolution declares wiring; it never constructs or owns a service.
pub const Application = enum { database, object_storage, queue, realtime, outbound_http, crypto };
pub const Provider = enum {
    sqlite,
    turso,
    d1,
    filesystem,
    r2,
    native_queue,
    workers_queue,
    native_realtime,
    durable_objects,
    native_http,
    workers_fetch,
    native_crypto,
    workers_crypto,

    pub fn application(self: Provider) Application {
        return switch (self) {
            .sqlite, .turso, .d1 => .database,
            .filesystem, .r2 => .object_storage,
            .native_queue, .workers_queue => .queue,
            .native_realtime, .durable_objects => .realtime,
            .native_http, .workers_fetch => .outbound_http,
            .native_crypto, .workers_crypto => .crypto,
        };
    }

    pub fn supports(self: Provider, target: Target) bool {
        return providerSupports(self, target);
    }

    pub fn usesBinding(self: Provider) bool {
        return switch (self.facility()) {
            .d1, .r2, .queues, .durable_objects => true,
            else => false,
        };
    }

    pub fn facility(self: Provider) Kind {
        return switch (self) {
            .sqlite => .sqlite,
            .turso, .native_http, .workers_fetch => .outbound_http,
            .d1 => .d1,
            .filesystem => .filesystem,
            .r2 => .r2,
            .native_queue => .threads,
            .workers_queue => .queues,
            .native_realtime => .websocket,
            .durable_objects => .durable_objects,
            .native_crypto => .crypto_random,
            .workers_crypto => .web_crypto,
        };
    }
};

pub const Provision = struct {
    capability: Application,
    provider: Provider,
    /// Workers binding name, never a credential or a resource identifier.
    binding: ?[]const u8 = null,
};

fn providerSupports(provider: Provider, target: Target) bool {
    return switch (provider) {
        .turso => true,
        .d1, .r2, .workers_queue, .durable_objects, .workers_fetch, .workers_crypto => target == .workers,
        else => target != .workers,
    };
}

pub fn defaultProvider(comptime required: Application, comptime target: Target) Provider {
    return switch (required) {
        .database => if (target == .workers) .d1 else .sqlite,
        .object_storage => if (target == .workers) .r2 else .filesystem,
        .queue => if (target == .workers) .workers_queue else .native_queue,
        .realtime => if (target == .workers) .durable_objects else .native_realtime,
        .outbound_http => if (target == .workers) .workers_fetch else .native_http,
        .crypto => if (target == .workers) .workers_crypto else .native_crypto,
    };
}

/// Explicit application deployment contract. Providers are mandatory: a
/// platform default is a suggestion, not an implicit service locator.
pub fn Contract(comptime subject: []const u8, comptime requirements: []const Application, comptime provisions: []const Provision) type {
    return struct {
        pub const name = subject;
        pub const required = requirements;
        pub const providers = provisions;

        pub fn resolve(comptime needed: Application) Provision {
            inline for (provisions) |provision| if (provision.capability == needed) return provision;
            @compileError(subject ++ " requires " ++ @tagName(needed) ++ ": missing explicit provider; declare a Provision using defaultProvider or an explicit alternative");
        }

        pub fn validate(comptime target: Target) void {
            inline for (provisions, 0..) |provision, i| {
                if (provision.provider.application() != provision.capability)
                    @compileError(subject ++ ": provider " ++ @tagName(provision.provider) ++ " cannot provide " ++ @tagName(provision.capability));
                if (!providerSupports(provision.provider, target))
                    @compileError(subject ++ " capability " ++ @tagName(provision.capability) ++ ": provider " ++ @tagName(provision.provider) ++ " unavailable on target " ++ @tagName(target) ++ "; select defaultProvider for this target or a supported explicit provider");
                inline for (provisions[0..i]) |previous| {
                    if (previous.capability == provision.capability)
                        @compileError(subject ++ ": duplicate provider for " ++ @tagName(provision.capability));
                    if (provision.binding) |resource_name| if (previous.binding) |prior| if (@import("std").mem.eql(u8, resource_name, prior))
                        @compileError(subject ++ ": duplicate resource binding " ++ resource_name ++ " for " ++ @tagName(previous.provider) ++ " and " ++ @tagName(provision.provider) ++ " on target " ++ @tagName(target));
                }
                requireKinds(subject ++ " capability " ++ @tagName(provision.capability) ++ " provider " ++ @tagName(provision.provider), &.{provision.provider.facility()}, target);
                if (provision.binding) |binding_name| if (binding_name.len == 0)
                    @compileError(subject ++ ": empty binding for " ++ @tagName(provision.capability));
                if (provision.provider.usesBinding() and provision.binding == null)
                    @compileError(subject ++ " capability " ++ @tagName(provision.capability) ++ " provider " ++ @tagName(provision.provider) ++ ": missing Workers binding name for target " ++ @tagName(target));
                if (!provision.provider.usesBinding() and provision.binding != null)
                    @compileError(subject ++ ": provider " ++ @tagName(provision.provider) ++ " does not use a resource binding");
            }
            inline for (requirements, 0..) |needed, index| {
                inline for (requirements[0..index]) |previous| if (previous == needed)
                    @compileError(subject ++ ": duplicate requirement " ++ @tagName(needed));
                _ = resolve(needed);
            }
        }

        pub fn validateRequirement(comptime component: []const u8, comptime needed: []const Application, comptime target: Target) void {
            validate(target);
            inline for (needed) |kind| {
                comptime var declared = false;
                inline for (requirements) |requirement| if (requirement == kind) {
                    declared = true;
                };
                if (!declared) @compileError(component ++ " requires " ++ @tagName(kind) ++ ", absent from application contract " ++ subject ++ " for target " ++ @tagName(target));
                _ = resolve(kind);
            }
        }

        /// Verify explicit borrowed facade fields, not their remote health.
        pub fn validateState(comptime State: type) void {
            inline for (requirements) |kind| {
                const field = switch (kind) {
                    .database => "db",
                    .object_storage => "store",
                    .queue => "queue",
                    .realtime => "realtime",
                    .outbound_http, .crypto => continue,
                };
                if (!@hasField(State, field)) @compileError(subject ++ " capability " ++ @tagName(kind) ++ ": State missing borrowed service field " ++ field);
                const Expected = switch (kind) {
                    .database => @import("db/db.zig").Db,
                    .object_storage => @import("storage.zig").Store,
                    .queue => @import("queue.zig").Producer,
                    .realtime => @import("realtime.zig").Service,
                    else => unreachable,
                };
                if (@FieldType(State, field) != Expected) @compileError(subject ++ " capability " ++ @tagName(kind) ++ ": State field " ++ field ++ " must use the existing portable facade " ++ @typeName(Expected));
            }
        }

        /// Versioned tooling protocol generated directly from this contract.
        /// "declared" is not remote readiness: CLI checks deployment bindings.
        pub fn writeManifest(comptime target: Target, writer: *@import("std").Io.Writer, comptime endpoints: anytype) !void {
            comptime @import("contract.zig").validateApplication(endpoints, @This(), target);
            const std = @import("std");
            try writer.writeAll("{\"version\":1,\"application\":");
            try std.json.Stringify.value(subject, .{}, writer);
            try writer.writeAll(",\"target\":");
            try std.json.Stringify.value(target, .{}, writer);
            try writer.writeAll(",\"requirements\":");
            try std.json.Stringify.value(requirements, .{}, writer);
            try writer.writeAll(",\"providers\":");
            try std.json.Stringify.value(provisions, .{}, writer);
            try writer.writeAll(",\"routes\":[");
            inline for (endpoints, 0..) |E, i| {
                if (i != 0) try writer.writeByte(',');
                try std.json.Stringify.value(.{
                    .method = E.http_method,
                    .path = E.route_path,
                    .operation_id = E.meta.operation_id,
                    .capabilities = E.meta.required_services,
                    .platform_capabilities = E.meta.required_capabilities,
                }, .{}, writer);
            }
            try writer.writeAll("]}\n");
        }
    };
}

/// Portable route requirements retain the original Endpoint metadata and
/// handler. Physical Requires remains available for platform escape hatches.
pub fn Uses(comptime EndpointType: type, comptime required: []const Application) type {
    return struct {
        pub const http_method = EndpointType.http_method;
        pub const route_path = EndpointType.route_path;
        pub const handle = EndpointType.handle;
        const metadata_value = blk: {
            var metadata = EndpointType.meta.*;
            metadata.required_services = required;
            break :blk metadata;
        };
        pub const meta = &metadata_value;
        pub const required_services = required;
        pub const required_capabilities: []const Kind = if (@hasDecl(EndpointType, "required_capabilities")) EndpointType.required_capabilities else &.{};
        pub fn register(app: anytype) !void {
            app.validateEndpoint(http_method, route_path, meta);
            _ = try app.endpoint(http_method, route_path, handle, meta);
        }
    };
}

/// Fine-grained facilities that framework components may require. This list
/// describes semantics, not implementation modules, so routes, middleware,
/// DI providers, and database backends can share it.
pub const Kind = enum {
    filesystem,
    threads,
    sockets,
    sqlite,
    d1,
    durable_objects,
    outbound_http,
    outbound_tcp,
    r2,
    queues,
    websocket,
    persistent_disk,
    persistent_storage,
    crypto_random,
    web_crypto,
};

pub const Set = struct {
    native: bool = true,
    workers: bool = true,
    containers: bool = true,
    needs_filesystem: bool = false,
    needs_threads: bool = false,
    needs_network: bool = false,

    pub fn supports(self: Set, target: Target) bool {
        return switch (target) {
            .native => self.native,
            .workers => self.workers,
            .containers => self.containers,
        };
    }
};

pub fn require(comptime package_name: []const u8, comptime capabilities: Set, comptime target: Target) void {
    if (!capabilities.supports(target)) @compileError(package_name ++ " does not support target " ++ @tagName(target));
    if (target == .workers and (capabilities.needs_filesystem or capabilities.needs_threads))
        @compileError(package_name ++ " requires capabilities unavailable on Workers");
}

pub fn available(comptime target: Target, comptime kind: Kind) bool {
    return switch (target) {
        .native => switch (kind) {
            .d1, .durable_objects, .r2, .queues, .web_crypto => false,
            else => true,
        },
        .workers => switch (kind) {
            .filesystem, .threads, .sockets, .sqlite, .persistent_disk => false,
            else => true,
        },
        .containers => switch (kind) {
            .d1, .durable_objects, .r2, .queues, .web_crypto => false,
            else => true,
        },
    };
}

/// Reject target-incompatible requirements with a diagnostic that identifies
/// the declaring route/module and the unavailable facility.
pub fn requireKinds(comptime subject: []const u8, comptime required: []const Kind, comptime target: Target) void {
    inline for (required) |kind| if (!available(target, kind)) {
        @compileError(subject ++ " requires " ++ @tagName(kind) ++ ", but target " ++ @tagName(target) ++ " does not provide it");
    };
}

/// Decorate endpoint metadata while preserving its schema functions and handler.
pub fn Requires(comptime EndpointType: type, comptime required: []const Kind) type {
    return struct {
        pub const http_method = EndpointType.http_method;
        pub const route_path = EndpointType.route_path;
        pub const handle = EndpointType.handle;
        const metadata_value = blk: {
            var metadata = EndpointType.meta.*;
            metadata.required_capabilities = required;
            break :blk metadata;
        };
        pub const meta = &metadata_value;
        pub const required_capabilities = required;
        pub const required_services: []const Application = if (@hasDecl(EndpointType, "required_services")) EndpointType.required_services else &.{};

        pub fn register(app: anytype) !void {
            app.validateEndpoint(http_method, route_path, meta);
            _ = try app.endpoint(http_method, route_path, handle, meta);
        }
    };
}

test "capability set" {
    const testing = @import("std").testing;
    try testing.expect(!(Set{ .workers = false }).supports(.workers));
}

test "portable provider mappings and explicit resolution" {
    const std = @import("std");
    inline for (.{ Target.native, Target.workers, Target.containers }) |target| {
        inline for (@typeInfo(Application).@"enum".field_names) |name| {
            const kind = @field(Application, name);
            const provider = comptime defaultProvider(kind, target);
            const C = Contract("fixture", &.{kind}, &.{.{ .capability = kind, .provider = provider, .binding = if (provider.usesBinding()) "RESOURCE" else null }});
            comptime C.validate(target);
            try std.testing.expectEqual(kind, C.resolve(kind).provider.application());
        }
    }
    const Remote = Contract("remote database", &.{.database}, &.{.{ .capability = .database, .provider = .turso }});
    comptime Remote.validate(.native);
    comptime Remote.validate(.workers);
}
