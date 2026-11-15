const std = @import("std");

buf: []const u8,
i: usize,

const Parser = @This();

pub fn init(buffer: []const u8) Parser {
    return Parser{
        .buf = buffer,
        .i = 0,
    };
}

pub const ParseError = std.fmt.ParseIntError;

pub fn parseInt(self: *Parser) ParseError!i64 {
    if (self.readChar() != 'i') return error.InvalidCharacter;

    const j: usize = self.i;

    while (self.i < self.buf.len and self.peekChar() != 'e')
        self.i += 1;

    const n: i64 = try std.fmt.parseInt(i64, self.buf[j..self.i], 10);

    if (self.readChar() != 'e') return error.InvalidCharacter;

    return n;
}

pub fn parseStr(self: *Parser) ParseError![]const u8 {
    const j: usize = self.i;

    while (self.i < self.buf.len and self.peekChar() != ':')
        self.i += 1;

    const n: usize = try std.fmt.parseInt(usize, self.buf[j..self.i], 10);

    if (self.readChar() != ':') return error.InvalidCharacter;

    const k: usize = self.i;

    self.i += n;

    return self.buf[k..self.i];
}

pub fn parseListAsStr(self: *Parser) ParseError![]const u8 {
    const j: usize = self.i;

    if (self.readChar() != 'l') return error.InvalidCharacter;

    var next_char: u8 = self.peekChar();
    while (self.i < self.buf.len and next_char != 'e') : (next_char = self.peekChar())
        switch (next_char) {
            'i' => _ = try self.parseInt(),

            '1'...'9' => _ = try self.parseStr(),

            'l' => _ = try self.parseListAsStr(),

            'd' => _ = try self.parseDictAsStr(),

            else => return error.InvalidCharacter,
        };

    if (self.readChar() != 'e') return error.InvalidCharacter;

    return self.buf[j..self.i];
}

pub fn parseDictAsStr(self: *Parser) ParseError![]const u8 {
    const j: usize = self.i;

    if (self.readChar() != 'd') return error.InvalidCharacter;

    var next_char: u8 = self.peekChar();
    while (self.i < self.buf.len and next_char != 'e') : (next_char = self.peekChar())
        switch (next_char) {
            'i' => _ = try self.parseInt(),

            '1'...'9' => _ = try self.parseStr(),

            'l' => _ = try self.parseListAsStr(),

            'd' => _ = try self.parseDictAsStr(),

            else => return error.InvalidCharacter,
        };

    if (self.readChar() != 'e') return error.InvalidCharacter;

    return self.buf[j..self.i];
}

const Dto = @import("types.zig").Dto;

pub fn parseDict(
    self: *Parser,
    comptime Schema: type,
    dto: *Dto(Schema),
) ParseError!void {
    if (self.readChar() != 'd') return error.InvalidCharacter;

    while (self.i < self.buf.len and self.peekChar() != 'e') {
        const key = try self.parseStr();

        const ti_schema = @typeInfo(Schema).@"struct";
        inline for (ti_schema.field_names, ti_schema.field_types) |field_name, field_type|
            if (std.mem.eql(u8, field_name, key)) {
                @field(dto, field_name) = switch (comptime field_type.t_bencode) {
                    .int => try self.parseInt(),
                    .string => try self.parseStr(),
                    .list => try self.parseListAsStr(),
                    .dict => try self.parseDictAsStr(),
                };

                break;
            };
    }

    if (self.readChar() != 'e') return error.InvalidCharacter;
}

pub fn printList(buffer: []const u8) ParseError!void {
    var parser: Parser = init(buffer);

    if (parser.readChar() != 'l') return error.InvalidCharacter;

    while (parser.i < parser.buf.len and parser.peekChar() != 'e')
        std.debug.print("\n  '{s}'", .{try parser.parseStr()});

    if (parser.readChar() != 'e') return error.InvalidCharacter;
}

fn peekChar(self: Parser) u8 {
    return self.buf[self.i];
}

fn readChar(self: *Parser) u8 {
    const c: u8 = self.buf[self.i];
    self.i += 1;
    return c;
}

fn eatWhitespace(self: Parser) void {
    while (self.i < self.buf.len and std.ascii.isWhitespace(self.peekChar()))
        self.i += 1;
}
