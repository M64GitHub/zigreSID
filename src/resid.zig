const std = @import("std");
const wrapper = @cImport({
    @cInclude("resid-c-wrapper.h");
});

pub const ReSid = struct {
    ptr: *wrapper.ReSID,

    pub fn init(name: [*:0]const u8) !ReSid {
        const sid = wrapper.ReSID_create(name) orelse return error.FailedToCreateReSID;
        return ReSid{ .ptr = sid };
    }

    pub fn deinit(self: *ReSid) void {
        wrapper.ReSID_destroy(self.ptr);
    }

    pub fn getName(self: *ReSid) [*:0]const u8 {
        return wrapper.ReSID_getName(self.ptr);
    }

    pub fn setChipModel(self: *ReSid, model: [*:0]const u8) bool {
        return wrapper.ReSID_setChipModel(self.ptr, model);
    }

    pub fn setSamplingRate(self: *ReSid, rate: i32) void {
        wrapper.ReSID_setSamplingRate(self.ptr, rate);
    }

    pub fn getSamplingRate(self: *ReSid) i32 {
        return wrapper.ReSID_getSamplingRate(self.ptr);
    }

    pub fn writeRegs(self: *ReSid, regs: *[25]u8) void {
        wrapper.ReSID_writeRegs(self.ptr, regs, 25);
    }

    pub fn getRegs(self: *ReSid) *[25]u8 {
        const regs: *[25]u8 = @ptrCast(wrapper.Resid_getRegs(self.ptr));
        return regs;
    }

    pub fn clock(self: *ReSid, cycle_count: u32, buf: []i16) i32 {
        const buflen: c_int = @as(c_int, buf.len);
        return wrapper.ReSID_clock(self.ptr, cycle_count, buf.ptr, buflen);
    }
};

pub const ReSidDmpPlayer = struct {
    pub const Playstate = enum(i32) {
        stopped = 0,
        playing = 1,
        paused = 2,
    };

    ptr: *wrapper.ReSIDDmpPlayer,
    dump: []u8 = &.{},
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, resid: *wrapper.ReSID) !ReSidDmpPlayer {
        const player = wrapper.ReSIDDmpPlayer_create(resid) orelse return error.FailedToCreatePlayer;
        return ReSidDmpPlayer{ .ptr = player, .allocator = allocator };
    }

    pub fn deinit(self: *ReSidDmpPlayer) void {
        wrapper.ReSIDDmpPlayer_destroy(self.ptr);
    }

    pub fn play(self: *ReSidDmpPlayer) void {
        wrapper.ReSIDDmpPlayer_play(self.ptr);
    }

    pub fn stop(self: *ReSidDmpPlayer) void {
        wrapper.ReSIDDmpPlayer_stop(self.ptr);
    }

    pub fn pause(self: *ReSidDmpPlayer) void {
        wrapper.ReSIDDmpPlayer_pause(self.ptr);
    }

    pub fn continuePlayback(self: *ReSidDmpPlayer) void {
        wrapper.ReSIDDmpPlayer_continue(self.ptr);
    }

    pub fn update(self: *ReSidDmpPlayer) bool {
        return wrapper.ReSIDDmpPlayer_update(self.ptr);
    }

    pub fn getPlayerContext(self: *ReSidDmpPlayer) *wrapper.DmpPlayerContext {
        return wrapper.ReSIDDmpPlayer_getPlayerContext(self.ptr);
    }

    pub fn fillAudioBuffer(self: *ReSidDmpPlayer) i32 {
        return wrapper.ReSIDDmpPlayer_fillAudioBuffer(self.ptr);
    }

    pub fn setDmp(self: *ReSidDmpPlayer, dump: []u8) void {
        self.dump = dump;
        wrapper.ReSIDDmpPlayer_setdmp(self.ptr, self.dump.ptr, @truncate(@as(u64, self.dump.len)));
    }

    pub fn loadDmp(self: *ReSidDmpPlayer, filename: []const u8) !void {
        var file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();

        const stat = try file.stat();
        const file_size = stat.size;

        const buffer = try self.allocator.alloc(u8, file_size);

        // Read the file into the buffer
        _ = try file.readAll(buffer);

        setDmp(self, buffer);
    }

    pub fn renderAudio(self: *ReSidDmpPlayer, start_step: u32, num_steps: u32, buffer: []i16) u32 {
        const buf_len: u32 = @truncate(buffer.len);
        return wrapper.ReSIDDmpPlayer_RenderAudio(self.ptr, start_step, num_steps, buf_len, buffer.ptr);
    }

    pub fn sdlAudioCallback(userdata: ?*anyopaque, stream: [*c]u8, len: c_int) callconv(.C) void {
        const player: *ReSidDmpPlayer = @ptrCast(@alignCast(userdata));
        wrapper.ReSIDDmpPlayer_SDL_audio_callback(player.ptr, userdata, stream, len);
    }

    pub fn updateExternal(self: *ReSidDmpPlayer, b: bool) void {
        wrapper.ReSIDDmpPlayer_updateExternal(self.ptr, b);
    }

    pub fn isPlaying(self: *ReSidDmpPlayer) bool {
        return wrapper.ReSIDDmpPlayer_isPlaying(self.ptr);
    }

    pub fn getPlayState(self: *ReSidDmpPlayer) Playstate {
        return @as(Playstate, @enumFromInt(wrapper.ReSIDDmpPlayer_getPlayerStatus(self.ptr)));
    }
};
