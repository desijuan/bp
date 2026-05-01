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

pub const Int: type = BpType(.int, i32);
pub const UInt: type = BpType(.int, u32);
pub const String: type = BpType(.string, []const u8);
pub const List: type = BpType(.list, []const u8);
pub const Dict: type = BpType(.dict, []const u8);

pub fn Dto(comptime T: type) type {
    const s_info: std.builtin.Type.Struct = @typeInfo(T).@"struct";
    const f_len: usize = s_info.fields.len;

    var field_names: [f_len][]const u8 = undefined;
    var field_types: [f_len]type = undefined;
    var field_attrs: [f_len]std.builtin.Type.StructField.Attributes = undefined;

    for (s_info.fields, 0..) |field, i| {
        const FieldType: type = @field(field.type, "value_type");

        field_names[i] = field.name;
        field_types[i] = FieldType;
        field_attrs[i] = .{
            .@"comptime" = false,
            .@"align" = @alignOf(FieldType),
        };
    }

    return @Struct(
        .auto,
        null,
        &field_names,
        &field_types,
        &field_attrs,
    );
}
