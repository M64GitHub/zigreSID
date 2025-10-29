const std = @import("std");
const ReSid = @import("resid");

const Player = ReSid.SdlDumpPlayer;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("[EXE] sdl dump player demo!\n", .{});
    try stdout.flush();

    // create SDL sid dump player and configure it
    var player = try Player.init(gpa, "player#1");
    defer player.deinit();

    // load sid dump
    try player.loadDmp("data/plasmaghost.sid.dmp");

    player.play();

    try stdout.print("[EXE] press enter to exit\n", .{});
    try stdout.flush();
    var read_buf: [1]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&read_buf);
    const reader: *std.io.Reader = &stdin_reader.interface;
    var slices = [_][]u8{&read_buf};
    _ = reader.readVec(&slices) catch 0;

    player.stop();
}
