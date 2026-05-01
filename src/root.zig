const std = @import("std");

const types = @import("types.zig");
pub const Int: type = types.Int;
pub const UInt: type = types.UInt;
pub const String: type = types.String;
pub const List: type = types.List;
pub const Dict: type = types.Dict;
pub const Dto: fn (comptime T: type) type = types.Dto;

pub const Parser = @import("Parser.zig");
