const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});
const ReSid = @import("resid");
const movy = @import("movy");

const Sid = ReSid.Sid;
const DumpPlayer = ReSid.DumpPlayer;
const MixingDumpPlayer = ReSid.MixingDumpPlayer;
const WavLoader = ReSid.WavLoader;
const WavData = ReSid.WavData;

fn playerThreadFunc(player: *MixingDumpPlayer) !void {
    while (player.isPlaying()) {
        if (!player.update()) {
            player.stop();
            const stdout = std.io.getStdOut().writer();
            try stdout.print("[PLAYER] Player stopped!\n", .{});
        }
        std.time.sleep(35 * std.time.ns_per_ms);
    }
}

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    try movy.terminal.beginRawMode();
    defer movy.terminal.endRawMode();

    try stdout.print("[EXE] Threaded Mixing Dump Player Example\n", .{});
    try stdout.print("[EXE] Press '1' to trigger WAV 1, '2' to trigger WAV 2, ESC to exit\n\n", .{});

    // Create a Sid instance and configure it
    var sid = try Sid.init("zigsid#1");
    defer sid.deinit();

    // Create a DumpPlayer instance
    const dump_player = try DumpPlayer.init(gpa, sid);

    // Wrap it in a MixingDumpPlayer
    var player = try MixingDumpPlayer.init(gpa, dump_player);
    defer player.deinit();

    // Load SID dump (use dummy filename for now)
    try player.loadDmp("data/plasmaghost.sid.dmp");

    // Load WAV files (use dummy filenames for now)
    var wav1 = try WavLoader.load(gpa, "data/explosion1.wav");
    defer wav1.deinit();

    var wav2 = try WavLoader.load(gpa, "data/explosion2.wav");
    defer wav2.deinit();

    try stdout.print("[EXE] Loaded WAV 1: {d} samples, {d} Hz, {d} channels\n", .{
        wav1.num_samples,
        wav1.sample_rate,
        wav1.num_channels,
    });
    try stdout.print("[EXE] Loaded WAV 2: {d} samples, {d} Hz, {d} channels\n", .{
        wav2.num_samples,
        wav2.sample_rate,
        wav2.num_channels,
    });

    // Initialize SDL (audio only, no events)
    if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
        try stdout.print("[EXE] Failed to initialize SDL: {s}\n", .{SDL.SDL_GetError()});
        return;
    }
    defer SDL.SDL_Quit();

    // Set up SDL audio
    var spec = SDL.SDL_AudioSpec{
        .freq = sid.getSamplingRate(),
        .format = SDL.AUDIO_S16SYS,
        .channels = 1,
        .samples = 4096,
        .callback = &DumpPlayer.sdlAudioCallback,
        .userdata = @ptrCast(&player.dump_player),
    };

    const dev = SDL.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("[EXE] Failed to open SDL audio device: {s}\n", .{SDL.SDL_GetError()});
        return;
    }
    defer SDL.SDL_CloseAudioDevice(dev);

    // Enable external updates (we control buffer filling)
    player.updateExternal(true);

    // Start SDL audio
    SDL.SDL_PauseAudioDevice(dev, 0);
    try stdout.print("[EXE] SDL audio started at {d} Hz.\n", .{sid.getSamplingRate()});

    // Start playback
    player.play();

    // Spawn update thread
    const playerThread = try std.Thread.spawn(.{}, playerThreadFunc, .{&player});
    defer playerThread.join();

    // Main loop
    var counter: u64 = 0;
    var running = true;

    while (running) {
        // Simulate main game loop - counting numbers
        counter += 1;
        if (counter % 100 == 0) {
            try stdout.print("[MAIN] Counter: {d}\n", .{counter});
        }

        // Input handling - using movy keyboard
        if (try movy.input.get()) |in| {
            switch (in) {
                .key => |key| {
                    switch (key.type) {
                        .Escape => {
                            running = false;
                            try stdout.print("[MAIN] ESC pressed, exiting...\n", .{});
                        },
                        .Char => {
                            if (key.sequence.len == 1) {
                                if (key.sequence[0] == '1') {
                                    try stdout.print("[MAIN] Triggering WAV 1!\n", .{});
                                    try player.addWavSource(wav1.pcm_data, wav1.num_channels);
                                } else if (key.sequence[0] == '2') {
                                    try stdout.print("[MAIN] Triggering WAV 2!\n", .{});
                                    try player.addWavSource(wav2.pcm_data, wav2.num_channels);
                                }
                            }
                        },
                        else => {},
                    }
                },
                else => {},
            }
        }

        // Sleep to simulate frame timing
        std.time.sleep(10 * std.time.ns_per_ms);
    }

    // Stop playback
    player.stop();
    SDL.SDL_PauseAudioDevice(dev, 1);
    try stdout.print("[EXE] SDL audio stopped.\n", .{});
}
