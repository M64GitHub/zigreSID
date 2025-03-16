const std = @import("std");
const ReSid = @import("resid").ReSid;
const SidFile = @import("sidfile").SidFile;
const SidPlayer = @import("sidplayer").SidPlayer;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const gpa = std.heap.page_allocator;

    // parse commandline
    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    if (args.len < 4) {
        std.debug.print("Usage: sid-dump <SID file> <output dump> <frames> [--debug]\n", .{});
        return;
    }

    const sid_filename = args[1];
    const output_filename = args[2];
    const max_frames = try std.fmt.parseInt(usize, args[3], 10);
    const dbg_enabled = args.len >= 5 and std.mem.eql(
        u8,
        args[4],
        "--debug",
    );

    // allocate output dump
    const dump_size = max_frames * 25; // 25 registers per frame
    var sid_dump = try gpa.alloc(u8, dump_size);

    // init sidfile
    var sid_file = SidFile.init();
    defer sid_file.deinit(gpa);

    // load .sid file
    try stdout.print("[EXE] loading Sid tune '{s}'\n", .{sid_filename});
    try sid_file.load(gpa, sid_filename);

    // print file info
    try sid_file.printHeader();

    // init sidplayer
    var player = try SidPlayer.init(gpa, sid_file);

    // -- call sid init
    try player.sidInit(sid_file.header.start_song - 1);

    // -- loop call sid play
    try stdout.print("[EXE] looping sid play()\n", .{});
    for (0..max_frames) |frame| {
        try player.sidPlay();
        const sid_registers = player.c64.sid.getRegisters();
        @memcpy(sid_dump[frame * 25 .. frame * 25 + 25], sid_registers[0..]);
        if (dbg_enabled)
            hexDumpRegisters(frame, &sid_registers);
    }

    // -- write dump to output file
    var file = try std.fs.cwd().createFile(output_filename, .{});
    defer file.close();
    try file.writeAll(sid_dump);
    std.debug.print("[EXE] SID binary dump saved to {s}!\n", .{output_filename});
}

fn hexDumpRegisters(frame: usize, registers: []const u8) void {
    var stdout = std.io.getStdOut().writer();

    stdout.print("[{X:06}] ", .{frame}) catch return;
    for (registers) |reg| {
        stdout.print("{X:02} ", .{reg}) catch return;
    }

    stdout.print("\n", .{}) catch return;
}
