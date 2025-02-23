const std = @import("std");
const c = @cImport({
    @cInclude("resid_wrapper.h");
});

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

    pub fn update(self: *ReSIDDmpPlayer) void {
        c.ReSIDDmpPlayer_update(self.ptr);
    }

    pub fn getPBData(self: *ReSIDDmpPlayer) *c.ReSIDPbData {
        return c.ReSIDDmpPlayer_getPBData(self.ptr);
    }
};
