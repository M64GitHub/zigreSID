const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});

const ReSID = @import("resid_cpp").Sid;
const DP = @import("resid_cpp").DumpPlayer;

pub const SdlDumpPlayer = struct {
    resid: ReSID,
    player: DP,
    dev: SDL.SDL_AudioDeviceID = 0,
    allocator: std.mem.Allocator,

    const samplingRate: i32 = 44100;
    const stdout = std.io.getStdOut().writer();

    pub fn init(allocator: std.mem.Allocator, name: [*:0]const u8) !*SdlDumpPlayer {
        var self = try std.heap.c_allocator.create(SdlDumpPlayer);

        self.resid = try ReSID.init(name);
        self.player = try DP.init(allocator, self.resid);
        self.dev = 0;
        self.allocator = allocator;

        try self.initsdl();

        return self;
    }

    pub fn deinit(self: *SdlDumpPlayer) void {
        if (self.dev != 0) {
            SDL.SDL_CloseAudioDevice(self.dev);
            SDL.SDL_Quit();
        }
        self.player.deinit();
        self.resid.deinit();
        std.heap.c_allocator.destroy(self);
    }

    pub fn initsdl(self: *SdlDumpPlayer) !void {
        var spec = SDL.SDL_AudioSpec{
            .freq = samplingRate,
            .format = SDL.AUDIO_S16,
            .channels = 1,
            .samples = 4096,
            .callback = &DP.sdlAudioCallback,
            .userdata = @ptrCast(&self.player),
        };

        if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
            try stdout.print("[SdlDumpPlayer] Failed to initialize SDL audio: {s}\n", .{SDL.SDL_GetError()});
            return error.FailedToInitSDL;
        }

        self.dev = SDL.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
        if (self.dev == 0) {
            try stdout.print("[SdlDumpPlayer] Failed to open SDL audio device: {s}\n", .{SDL.SDL_GetError()});
            return error.FailedToOpenSDLDevice;
        }

        SDL.SDL_PauseAudioDevice(self.dev, 0);
    }

    pub fn setDmp(self: *SdlDumpPlayer, dump: []u8) void {
        self.dump = dump;
        self.player.setDmp(self.player.ptr, self.dump);
    }

    pub fn loadDmp(self: *SdlDumpPlayer, filename: []const u8) !void {
        try self.player.loadDmp(filename);
    }

    pub fn play(self: *SdlDumpPlayer) void {
        self.player.play();
    }

    pub fn stop(self: *SdlDumpPlayer) void {
        self.player.stop();
    }
};
