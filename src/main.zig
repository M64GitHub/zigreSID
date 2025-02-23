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

    // -- create sid and configure it

    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();
    _ = sid.setChipModel("MOS8580");

    // -- create player and initialize it with a demo sound

    var player = try ReSIDDmpPlayer.init(sid.ptr);
    defer player.deinit();
    player.setDmp(c.demo_sid, c.demo_sid_len); // set buffer of demo sound

    // -- THAT's IT! All we have to do now is to call player.play()
    // for this SDL implementation we need SDL to callback our
    // player.sdlAudioCallback()

    // -- init sdl with a callback to our player

    // SDL2 Audio Initialization
    var spec = c.SDL_AudioSpec{
        .freq = samplingRate,
        .format = c.AUDIO_S16,
        .channels = 1,
        .samples = 2048,
        .callback = ReSIDDmpPlayer.getAudioCallback(),
        .userdata = @ptrCast(&player), // reference to player
    };

    if (c.SDL_Init(c.SDL_INIT_AUDIO) < 0) {
        try stdout.print("Failed to initialize SDL audio: {s}\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_Quit();

    const dev = c.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("Failed to open SDL audio device: {s}\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_CloseAudioDevice(dev);

    c.SDL_PauseAudioDevice(dev, 0); // Start playback
    try stdout.print("Playback started at {d} Hz.\n", .{samplingRate});

    // -- end of SDL initialization

    // all we have to do now is to call .play()

    player.play();

    for (1..10) |i| {
        stdout.print("Still alive! Step {d}\n", .{i}) catch {};
        std.time.sleep(0.5 * std.time.ns_per_s);
    }

    try stdout.print("Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();

    c.SDL_PauseAudioDevice(dev, 1); // Stop playback
    try stdout.print("Playback stopped.\n", .{});
}
