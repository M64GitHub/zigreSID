const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});
const ReSid = @import("resid");
const flagz = @import("flagz");

const Sid = ReSid.Sid;
const DumpPlayer = ReSid.DumpPlayer;

var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    const gpa = std.heap.page_allocator;

    const my_args = struct {
        filename: []u8,
    };

    const parsed = try flagz.parse(my_args, gpa);

    const sampling_rate = 44100;
    const pcm_buffer = try gpa.alloc(i16, sampling_rate * 10);
    defer gpa.free(pcm_buffer);

    try stdout.print("[EXE] audio rendering demo!\n", .{});
    try stdout.flush();

    // create a Sid instance and configure it
    var sid = try Sid.init("zigsid#1");
    sid.setSamplingRate(sampling_rate);
    defer sid.deinit();

    // create a DumpPlayer instance and initialize it with the Sid instance
    var player = try DumpPlayer.init(gpa, sid);
    defer player.deinit();

    // load dump
    try player.loadDmp(parsed.filename);

    // render 8 seconds audio into PCM audio buffer
    const steps_rendered = player.renderAudio(0, 50 * 8, pcm_buffer);

    // write generated audio to file
    const file = try std.fs.cwd().createFile(
        "pcm_dump.raw",
        .{ .truncate = true },
    );
    defer file.close();
    try file.writeAll(std.mem.sliceAsBytes(pcm_buffer));
    try stdout.print("[EXE] pcm dump written to 'pcm_dump.raw'\n", .{});

    try stdout.print("[EXE] steps rendered {d}\n", .{steps_rendered});
    try stdout.flush();

    // playback the rendered audio via SDL.SDL_QueueAudio
    // -- init sdl with a callback to our player
    var spec = SDL.SDL_AudioSpec{
        .freq = sid.getSamplingRate(),
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = null,
        .userdata = null, // reference to player
    };

    if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
        try stdout.print(
            "[EXE] failed to initialize SDL audio: {s}\n",
            .{SDL.SDL_GetError()},
        );
        try stdout.flush();
        return;
    }
    defer SDL.SDL_Quit();

    const dev = SDL.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
    if (dev == 0) {
        try stdout.print(
            "[EXE] failed to open SDL audio device: {s}\n",
            .{SDL.SDL_GetError()},
        );
        try stdout.flush();
        return;
    }
    defer SDL.SDL_CloseAudioDevice(dev);

    SDL.SDL_PauseAudioDevice(dev, 0); // Start SDL audio
    try stdout.print("[EXE] sdl audio started at 44100 Hz.\n", .{});
    try stdout.flush();
    // -- end of SDL initialization

    // enqueue rendered audio
    const buf_len: u32 = @truncate(pcm_buffer.len);
    const rv = SDL.SDL_QueueAudio(dev, pcm_buffer.ptr, buf_len);
    try stdout.print("[EXE] SDL_QueueAudio() result: {d}\n", .{rv});

    try stdout.print("[EXE] press enter to exit\n", .{});
    try stdout.flush();
    var read_buf: [1]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&read_buf);
    const reader: *std.io.Reader = &stdin_reader.interface;
    var slices = [_][]u8{&read_buf};
    _ = reader.readVec(&slices) catch 0;

    SDL.SDL_PauseAudioDevice(dev, 1); // Stop SDL audio
    try stdout.print("[EXE] sdl audio stopped.\n", .{});
    try stdout.flush();
}
