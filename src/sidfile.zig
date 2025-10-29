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
    data: []u8,
    header: SidHeader,
    file_size: u32,
    file_name: []u8,
    loaded: bool,

    pub fn init() SidFile {
        return SidFile{
            .data = &[_]u8{},
            .header = undefined,
            .file_size = 0,
            .file_name = "",
            .loaded = false,
        };
    }

    pub fn load(
        self: *SidFile,
        allocator: std.mem.Allocator,
        filename: []const u8,
    ) !void {
        const file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();

        const file_size = (try file.stat()).size;
        self.data = try allocator.alloc(u8, file_size);
        self.file_size = @as(u32, @truncate(file_size));
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
        self.loaded = true;
    }

    pub fn parseHeader(self: *SidFile) !void {
        if (self.data.len < 124) return error.InvalidSid;

        self.header = @bitCast(
            @as(*const SidHeader, @alignCast(@ptrCast(&self.data[0]))).*,
        );

        if (!std.mem.eql(u8, &@as([4]u8, self.header.id), "PSID") and
            !std.mem.eql(u8, &@as([4]u8, self.header.id), "RSID"))
        {
            return error.InvalidSid;
        }
    }

    pub fn getSidDataSlice(self: *const SidFile) []const u8 {
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

    pub fn deinit(self: *SidFile, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }

    pub fn printHeader(self: *SidFile) !void {
        var stdout_buffer: [1024]u8 = undefined;
        var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
        const stdout = &stdout_writer.interface;

        try stdout.print("[sidfile] Loaded Sid tune: {s}\n", .{self.getName()});
        try stdout.print("[sidfile] Author         : {s}\n", .{self.getAuthor()});
        try stdout.print("[sidfile] Release Info   : {s}\n", .{self.getRelease()});
        try stdout.print("[sidfile] ID             : {s}\n", .{self.getId()});
        try stdout.print("[sidfile] Version        : {X:0>4}\n", .{self.header.version});
        try stdout.print("[sidfile] Data offset    : {X:0>4}\n", .{self.header.data_offset});
        try stdout.print("[sidfile] Load address   : {X:0>4}\n", .{self.header.load_address});
        try stdout.print("[sidfile] Init address   : {X:0>4}\n", .{self.header.init_address});
        try stdout.print("[sidfile] Play address   : {X:0>4}\n", .{self.header.play_address});
        try stdout.print("[sidfile] Number of songs: {X:0>4}\n", .{self.header.num_songs});
        try stdout.print("[sidfile] Start song#    : {X:0>4}\n", .{self.header.start_song});
        try stdout.print("[sidfile] Speed          : {X:0>8}\n", .{self.header.speed});
        try stdout.print("[sidfile] Filesize       : {X:0>8}\n", .{self.file_size});
    }
};
