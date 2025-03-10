const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL.h");
});
const CPU = @import("6510/6510.zig").CPU;
const ReSID = @import("resid/resid.zig").ReSID;
const SIDFile = @import("resid/sidfile.zig").SIDFile;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    const max_frames = 100000;

    // -- read and parse the .sid file

    // const file_name = "data/Cybernoid_II.sid";
    const file_name = "data/Club64.sid";

    try stdout.print("[MAIN] Loading SID tune '{s}'\n", .{file_name});

    var sidfile = SIDFile.init(gpa);
    try sidfile.loadFile(file_name);
    try stdout.print("[MAIN] Loaded SID tune: {s}\n", .{sidfile.getName()});
    try stdout.print("[MAIN] Author         : {s}\n", .{sidfile.getAuthor()});
    try stdout.print("[MAIN] Release Info   : {s}\n", .{sidfile.getRelease()});
    try stdout.print("[MAIN] ID             : {s}\n", .{sidfile.getId()});
    try stdout.print("[MAIN] Version        : {X:0>4}\n", .{sidfile.header.version});
    try stdout.print("[MAIN] Data offset    : {X:0>4}\n", .{
        sidfile.header.data_offset,
    });
    try stdout.print("[MAIN] Load address   : {X:0>4}\n", .{
        sidfile.header.load_address,
    });
    try stdout.print("[MAIN] Init address   : {X:0>4}\n", .{
        sidfile.header.init_address,
    });
    try stdout.print("[MAIN] Play address   : {X:0>4}\n", .{
        sidfile.header.play_address,
    });
    try stdout.print("[MAIN] Number of songs: {X:0>4}\n", .{
        sidfile.header.num_songs,
    });
    try stdout.print("[MAIN] Start song#    : {X:0>4}\n", .{
        sidfile.header.start_song,
    });
    try stdout.print("[MAIN] Speed          : {X:0>8}\n", .{
        sidfile.header.speed,
    });
    try stdout.print("[MAIN] Filesize       : {X:0>8}\n", .{
        sidfile.filesize,
    });

    const sid_rawmem = sidfile.getSIDDataSlice();

    var mem_address: u16 = 0;
    var is_prg: bool = false;

    if (sidfile.header.load_address == 0) {
        mem_address = @as(u16, sid_rawmem[1]) * 256 +
            @as(u16, sid_rawmem[0]);
        try stdout.print("[MAIN] 0 Load Address!: {X:0>4}\n", .{
            mem_address,
        });
        is_prg = true;
    } else {
        mem_address = sidfile.header.load_address;
    }

    // -- initialize CPU

    try stdout.print("[MAIN] Initializing CPU\n", .{});
    var cpu = CPU.Init(gpa, 0x800); // address does not matter here
    cpu.mem.Data[0x01] = 0x37;

    // write the sid player routine and data into the emulator memory
    if (is_prg) {
        const loaded_addr = cpu.SetPrg(sid_rawmem, false);
        try stdout.print("[MAIN] Loaded address : {X:0>4}\n", .{loaded_addr});
    } else {
        cpu.WriteMem(sid_rawmem, mem_address);
    }

    // -- Call SID Init
    try stdout.print("[MAIN] Calling SID Init\n", .{});
    cpu.A = 0;
    cpu.X = 0;
    cpu.Y = 0;
    cpu.Call(sidfile.header.init_address);
    try stdout.print("CYCLES: {d}\n", .{cpu.cycles_executed});

    // -- Loop Call SID Play
    try stdout.print("[MAIN] Calling SID Play\n", .{});
    for (0..max_frames) |i| {
        cpu.cycles_executed = 0;
        cpu.Reset();
        cpu.Call(sidfile.header.play_address);
        if (cpu.ext_sid_reg_written) {
            try stdout.print("{d}: ", .{i});
            try stdout.print("CYCLES: {d}\n", .{cpu.cycles_executed});
            cpu.PrintSIDRegisters();
        }
    }
}
