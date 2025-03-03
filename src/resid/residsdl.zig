const std = @import("std");
const SDL = @cImport({
    @cInclude("SDL.h");
});

const ReSID = @import("resid.zig").ReSID;
const ReSIDDmpPlayer = @import("resid.zig").ReSIDDmpPlayer;

pub const SDLreSIDDmpPlayer = struct {
    resid: ReSID,
    player: ReSIDDmpPlayer,
    dev: SDL.SDL_AudioDeviceID = 0,
    allocator: std.mem.Allocator,

    const samplingRate: i32 = 44100;
    const stdout = std.io.getStdOut().writer();

    pub fn init(allocator: std.mem.Allocator, name: [*:0]const u8) !*SDLreSIDDmpPlayer {
        var self = try std.heap.c_allocator.create(SDLreSIDDmpPlayer);

        self.resid = try ReSID.init(name);
        self.player = try ReSIDDmpPlayer.init(allocator, self.resid.ptr);
        self.dev = 0;
        self.allocator = allocator;

        try self.initsdl();

        return self;
    }

    pub fn deinit(self: *SDLreSIDDmpPlayer) void {
        if (self.dev != 0) {
            SDL.SDL_CloseAudioDevice(self.dev);
            SDL.SDL_Quit();
        }
        self.player.deinit();
        self.resid.deinit();
        std.heap.c_allocator.destroy(self);
    }

    pub fn initsdl(self: *SDLreSIDDmpPlayer) !void {
        var spec = SDL.SDL_AudioSpec{
            .freq = samplingRate,
            .format = SDL.AUDIO_S16,
            .channels = 1,
            .samples = 4096,
            .callback = &ReSIDDmpPlayer.sdlAudioCallback,
            .userdata = @ptrCast(&self.player),
        };

        if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
            try stdout.print("[SDLreSIDDmpPlayer] Failed to initialize SDL audio: {s}\n", .{SDL.SDL_GetError()});
            return error.FailedToInitSDL;
        }

        self.dev = SDL.SDL_OpenAudioDevice(null, 0, &spec, null, 0);
        if (self.dev == 0) {
            try stdout.print("[SDLreSIDDmpPlayer] Failed to open SDL audio device: {s}\n", .{SDL.SDL_GetError()});
            return error.FailedToOpenSDLDevice;
        }

        SDL.SDL_PauseAudioDevice(self.dev, 0);
    }

    pub fn setDmp(self: *SDLreSIDDmpPlayer, dump: []u8) void {
        self.dump = dump;
        self.player.setDmp(self.player.ptr, self.dump);
    }

    pub fn loadDmp(self: *SDLreSIDDmpPlayer, filename: []const u8) !void {
        try self.player.loadDmp(filename);
    }

    pub fn play(self: *SDLreSIDDmpPlayer) void {
        self.player.play();
    }

    pub fn stop(self: *SDLreSIDDmpPlayer) void {
        self.player.stop();
    }
};
