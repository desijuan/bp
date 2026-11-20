const std = @import("std");

const EBencodeType = enum(u2) {
    int,
    string,
    list,
    dict,
};

///
/// Type wrapper around EBencodeType
///
pub fn BencodeType(comptime eBencodeType: EBencodeType) type {
    return struct {
        pub const t_bencode = eBencodeType;
    };
}

pub fn DtoType(comptime eBencodeType: EBencodeType) type {
    return switch (eBencodeType) {
        .int => i64,
        .string => []const u8,
        .list => []const u8,
        .dict => []const u8,
    };
}

///
/// Takes a struct with fields of type BencodeType and returns a struct
/// with each field converted via the function DtoType
///
pub fn Dto(comptime Schema: type) type {
    const si_schema = @typeInfo(Schema).@"struct";
    const len: usize = si_schema.field_names.len;

    var field_types: [len]type = undefined;
    var field_attrs: [len]std.builtin.Type.Struct.FieldAttributes = undefined;

    inline for (si_schema.field_types, 0..) |field_type, i| {
        if (@typeInfo(field_type) != .@"struct" or !@hasDecl(field_type, "t_bencode"))
            @compileError("Fields must be of type BencodeType");

        field_types[i] = DtoType(field_type.t_bencode);
        field_attrs[i] = .{};
    }

    return @Struct(.auto, null, si_schema.field_names, &field_types, &field_attrs);
}
