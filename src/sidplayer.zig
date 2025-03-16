const std = @import("std");
const SidFile = @import("sidfile").SidFile;
const C64 = @import("zig64");

pub const SidPlayer = struct {
    sid_file: SidFile,
    // we must allocate c64 later, when we know the VIC type from the sid_file
    c64: *C64,
    dbg_enabled: bool,

    pub fn init(allocator: std.mem.Allocator, sid_file: SidFile) !*SidPlayer {
        var sid_player =
            try allocator.create(SidPlayer);

        sid_player.* = SidPlayer{
            .sid_file = sid_file,
            .c64 = undefined,
            .dbg_enabled = false,
        };

        try sid_player.load(allocator);
        return sid_player;
    }

    pub fn loadFile(
        self: *SidPlayer,
        allocator: std.mem.Allocator,
        file_name: []const u8,
    ) !void {
        try self.sid_file.load(allocator, file_name);
        try self.load(self.sid_file);
    }

    pub fn load(
        self: *SidPlayer,
        allocator: std.mem.Allocator,
    ) !void {
        if (!self.sid_file.loaded) return error.SidFileNotLoaded;
        const stdout = std.io.getStdOut().writer();
        const sid_rawmem: []const u8 = self.sid_file.getSidDataSlice();

        var mem_address: u16 = 0;
        var is_prg: bool = false;

        if (self.sid_file.header.load_address == 0) {
            mem_address = @as(u16, sid_rawmem[1]) * 256 +
                @as(u16, sid_rawmem[0]);
            if (self.dbg_enabled) {
                try stdout
                    .print("[sidplayer] '.prg' format! load arress: {X:0>4}\n", .{
                    mem_address,
                });
            }
            is_prg = true;
        } else {
            mem_address = self.sid_file.header.load_address;
        }

        self.c64 = try C64.init(allocator, C64.Vic.Model.pal, 0x0000);
        var local_c64 = self.c64;

        // write the sid player routine and data into the c64lator memory
        if (is_prg) {
            const loaded_addr = try local_c64.setPrg(sid_rawmem, false);
            if (self.dbg_enabled) {
                try stdout.print(
                    "[sidplayer] sid file loaded to address : {X:0>4}\n",
                    .{loaded_addr},
                );
            }
        } else {
            self.c64.cpu.writeMem(sid_rawmem, mem_address);
            if (self.dbg_enabled) {
                try stdout.print(
                    "[sidplayer] sid file loaded to address : {X:0>4}\n",
                    .{mem_address},
                );
            }
        }
    }

    pub fn sidInit(self: *SidPlayer, tune: u16) !void {
        if (!self.sid_file.loaded) return error.SidFileNotLoaded;

        self.c64.cpu.a = @as(u8, @truncate(tune));
        self.c64.call(self.sid_file.header.init_address);
    }

    pub fn sidPlay(self: *SidPlayer) !void {
        if (!self.sid_file.loaded) return error.SidFileNotLoaded;

        self.c64.call(self.sid_file.header.play_address);
    }
};
