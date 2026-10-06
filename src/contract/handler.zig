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

fn validateDto(comptime T: type) void {
    const rules = blk: {
        if (@hasDecl(T, "validation")) {
            if (@hasDecl(T, "__schema") and @hasField(@TypeOf(T.__schema), "validates")) @compileError("Akamata DTO must declare either validation or __schema.validates, not both");
            break :blk T.validation;
        }
        if (!@hasDecl(T, "__schema")) return;
        if (!@hasField(@TypeOf(T.__schema), "validates")) return;
        break :blk T.__schema.validates;
    };
    if (@typeInfo(@TypeOf(rules)) != .@"struct") @compileError("Akamata DTO validation must be a field-to-rule-tuple declaration");
    inline for (reflection.fields(@typeInfo(@TypeOf(rules)).@"struct")) |field| {
        if (!@hasField(T, field.name)) @compileError("Akamata DTO validation references unknown field " ++ field.name);
        const tuple = @field(rules, field.name);
        if (@typeInfo(@TypeOf(tuple)) != .@"struct" or !@typeInfo(@TypeOf(tuple)).@"struct".is_tuple) @compileError("Akamata DTO validation field " ++ field.name ++ " must contain a tuple of model.rule values");
        inline for (tuple) |rule| {
            if (@TypeOf(rule) != @import("../model/validate.zig").Rule) @compileError("Akamata DTO validation requires model.rule values for " ++ field.name);
            if ((rule.kind == .min_len or rule.kind == .max_len) and rule.int_a < 0) @compileError("Akamata DTO length validation cannot be negative");
            if (rule.kind == .range and rule.int_a > rule.int_b) @compileError("Akamata DTO validation range minimum exceeds maximum");
        }
    }
}

