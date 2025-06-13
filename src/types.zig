const std = @import("std");

pub const BencodeType = enum(u2) {
    int,
    string,
    list,
    dict,
};

pub const Int = struct {
    pub const bencode_type: BencodeType = .int;
    pub const value_type: type = u32;
};

pub const String = struct {
    pub const bencode_type: BencodeType = .string;
    pub const value_type: type = []const u8;
};

pub const Dict = struct {
    pub const bencode_type: BencodeType = .dict;
    pub const value_type: type = []const u8;
};

pub const List = struct {
    pub const bencode_type: BencodeType = .list;
    pub const value_type: type = []const u8;
};

pub fn Dto(comptime T: type) type {
    const struct_info = @typeInfo(T).@"struct";
    var fields: [struct_info.fields.len]std.builtin.Type.StructField = undefined;
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
