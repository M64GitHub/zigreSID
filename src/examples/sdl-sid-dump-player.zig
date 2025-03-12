const std = @import("std");

const SdlReSidDmpPlayer = @import("residsdl").SdlReSidDmpPlayer;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    try stdout.print("[MAIN] zigSid audio demo sdl dump player!\n", .{});

    // create SDL sid dump player and configure it
    var player = try SdlReSidDmpPlayer.init(gpa, "MY Sid Player");
    defer player.deinit();

    // load sid dump
    try player.loadDmp("data/plasmaghost.sid.dmp");

    player.play();

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();
}
