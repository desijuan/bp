# bp — Bencode Parser

Zero-allocation, dependency-free Bencode parser written in Zig.

bp follows a zero-copy design: all parsed values reference the input buffer directly.
No heap allocations are performed, memory is fully managed by the caller.

---

## Installation

Add bp as a dependency in your `build.zig.zon`:

```bash
zig fetch --save "git+https://github.com/desijuan/bp"
```

Then import it in your `build.zig`:

```zig
const bp = b.dependency("bp", .{});
exe_mod.addImport("bp", bp.module("bp"));
```

---

## Overview

bp parses Bencode data into user-defined Zig structs.

Instead of dynamically allocating structures, bp requires a **schema** (defined as a Zig struct)
describing the expected shape of the data. It then fills a corresponding runtime struct with values
that reference the original buffer.

All 4 Bencode types are supported:
- integer     --> bp.Int
- byte string --> bp.String
- list        --> bp.List
- dictionary  --> bp.Dict

---

## Example 1

When trying to download a torrent, one has to ask the tracker for a list of peers. This is done via
a GET request. The tracker responds in bencode format with the following schema:
```zig
pub const TrackerResponseInfo = struct {
    interval: bp.Int,
    peers: bp.String,
};
```

To parse the response we would do:
```zig
const res_body = try http.requestPeers();
defer gpa.free(res_body);

var parser: bp.Parser = undefined;
parser = bp.Parser.init(res_body);

var trackerResponse: bp.Dto(TrackerResponseInfo) = undefined;
try parser.parseDict(TrackerResponseInfo, &trackerResponse);
```

## Example 2

We will parse the torrent file:
`test/debian-12.9.0-amd64-netinst.iso.torrent`

### 1. Define the schema

Bencode dictionaries are mapped to Zig structs. The structure of the bencode message should be known
upfront. In our example we would define our schema the following way:

```zig
const TorrentFileInfo = struct {
    @"creation date": bp.Int,
    announce: bp.String,
    comment: bp.String,
    @"created by": bp.String,
    info: bp.Dict,
    @"url-list": bp.List,
};
```

Notes:
- Field order does not matter (bencode dictionaries are unordered).
- Keys must match exactly (including spaces, dashes, etc.).
- The types of the fields must be one of:
  - bp.Int
  - bp.String
  - bp.List
  - bp.Dict

---

### 2. Create the DTO

The `bp.Dto` function generates the Data Transfer Object that will be used to parse the data:

```zig
var torrent_file: bp.Dto(TorrentFileInfo) = undefined;
```

This expands to something equivalent to:

```zig
const TorrentFile = struct {
    @"creation date": u32,
    announce: []const u8,
    comment: []const u8,
    @"created by": []const u8,
    info: []const u8,
    @"url-list": []const u8,
};
```

Type mapping:
- `bp.Int`              --> `i32`
- `bp.String`           --> `[]const u8`
- `bp.Dict` / `bp.List` --> raw slices of encoded data

---

### 3. Parse

```zig
const parser = Parser.init(buffer);
try parser.parseDict(TorrentFileInfo, &torrent_file);
```

After parsing:
- integers are decoded
- strings are slices into the original buffer
- lists and dictionaries are returned as raw encoded slices

---

### Memory model

bp does **not** copy data.

All slices in the resulting struct **alias the input buffer**.

This implies:

- The input buffer must remain alive while the parsed data is in use.
- The user is responsible of copying the data if ownership is needed.


---

### Nested parsing

Since dictionaries and lists are returned as raw slices, they can be parsed further.

Example: parsing the `info` field:

```zig
const TorrentInfo = struct {
    length: bp.Int,
    @"piece length": bp.Int,
    name: bp.String,
    pieces: bp.String,
};

var torrent: bp.Dto(TorrentInfo) = undefined;

const parser = Parser.init(torrent_file.info);
try parser.parseDict(TorrentInfo, &torrent);
```

---

## Running the example

See `test/test.zig` for a complete working example.

Run:

```bash
zig build test --summary all
```

or equivalently:

```bash
make test
```

---

## Design

bp is designed for:
- zero allocations
- predictable performance
- explicit memory ownership

Trade-offs:
- requires a predefined schema
- does not build dynamic tree structures
- caller is responsible for buffer lifetime

---

## Contributing

Issues and pull requests are welcome.
If you find a bug or unclear behavior, please report it.
