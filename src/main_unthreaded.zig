const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL.h");
});
const sounddata = @import("demo-sound-data.zig");

const ReSID = @import("resid/resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid/resid.zig").ReSIDDmpPlayer;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const samplingRate: i32 = 44100;

    try stdout.print("[MAIN] zigSID audio demo unthreaded!\n", .{});

    // create a ReSID instance and configure it
    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();

    // create a ReSIDDmpPlayer instance and initialize it with the ReSID instance
    var player = try ReSIDDmpPlayer.init(sid.ptr);
    defer player.deinit();
    player.setDmp(sounddata.demo_sid, sounddata.demo_sid_len); // set dump to be played

    // init sdl with a callback to our player
    var spec = SDL.SDL_AudioSpec{
        .freq = samplingRate,
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = &ReSIDDmpPlayer.sdlAudioCallback,
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
    // end of SDL initialization

    // start the playback!
    player.play();

    // do something in main: print the SID registers, and player stats
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
