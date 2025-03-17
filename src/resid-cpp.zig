const std = @import("std");
const wrapper = @cImport({
    @cInclude("resid-c-wrapper.h");
});

pub const Sid = struct {
    ptr: *wrapper.ReSID,

    pub fn init(name: [*:0]const u8) !Sid {
        const sid = wrapper.ReSID_create(name) orelse return error.FailedToCreateSid;
        return Sid{ .ptr = sid };
    }

    pub fn deinit(self: *Sid) void {
        wrapper.ReSID_destroy(self.ptr);
    }

    pub fn getName(self: *Sid) [*:0]const u8 {
        return wrapper.ReSID_getName(self.ptr);
    }

    pub fn setChipModel(self: *Sid, model: [*:0]const u8) bool {
        return wrapper.ReSID_setChipModel(self.ptr, model);
    }

    pub fn setSamplingRate(self: *Sid, rate: i32) void {
        wrapper.ReSID_setSamplingRate(self.ptr, rate);
    }

    pub fn getSamplingRate(self: *Sid) i32 {
        return wrapper.ReSID_getSamplingRate(self.ptr);
    }

    pub fn writeRegs(self: *Sid, regs: *[25]u8) void {
        wrapper.ReSID_writeRegs(self.ptr, regs, 25);
    }

    pub fn getRegs(self: *Sid) *[25]u8 {
        const regs: *[25]u8 = @ptrCast(wrapper.Resid_getRegs(self.ptr));
        return regs;
    }

    pub fn clock(self: *Sid, cycle_count: u32, buf: []i16) i32 {
        const buflen: c_int = @as(c_int, buf.len);
        return wrapper.ReSID_clock(self.ptr, cycle_count, buf.ptr, buflen);
    }
};

pub const DumpPlayer = struct {
    pub const Playstate = enum(i32) {
        stopped = 0,
        playing = 1,
        paused = 2,
    };

    ptr: *wrapper.ReSIDDmpPlayer,
    dump: []u8 = &.{},
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, resid: Sid) !DumpPlayer {
        const player = wrapper.ReSIDDmpPlayer_create(resid.ptr) orelse
            return error.FailedToCreatePlayer;
        return DumpPlayer{ .ptr = player, .allocator = allocator };
    }

    pub fn deinit(self: *DumpPlayer) void {
        wrapper.ReSIDDmpPlayer_destroy(self.ptr);
    }

    pub fn play(self: *DumpPlayer) void {
        wrapper.ReSIDDmpPlayer_play(self.ptr);
    }

    pub fn stop(self: *DumpPlayer) void {
        wrapper.ReSIDDmpPlayer_stop(self.ptr);
    }

    pub fn pause(self: *DumpPlayer) void {
        wrapper.ReSIDDmpPlayer_pause(self.ptr);
    }

    pub fn continuePlayback(self: *DumpPlayer) void {
        wrapper.ReSIDDmpPlayer_continue(self.ptr);
    }

    pub fn update(self: *DumpPlayer) bool {
        return wrapper.ReSIDDmpPlayer_update(self.ptr);
    }

    pub fn getPlayerContext(self: *DumpPlayer) *wrapper.DmpPlayerContext {
        return wrapper.ReSIDDmpPlayer_getPlayerContext(self.ptr);
    }

    pub fn fillAudioBuffer(self: *DumpPlayer) i32 {
        return wrapper.ReSIDDmpPlayer_fillAudioBuffer(self.ptr);
    }

    pub fn setDmp(self: *DumpPlayer, dump: []u8) void {
        self.dump = dump;
        wrapper.ReSIDDmpPlayer_setdmp(self.ptr, self.dump.ptr, @truncate(@as(u64, self.dump.len)));
    }

    pub fn loadDmp(self: *DumpPlayer, filename: []const u8) !void {
        var file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();

        const stat = try file.stat();
        const file_size = stat.size;

        const buffer = try self.allocator.alloc(u8, file_size);

        _ = try file.readAll(buffer);
        setDmp(self, buffer);
    }

    pub fn renderAudio(self: *DumpPlayer, start_step: u32, num_steps: u32, buffer: []i16) u32 {
        const buf_len: u32 = @truncate(buffer.len);
        return wrapper.ReSIDDmpPlayer_RenderAudio(self.ptr, start_step, num_steps, buf_len, buffer.ptr);
    }

    pub fn sdlAudioCallback(userdata: ?*anyopaque, stream: [*c]u8, len: c_int) callconv(.C) void {
        const player: *DumpPlayer = @ptrCast(@alignCast(userdata));
        wrapper.ReSIDDmpPlayer_SDL_audio_callback(player.ptr, userdata, stream, len);
    }

    pub fn updateExternal(self: *DumpPlayer, b: bool) void {
        wrapper.ReSIDDmpPlayer_updateExternal(self.ptr, b);
    }

    pub fn isPlaying(self: *DumpPlayer) bool {
        return wrapper.ReSIDDmpPlayer_isPlaying(self.ptr);
    }

    pub fn getPlayState(self: *DumpPlayer) Playstate {
        return @as(Playstate, @enumFromInt(wrapper.ReSIDDmpPlayer_getPlayerStatus(self.ptr)));
    }
};
