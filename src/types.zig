const std = @import("std");

pub const BencodeType = enum(u2) {
    int,
    string,
    list,
    dict,
};

inline fn ParsedValue(comptime tag: BencodeType, comptime T: type) type {
    return struct {
        pub const bencode_type = tag;
        pub const value_type = T;
    };
}

pub const Int = ParsedValue(.int, u32);
pub const String = ParsedValue(.string, []const u8);
pub const List = ParsedValue(.list, []const u8);
pub const Dict = ParsedValue(.dict, []const u8);

pub fn Dto(comptime T: type) type {
    const struct_info = @typeInfo(T).@"struct";
    comptime var fields: [struct_info.fields.len]std.builtin.Type.StructField = undefined;
    for (struct_info.fields, 0..) |field, i| {
        const FieldType: type = @field(field.type, "value_type");
        fields[i] = std.builtin.Type.StructField{
            .name = field.name,
            .type = FieldType,
            .default_value_ptr = null,
            .is_comptime = false,
            .alignment = @alignOf(FieldType),
        };
    }
    return @Type(std.builtin.Type{
        .@"struct" = std.builtin.Type.Struct{
            .layout = .auto,
            .fields = &fields,
            .decls = &.{},
            .is_tuple = false,
        },
    });
}
