const std = @import("std");

const bp = @import("bp");
const Parser = bp.Parser;

const data = @import("data.zig");

const TorrentFileInfo: type = data.TorrentFileInfo;
const TorrentFile: type = bp.Dto(TorrentFileInfo);

const TorrentInfo: type = data.TorrentInfo;
const Torrent: type = bp.Dto(TorrentInfo);

const testing = std.testing;

test "parse debian torrent" {
    const da = testing.allocator;

    const file_buffer: []const u8 = try @import("utils.zig").readFile(
        da,
        "test/debian-12.9.0-amd64-netinst.iso.torrent",
    );
    defer da.free(file_buffer);

    var torrentFile = TorrentFile{
        .@"creation date" = 0,
        .announce = &.{},
        .comment = &.{},
        .@"created by" = &.{},
        .info = &.{},
        .@"url-list" = &.{},
    };

    var parser = Parser.init(file_buffer);
    try parser.parseDict(TorrentFileInfo, &torrentFile);

    std.debug.print("#####", .{});
    std.debug.print("\n\n Torrent File:\n", .{});
    try data.printTorrentFile(torrentFile);

    var torrent = Torrent{
        .length = 0,
        .@"piece length" = 0,
        .name = &.{},
        .pieces = &.{},
    };

    parser = Parser.init(torrentFile.info);
    try parser.parseDict(TorrentInfo, &torrent);

    std.debug.print("\n\n Torrent Info:\n", .{});
    data.printTorrent(torrent);

    std.debug.print("\n#####\n", .{});
}
