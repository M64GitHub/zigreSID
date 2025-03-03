const std = @import("std");

const SDLreSIDDmpPlayer = @import("resid/residsdl.zig").SDLreSIDDmpPlayer;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    try stdout.print("[MAIN] zigSID audio demo sdl dump player!\n", .{});

    // create SDL sid dump player and configure it
    var player = try SDLreSIDDmpPlayer.init(allocator, "MY SID Player");
    defer player.deinit();

    // load sid dump
    try player.loadDmp("data/plasmaghost.sid.dmp");

    player.play();

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();
}
