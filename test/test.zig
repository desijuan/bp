const std = @import("std");

const bp = @import("bp");
const Parser = bp.Parser;

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

const testing = std.testing;

test "parse debian torrent" {
    const da = testing.allocator;

    // zig fmt: off
    const file_buffer: []const u8 = try @import("utils.zig").readFile(
        da, "test/debian-12.9.0-amd64-netinst.iso.torrent",
    ); defer da.free(file_buffer);
    // zig fmt: on

    var parser = Parser.init(file_buffer);
    var torrentFile: bp.Dto(TorrentFileInfo) = undefined;
    try parser.parseDict(TorrentFileInfo, &torrentFile);

    try testing.expectEqual(1736599700, torrentFile.@"creation date");
    try testing.expectEqualSlices(u8, "http://bttracker.debian.org:6969/announce", torrentFile.announce);
    try testing.expectEqualSlices(u8, "\"Debian CD from cdimage.debian.org\"", torrentFile.comment);
    try testing.expectEqualSlices(u8, "mktorrent 1.1", torrentFile.@"created by");

    parser = Parser.init(torrentFile.info);
    var torrent: bp.Dto(TorrentInfo) = undefined;
    try parser.parseDict(TorrentInfo, &torrent);

    try testing.expectEqual(662700032, torrent.length);
    try testing.expectEqual(262144, torrent.@"piece length");
    try testing.expectEqualSlices(u8, "debian-12.9.0-amd64-netinst.iso", torrent.name);
}
