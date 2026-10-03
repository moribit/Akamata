/// A field view shared by schema, contract, and code generation consumers.
/// Zig 0.17 exposes parallel name/type/attribute arrays in @typeInfo.
pub const Field = struct {
    name: [:0]const u8,
    type: type = void,
    value: comptime_int = 0,
    default_value_ptr: ?*const anyopaque = null,

    pub inline fn defaultValue(comptime self: Field) ?self.type {
        const ptr: *const self.type = @ptrCast(@alignCast(self.default_value_ptr orelse return null));
        return ptr.*;
    }
};

pub fn fields(comptime info: anytype) [info.field_names.len]Field {
    var result: [info.field_names.len]Field = undefined;
    for (info.field_names, 0..) |name, i| {
        result[i] = .{ .name = name };
        if (@hasField(@TypeOf(info), "field_types")) result[i].type = info.field_types[i];
        if (@hasField(@TypeOf(info), "field_values")) result[i].value = info.field_values[i];
        if (@hasField(@TypeOf(info), "field_attrs")) {
            if (@hasField(@TypeOf(info.field_attrs[i]), "default_value_ptr")) {
                result[i].default_value_ptr = info.field_attrs[i].default_value_ptr;
            }
        }
    }
    return result;
}
