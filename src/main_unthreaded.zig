const std = @import("std");
const sounddata = @cImport({
    @cInclude("demo_sound.h");
});
const SDL = @cImport({
    @cInclude("SDL.h");
});

const ReSID = @import("resid/resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid/resid.zig").ReSIDDmpPlayer;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const samplingRate: i32 = 44100;

    try stdout.print("[MAIN] zigSID audio demo unthreaded!\n", .{});

    // -- create sid and configure it
    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();
    _ = sid.setChipModel("MOS8580"); // just demo usage, this is the default

    // -- create player and initialize it with a demo sound
    var player = try ReSIDDmpPlayer.init(sid.ptr);
    defer player.deinit();
    player.setDmp(sounddata.demo_sid, sounddata.demo_sid_len); // set buffer of demo sound

    // -- THAT's IT! All we have to do now is to call player.play()
    // For this SDL implementation we need SDL to callback our
    // player.sdlAudioCallback(), it is specified below.
    // The userdata is required to point to the player object

    // -- init sdl with a callback to our player

    // SDL2 Audio Initialization
    var spec = SDL.SDL_AudioSpec{
        .freq = samplingRate,
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = ReSIDDmpPlayer.getAudioCallback(),
        .userdata = @ptrCast(&player), // reference to player
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
    try stdout.print("[MAIN] SDL audio started at {d} Hz.\n", .{samplingRate});

    // -- end of SDL initialization

    // all we have to do now is to call .play()

    player.play();

    // print the SID registers, and player stats
    for (1..10) |_| {
        const regs = sid.getRegs(); // [25]u8 array

        try stdout.print("[MAIN] SID Registers: ", .{});
        for (regs) |value| {
            try stdout.print("{x:0>2} ", .{value});
        }
        try stdout.print("\n", .{});

        try stdout.print("[MAIN] {d} buffers played, {d} buffer underruns, {d} SID frames\n", .{ player.getPlayerContext().stat_bufwrites, player.getPlayerContext().stat_buf_underruns, player.getPlayerContext().stat_framectr });

        std.time.sleep(0.5 * std.time.ns_per_s);
    }

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();

    SDL.SDL_PauseAudioDevice(dev, 1); // Stop SDL audio
    try stdout.print("[MAIN] SDL audio stopped.\n", .{});
}
