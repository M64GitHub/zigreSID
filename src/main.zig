const std = @import("std");
const ReSID = @import("resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid.zig").ReSIDDmpPlayer;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var resid = try ReSID.init("MyZIGSID");
    defer resid.deinit();

    resid.setDBGOutput(true);
    _ = resid.setChipModel("MOS6581");

    try stdout.print("SID instance name: {s}\\n", .{resid.getName()});

    var player = try ReSIDDmpPlayer.init(resid.ptr);
    defer player.deinit();

    player.play();
    while (true) {
        player.update();
        // Add playback logic or break conditions if needed
    }
}
