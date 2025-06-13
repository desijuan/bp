const std = @import("std");
const bp = @import("bp");

pub const TorrentFileInfo = struct {
    @"creation date": bp.Int,
    announce: bp.String,
    comment: bp.String,
    @"created by": bp.String,
    info: bp.Dict,
    @"url-list": bp.List,
};

pub const TorrentInfo = struct {
    length: bp.Int,
    @"piece length": bp.Int,
    name: bp.String,
    pieces: bp.String,
};

const Parser = bp.Parser;

const TorrentFile: type = bp.Dto(TorrentFileInfo);
pub fn printTorrentFile(torrentFile: TorrentFile) !void {
    inline for (@typeInfo(TorrentFile).@"struct".fields) |field| switch (@typeInfo(field.type)) {
        .pointer => if (comptime std.mem.eql(u8, "info", field.name))
            std.debug.print("{s}: {s} [..]\n", .{ field.name, torrentFile.info[0..90] })
        else if (comptime std.mem.eql(u8, "url-list", field.name)) {
            std.debug.print("{s}:", .{field.name});
            try Parser.printList(torrentFile.@"url-list");
        } else std.debug.print("{s}: '{s}'\n", .{ field.name, @field(torrentFile, field.name) }),

        .int => std.debug.print("{s}: {d}\n", .{ field.name, @field(torrentFile, field.name) }),

        else => unreachable,
    };
}

const Torrent: type = bp.Dto(TorrentInfo);
pub fn printTorrent(torrent: Torrent) void {
    inline for (@typeInfo(Torrent).@"struct".fields) |field| switch (@typeInfo(field.type)) {
        .pointer => if (comptime std.mem.eql(u8, "pieces", field.name))
            std.debug.print("{s}: {x} [..]\n", .{ field.name, torrent.pieces[0..20] })
        else
            std.debug.print("{s}: '{s}'\n", .{ field.name, @field(torrent, field.name) }),

        .int => std.debug.print("{s}: {d}\n", .{ field.name, @field(torrent, field.name) }),

        else => unreachable,
    };
}
