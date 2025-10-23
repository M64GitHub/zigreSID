const std = @import("std");

pub const WavData = struct {
    pcm_data: []i16,
    sample_rate: u32,
    num_channels: u16,
    num_samples: usize,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *WavData) void {
        self.allocator.free(self.pcm_data);
    }
};

pub const WavLoader = struct {
    pub fn load(allocator: std.mem.Allocator, filename: []const u8) !WavData {
        const file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();

        const file_size = (try file.stat()).size;
        const file_data = try allocator.alloc(u8, file_size);
        defer allocator.free(file_data);

        _ = try file.readAll(file_data);

        return try parseWav(allocator, file_data);
    }

    fn parseWav(allocator: std.mem.Allocator, data: []const u8) !WavData {
        if (data.len < 44) return error.InvalidWavFile;

        // Check RIFF header
        if (!std.mem.eql(u8, data[0..4], "RIFF")) return error.InvalidWavFile;
        if (!std.mem.eql(u8, data[8..12], "WAVE")) return error.InvalidWavFile;

        // Find fmt chunk
        var pos: usize = 12;
        var fmt_found = false;
        var sample_rate: u32 = 0;
        var num_channels: u16 = 0;
        var bits_per_sample: u16 = 0;

        while (pos + 8 <= data.len) {
            const chunk_id = data[pos .. pos + 4];
            const chunk_size = std.mem.readInt(u32, data[pos + 4 .. pos + 8][0..4], .little);

            if (std.mem.eql(u8, chunk_id, "fmt ")) {
                if (pos + 8 + chunk_size > data.len) return error.InvalidWavFile;

                const audio_format = std.mem.readInt(u16, data[pos + 8 .. pos + 10][0..2], .little);
                if (audio_format != 1) return error.UnsupportedWavFormat; // Only PCM supported

                num_channels = std.mem.readInt(u16, data[pos + 10 .. pos + 12][0..2], .little);
                sample_rate = std.mem.readInt(u32, data[pos + 12 .. pos + 16][0..4], .little);
                bits_per_sample = std.mem.readInt(u16, data[pos + 22 .. pos + 24][0..2], .little);

                if (bits_per_sample != 16) return error.UnsupportedBitDepth;

                fmt_found = true;
                pos += 8 + chunk_size;
            } else if (std.mem.eql(u8, chunk_id, "data")) {
                if (!fmt_found) return error.InvalidWavFile;

                const data_size = chunk_size;
                const data_start = pos + 8;

                if (data_start + data_size > data.len) return error.InvalidWavFile;

                // Calculate number of samples
                const bytes_per_sample: usize = 2; // 16-bit
                const num_samples = data_size / (bytes_per_sample * num_channels);

                // Allocate PCM buffer
                const pcm_data = try allocator.alloc(i16, num_samples * num_channels);

                // Copy PCM data
                for (0..num_samples * num_channels) |i| {
                    const byte_offset = data_start + i * 2;
                    pcm_data[i] = std.mem.readInt(i16, data[byte_offset .. byte_offset + 2][0..2], .little);
                }

                return WavData{
                    .pcm_data = pcm_data,
                    .sample_rate = sample_rate,
                    .num_channels = num_channels,
                    .num_samples = num_samples,
                    .allocator = allocator,
                };
            } else {
                // Skip unknown chunk
                pos += 8 + chunk_size;
            }
        }

        return error.InvalidWavFile;
    }
};
