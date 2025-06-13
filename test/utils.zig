const std = @import("std");
const testing = std.testing;

const File = std.fs.File;
const FileBufferedReader = std.io.BufferedReader(4096, File.Reader);

pub const Error = File.OpenError || File.GetSeekPosError || FileBufferedReader.Error ||
    error{ OutOfMemory, ReadError };

pub fn readFile(
    allocator: std.mem.Allocator,
    path: []const u8,
) Error![]const u8 {
    const file: File = std.fs.cwd().openFile(path, .{ .mode = .read_only }) catch |err| {
        std.log.err("Error opening file: {s}", .{path});
        return err;
    };
    defer file.close();

    var file_br: FileBufferedReader = std.io.bufferedReader(file.reader());
    const reader: FileBufferedReader.Reader = file_br.reader();

    const size: u64 = try file.getEndPos();
    const buffer: []u8 = try allocator.alloc(u8, size);
    errdefer allocator.free(buffer);

    const nread: usize = try reader.readAll(buffer);
    if (nread != size) return error.ReadError;

    return buffer;
}
