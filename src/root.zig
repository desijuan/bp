const types = @import("types.zig");
const BencodeType = types.BencodeType;

pub const Int: type = BencodeType(.int);
pub const String: type = BencodeType(.string);
pub const List: type = BencodeType(.list);
pub const Dict: type = BencodeType(.dict);

pub const Dto: fn (comptime type) type = types.Dto;

pub const Parser: type = @import("Parser.zig");
