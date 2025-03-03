const std = @import("std");

const ReSID = @import("resid/resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid/resid.zig").ReSIDDmpPlayer;
const Wav = @import("resid/wav.zig").Wav;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();
    const sampling_rate = 44100;

    var pcm_buffer: [sampling_rate * 10]i16 = undefined; // 10s mono PCM buffer

    try stdout.print("[MAIN] zigSID audio rendering wav writer demo!\n", .{});

    // create a ReSID instance and configure it
    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();

    // create a ReSIDDmpPlayer instance and initialize it with the ReSID instance
    var player = try ReSIDDmpPlayer.init(allocator, sid.ptr);
    defer player.deinit();

    // load dump
    try player.loadDmp("data/plasmaghost.sid.dmp");

    // render 50 * 10 frames into PCM audio buffer
    // sid updates (audio frames) are made at 50.125 Hz, this will create 10 seconds audio
    const steps_rendered = player.renderAudio(0, 50 * 10, pcm_buffer.len, &pcm_buffer);
    try stdout.print("[MAIN] Steps rendered {d}\n", .{steps_rendered});

    // create a stereo wav file and write it to disk
    var mywav = Wav.init(allocator, "sid-out.wav");
    mywav.setMonoBuffer(&pcm_buffer);
    try mywav.writeStereo();
}
