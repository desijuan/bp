const std = @import("std");

pub const BencodeType = enum(u2) {
    int,
    string,
    list,
    dict,
};

inline fn BpType(comptime tag: BencodeType, comptime T: type) type {
    comptime return struct {
        pub const bencode_type: BencodeType = tag;
        pub const value_type: type = T;
    };
}

pub const Int = BpType(.int, u32);
pub const String = BpType(.string, []const u8);
pub const List = BpType(.list, []const u8);
pub const Dict = BpType(.dict, []const u8);

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
