const std = @import("std");
const ReSid = @import("resid");

const SidFile = ReSid.SidFile;
const SidPlayer = ReSid.SidPlayer;

pub const CsvFormat = enum { hex, decimal };

pub const ParsedArgs = struct {
    sid_filename: []const u8,
    output_filename: []const u8,
    max_frames: usize,
    dbg_enabled: bool,
    csv_enabled: bool,
    csv_format: CsvFormat,
    wav_output: ?[]const u8,
};

var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

fn printUsage() void {
    stdout.print(
        \\sid-dump - Convert SID music files to register dump format
        \\
        \\Usage: sid-dump <SID file> <output dump> <frames> [options]
        \\
        \\Required arguments:
        \\  <SID file>      Path to input .sid file
        \\  <output dump>   Path for output dump file (.dmp or .csv)
        \\  <frames>        Number of frames to capture (50 frames ≈ 1 second at PAL rate)
        \\
        \\Options:
        \\  --debug         Print register values for each frame during capture
        \\  --csv-dec       Output as CSV with decimal values
        \\  --csv-hex       Output as CSV with hexadecimal values
        \\  --wav <file>    Also generate a WAV audio file
        \\  --help, -h      Show this help message
        \\
        \\Examples:
        \\  sid-dump song.sid song.dmp 3000
        \\  sid-dump song.sid song.csv 1500 --csv-hex
        \\  sid-dump song.sid song.dmp 6000 --wav song.wav --debug
        \\
    , .{}) catch {};
    stdout.flush() catch {};
}

pub fn main() !void {
    const gpa = std.heap.page_allocator;

    // parse commandline
    const args = try parseCommandLine(gpa);

    // allocate output dump
    const dump_size = args.max_frames * 25; // 25 registers per frame
    var sid_dump = try gpa.alloc(u8, dump_size);

    // init sidfile
    var sid_file = SidFile.init();
    defer sid_file.deinit(gpa);

    try stdout.print("[EXE] loading Sid file '{s}'\n", .{args.sid_filename});
    if (sid_file.load(gpa, args.sid_filename)) {
        try stdout.print("[EXE] Loaded SID file successfully!\n", .{});
    } else |err| {
        try stdout.print("[ERROR] Failed to load SID file: {}\n", .{err});
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
        try stdout.print(
            "[EXE] SID binary dump saved to {s}!\n",
            .{args.output_filename},
        );
    }

    // convert to wave file, and save
    if (args.wav_output) |filename| {
        try stdout.print("[EXE] converting SID to WAV: {s}\n", .{filename});
        try stdout.flush();
        // TODO: Implement WAV conversion logic here
    }
    try stdout.flush();
}

fn parseCommandLine(allocator: std.mem.Allocator) !ParsedArgs {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Check for --help or -h flag first
    for (args) |arg| {
        if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
            printUsage();
            std.process.exit(0);
        }
    }

    if (args.len < 4) {
        printUsage();
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
                try stdout.print("Error: --wav requires an output filename.\n\n", .{});
                printUsage();
                return error.InvalidArguments;
            }
            parsed.wav_output = args[i + 1]; // Store WAV filename
            i += 1; // Skip next argument
        } else {
            try stdout.print("Error: Unknown option '{s}'\n\n", .{args[i]});
            printUsage();
            return error.InvalidArguments;
        }
    }

    return parsed;
}

fn hexDumpRegisters(frame: usize, registers: []const u8) void {
    stdout.print("[{X:06}] ", .{frame}) catch return;
    for (registers) |reg| {
        stdout.print("{X:02} ", .{reg}) catch return;
    }

    stdout.print("\n", .{}) catch return;
}

fn writeCsvDump(output_filename: []const u8, sid_dump: []const u8, max_frames: usize, format: CsvFormat) !void {
    var file = try std.fs.cwd().createFile(output_filename, .{});
    defer file.close();

    // Create writer with buffer
    var write_buf: [4096]u8 = undefined;
    var file_writer = file.writer(&write_buf);
    const writer: *std.io.Writer = &file_writer.interface;

    // Write CSV header
    try writer.writeAll("Frame, R00, R01, R02, ..., R24\n");

    // Write each frame's registers in CSV format
    for (0..max_frames) |frame| {
        try writer.print("{d}, ", .{frame});
        for (0..25) |r| {
            switch (format) {
                .hex => try writer.print("{X:02}", .{sid_dump[frame * 25 + r]}),
                .decimal => try writer.print("{d}", .{sid_dump[frame * 25 + r]}),
            }
            if (r < 24) try writer.writeAll(", ");
        }
        try writer.writeAll("\n");
    }
    try writer.flush();

    try stdout.print("[EXE] CSV dump saved to {s}!\n", .{output_filename});
}
