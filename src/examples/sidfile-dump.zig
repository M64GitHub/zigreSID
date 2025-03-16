const std = @import("std");
const ReSid = @import("resid").ReSid;
const SidFile = @import("sidfile").SidFile;
const SidPlayer = @import("sidplayer").SidPlayer;

pub const CsvFormat = enum { hex, decimal };

pub const ParsedArgs = struct {
    sid_filename: []const u8,
    output_filename: []const u8,
    max_frames: usize,
    dbg_enabled: bool,
    csv_enabled: bool,
    csv_format: CsvFormat, // 🔥 NEW: HEX OR DECIMAL!
    wav_output: ?[]const u8,
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const gpa = std.heap.page_allocator;

    // parse commandline
    const args = try parseCommandLine(gpa);

    std.debug.print("[EXE] loading Sid file '{s}'\n", .{args.sid_filename});
    // allocate output dump
    const dump_size = args.max_frames * 25; // 25 registers per frame
    var sid_dump = try gpa.alloc(u8, dump_size);

    // init sidfile
    var sid_file = SidFile.init();
    defer sid_file.deinit(gpa);

    // load .sid file
    std.debug.print("[EXE] SID filename raw bytes: ", .{});
    for (args.sid_filename) |byte| {
        std.debug.print("{X:02} ", .{byte});
    }
    std.debug.print("\n", .{});
    std.debug.print("[EXE] loading Sid file '{s}'\n", .{args.sid_filename});
    try stdout.print("[EXE] loading Sid file '{s}'\n", .{args.sid_filename});
    if (sid_file.load(gpa, args.sid_filename)) {
        std.debug.print("[EXE] Loaded SID file successfully!\n", .{});
    } else |err| {
        std.debug.print("[ERROR] Failed to load SID file: {}\n", .{err});
        return err;
    }

    // print file info
    try sid_file.printHeader();

    // init sidplayer
    var player = try SidPlayer.init(gpa, sid_file);

    // call sid init
    try player.sidInit(sid_file.header.start_song - 1);

    // loop call sid play, fill the dump
    try stdout.print("[EXE] looping sid play()\n", .{});
    for (0..args.max_frames) |frame| {
        try player.sidPlay();
        const sid_registers = player.c64.sid.getRegisters();
        @memcpy(sid_dump[frame * 25 .. frame * 25 + 25], sid_registers[0..]);
        if (args.dbg_enabled)
            hexDumpRegisters(frame, &sid_registers);
    }

    if (args.csv_enabled) {
        // convert to csv file, and save
        try writeCsvDump(
            args.output_filename,
            sid_dump,
            args.max_frames,
            args.csv_format,
        );
    } else {

        // write dump to output file
        var file = try std.fs.cwd().createFile(args.output_filename, .{});
        defer file.close();
        try file.writeAll(sid_dump);
        std.debug.print("[EXE] SID binary dump saved to {s}!\n", .{args.output_filename});
    }

    // convert to wave file, and save
    if (args.wav_output) |filename| {
        std.debug.print("[EXE] converting SID to WAV: {s}\n", .{filename});
        // TODO: Implement WAV conversion logic here
    }
}

fn parseCommandLine(allocator: std.mem.Allocator) !ParsedArgs {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 4) {
        std.debug.print("Usage: sid-dump <SID file> <output dump> <frames> [--debug] [--csv-dec] [--csv-hex] [--wav <wavfile>]\n", .{});
        return error.InvalidArguments;
    }

    var parsed = ParsedArgs{
        .sid_filename = try allocator.dupe(u8, args[1]),
        .output_filename = try allocator.dupe(u8, args[2]),
        .max_frames = try std.fmt.parseInt(usize, args[3], 10),
        .dbg_enabled = false,
        .csv_enabled = false,
        .wav_output = null,
        .csv_format = .decimal,
    };

    var i: usize = 4; // Start checking optional args
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--debug")) {
            parsed.dbg_enabled = true;
        } else if (std.mem.eql(u8, args[i], "--csv-hex")) {
            parsed.csv_enabled = true;
            parsed.csv_format = .hex;
        } else if (std.mem.eql(u8, args[i], "--csv-dec")) {
            parsed.csv_enabled = true;
            parsed.csv_format = .decimal;
        } else if (std.mem.eql(u8, args[i], "--wav")) {
            if (i + 1 >= args.len) {
                std.debug.print("Error: --wav requires an output filename.\n", .{});
                std.debug.print("Usage: sid-dump <SID file> <output dump> <frames> [--debug] [--csv-dec] [--csv-hex] [--wav <wavfile>]\n", .{});
                return error.InvalidArguments;
            }
            parsed.wav_output = args[i + 1]; // Store WAV filename
            i += 1; // Skip next argument
        } else {
            std.debug.print("Error: Unknown option {s}\n", .{args[i]});
            std.debug.print("Usage: sid-dump <SID file> <output dump> <frames> [--debug] [--csv-dec] [--csv-hex] [--wav <wavfile>]\n", .{});
            return error.InvalidArguments;
        }
    }

    return parsed;
}

fn hexDumpRegisters(frame: usize, registers: []const u8) void {
    var stdout = std.io.getStdOut().writer();

    stdout.print("[{X:06}] ", .{frame}) catch return;
    for (registers) |reg| {
        stdout.print("{X:02} ", .{reg}) catch return;
    }

    stdout.print("\n", .{}) catch return;
}

fn writeCsvDump(output_filename: []const u8, sid_dump: []const u8, max_frames: usize, format: CsvFormat) !void {
    var file = try std.fs.cwd().createFile(output_filename, .{});
    defer file.close();

    // Write CSV header
    try file.writeAll("Frame, R00, R01, R02, ..., R24\n");

    // Write each frame’s registers in CSV format
    for (0..max_frames) |frame| {
        try file.writer().print("{d}, ", .{frame});
        for (0..25) |r| {
            switch (format) {
                .hex => try file.writer().print("{X:02}", .{sid_dump[frame * 25 + r]}),
                .decimal => try file.writer().print("{d}", .{sid_dump[frame * 25 + r]}),
            }
            if (r < 24) try file.writer().writeAll(", ");
        }
        try file.writer().writeAll("\n");
    }

    std.debug.print("[EXE] CSV dump saved to {s}!\n", .{output_filename});
}
