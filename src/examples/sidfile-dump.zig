const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});
const Emulator = @import("mos6510").Emulator;
const ReSid = @import("resid").ReSid;
const SidFile = @import("sidfile").SidFile;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    const max_frames = 100000;

    // -- read and parse the .sid file

    // const file_name = "data/Cybernoid_II.sid";
    const file_name = "data/Club64.sid";

    try stdout.print("[MAIN] Loading Sid tune '{s}'\n", .{file_name});

    var sidfile = SidFile.init(gpa);
    try sidfile.loadFile(file_name);
    try stdout.print("[MAIN] Loaded Sid tune: {s}\n", .{sidfile.getName()});
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

    const sid_rawmem = sidfile.getSidDataSlice();

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

    // -- initialize Cpu

    try stdout.print("[MAIN] Initializing EMU\n", .{});
    var emu = Emulator.init(gpa, Emulator.VicType.pal, 0x0800);
    emu.mem.data[0x01] = 0x37;

    // emu.dbg_enabled = true;

    // write the sid player routine and data into the emulator memory
    if (is_prg) {
        const loaded_addr = emu.setPrg(sid_rawmem, false);
        try stdout.print("[MAIN] Loaded address : {X:0>4}\n", .{loaded_addr});
    } else {
        // emu.WriteMem(sid_rawmem, mem_address);
    }

    // -- Call Sid Init
    try stdout.print("[MAIN] Calling Sid Init\n", .{});
    emu.cpu.a = 0;
    emu.cpu.x = 0;
    emu.cpu.y = 0;
    emu.call(sidfile.header.init_address);
    try stdout.print("CYCLES: {d}\n", .{emu.cpu.cycles_executed});

    // emu.cpu.dbg_enabled = true;
    // -- Loop Call Sid Play
    try stdout.print("[MAIN] Calling Sid Play\n", .{});
    for (0..max_frames) |i| {
        emu.cpu.cycles_executed = 0;
        emu.cpu.a = 0;
        emu.cpu.x = 0;
        emu.cpu.y = 0;
        emu.call(sidfile.header.play_address);
        if (emu.cpu.ext_sid_reg_written) {
            try stdout.print("[FRM ] {d} ", .{i});
            try stdout.print("[CYCL] {d} ", .{emu.cpu.cycles_executed});
            emu.sid.printRegisters();
        }
    }
}
