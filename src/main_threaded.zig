const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
    @cInclude("resid_wrapper.h");
    @cInclude("demo_sound.h");
});

const ReSID = @import("resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid.zig").ReSIDDmpPlayer;

fn playerThreadFunc(player: *ReSIDDmpPlayer) void {
    while (player.isPlaying()) {
        player.update();
        std.time.sleep(5 * std.time.ns_per_ms);
        player.getPBData().buf_
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const samplingRate: i32 = 44100;

    try stdout.print("[MAIN] zigSID audio demo threaded!\n", .{});

    // -- create sid and configure it
    var sid = try ReSID.init("MyZIGSID");
    defer sid.deinit();
    _ = sid.setChipModel("MOS8580"); // just demo usage, this is the default

    // -- create player and initialize it with a demo sound
    var player = try ReSIDDmpPlayer.init(sid.ptr);
    defer player.deinit();
    player.setDmp(c.demo_sid, c.demo_sid_len); // set buffer of demo sound
    player.updateExternal(true); // make sure, SDL does not call the update-
    // function

    // -- THAT's IT! All we have to do now is to call player.play()
    // For this SDL implementation we need SDL to callback our
    // player.sdlAudioCallback(), it is specified below.
    // The userdata is required to point to the player object
    // The audio callback is not calling player.update(), so we will start
    // our update thread directly after player.play
    // (to make sure, player.isPlaying will return true)

    // -- init sdl with a callback to our player

    // SDL2 Audio Initialization
    var spec = c.SDL_AudioSpec{
        .freq = samplingRate,
        .format = c.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = ReSIDDmpPlayer.getAudioCallback(),
        .userdata = @ptrCast(&player), // reference to player
    };

    if (c.SDL_Init(c.SDL_INIT_AUDIO) < 0) {
        try stdout.print("[MAIN] Failed to initialize SDL audio: {s}\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_Quit();

    const dev = c.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("[MAIN] Failed to open SDL audio device: {s}\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_CloseAudioDevice(dev);

    c.SDL_PauseAudioDevice(dev, 0); // Start playback
    try stdout.print("[MAIN] SDL audio started at {d} Hz.\n", .{samplingRate});

    // -- end of SDL initialization

    // all we have to do now is to call .play()

    player.play(); // now player.isPlaying() will return true
    const playerThread = try std.Thread.spawn(.{}, playerThreadFunc, .{&player});
    defer playerThread.join(); // Wait for the thread to finish (if needed)

    // print the SID registers
    for (1..10) |_| {
        const regs = sid.getRegs(); // [25]u8 array

        try stdout.print("SID Registers: ", .{});
        for (regs) |value| {
            try stdout.print("{x:0>2} ", .{value});
        }
        try stdout.print("\n", .{});
        std.time.sleep(0.5 * std.time.ns_per_s);
    }

    try stdout.print("[MAIN] Press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();

    c.SDL_PauseAudioDevice(dev, 1); // Stop playback
    try stdout.print("[MAIN] SDL audio stopped.\n", .{});
}
