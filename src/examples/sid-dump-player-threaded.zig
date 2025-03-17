const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});
const ReSid = @import("resid");

const Sid = ReSid.Sid;
const DumpPlayer = ReSid.DumpPlayer;
const Playstate = DumpPlayer.Playstate;

fn playerThreadFunc(player: *DumpPlayer) !void {
    while (player.isPlaying()) {
        if (!player.update()) {
            player.stop();
        }
        std.time.sleep(35 * std.time.ns_per_ms);
    }
}

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    try stdout.print("[EXE] dump player demo threaded!\n", .{});

    // create a ReSid instance and configure it
    var sid = try Sid.init("zigsid#1");
    defer sid.deinit();

    // create a DumpPlayer instance and initialize it with the ReSid instance
    var player = try DumpPlayer.init(gpa, sid.ptr);
    defer player.deinit();

    // load dump
    try player.loadDmp("data/plasmaghost.sid.dmp");

    player.updateExternal(true); // make sure, SDL does not call the update function

    // -- init sdl with a callback to our player
    var spec = SDL.SDL_AudioSpec{
        .freq = sid.getSamplingRate(),
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = &DumpPlayer.sdlAudioCallback,
        .userdata = @ptrCast(&player),
    };

    if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
        try stdout.print("[EXE] failed to initialize SDL audio: {s}\n", .{SDL.SDL_GetError()});
        return;
    }
    defer SDL.SDL_Quit();

    const dev = SDL.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("[EXE] failed to open SDL audio device: {s}\n", .{SDL.SDL_GetError()});
        return;
    }
    defer SDL.SDL_CloseAudioDevice(dev);

    SDL.SDL_PauseAudioDevice(dev, 0); // Start SDL audio
    try stdout.print("[EXE] sdl audio started at {d} Hz.\n", .{sid.getSamplingRate()});
    // -- end of SDL initialization

    // start the playback, and thread for calling the update function
    player.play();
    const playerThread = try std.Thread.spawn(.{}, playerThreadFunc, .{&player});
    defer playerThread.join(); // Wait for the thread to finish (if needed)

    // do something in main: print the Sid registers, and player stats
    for (1..10) |_| {
        const regs = sid.getRegs(); // [25]u8 array

        try stdout.print("[EXE] sid registers: ", .{});
        for (regs) |value| {
            try stdout.print("{x:0>2} ", .{value});
        }
        try stdout.print("\n", .{});

        try stdout.print("[EXE] {d} buffers played, {d} buffer underruns, {d} Sid frames\n", .{
            player.getPlayerContext().stat_bufwrites,
            player.getPlayerContext().stat_buf_underruns,
            player.getPlayerContext().stat_framectr,
        });

        std.time.sleep(0.5 * std.time.ns_per_s);
    }

    try stdout.print("[EXE] press enter to exit\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    player.stop();

    if (player.getPlayState() == Playstate.stopped) {
        try stdout.print("[EXE] player stopped!\n", .{});
    }

    SDL.SDL_PauseAudioDevice(dev, 1); // Stop SDL audio
    try stdout.print("[EXE] sdl audio stopped.\n", .{});
}
