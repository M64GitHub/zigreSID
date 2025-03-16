const std = @import("std");
const ReSid = @import("resid");

const Sid = ReSid.Sid;
const DumpPlayer = ReSid.DumpPlayer;
const WavWriter = ReSid.WavWriter;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();
    const sampling_rate = 44100;

    const pcm_buffer = try gpa.alloc(i16, sampling_rate * 10); // audio buffer
    defer gpa.free(pcm_buffer);

    try stdout.print("[MAIN] zigSid audio rendering wav writer demo!\n", .{});

    // create a Sid instance and configure it
    var sid = try Sid.init("sid#1");
    defer sid.deinit();

    // create a DumpPlayer instance and initialize it with the Sid instance
    var player = try DumpPlayer.init(gpa, sid.ptr);
    defer player.deinit();

    try player.loadDmp("data/plasmaghost.sid.dmp");

    // render 50 * 10 frames into PCM audio buffer
    // sid updates (audio frames) are executed at virtually 50.125 Hz
    // this will create 10 seconds audio
    const steps_rendered = player.renderAudio(0, 50 * 10, pcm_buffer);
    try stdout.print("[MAIN] Steps rendered {d}\n", .{steps_rendered});

    // create a stereo wav file and write it to disk
    var mywav = WavWriter.init(gpa, "sid-out.wav");
    mywav.setMonoBuffer(pcm_buffer);
    try mywav.writeStereo();
}
