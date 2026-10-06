//! Ordinary Zig functions adapted to the existing Context handler ABI.
const std = @import("std");
const contract = @import("../contract.zig");
const context = @import("../context.zig");
const reflection = @import("../reflection.zig");
const openapi = @import("../openapi.zig");
const Code = @import("../http/status.zig").Code;

pub fn Result(comptime T: type, comptime code: u16) type {
    return struct {
        pub const ResponseType = T;
        pub const status_code = code;
        value: T,
    };
}
pub fn created(value: anytype) Result(@TypeOf(value), 201) {
    return .{ .value = value };
}
pub fn accepted(value: anytype) Result(@TypeOf(value), 202) {
    return .{ .value = value };
}
pub fn noContent() Result(void, 204) {
    return .{ .value = {} };
}

/// Request-local borrow; authentication middleware retains responsibility for credentials.
pub fn Principal(comptime T: type) type {
    return struct {
        pub const PrincipalType = T;
        value: *const T,
    };
}
fn isPrincipal(comptime T: type) bool {
    return @typeInfo(T) == .@"struct" and @hasDecl(T, "PrincipalType");
}

fn isMarker(comptime T: type) bool {
    return @typeInfo(T) == .@"struct" and @hasDecl(T, "input_source") and @hasDecl(T, "read");
}
fn isResult(comptime T: type) bool {
    return @typeInfo(T) == .@"struct" and @hasDecl(T, "ResponseType") and @hasDecl(T, "status_code");
}
fn validateValue(comptime T: type) void {
    if (T == void or T == []const u8) return;
    switch (@typeInfo(T)) {
        .bool, .int, .float, .@"enum" => {},
        .optional => |v| validateValue(v.child),
        .array => |v| validateValue(v.child),
        .pointer => |v| {
            if (v.size != .slice) @compileError("Akamata handler response cannot contain owning/raw pointers; use a slice or manual Context response");
            validateValue(v.child);
        },
        .@"struct" => |v| inline for (reflection.fields(v)) |field| validateValue(field.type),
        else => @compileError("unsupported Akamata handler return type; return a JSON value, []const u8, void, or a status helper"),
    }
}

