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

    try stdout.print("[MAIN] Initializing CPU\n", .{});
    // var cpu = CPU.Init(gpa, 0x800);

    const file_name = "data/plasmaghost.sid";
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
}
