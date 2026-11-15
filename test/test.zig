const std = @import("std");

const bp = @import("bp");
const Parser = bp.Parser;

const TorrentFileSchema = struct {
    @"creation date": bp.Int,
    announce: bp.String,
    comment: bp.String,
    @"created by": bp.String,
    info: bp.Dict,
    @"url-list": bp.List,
};

const TorrentSchema = struct {
    length: bp.Int,
    @"piece length": bp.Int,
    name: bp.String,
    pieces: bp.String,
};

const testing = std.testing;

test "parse debian torrent" {
    const ta = testing.allocator;
    const io = testing.io;

    const buffer: []const u8 = try std.Io.Dir.readFileAlloc(
        std.Io.Dir.cwd(),
        io,
        "test/debian-12.9.0-amd64-netinst.iso.torrent",
        ta,
        std.Io.Limit.unlimited,
    );
    defer ta.free(buffer);

    var parser: Parser = undefined;

    parser = Parser.init(buffer);
    var torrentFile: bp.Dto(TorrentFileSchema) = undefined;
    try parser.parseDict(TorrentFileSchema, &torrentFile);

    try testing.expectEqual(1736599700, torrentFile.@"creation date");
    try testing.expectEqualSlices(u8, "http://bttracker.debian.org:6969/announce", torrentFile.announce);
    try testing.expectEqualSlices(u8, "\"Debian CD from cdimage.debian.org\"", torrentFile.comment);
    try testing.expectEqualSlices(u8, "mktorrent 1.1", torrentFile.@"created by");

    parser = Parser.init(torrentFile.info);
    var torrent: bp.Dto(TorrentSchema) = undefined;
    try parser.parseDict(TorrentSchema, &torrent);

    try testing.expectEqual(662700032, torrent.length);
    try testing.expectEqual(262144, torrent.@"piece length");
    try testing.expectEqualSlices(u8, "debian-12.9.0-amd64-netinst.iso", torrent.name);
}