pub fn Endpoint(comptime State: type, comptime options: anytype) type {
    const handler = options.handler;
    const path = options.path;
    const fn_info = @typeInfo(@TypeOf(handler));
    if (fn_info != .@"fn") @compileError("Akamata endpoint .handler must be an ordinary Zig function");
    const params = fn_info.@"fn".param_types;
    const Ctx = context.Context(State);
    comptime var body: ?type = null;
    comptime var context_count: usize = 0;
    inline for (params, 0..) |maybe, i| {
        const T = maybe orelse @compileError("Akamata handler parameters must have concrete types; generic anytype parameters are unsupported");
        if (T == *Ctx) {
            context_count += 1;
            continue;
        }
        if (isPrincipal(T)) continue;
        if (!isMarker(T)) @compileError("unsupported Akamata handler parameter: use *Context(State), Path, Query, Header, Cookie, Json or Principal");
        if (T.input_source == .json) {
            if (body != null) @compileError("Akamata handler may bind only one JSON body");
            if (@typeInfo(T.Value) != .@"struct") @compileError("Akamata Json request DTO must be a struct");
            body = T.Value;
        }
        inline for (params[0..i]) |prior| if (prior) |P| {
            if (isMarker(P) and P.input_source == T.input_source and std.mem.eql(u8, P.input_name, T.input_name)) @compileError("ambiguous Akamata handler binding: duplicate input " ++ T.input_name);
        };
        if (T.input_source == .path) {
            comptime var found = false;
            for (@import("../static_router.zig").parse(path)) |segment| if (segment.kind != .literal and std.mem.eql(u8, segment.text, T.input_name)) {
                found = true;
            };
            if (!found) @compileError("Akamata Path parameter " ++ T.input_name ++ " is absent from route " ++ path);
        }
    }
    if (context_count > 1) @compileError("Akamata handler may accept only one Context parameter");
    inline for (@import("../static_router.zig").parse(path)) |segment| if (segment.kind != .literal) {
        comptime var bound = false;
        for (params) |P| if (P) |T| {
            if (isMarker(T) and T.input_source == .path and std.mem.eql(u8, T.input_name, segment.text)) bound = true;
        };
        if (!bound) @compileError("Akamata route " ++ path ++ " requires Path binding for " ++ segment.text);
    };
    const Return = fn_info.@"fn".return_type orelse @compileError("Akamata handler must declare a return type");
    const has_errors = @typeInfo(Return) == .error_union;
    const Value = if (has_errors) @typeInfo(Return).error_union.payload else Return;
    const Payload = if (isResult(Value)) Value.ResponseType else Value;
    validateValue(Payload);
    const mapping = if (@hasField(@TypeOf(options), "errors")) options.errors else .{};
    const fallback: ?Code = if (@hasField(@TypeOf(options), "fallback")) options.fallback else null;
    if (has_errors and fallback == null) {
        if (@typeInfo(@typeInfo(Return).error_union.error_set).error_set.error_names == null) @compileError("Akamata anyerror handler requires an explicit .fallback HTTP status");
        contract.validateErrorMap(handler, mapping);
    }
    const success: u16 = if (isResult(Value)) Value.status_code else if (@hasField(@TypeOf(options), "success_status")) options.success_status else 200;
    const endpoint_meta = openapi.Spec(.{
        .request = body,
        .response = if (Payload == void) null else Payload,
        .response_content_type = if (Payload == []const u8) "text/plain" else "application/json",
        .success_status = success,
        .operation_id = if (@hasField(@TypeOf(options), "operation_id")) options.operation_id else "",
        .security = if (@hasField(@TypeOf(options), "security")) options.security else &.{},
        .summary = if (@hasField(@TypeOf(options), "summary")) options.summary else "",
    });
    const Metadata = struct {
        fn parameters(w: *std.Io.Writer) anyerror!usize {
            var count: usize = 0;
            inline for (params) |maybe| {
                const T = maybe.?;
                if (comptime isMarker(T) and T.input_source != .json) {
                    if (count > 0) try w.writeAll(",");
                    count += 1;
                    try w.writeAll("{\"name\":");
                    try std.json.Stringify.value(T.input_name, .{}, w);
                    try w.print(",\"in\":\"{s}\",\"required\":{s},\"schema\":", .{ @tagName(T.input_source), if (T.input_source == .path or @typeInfo(T.Value) != .optional) "true" else "false" });
                    const Scalar = if (@typeInfo(T.Value) == .optional) @typeInfo(T.Value).optional.child else T.Value;
                    try openapi.writeQueryFieldSchema(Scalar, w);
                    try w.writeAll("}");
                }
            }
            return count;
        }
        const value: openapi.EndpointMeta = blk: {
            var m = endpoint_meta.*;
            m.parameters_fn = parameters;
            break :blk m;
        };
    };
    return struct {
        pub const http_method = options.method;
        pub const route_path = path;
        pub const meta = &Metadata.value;
        pub const ResponseType = Payload;
        pub fn register(app: anytype) !void {
            _ = try app.endpoint(http_method, route_path, handle, meta);
        }
        pub fn handle(c: *Ctx) anyerror!void {
            var args: std.meta.ArgsTuple(@TypeOf(handler)) = undefined;
            inline for (params, 0..) |maybe, i| {
                const T = maybe.?;
                if (T == *Ctx) {
                    args[i] = c;
                } else if (comptime isPrincipal(T)) {
                    const principal = c.requirePrincipal(T.PrincipalType) catch {
                        try c.json(.{ .error_kind = "unauthorized" }, 401);
                        return;
                    };
                    args[i] = .{ .value = principal };
                } else if (T.input_source == .json) {
                    const dto = (try c.validatedJson(T.Value)) orelse return;
                    args[i] = .{ .value = dto };
                } else args[i] = T.read(c) catch {
                    try c.badRequest("invalid request parameter: " ++ T.input_name);
                    return;
                };
            }
            const value = if (has_errors) @call(.auto, handler, args) catch |err| {
                inline for (reflection.fields(@typeInfo(@TypeOf(mapping)).@"struct")) |field| {
                    if (std.mem.eql(u8, @errorName(err), field.name)) {
                        try c.json(.{ .error_kind = field.name }, @backingInt(@as(Code, @field(mapping, field.name))));
                        return;
                    }
                }
                if (fallback) |code| {
                    try c.json(.{ .error_kind = "internal_server_error" }, @backingInt(code));
                    return;
                }
                unreachable;
            } else @call(.auto, handler, args);
            if (Payload == void) {
                if (isResult(Value)) c.status(success);
            } else if (Payload == []const u8) {
                c.status(success);
                try c.text(if (comptime isResult(Value)) value.value else value);
            } else try c.json(if (comptime isResult(Value)) value.value else value, success);
        }
    };
}
