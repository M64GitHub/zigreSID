const std = @import("std");
const DumpPlayer = @import("resid_cpp").DumpPlayer;
const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});

const MAX_WAV_SOURCES = 100;

const WavSource = struct {
    pcm_data: []const i16,
    position: usize,
    total_samples: usize,
    num_channels: u16,
    active: bool,

    pub fn init(pcm_data: []const i16, num_channels: u16) WavSource {
        return WavSource{
            .pcm_data = pcm_data,
            .position = 0,
            .total_samples = pcm_data.len,
            .num_channels = num_channels,
            .active = true,
        };
    }

    pub fn isFinished(self: *const WavSource) bool {
        return self.position >= self.total_samples;
    }

    pub fn advance(self: *WavSource, samples: usize) void {
        self.position += samples;
    }
};

pub const MixingDumpPlayer = struct {
    dump_player: DumpPlayer,
    wav_sources: [MAX_WAV_SOURCES]?WavSource,
    mutex: std.Thread.Mutex,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, dump_player: DumpPlayer) !MixingDumpPlayer {
        return MixingDumpPlayer{
            .dump_player = dump_player,
            .wav_sources = [_]?WavSource{null} ** MAX_WAV_SOURCES,
            .mutex = std.Thread.Mutex{},
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *MixingDumpPlayer) void {
        self.dump_player.deinit();
    }

    pub fn addWavSource(self: *MixingDumpPlayer, pcm_data: []const i16, num_channels: u16) !void {
        self.mutex.lock();
        defer self.mutex.unlock();

        // Find empty slot
        for (&self.wav_sources) |*slot| {
            if (slot.* == null) {
                slot.* = WavSource.init(pcm_data, num_channels);
                return;
            }
        }

        return error.TooManyWavSources;
    }

    pub fn update(self: *MixingDumpPlayer) bool {
        // First, update the underlying DumpPlayer to fill buffer with SID audio
        const result = self.dump_player.update();

        // Get the buffer that was just filled
        const ctx = self.dump_player.getPlayerContext();
        const buffer = ctx.buf_ptr_next;
        const buffer_size: usize = 4096; // Fixed buffer size from audio-config.h

        // Lock for accessing wav_sources
        self.mutex.lock();
        defer self.mutex.unlock();

        // Mix in active WAV sources
        for (&self.wav_sources) |*slot| {
            if (slot.*) |*wav_src| {
                if (!wav_src.active or wav_src.isFinished()) {
                    slot.* = null; // Remove finished WAV
                    continue;
                }

                // Calculate how many samples we can mix from this WAV
                const remaining = wav_src.total_samples - wav_src.position;
                const samples_to_mix = @min(remaining, buffer_size);

                // Get source slice
                const src_slice = wav_src.pcm_data[wav_src.position .. wav_src.position + samples_to_mix];

                // Handle mono/stereo conversion if needed
                if (wav_src.num_channels == 1) {
                    // WAV is mono, buffer is mono - direct mix
                    SDL.SDL_MixAudioFormat(
                        @ptrCast(buffer),
                        @ptrCast(src_slice.ptr),
                        SDL.AUDIO_S16SYS,
                        @intCast(samples_to_mix * @sizeOf(i16)),
                        SDL.SDL_MIX_MAXVOLUME,
                    );
                } else if (wav_src.num_channels == 2) {
                    // WAV is stereo, but SID buffer is mono
                    // Mix both channels (simple downmix)
                    for (0..samples_to_mix / 2) |i| {
                        const left = src_slice[i * 2];
                        const right = src_slice[i * 2 + 1];
                        const mixed_sample: i32 = @divTrunc(@as(i32, left) + @as(i32, right), 2);
                        const clamped: i16 = @intCast(std.math.clamp(
                            mixed_sample + @as(i32, buffer[i]),
                            std.math.minInt(i16),
                            std.math.maxInt(i16),
                        ));
                        buffer[i] = clamped;
                    }
                }

                // Advance position
                wav_src.advance(samples_to_mix);

                // If finished, mark for removal
                if (wav_src.isFinished()) {
                    wav_src.active = false;
                }
            }
        }

        return result;
    }

    // Proxy methods to underlying DumpPlayer
    pub fn play(self: *MixingDumpPlayer) void {
        self.dump_player.play();
    }

    pub fn stop(self: *MixingDumpPlayer) void {
        self.dump_player.stop();
    }

    pub fn pause(self: *MixingDumpPlayer) void {
        self.dump_player.pause();
    }

    pub fn continuePlayback(self: *MixingDumpPlayer) void {
        self.dump_player.continuePlayback();
    }

    pub fn isPlaying(self: *MixingDumpPlayer) bool {
        return self.dump_player.isPlaying();
    }

    pub fn updateExternal(self: *MixingDumpPlayer, external: bool) void {
        self.dump_player.updateExternal(external);
    }

    pub fn loadDmp(self: *MixingDumpPlayer, filename: []const u8) !void {
        try self.dump_player.loadDmp(filename);
    }

    pub fn getPlayerContext(self: *MixingDumpPlayer) *@import("resid_cpp").Cpp.DmpPlayerContext {
        return self.dump_player.getPlayerContext();
    }
};
