const std = @import("std");
const c = @cImport({
    @cInclude("resid-c-wrapper.h");
});

pub const DP_PLAYSTATE = enum(c_int) {
    stopped = 0,
    playing = 1,
    paused = 2,
};

pub const ReSID = struct {
    ptr: *c.ReSID,

    pub fn init(name: [*:0]const u8) !ReSID {
        const sid = c.ReSID_create(name) orelse return error.FailedToCreateReSID;
        return ReSID{ .ptr = sid };
    }

    pub fn deinit(self: *ReSID) void {
        c.ReSID_destroy(self.ptr);
    }

    pub fn getName(self: *ReSID) [*:0]const u8 {
        return c.ReSID_getName(self.ptr);
    }

    pub fn setDBGOutput(self: *ReSID, enable: bool) void {
        c.ReSID_setDBGOutput(self.ptr, enable);
    }

    pub fn setChipModel(self: *ReSID, model: [*:0]const u8) bool {
        return c.ReSID_setChipModel(self.ptr, model);
    }

    pub fn setSamplingRate(self: *ReSID, rate: i32) void {
        c.ReSID_setSamplingRate(self.ptr, rate);
    }

    pub fn getSamplingRate(self: *ReSID) i32 {
        return c.ReSID_getSamplingRate(self.ptr);
    }

    pub fn writeRegs(self: *ReSID, regs: *[25]u8) void {
        c.ReSID_writeRegs(self.ptr, regs, 25);
    }

    pub fn getRegs(self: *ReSID) [25]u8 {
        const regs_ptr = c.Resid_getRegs(self.ptr);
        var regs: [25]u8 = undefined;
        std.mem.copyForwards(u8, &regs, regs_ptr[0..25]);
        return regs;
    }
    pub fn clock(self: *ReSID, cycle_count: u32, buf: []i16) i32 {
        const buflen: c_int = @as(c_int, buf.len);
        return c.ReSID_clock(self.ptr, cycle_count, buf.ptr, buflen);
    }
};

pub const ReSIDDmpPlayer = struct {
    ptr: *c.ReSIDDmpPlayer,

    pub fn init(resid: *c.ReSID) !ReSIDDmpPlayer {
        const player = c.ReSIDDmpPlayer_create(resid) orelse return error.FailedToCreatePlayer;
        return ReSIDDmpPlayer{ .ptr = player };
    }

    pub fn deinit(self: *ReSIDDmpPlayer) void {
        c.ReSIDDmpPlayer_destroy(self.ptr);
    }

    pub fn play(self: *ReSIDDmpPlayer) void {
        c.ReSIDDmpPlayer_play(self.ptr);
    }

    pub fn stop(self: *ReSIDDmpPlayer) void {
        c.ReSIDDmpPlayer_stop(self.ptr);
    }

    pub fn pause(self: *ReSIDDmpPlayer) void {
        c.ReSIDDmpPlayer_pause(self.ptr);
    }

    pub fn continuePlayback(self: *ReSIDDmpPlayer) void {
        c.ReSIDDmpPlayer_continue(self.ptr);
    }

    pub fn update(self: *ReSIDDmpPlayer) bool {
        return c.ReSIDDmpPlayer_update(self.ptr);
    }

    pub fn getPlayerContext(self: *ReSIDDmpPlayer) *c.DmpPlayerContext {
        return c.ReSIDDmpPlayer_getPlayerContext(self.ptr);
    }

    pub fn setDmp(self: *ReSIDDmpPlayer, dump: [*c]u8, len: c_uint) void {
        c.ReSIDDmpPlayer_setdmp(self.ptr, dump, len);
    }

    pub fn fillAudioBuffer(self: *ReSIDDmpPlayer) i32 {
        return c.ReSIDDmpPlayer_fillAudioBuffer(self.ptr);
    }

    pub fn renderAudio(self: *ReSIDDmpPlayer, start_step: u32, num_steps: u32, buf_size: u32, buffer: []i16) u32 {
        return @as(u32, c.ReSIDDmpPlayer_RenderAudio(self.ptr, start_step, num_steps, buf_size, buffer.ptr));
    }

    pub fn sdlAudioCallback(userdata: ?*anyopaque, stream: [*c]u8, len: c_int) callconv(.C) void {
        const player: *ReSIDDmpPlayer = @ptrCast(@alignCast(userdata));
        c.ReSIDDmpPlayer_SDL_audio_callback(player.ptr, userdata, stream, len);
    }

    pub fn updateExternal(self: *ReSIDDmpPlayer, b: bool) void {
        c.ReSIDDmpPlayer_updateExternal(self.ptr, b);
    }

    pub fn isPlaying(self: *ReSIDDmpPlayer) bool {
        return c.ReSIDDmpPlayer_isPlaying(self.ptr);
    }

    pub fn getPlayState(self: *ReSIDDmpPlayer) DP_PLAYSTATE {
        return @as(DP_PLAYSTATE, @enumFromInt(c.ReSIDDmpPlayer_getPlayerStatus(self.ptr)));
    }
};
