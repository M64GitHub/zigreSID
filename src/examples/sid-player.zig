const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});
const ReSid = @import("resid");

const Sid = ReSid.Sid;
const SidFile = ReSid.SidFile;
const SidPlayer = ReSid.SidPlayer;

// Context for audio generation
const AudioContext = struct {
    sid: Sid,
    sid_player: *SidPlayer,
    mutex: std.Thread.Mutex,

    // Single buffer for audio
    buffer: [4096]i16,
    buf_ptr_next: [*]i16,
    buf_ready: bool,

    frame_counter: u64,
    playing: bool,
};

fn playerThreadFunc(ctx: *AudioContext) !void {
    const stdout = std.io.getStdOut().writer();
    const cycles_per_sample = 985248 / 44100; // PAL clock / sample rate
    const samples_per_frame = 880; // 44100 / 50.125 = 879.8 ≈ 880
    var buffer_pos: usize = 0;

    while (ctx.playing) {
        // Call sidPlay to update SID registers (happens at 50.125Hz)
        ctx.sid_player.sidPlay() catch |err| {
            try stdout.print("[PLAYER] sidPlay error: {}\n", .{err});
            ctx.playing = false;
            return;
        };

        // Get updated registers from C64 SID
        const registers = ctx.sid_player.c64.sid.getRegisters();

        // Write them to our audio Sid and generate one frame of audio
        ctx.sid.writeRegs(@constCast(&registers));

        // Generate samples directly into buffer
        ctx.mutex.lock();
        _ = ctx.sid.clock(cycles_per_sample * samples_per_frame, ctx.buf_ptr_next[buffer_pos..buffer_pos + samples_per_frame]);
        buffer_pos += samples_per_frame;

        // If buffer is full, mark as ready and wait for SDL to consume
        if (buffer_pos >= 4096) {
            ctx.buf_ready = true;
            buffer_pos = 0;

            // Wait until SDL consumes the buffer
            ctx.mutex.unlock();
            while (ctx.buf_ready and ctx.playing) {
                std.time.sleep(1 * std.time.ns_per_ms);
            }
            ctx.mutex.lock();
        }

        ctx.frame_counter += 1;
        ctx.mutex.unlock();

        // Sleep for one PAL frame (50.125 Hz = 19.950125 ms)
        std.time.sleep(19950124);
    }
}

fn audioCallback(userdata: ?*anyopaque, stream: [*c]u8, len: c_int) callconv(.C) void {
    const ctx: *AudioContext = @ptrCast(@alignCast(userdata));

    ctx.mutex.lock();
    defer ctx.mutex.unlock();

    const buffer: [*]i16 = @ptrCast(@alignCast(stream));
    const samples: usize = @intCast(@divExact(len, 2)); // 16-bit samples

    if (ctx.buf_ready) {
        // Copy from the filled buffer
        @memcpy(buffer[0..samples], ctx.buf_ptr_next[0..samples]);
        ctx.buf_ready = false;
    } else {
        // Buffer not ready - output silence
        @memset(buffer[0..samples], 0);
    }
}

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    // Parse command-line arguments
    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    if (args.len < 2) {
        try stdout.print("Usage: {s} <sidfile.sid>\n", .{args[0]});
        return error.InvalidArguments;
    }

    const sid_filename = args[1];

    // Load SID file
    try stdout.print("[SID PLAYER] Loading: {s}\n", .{sid_filename});
    var sid_file = SidFile.init();
    defer sid_file.deinit(gpa);

    try sid_file.load(gpa, sid_filename);
    try sid_file.printHeader();

    // Create SidPlayer with C64 emulation
    var sid_player = try SidPlayer.init(gpa, sid_file);

    // Initialize the song (use start_song from header, 0-indexed)
    const song_number = sid_file.header.start_song - 1;
    try stdout.print("[SID PLAYER] Initializing song #{d}\n", .{song_number});
    try sid_player.sidInit(song_number);

    // Create audio Sid for rendering
    var audio_sid = try Sid.init("audio_sid");
    defer audio_sid.deinit();
    _ = audio_sid.setChipModel("MOS8580");
    audio_sid.setSamplingRate(44100);

    // Create audio context with single buffer
    var audio_ctx = AudioContext{
        .sid = audio_sid,
        .sid_player = sid_player,
        .mutex = std.Thread.Mutex{},
        .buffer = [_]i16{0} ** 4096,
        .buf_ptr_next = undefined,
        .buf_ready = false,
        .frame_counter = 0,
        .playing = true,
    };

    // Initialize buffer pointer
    audio_ctx.buf_ptr_next = &audio_ctx.buffer;

    // Initialize SDL audio
    if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
        try stdout.print("[ERROR] Failed to initialize SDL: {s}\n", .{SDL.SDL_GetError()});
        return error.SDLInitFailed;
    }
    defer SDL.SDL_Quit();

    var spec = SDL.SDL_AudioSpec{
        .freq = 44100,
        .format = SDL.AUDIO_S16SYS,
        .channels = 1,
        .samples = 4096,
        .callback = audioCallback,
        .userdata = @ptrCast(&audio_ctx),
    };

    const dev = SDL.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print("[ERROR] Failed to open SDL audio device: {s}\n", .{SDL.SDL_GetError()});
        return error.SDLAudioFailed;
    }
    defer SDL.SDL_CloseAudioDevice(dev);

    // Start audio
    SDL.SDL_PauseAudioDevice(dev, 0);
    try stdout.print("[SID PLAYER] Audio started at 44100 Hz\n", .{});

    // Spawn playback thread
    const player_thread = try std.Thread.spawn(.{}, playerThreadFunc, .{&audio_ctx});
    defer player_thread.join();

    // Main loop - wait for user input
    try stdout.print("[SID PLAYER] Playing... Press Enter to stop.\n", .{});
    _ = std.io.getStdIn().reader().readByte() catch null;

    // Stop playback
    audio_ctx.playing = false;
    SDL.SDL_PauseAudioDevice(dev, 1);
    try stdout.print("[SID PLAYER] Stopped. Frames played: {d}\n", .{audio_ctx.frame_counter});
}
