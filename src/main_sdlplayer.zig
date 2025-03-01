const std = @import("std");
const sounddata = @cImport({
    @cInclude("demo_sound.h");
});

const SDLreSIDDmpPlayer = @import("resid/residsdl.zig").SDLreSIDDmpPlayer;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("[MAIN] zigSID audio demo sdl dump player!\n", .{});

    // -- create sid dump player and configure it
    var player = try SDLreSIDDmpPlayer.init("MY SID Player");
    defer player.deinit();

    player.setDmp(sounddata.demo_sid, sounddata.demo_sid_len);

    player.play();

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();
}
