const std = @import("std");

pub const WavHeader = extern struct {
    chunk_id: [4]u8 = .{ 'R', 'I', 'F', 'F' },
    chunk_size: u32, // 4 + (8 + subchunk1_size) + (8 + subchunk2_size)
    format: [4]u8 = .{ 'W', 'A', 'V', 'E' },
    subchunk1_id: [4]u8 = .{ 'f', 'm', 't', ' ' },
    subchunk1_size: u32 = 16, // PCM header size
    audio_format: u16 = 1, // PCM = 1
    num_channels: u16,
    sample_rate: u32,
    byte_rate: u32,
    block_align: u16,
    bits_per_sample: u16,
    subchunk2_id: [4]u8 = .{ 'd', 'a', 't', 'a' },
    subchunk2_size: u32, // Number of bytes in the audio data
};

pub const WavWriter = struct {
    allocator: std.mem.Allocator,
    filename: []const u8,
    buffer: []i16 = &.{}, // Empty by default
    sample_rate: u32 = 44100,
    num_channels: u16 = 1,

    pub fn init(allocator: std.mem.Allocator, filename: []const u8) WavWriter {
        return WavWriter{
            .allocator = allocator,
            .filename = filename,
        };
    }

    pub fn setMonoBuffer(self: *WavWriter, buffer: []i16) void {
        self.buffer = buffer;
    }

    pub fn write(self: *WavWriter) !void {
        const wav_data = try self.createWavBuffer();
        defer self.allocator.free(wav_data);
        try self.writeToFile(wav_data);
    }

    pub fn writeStereo(self: *WavWriter) !void {
        const stereo_buffer = try self.convertMonoToStereo();
        defer self.allocator.free(stereo_buffer);
        const wav_data = try self.createWavBufferWithBuffer(stereo_buffer, 2);
        defer self.allocator.free(wav_data);
        try self.writeToFile(wav_data);
    }

    pub fn writeMono(self: *WavWriter) !void {
        const wav_data = try self.createWavBufferWithBuffer(
            self.buffer,
            1,
        );
        defer self.allocator.free(wav_data);
        try self.writeToFile(wav_data);
    }

    fn createWavBuffer(self: *WavWriter) ![]u8 {
        return self.createWavBufferWithBuffer(self.buffer, self.num_channels);
    }

    fn createWavBufferWithBuffer(
        self: *WavWriter,
        pcm_buffer: []i16,
        num_channels: u16,
    ) ![]u8 {
        const bits_per_sample: u16 = 16;
        const block_align: u16 = num_channels * (bits_per_sample / 8);
        const byte_rate: u32 = self.sample_rate * @as(u32, block_align);
        const buf_len: u32 = @truncate(pcm_buffer.len);
        const pcm_size: u32 = buf_len * @sizeOf(i16);
        var header = WavHeader{
            .chunk_size = 36 + pcm_size,
            .num_channels = num_channels,
            .sample_rate = self.sample_rate,
            .byte_rate = byte_rate,
            .block_align = block_align,
            .bits_per_sample = bits_per_sample,
            .subchunk2_size = pcm_size,
        };

        // Allocate memory for the WAV buffer
        const wav_size = @sizeOf(WavHeader) + pcm_size;
        var wav_buffer = try self.allocator.alloc(u8, wav_size);

        // Copy header and PCM data into the buffer
        @memcpy(wav_buffer[0..@sizeOf(WavHeader)], std.mem.asBytes(&header));
        @memcpy(
            wav_buffer[@sizeOf(WavHeader)..],
            std.mem.sliceAsBytes(pcm_buffer),
        );

        return wav_buffer;
    }

    fn convertMonoToStereo(self: *WavWriter) ![]i16 {
        const stereo_pcm = try self.allocator.alloc(i16, self.buffer.len * 2);
        for (self.buffer, 0..) |sample, i| {
            stereo_pcm[i * 2] = sample; // Left
            stereo_pcm[i * 2 + 1] = sample; // Right
        }
        return stereo_pcm;
    }

    fn writeToFile(self: *WavWriter, wav_data: []u8) !void {
        var file = try std.fs.cwd().createFile(
            self.filename,
            .{ .truncate = true },
        );
        defer file.close();
        try file.writeAll(wav_data);
    }
};
