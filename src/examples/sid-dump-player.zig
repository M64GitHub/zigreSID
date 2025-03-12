const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});

const ReSid = @import("resid").ReSid;
const ReSidDmpPlayer = @import("resid").ReSidDmpPlayer;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    try stdout.print("[MAIN] zigSid audio demo unthreaded!\n", .{});

    // create a ReSid instance and configure it
    var sid = try ReSid.init("MyZIGSid");
    defer sid.deinit();

    // create a ReSidDmpPlayer instance and initialize it with the ReSid instance
    var player = try ReSidDmpPlayer.init(gpa, sid.ptr);
    defer player.deinit();

    // load dump
    try player.loadDmp("data/plasmaghost.sid.dmp");

    // init sdl with a callback to our player
    var spec = SDL.SDL_AudioSpec{
        .freq = sid.getSamplingRate(),
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = &ReSidDmpPlayer.sdlAudioCallback,
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
    try stdout.print("[MAIN] SDL audio started at {d} Hz.\n", .{sid.getSamplingRate()});
    // end of SDL initialization

    player.play();

    // do something in main: print the Sid registers, and player stats
    for (1..10) |_| {
        const regs = sid.getRegs(); // [25]u8 array

        try stdout.print("[MAIN] Sid Registers: ", .{});
        for (regs) |value| {
            try stdout.print("{x:0>2} ", .{value});
        }
        try stdout.print("\n", .{});

        try stdout.print("[MAIN] {d} buffers played, {d} buffer underruns, {d} Sid frames\n", .{ player.getPlayerContext().stat_bufwrites, player.getPlayerContext().stat_buf_underruns, player.getPlayerContext().stat_framectr });

        std.time.sleep(0.5 * std.time.ns_per_s);
    }

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();

    SDL.SDL_PauseAudioDevice(dev, 1); // Stop SDL audio
    try stdout.print("[MAIN] SDL audio stopped.\n", .{});
}
