const std = @import("std");
const Cpp = @cImport({
    @cInclude("resid-c-wrapper.h");
});

pub const Sid = struct {
    ptr: *Cpp.ReSID,

    pub fn init(name: [*:0]const u8) !Sid {
        const sid = Cpp.ReSID_create(name) orelse return error.FailedToCreateSid;
        return Sid{ .ptr = sid };
    }

    pub fn deinit(self: *Sid) void {
        Cpp.ReSID_destroy(self.ptr);
    }

    pub fn getName(self: *Sid) [*:0]const u8 {
        return Cpp.ReSID_getName(self.ptr);
    }

    pub fn setChipModel(self: *Sid, model: [*:0]const u8) bool {
        return Cpp.ReSID_setChipModel(self.ptr, model);
    }

    pub fn setSamplingRate(self: *Sid, rate: i32) void {
        Cpp.ReSID_setSamplingRate(self.ptr, rate);
    }

    pub fn getSamplingRate(self: *Sid) i32 {
        return Cpp.ReSID_getSamplingRate(self.ptr);
    }

    pub fn writeRegs(self: *Sid, regs: *[25]u8) void {
        Cpp.ReSID_writeRegs(self.ptr, regs, 25);
    }

    pub fn getRegs(self: *Sid) *[25]u8 {
        const regs: *[25]u8 = @ptrCast(Cpp.Resid_getRegs(self.ptr));
        return regs;
    }

    pub fn clock(self: *Sid, cycle_count: u32, buf: []i16) i32 {
        const buflen: c_int = @intCast(buf.len);
        return Cpp.ReSID_clock(self.ptr, cycle_count, buf.ptr, buflen);
    }
};

pub const DumpPlayer = struct {
    pub const Playstate = enum(i32) {
        stopped = 0,
        playing = 1,
        paused = 2,
    };

    ptr: *Cpp.ReSIDDmpPlayer,
    dump: []u8 = &.{},
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, resid: Sid) !DumpPlayer {
        const player = Cpp.ReSIDDmpPlayer_create(resid.ptr) orelse
            return error.FailedToCreatePlayer;
        return DumpPlayer{ .ptr = player, .allocator = allocator };
    }

    pub fn deinit(self: *DumpPlayer) void {
        Cpp.ReSIDDmpPlayer_destroy(self.ptr);
    }

    pub fn play(self: *DumpPlayer) void {
        Cpp.ReSIDDmpPlayer_play(self.ptr);
    }

    pub fn stop(self: *DumpPlayer) void {
        Cpp.ReSIDDmpPlayer_stop(self.ptr);
    }

    pub fn pause(self: *DumpPlayer) void {
        Cpp.ReSIDDmpPlayer_pause(self.ptr);
    }

    pub fn continuePlayback(self: *DumpPlayer) void {
        Cpp.ReSIDDmpPlayer_continue(self.ptr);
    }

    pub fn reset(self: *DumpPlayer) void {
        Cpp.ReSIDDmpPlayer_reset(self.ptr);
    }

    pub fn update(self: *DumpPlayer) bool {
        return Cpp.ReSIDDmpPlayer_update(self.ptr);
    }

    pub fn getPlayerContext(self: *DumpPlayer) *Cpp.DmpPlayerContext {
        return Cpp.ReSIDDmpPlayer_getPlayerContext(self.ptr);
    }

    pub fn fillAudioBuffer(self: *DumpPlayer) i32 {
        return Cpp.ReSIDDmpPlayer_fillAudioBuffer(self.ptr);
    }

    pub fn setDmp(self: *DumpPlayer, dump: []u8) void {
        self.dump = dump;
        Cpp.ReSIDDmpPlayer_setdmp(self.ptr, self.dump.ptr, @truncate(@as(u64, self.dump.len)));
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
        return Cpp.ReSIDDmpPlayer_RenderAudio(self.ptr, start_step, num_steps, buf_len, buffer.ptr);
    }

    pub fn sdlAudioCallback(userdata: ?*anyopaque, stream: [*c]u8, len: c_int) callconv(.C) void {
        const player: *DumpPlayer = @ptrCast(@alignCast(userdata));
        Cpp.ReSIDDmpPlayer_SDL_audio_callback(player.ptr, userdata, stream, len);
    }

    pub fn updateExternal(self: *DumpPlayer, b: bool) void {
        Cpp.ReSIDDmpPlayer_updateExternal(self.ptr, b);
    }

    pub fn isPlaying(self: *DumpPlayer) bool {
        return Cpp.ReSIDDmpPlayer_isPlaying(self.ptr);
    }

    pub fn getPlayState(self: *DumpPlayer) Playstate {
        return @as(Playstate, @enumFromInt(Cpp.ReSIDDmpPlayer_getPlayerStatus(self.ptr)));
    }
};
