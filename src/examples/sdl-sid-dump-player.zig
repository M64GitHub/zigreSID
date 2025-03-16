const std = @import("std");
const ReSid = @import("resid");

const Player = ReSid.SdlDumpPlayer;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    try stdout.print("[EXE] sdl dump player demo!\n", .{});

    // create SDL sid dump player and configure it
    var player = try Player.init(gpa, "player#1");
    defer player.deinit();

    // load sid dump
    try player.loadDmp("data/plasmaghost.sid.dmp");

    player.play();

    try stdout.print("[EXE] press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();
}
