const std = @import("std");
const sounddata = @import("demo-sound-data.zig");

const ReSID = @import("resid/resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid/resid.zig").ReSIDDmpPlayer;
const Wav = @import("resid/wav.zig").Wav;

const allocator = std.heap.page_allocator;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const sampling_rate = 44100;

    var pcm_buffer: [sampling_rate * 10]i16 = undefined; // 10s mono PCM buffer

    try stdout.print("[MAIN] zigSID audio rendering wav writer demo!\n", .{});

    // create sid and configure it
    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();

    // create a ReSIDDmpPlayer instance and initialize it with the ReSID instance
    var player = try ReSIDDmpPlayer.init(sid.ptr);
    defer player.deinit();

    // set the dump to be rendered
    player.setDmp(sounddata.demo_sid, sounddata.demo_sid_len);

    // render 8 seconds audio into PCM audio buffer
    const steps_rendered = player.renderAudio(0, 50 * 10, @as(u32, pcm_buffer.len), &pcm_buffer);
    try stdout.print("[MAIN] Steps rendered {d}\n", .{steps_rendered});

    // create a stereo wav file and write it to disk
    var mywav = Wav.init(allocator, "sid-out.wav");
    mywav.setMonoBuffer(&pcm_buffer);
    try mywav.writeStereo();
}
