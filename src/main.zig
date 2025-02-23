const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
    @cInclude("resid_wrapper.h");
    @cInclude("demo_sound.h");
});

const ReSID = @import("resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid.zig").ReSIDDmpPlayer;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const samplingRate: i32 = 44100;

    // -- create sid and player

    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();

    sid.setSamplingRate(samplingRate);
    sid.setDBGOutput(true);
    _ = sid.setChipModel("MOS6581");

    try stdout.print("SID instance name: {s}\\n", .{sid.getName()});

    var player = try ReSIDDmpPlayer.init(sid.ptr);
    defer player.deinit();
    player.setDmp(c.demo_sid, c.demo_sid_len);

    // -- init sdl with a callback to our player

    // SDL2 Audio Initialization
    var spec = c.SDL_AudioSpec{
        .freq = samplingRate,
        .format = c.AUDIO_S16SYS,
        .channels = 2,
        .samples = 4096,
        .callback = ReSIDDmpPlayer.getAudioCallback(),
        .userdata = @ptrCast(&player),
    };

    if (c.SDL_Init(c.SDL_INIT_AUDIO) < 0) {
        try stdout.print("Failed to initialize SDL audio: {s}\\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_Quit();

    const dev = c.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("Failed to open SDL audio device: {s}\\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_CloseAudioDevice(dev);

    c.SDL_PauseAudioDevice(dev, 0); // Start playback
    try stdout.print("Playback started at {d} Hz.\\n", .{samplingRate});

    player.play();

    std.time.sleep(5 * std.time.ns_per_s); // Let the sound play for a bit

    c.SDL_PauseAudioDevice(dev, 1); // Stop playback
    try stdout.print("Playback stopped.\\n", .{});
}
