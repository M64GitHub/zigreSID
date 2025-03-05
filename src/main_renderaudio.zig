const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL.h");
});

const ReSID = @import("resid/resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid/resid.zig").ReSIDDmpPlayer;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    const sampling_rate = 44100;
    const pcm_buffer = try gpa.alloc(i16, sampling_rate * 10);
    defer gpa.free(pcm_buffer);

    try stdout.print("[MAIN] zigSID audio rendering demo!\n", .{});

    // create a ReSID instance and configure it
    var sid = try ReSID.init("MyZIGSID");
    sid.setSamplingRate(sampling_rate);
    defer sid.deinit();

    // create a ReSIDDmpPlayer instance and initialize it with the ReSID instance
    var player = try ReSIDDmpPlayer.init(gpa, sid.ptr);
    defer player.deinit();

    // load dump
    try player.loadDmp("data/plasmaghost.sid.dmp");

    // render 8 seconds audio into PCM audio buffer
    const steps_rendered = player.renderAudio(0, 50 * 8, pcm_buffer);

    // write generated audio to file
    const file = try std.fs.cwd().createFile("pcm_dump.raw", .{ .truncate = true });
    defer file.close();
    try file.writeAll(std.mem.sliceAsBytes(pcm_buffer));
    std.debug.print("[MAIN] PCM dump written to 'pcm_dump.raw'\n", .{});

    try stdout.print("[MAIN] Steps rendered {d}\n", .{steps_rendered});

    // -- playback the rendered audio via SDL.SDL_QueueAudio

    // init sdl with a callback to our player
    var spec = SDL.SDL_AudioSpec{
        .freq = sid.getSamplingRate(),
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = null,
        .userdata = null, // reference to player
    };

    if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
        try stdout.print("[MAIN] Failed to initialize SDL audio: {s}\n", .{SDL.SDL_GetError()});
        return;
    }
    defer SDL.SDL_Quit();

    const dev = SDL.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("[MAIN] Failed to open SDL audio device: {s}\n", .{SDL.SDL_GetError()});
        return;
    }
    defer SDL.SDL_CloseAudioDevice(dev);

    SDL.SDL_PauseAudioDevice(dev, 0); // Start SDL audio
    try stdout.print("[MAIN] SDL audio started at 44100 Hz.\n", .{});
    // end of SDL initialization

    // enqueue rendered audio
    const buf_len: u32 = @truncate(pcm_buffer.len);
    const rv = SDL.SDL_QueueAudio(dev, pcm_buffer.ptr, buf_len);
    try stdout.print("[MAIN] SDL_QueueAudio() result: {d}\n", .{rv});

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    SDL.SDL_PauseAudioDevice(dev, 1); // Stop SDL audio
    try stdout.print("[MAIN] SDL audio stopped.\n", .{});
}