fn errorResponses(comptime mapping: anytype, comptime fallback: ?Code, comptime principal_required: bool) []const openapi.ResponseDoc {
    const fields = reflection.fields(@typeInfo(@TypeOf(mapping)).@"struct");
    var docs: [fields.len + 2]openapi.ResponseDoc = undefined;
    var count: usize = 0;
    for (fields) |field| {
        const code = @backingInt(@as(Code, @field(mapping, field.name)));
        if (code < 400 or code > 599) @compileError("Akamata application error mapping must use a 4xx or 5xx HTTP status");
        var found = false;
        for (docs[0..count]) |*doc| if (doc.status == code) {
            doc.error_kinds = doc.error_kinds ++ .{field.name};
            found = true;
        };
        if (!found) {
            docs[count] = .{ .status = code, .description = "Application error", .error_kinds = &.{field.name} };
            count += 1;
        }
    }
    const extras = .{
        .{ .status = if (fallback) |code| @backingInt(code) else 0, .kind = "internal_server_error" },
        .{ .status = if (principal_required) 401 else 0, .kind = "unauthorized" },
    };
    inline for (extras) |extra| {
        if (extra.status == 0) continue;
        if (extra.status < 400 or extra.status > 599) @compileError("Akamata fallback must use a 4xx or 5xx HTTP status");
        var found = false;
        for (docs[0..count]) |*doc| if (doc.status == extra.status) {
            doc.error_kinds = doc.error_kinds ++ .{extra.kind};
            found = true;
        };
        if (!found) {
            docs[count] = .{ .status = extra.status, .description = "Application error", .error_kinds = &.{extra.kind} };
            count += 1;
        }
    }
    const result = docs[0..count].*;
    return &result;
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
        if (T.input_source != .json) {
            if (T.input_source == .path and @typeInfo(T.Value) == .optional) @compileError("Akamata Path binding is required and cannot use an optional type");
            const Scalar = if (@typeInfo(T.Value) == .optional) @typeInfo(T.Value).optional.child else T.Value;
            const supported = Scalar == []const u8 or @typeInfo(Scalar) == .int or @typeInfo(Scalar) == .float or (Scalar == bool and T.input_source != .path);
            if (!supported) @compileError("unsupported Akamata input binding for " ++ T.input_name ++ ": use string, integer, float or a non-path boolean");
        }
        if (T.input_source == .json) {
            if (body != null) @compileError("Akamata handler may bind only one JSON body");
            if (@typeInfo(T.Value) != .@"struct") @compileError("Akamata Json request DTO must be a struct");
            validateDto(T.Value);
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
    const mapped_fields = reflection.fields(@typeInfo(@TypeOf(mapping)).@"struct");
    if (!has_errors and mapped_fields.len > 0) @compileError("Akamata error mapping requires a handler with an error-union return type");
    if (has_errors) if (@typeInfo(@typeInfo(Return).error_union.error_set).error_set.error_names) |names| {
        inline for (mapped_fields) |field| {
            comptime var exists = false;
            inline for (names) |name| if (std.mem.eql(u8, name, field.name)) {
                exists = true;
            };
            if (!exists) @compileError("HTTP mapping contains error not returned by handler: " ++ field.name);
        }
    };
    if (has_errors and fallback == null) {
        if (@typeInfo(@typeInfo(Return).error_union.error_set).error_set.error_names == null) @compileError("Akamata anyerror handler requires an explicit .fallback HTTP status");
        contract.validateErrorMap(handler, mapping);
    }
    const success: u16 = if (isResult(Value)) Value.status_code else if (@hasField(@TypeOf(options), "success_status")) options.success_status else 200;
    const principal_required = blk: {
        for (params) |maybe| if (maybe) |T| {
            if (isPrincipal(T)) break :blk true;
        };
        break :blk false;
    };
    const endpoint_meta = openapi.Spec(.{
        .request = body,
        .response = if (Payload == void) null else Payload,
        .response_content_type = if (Payload == []const u8) "text/plain" else "application/json",
        .success_status = success,
        .operation_id = if (@hasField(@TypeOf(options), "operation_id")) options.operation_id else "",
        .security = if (@hasField(@TypeOf(options), "security")) options.security else &.{},
        .additional_responses = errorResponses(mapping, fallback, principal_required),
        .summary = if (@hasField(@TypeOf(options), "summary")) options.summary else "",
    });
    const has_query = blk: {
        for (params) |maybe| if (maybe) |T| {
            if (isMarker(T) and T.input_source == .query) break :blk true;
        };
        break :blk false;
    };
    const query_required = blk: {
        for (params) |maybe| if (maybe) |T| {
            if (isMarker(T) and T.input_source == .query and @typeInfo(T.Value) != .optional) break :blk true;
        };
        break :blk false;
    };
    const Metadata = struct {
        fn queryFields(w: *std.Io.Writer) anyerror!void {
            inline for (params) |maybe| {
                const T = maybe.?;
                if (comptime isMarker(T) and T.input_source == .query) {
                    try w.writeAll("    ");
                    try std.json.Stringify.value(T.input_name, .{}, w);
                    try w.writeAll(if (@typeInfo(T.Value) == .optional) "?: " else ": ");
                    const Scalar = if (@typeInfo(T.Value) == .optional) @typeInfo(T.Value).optional.child else T.Value;
                    try openapi.writeTsScalar(Scalar, w);
                    try w.writeAll(";\n");
                }
            }
        }
        fn pathType(name: []const u8, w: *std.Io.Writer) anyerror!void {
            inline for (params) |maybe| {
                const T = maybe.?;
                if (comptime isMarker(T) and T.input_source == .path) {
                    if (std.mem.eql(u8, name, T.input_name)) return openapi.writeTsScalar(T.Value, w);
                }
            }
            return error.MissingPathMetadata;
        }
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
            m.query_ts_fields_fn = if (has_query) queryFields else null;
            m.query_required = query_required;
            m.path_ts_type_fn = pathType;
            m.required_services = if (@hasField(@TypeOf(options), "capabilities")) options.capabilities else &.{};
            m.required_capabilities = if (@hasField(@TypeOf(options), "platform_capabilities")) options.platform_capabilities else &.{};
            break :blk m;
        };
    };
    return struct {
        pub const http_method = options.method;
        pub const route_path = path;
        pub const meta = &Metadata.value;
        pub const ResponseType = Payload;
        pub fn register(app: anytype) !void {
            app.validateEndpoint(http_method, route_path, meta);
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
