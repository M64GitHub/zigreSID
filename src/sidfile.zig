const std = @import("std");

const SidHeader = packed struct {
    // id: [4]u8, // "PSid" or "RSid"
    id: @Vector(4, u8), // "PSid" or "RSid"
    version: u16, // Version number (usually 2 or 4)
    data_offset: u16, // Offset where Sid data begins
    load_address: u16, // Where to load the Sid data
    init_address: u16, // Init routine address
    play_address: u16, // Play routine address
    num_songs: u16, // Number of subsongs
    start_song: u16, // Default song index
    speed: u32, // Bit 0: 0 = 50Hz PAL, 1 = CIA Timer
    name: @Vector(32, u8), // ASCII song name
    author: @Vector(32, u8), // ASCII composer name
    released: @Vector(32, u8), // ASCII release info
    flags: u16, // PAL/NTSC compatibility flags
    start_page: u16, // Only for RSid (usually 0x00)
    page_length: u16, // Only for RSid (usually 0x00)
};

pub const SidFile = struct {
    allocator: std.mem.Allocator,
    data: []u8,
    header: SidHeader,
    filesize: u32,

    pub fn init(allocator: std.mem.Allocator) SidFile {
        return SidFile{
            .allocator = allocator,
            .data = &[_]u8{},
            .header = undefined,
            .filesize = 0,
        };
    }

    pub fn loadFile(self: *SidFile, filename: []const u8) !void {
        const file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();

        const file_size = (try file.stat()).size;
        self.data = try self.allocator.alloc(u8, file_size);
        self.filesize = @as(u32, @truncate(file_size));
        _ = try file.readAll(self.data);
        try self.parseHeader();
        // need to convert from little to big endian
        self.header.data_offset = toBigEndianU16(self.header.data_offset);
        self.header.load_address = toBigEndianU16(self.header.load_address);
        self.header.init_address = toBigEndianU16(self.header.init_address);
        self.header.play_address = toBigEndianU16(self.header.play_address);
        self.header.num_songs = toBigEndianU16(self.header.num_songs);
        self.header.start_song = toBigEndianU16(self.header.start_song);
        self.header.version = toBigEndianU16(self.header.version);
        self.header.speed = toBigEndianU32(self.header.speed);
    }

    pub fn parseHeader(self: *SidFile) !void {
        if (self.data.len < 124) return error.InvalidSid;

        self.header = @bitCast(@as(*const SidHeader, @alignCast(@ptrCast(&self.data[0]))).*);

        if (!std.mem.eql(u8, &@as([4]u8, self.header.id), "PSID") and
            !std.mem.eql(u8, &@as([4]u8, self.header.id), "RSID"))
        {
            return error.InvalidSid;
        }
    }

    pub fn getSidDataSlice(self: *SidFile) []const u8 {
        return self.data[self.header.data_offset..];
    }

    pub fn getId(self: *SidFile) []const u8 {
        return @as([*]const u8, @ptrCast(&self.header.id))[0..4]; // Convert to slice
    }

    pub fn getName(self: *SidFile) []const u8 {
        return @as([*]const u8, @ptrCast(&self.header.name))[0..32]; // Convert to slice
    }

    pub fn getAuthor(self: *SidFile) []const u8 {
        return @as([*]const u8, @ptrCast(&self.header.author))[0..32]; // Convert to slice
    }

    pub fn getRelease(self: *SidFile) []const u8 {
        return @as([*]const u8, @ptrCast(&self.header.released))[0..32]; // Convert to slice
    }

    fn toBigEndianU16(value: u16) u16 {
        return @byteSwap(value);
    }

    fn toBigEndianU32(value: u32) u32 {
        return @byteSwap(value);
    }

    pub fn deinit(self: *SidFile) void {
        self.allocator.free(self.data);
    }
};
