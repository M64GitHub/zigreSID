const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub const CPU = struct {
    pc: u16 = 0,
    a: u8 = 0,
    x: u8 = 0,
    y: u8 = 0,
    flags: u8 = 0,
    sp: u8 = 0xff,
    mem: [0x10000]u8 = [_]u8{0} ** 0x10000,
    cpucycles: u32 = 0,

    pub fn init(self: *CPU, newpc: u16, newa: u8, newx: u8, newy: u8) void {
        self.pc = newpc;
        self.a = newa;
        self.x = newx;
        self.y = newy;
        self.flags = 0;
        self.sp = 0xff;
        self.cpucycles = 0;
    }
    pub fn setpc(self: *CPU, arg_newpc: c_ushort) void {
        self.pc = arg_newpc;
    }

    pub fn readByte(self: *CPU, address: u16) u8 {
        return self.mem[address];
    }

    pub fn writeByte(self: *CPU, address: u16, val: u8) void {
        self.mem[address] = val;
    }

    pub fn run(self: *CPU) !c_int {
        var temp: c_uint = undefined;

        const op: u8 = self.mem[self.pc];
        try stdout.print("op: {d}\n", .{op});
        try stdout.print("pc: {d}\n", .{self.pc});

        self.pc +%= 1;

        self.cpucycles +%= @as(c_uint, @bitCast(cpucycles_table[op]));
        while (true) {
            switch (@as(c_int, @bitCast(@as(c_uint, op)))) {
                @as(c_int, 167) => {
                    {
                        self.a = self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.x = self.a;
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 183) => {
                    {
                        self.a = self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 255)))];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.x = self.a;
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 175) => {
                    {
                        self.a = self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.x = self.a;
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 163) => {
                    {
                        self.a = self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))))];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.x = self.a;
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 179) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, 0)) & @as(c_int, 65535)) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a = self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.x = self.a;
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 26), @as(c_int, 58), @as(c_int, 90), @as(c_int, 122), @as(c_int, 218), @as(c_int, 250) => break,
                @as(c_int, 128), @as(c_int, 130), @as(c_int, 137), @as(c_int, 194), @as(c_int, 226), @as(c_int, 4), @as(c_int, 68), @as(c_int, 100), @as(c_int, 20), @as(c_int, 52), @as(c_int, 84), @as(c_int, 116), @as(c_int, 212), @as(c_int, 244) => {
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 12), @as(c_int, 28), @as(c_int, 60), @as(c_int, 92), @as(c_int, 124), @as(c_int, 220), @as(c_int, 252) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 105) => {
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[self.pc])));
                        _ = &tempval;
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            temp = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 9)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 6)));
                            }
                            if (temp <= @as(c_uint, @bitCast(@as(c_int, 15)))) {
                                temp = ((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))));
                            } else {
                                temp = (((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) +% @as(c_uint, @bitCast(@as(c_int, 16)));
                            }
                            if (!((((@as(c_uint, @bitCast(@as(c_uint, self.a))) +% tempval) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)))) & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 2)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 128)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 128)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and !(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 496)))) > @as(c_uint, @bitCast(@as(c_int, 144)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 4080)))) > @as(c_uint, @bitCast(@as(c_int, 240)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        } else {
                            temp = (tempval +% @as(c_uint, @bitCast(@as(c_uint, self.a)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (!(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 255)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        }
                        self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 101) => {
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])));
                        _ = &tempval;
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            temp = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 9)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 6)));
                            }
                            if (temp <= @as(c_uint, @bitCast(@as(c_int, 15)))) {
                                temp = ((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))));
                            } else {
                                temp = (((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) +% @as(c_uint, @bitCast(@as(c_int, 16)));
                            }
                            if (!((((@as(c_uint, @bitCast(@as(c_uint, self.a))) +% tempval) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)))) & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 2)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 128)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 128)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and !(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 496)))) > @as(c_uint, @bitCast(@as(c_int, 144)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 4080)))) > @as(c_uint, @bitCast(@as(c_int, 240)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        } else {
                            temp = (tempval +% @as(c_uint, @bitCast(@as(c_uint, self.a)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (!(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 255)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        }
                        self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 117) => {
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))])));
                        _ = &tempval;
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            temp = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 9)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 6)));
                            }
                            if (temp <= @as(c_uint, @bitCast(@as(c_int, 15)))) {
                                temp = ((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))));
                            } else {
                                temp = (((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) +% @as(c_uint, @bitCast(@as(c_int, 16)));
                            }
                            if (!((((@as(c_uint, @bitCast(@as(c_uint, self.a))) +% tempval) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)))) & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 2)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 128)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 128)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and !(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 496)))) > @as(c_uint, @bitCast(@as(c_int, 144)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 4080)))) > @as(c_uint, @bitCast(@as(c_int, 240)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        } else {
                            temp = (tempval +% @as(c_uint, @bitCast(@as(c_uint, self.a)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (!(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 255)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        }
                        self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 109) => {
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])));
                        _ = &tempval;
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            temp = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 9)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 6)));
                            }
                            if (temp <= @as(c_uint, @bitCast(@as(c_int, 15)))) {
                                temp = ((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))));
                            } else {
                                temp = (((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) +% @as(c_uint, @bitCast(@as(c_int, 16)));
                            }
                            if (!((((@as(c_uint, @bitCast(@as(c_uint, self.a))) +% tempval) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)))) & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 2)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 128)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 128)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and !(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 496)))) > @as(c_uint, @bitCast(@as(c_int, 144)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 4080)))) > @as(c_uint, @bitCast(@as(c_int, 240)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        } else {
                            temp = (tempval +% @as(c_uint, @bitCast(@as(c_uint, self.a)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (!(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 255)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        }
                        self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 125) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))])));
                        _ = &tempval;
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            temp = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 9)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 6)));
                            }
                            if (temp <= @as(c_uint, @bitCast(@as(c_int, 15)))) {
                                temp = ((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))));
                            } else {
                                temp = (((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) +% @as(c_uint, @bitCast(@as(c_int, 16)));
                            }
                            if (!((((@as(c_uint, @bitCast(@as(c_uint, self.a))) +% tempval) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)))) & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 2)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 128)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 128)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and !(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 496)))) > @as(c_uint, @bitCast(@as(c_int, 144)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 4080)))) > @as(c_uint, @bitCast(@as(c_int, 240)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        } else {
                            temp = (tempval +% @as(c_uint, @bitCast(@as(c_uint, self.a)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (!(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 255)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        }
                        self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 121) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])));
                        _ = &tempval;
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            temp = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 9)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 6)));
                            }
                            if (temp <= @as(c_uint, @bitCast(@as(c_int, 15)))) {
                                temp = ((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))));
                            } else {
                                temp = (((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) +% @as(c_uint, @bitCast(@as(c_int, 16)));
                            }
                            if (!((((@as(c_uint, @bitCast(@as(c_uint, self.a))) +% tempval) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)))) & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 2)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 128)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 128)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and !(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 496)))) > @as(c_uint, @bitCast(@as(c_int, 144)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 4080)))) > @as(c_uint, @bitCast(@as(c_int, 240)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        } else {
                            temp = (tempval +% @as(c_uint, @bitCast(@as(c_uint, self.a)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (!(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 255)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        }
                        self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 97) => {
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))))])));
                        _ = &tempval;
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            temp = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 9)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 6)));
                            }
                            if (temp <= @as(c_uint, @bitCast(@as(c_int, 15)))) {
                                temp = ((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))));
                            } else {
                                temp = (((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) +% @as(c_uint, @bitCast(@as(c_int, 16)));
                            }
                            if (!((((@as(c_uint, @bitCast(@as(c_uint, self.a))) +% tempval) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)))) & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 2)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 128)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 128)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and !(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 496)))) > @as(c_uint, @bitCast(@as(c_int, 144)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 4080)))) > @as(c_uint, @bitCast(@as(c_int, 240)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        } else {
                            temp = (tempval +% @as(c_uint, @bitCast(@as(c_uint, self.a)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (!(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 255)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        }
                        self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 113) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, 0)) & @as(c_int, 65535)) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])));
                        _ = &tempval;
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            temp = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 9)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 6)));
                            }
                            if (temp <= @as(c_uint, @bitCast(@as(c_int, 15)))) {
                                temp = ((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))));
                            } else {
                                temp = (((temp & @as(c_uint, @bitCast(@as(c_int, 15)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240)))) +% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) +% @as(c_uint, @bitCast(@as(c_int, 16)));
                            }
                            if (!((((@as(c_uint, @bitCast(@as(c_uint, self.a))) +% tempval) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)))) & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 2)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 128)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 128)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and !(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 496)))) > @as(c_uint, @bitCast(@as(c_int, 144)))) {
                                temp +%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if ((temp & @as(c_uint, @bitCast(@as(c_int, 4080)))) > @as(c_uint, @bitCast(@as(c_int, 240)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        } else {
                            temp = (tempval +% @as(c_uint, @bitCast(@as(c_uint, self.a)))) +% @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)));
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (!(((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            if (temp > @as(c_uint, @bitCast(@as(c_int, 255)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                        }
                        self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 41) => {
                    {
                        self.a &= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 37) => {
                    {
                        self.a &= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 53) => {
                    {
                        self.a &= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 45) => {
                    {
                        self.a &= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 61) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a &= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 57) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a &= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 33) => {
                    {
                        self.a &= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 49) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, 0)) & @as(c_int, 65535)) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a &= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 10) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.a)));
                        temp <<= @intCast(@as(c_int, 1));
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        {
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    break;
                },
                @as(c_int, 6) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])));
                        temp <<= @intCast(@as(c_int, 1));
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        {
                            self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 22) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))])));
                        temp <<= @intCast(@as(c_int, 1));
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        {
                            self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 14) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])));
                        temp <<= @intCast(@as(c_int, 1));
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        {
                            self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 30) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))])));
                        temp <<= @intCast(@as(c_int, 1));
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        {
                            self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 144) => {
                    if (!((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) != 0)) {
                        self.cpucycles +%= 1;
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[
                            blk: {
                                const ref = &self.pc;
                                const tmp = ref.*;
                                ref.* +%= 1;
                                break :blk tmp;
                            }
                        ])));
                        if (temp < @as(c_uint, @bitCast(@as(c_int, 128)))) {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ (@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp)) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate(@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        } else {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ ((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256))))) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256)))))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        }
                    } else {
                        self.pc +%= 1;
                    }
                    break;
                },
                @as(c_int, 176) => {
                    if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) != 0) {
                        self.cpucycles +%= 1;
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[
                            blk: {
                                const ref = &self.pc;
                                const tmp = ref.*;
                                ref.* +%= 1;
                                break :blk tmp;
                            }
                        ])));
                        if (temp < @as(c_uint, @bitCast(@as(c_int, 128)))) {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ (@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp)) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate(@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        } else {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ ((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256))))) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256)))))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        }
                    } else {
                        self.pc +%= 1;
                    }
                    break;
                },
                @as(c_int, 240) => {
                    if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 2)) != 0) {
                        self.cpucycles +%= 1;
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[
                            blk: {
                                const ref = &self.pc;
                                const tmp = ref.*;
                                ref.* +%= 1;
                                break :blk tmp;
                            }
                        ])));
                        if (temp < @as(c_uint, @bitCast(@as(c_int, 128)))) {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ (@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp)) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate(@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        } else {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ ((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256))))) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256)))))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        }
                    } else {
                        self.pc +%= 1;
                    }
                    break;
                },
                @as(c_int, 36) => {
                    {
                        self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 64))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))]))) & (@as(c_int, 128) | @as(c_int, 64)))))));
                        if (!((@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))]))) & @as(c_int, @bitCast(@as(c_uint, self.a)))) != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 2)))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 44) => {
                    {
                        self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 64))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))]))) & (@as(c_int, 128) | @as(c_int, 64)))))));
                        if (!((@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))]))) & @as(c_int, @bitCast(@as(c_uint, self.a)))) != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 2)))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 48) => {
                    if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 128)) != 0) {
                        self.cpucycles +%= 1;
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[
                            blk: {
                                const ref = &self.pc;
                                const tmp = ref.*;
                                ref.* +%= 1;
                                break :blk tmp;
                            }
                        ])));
                        if (temp < @as(c_uint, @bitCast(@as(c_int, 128)))) {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ (@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp)) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate(@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        } else {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ ((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256))))) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256)))))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        }
                    } else {
                        self.pc +%= 1;
                    }
                    break;
                },
                @as(c_int, 208) => {
                    if (!((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 2)) != 0)) {
                        self.cpucycles +%= 1;
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[
                            blk: {
                                const ref = &self.pc;
                                const tmp = ref.*;
                                ref.* +%= 1;
                                break :blk tmp;
                            }
                        ])));
                        if (temp < @as(c_uint, @bitCast(@as(c_int, 128)))) {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ (@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp)) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate(@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        } else {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ ((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256))))) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256)))))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        }
                    } else {
                        self.pc +%= 1;
                    }
                    break;
                },
                @as(c_int, 16) => {
                    if (!((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 128)) != 0)) {
                        self.cpucycles +%= 1;
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[
                            blk: {
                                const ref = &self.pc;
                                const tmp = ref.*;
                                ref.* +%= 1;
                                break :blk tmp;
                            }
                        ])));
                        if (temp < @as(c_uint, @bitCast(@as(c_int, 128)))) {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ (@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp)) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate(@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        } else {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ ((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256))))) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256)))))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        }
                    } else {
                        self.pc +%= 1;
                    }
                    break;
                },
                @as(c_int, 80) => {
                    if (!((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 64)) != 0)) {
                        self.cpucycles +%= 1;
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[
                            blk: {
                                const ref = &self.pc;
                                const tmp = ref.*;
                                ref.* +%= 1;
                                break :blk tmp;
                            }
                        ])));
                        if (temp < @as(c_uint, @bitCast(@as(c_int, 128)))) {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ (@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp)) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate(@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        } else {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ ((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256))))) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256)))))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        }
                    } else {
                        self.pc +%= 1;
                    }
                    break;
                },
                @as(c_int, 112) => {
                    if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 64)) != 0) {
                        self.cpucycles +%= 1;
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[
                            blk: {
                                const ref = &self.pc;
                                const tmp = ref.*;
                                ref.* +%= 1;
                                break :blk tmp;
                            }
                        ])));
                        if (temp < @as(c_uint, @bitCast(@as(c_int, 128)))) {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ (@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp)) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate(@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        } else {
                            self.cpucycles +%= @as(c_uint, @bitCast(if (((@as(c_uint, @bitCast(@as(c_uint, self.pc))) ^ ((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256))))) & @as(c_uint, @bitCast(@as(c_int, 65280)))) != 0) @as(c_int, 1) else @as(c_int, 0)));
                            _ = blk: {
                                const tmp = @as(c_ushort, @bitCast(@as(c_ushort, @truncate((@as(c_uint, @bitCast(@as(c_uint, self.pc))) +% temp) -% @as(c_uint, @bitCast(@as(c_int, 256)))))));
                                self.pc = tmp;
                                break :blk tmp;
                            };
                        }
                    } else {
                        self.pc +%= 1;
                    }
                    break;
                },
                @as(c_int, 24) => {
                    self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                    break;
                },
                @as(c_int, 216) => {
                    self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 8)))));
                    break;
                },
                @as(c_int, 88) => {
                    self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 4)))));
                    break;
                },
                @as(c_int, 184) => {
                    self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                    break;
                },
                @as(c_int, 201) => {
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.a))) - @as(c_int, @bitCast(@as(c_uint, self.mem[self.pc])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.a))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[self.pc])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 197) => {
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.a))) - @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.a))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 213) => {
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.a))) - @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.a))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 205) => {
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.a))) - @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.a))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 221) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.a))) - @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.a))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 217) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.a))) - @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.a))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 193) => {
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.a))) - @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))))])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.a))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))))])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 209) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, 0)) & @as(c_int, 65535)) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.a))) - @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.a))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 224) => {
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.x))) - @as(c_int, @bitCast(@as(c_uint, self.mem[self.pc])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.x))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[self.pc])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 228) => {
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.x))) - @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.x))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 236) => {
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.x))) - @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.x))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 192) => {
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.y))) - @as(c_int, @bitCast(@as(c_uint, self.mem[self.pc])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.y))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[self.pc])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 196) => {
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.y))) - @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.y))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 204) => {
                    {
                        temp = @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.y))) - @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])))) & @as(c_int, 255)));
                        self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~((@as(c_int, 1) | @as(c_int, 128)) | @as(c_int, 2)))) | (temp & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                        if (!(temp != 0)) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 2)))));
                        }
                        if (@as(c_int, @bitCast(@as(c_uint, self.y))) >= @as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])))) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 198) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))]))) - @as(c_int, 1)));
                        {
                            self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 214) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) - @as(c_int, 1)));
                        {
                            self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 206) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))]))) - @as(c_int, 1)));
                        {
                            self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 222) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))]))) - @as(c_int, 1)));
                        {
                            self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 202) => {
                    self.x -%= 1;
                    {
                        if (!(self.x != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.x))) & @as(c_int, 128))))));
                        }
                    }
                    break;
                },
                @as(c_int, 136) => {
                    self.y -%= 1;
                    {
                        if (!(self.y != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.y))) & @as(c_int, 128))))));
                        }
                    }
                    break;
                },
                @as(c_int, 73) => {
                    {
                        self.a ^= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 69) => {
                    {
                        self.a ^= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 85) => {
                    {
                        self.a ^= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 77) => {
                    {
                        self.a ^= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 93) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a ^= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 89) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a ^= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 65) => {
                    {
                        self.a ^= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 81) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, 0)) & @as(c_int, 65535)) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a ^= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 230) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))]))) + @as(c_int, 1)));
                        {
                            self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 246) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) + @as(c_int, 1)));
                        {
                            self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 238) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))]))) + @as(c_int, 1)));
                        {
                            self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 254) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))]))) + @as(c_int, 1)));
                        {
                            self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 232) => {
                    self.x +%= 1;
                    {
                        if (!(self.x != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.x))) & @as(c_int, 128))))));
                        }
                    }
                    break;
                },
                @as(c_int, 200) => {
                    self.y +%= 1;
                    {
                        if (!(self.y != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.y))) & @as(c_int, 128))))));
                        }
                    }
                    break;
                },
                @as(c_int, 32) => {
                    _ = blk: {
                        const tmp = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)) >> @intCast(8)))));
                        self.mem[
                            @as(c_uint, @intCast(@as(c_int, 256) + @as(c_int, @bitCast(@as(c_uint, blk_1: {
                                const ref = &self.sp;
                                const tmp_2 = ref.*;
                                ref.* -%= 1;
                                break :blk_1 tmp_2;
                            })))))
                        ] = tmp;
                        break :blk tmp;
                    };
                    _ = blk: {
                        const tmp = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)) & @as(c_int, 255)))));
                        self.mem[
                            @as(c_uint, @intCast(@as(c_int, 256) + @as(c_int, @bitCast(@as(c_uint, blk_1: {
                                const ref = &self.sp;
                                const tmp_2 = ref.*;
                                ref.* -%= 1;
                                break :blk_1 tmp_2;
                            })))))
                        ] = tmp;
                        break :blk tmp;
                    };
                    self.pc = @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))));
                    break;
                },
                @as(c_int, 76) => {
                    self.pc = @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))));
                    break;
                },
                @as(c_int, 108) => {
                    {
                        var adr: c_ushort = @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))));
                        _ = &adr;
                        self.pc = @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[adr]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, adr))) + @as(c_int, 1)) & @as(c_int, 255)) | (@as(c_int, @bitCast(@as(c_uint, adr))) & @as(c_int, 65280))))]))) << @intCast(8))))));
                    }
                    break;
                },
                @as(c_int, 169) => {
                    {
                        self.a = self.mem[self.pc];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 165) => {
                    {
                        self.a = self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 181) => {
                    {
                        self.a = self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 173) => {
                    {
                        self.a = self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 189) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a = self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 185) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a = self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 161) => {
                    {
                        self.a = self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))))];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 177) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, 0)) & @as(c_int, 65535)) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a = self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 162) => {
                    {
                        self.x = self.mem[self.pc];
                        if (!(self.x != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.x))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 166) => {
                    {
                        self.x = self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))];
                        if (!(self.x != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.x))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 182) => {
                    {
                        self.x = self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 255)))];
                        if (!(self.x != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.x))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 174) => {
                    {
                        self.x = self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))];
                        if (!(self.x != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.x))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 190) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.x = self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))];
                        if (!(self.x != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.x))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 160) => {
                    {
                        self.y = self.mem[self.pc];
                        if (!(self.y != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.y))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 164) => {
                    {
                        self.y = self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))];
                        if (!(self.y != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.y))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 180) => {
                    {
                        self.y = self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))];
                        if (!(self.y != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.y))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 172) => {
                    {
                        self.y = self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))];
                        if (!(self.y != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.y))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 188) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.y = self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))];
                        if (!(self.y != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.y))) & @as(c_int, 128))))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 74) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.a)));
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 1)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        temp >>= @intCast(@as(c_int, 1));
                        {
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    break;
                },
                @as(c_int, 70) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])));
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 1)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        temp >>= @intCast(@as(c_int, 1));
                        {
                            self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 86) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))])));
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 1)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        temp >>= @intCast(@as(c_int, 1));
                        {
                            self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 78) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])));
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 1)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        temp >>= @intCast(@as(c_int, 1));
                        {
                            self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 94) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))])));
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 1)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        temp >>= @intCast(@as(c_int, 1));
                        {
                            self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 234) => break,
                @as(c_int, 9) => {
                    {
                        self.a |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 5) => {
                    {
                        self.a |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 21) => {
                    {
                        self.a |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 13) => {
                    {
                        self.a |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 29) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 25) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 1) => {
                    {
                        self.a |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 17) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, 0)) & @as(c_int, 65535)) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        self.a |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])))))));
                        {
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 72) => {
                    _ = blk: {
                        const tmp = self.a;
                        self.mem[
                            @as(c_uint, @intCast(@as(c_int, 256) + @as(c_int, @bitCast(@as(c_uint, blk_1: {
                                const ref = &self.sp;
                                const tmp_2 = ref.*;
                                ref.* -%= 1;
                                break :blk_1 tmp_2;
                            })))))
                        ] = tmp;
                        break :blk tmp;
                    };
                    break;
                },
                @as(c_int, 8) => {
                    _ = blk: {
                        const tmp = @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, @bitCast(@as(c_uint, self.flags))) | @as(c_int, 48)))));
                        self.mem[
                            @as(c_uint, @intCast(@as(c_int, 256) + @as(c_int, @bitCast(@as(c_uint, blk_1: {
                                const ref = &self.sp;
                                const tmp_2 = ref.*;
                                ref.* -%= 1;
                                break :blk_1 tmp_2;
                            })))))
                        ] = tmp;
                        break :blk tmp;
                    };
                    break;
                },
                @as(c_int, 104) => {
                    {
                        self.a = self.mem[
                            @as(c_uint, @intCast(@as(c_int, 256) + @as(c_int, @bitCast(@as(c_uint, blk: {
                                const ref = &self.sp;
                                ref.* +%= 1;
                                break :blk ref.*;
                            })))))
                        ];
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    break;
                },
                @as(c_int, 40) => {
                    self.flags = self.mem[
                        @as(c_uint, @intCast(@as(c_int, 256) + @as(c_int, @bitCast(@as(c_uint, blk: {
                            const ref = &self.sp;
                            ref.* +%= 1;
                            break :blk ref.*;
                        })))))
                    ];
                    break;
                },
                @as(c_int, 42) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.a)));
                        temp <<= @intCast(@as(c_int, 1));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) != 0) {
                            temp |= @as(c_uint, @bitCast(@as(c_int, 1)));
                        }
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        {
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    break;
                },
                @as(c_int, 38) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])));
                        temp <<= @intCast(@as(c_int, 1));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) != 0) {
                            temp |= @as(c_uint, @bitCast(@as(c_int, 1)));
                        }
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        {
                            self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 54) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))])));
                        temp <<= @intCast(@as(c_int, 1));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) != 0) {
                            temp |= @as(c_uint, @bitCast(@as(c_int, 1)));
                        }
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        {
                            self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 46) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])));
                        temp <<= @intCast(@as(c_int, 1));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) != 0) {
                            temp |= @as(c_uint, @bitCast(@as(c_int, 1)));
                        }
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        {
                            self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 62) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))])));
                        temp <<= @intCast(@as(c_int, 1));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) != 0) {
                            temp |= @as(c_uint, @bitCast(@as(c_int, 1)));
                        }
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        {
                            self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 106) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.a)));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) != 0) {
                            temp |= @as(c_uint, @bitCast(@as(c_int, 256)));
                        }
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 1)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        temp >>= @intCast(@as(c_int, 1));
                        {
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.a != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    break;
                },
                @as(c_int, 102) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) != 0) {
                            temp |= @as(c_uint, @bitCast(@as(c_int, 256)));
                        }
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 1)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        temp >>= @intCast(@as(c_int, 1));
                        {
                            self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 118) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))])));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) != 0) {
                            temp |= @as(c_uint, @bitCast(@as(c_int, 256)));
                        }
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 1)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        temp >>= @intCast(@as(c_int, 1));
                        {
                            self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 110) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) != 0) {
                            temp |= @as(c_uint, @bitCast(@as(c_int, 256)));
                        }
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 1)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        temp >>= @intCast(@as(c_int, 1));
                        {
                            self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 126) => {
                    {
                        temp = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))])));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) != 0) {
                            temp |= @as(c_uint, @bitCast(@as(c_int, 256)));
                        }
                        if ((temp & @as(c_uint, @bitCast(@as(c_int, 1)))) != 0) {
                            self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                        } else {
                            self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                        }
                        temp >>= @intCast(@as(c_int, 1));
                        {
                            self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                            if (!(self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] != 0)) {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                            } else {
                                self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))]))) & @as(c_int, 128))))));
                            }
                        }
                    }
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 64) => {
                    if (@as(c_int, @bitCast(@as(c_uint, self.sp))) == @as(c_int, 255)) return 0;
                    self.flags = self.mem[
                        @as(c_uint, @intCast(@as(c_int, 256) + @as(c_int, @bitCast(@as(c_uint, blk: {
                            const ref = &self.sp;
                            ref.* +%= 1;
                            break :blk ref.*;
                        })))))
                    ];
                    self.pc = @as(c_ushort, @bitCast(@as(c_ushort, self.mem[
                        @as(c_uint, @intCast(@as(c_int, 256) + @as(c_int, @bitCast(@as(c_uint, blk: {
                            const ref = &self.sp;
                            ref.* +%= 1;
                            break :blk ref.*;
                        })))))
                    ])));
                    self.pc |= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[
                        @as(c_uint, @intCast(@as(c_int, 256) + @as(c_int, @bitCast(@as(c_uint, blk: {
                            const ref = &self.sp;
                            ref.* +%= 1;
                            break :blk ref.*;
                        })))))
                    ]))) << @intCast(8)))));
                    break;
                },
                @as(c_int, 96) => {
                    if (@as(c_int, @bitCast(@as(c_uint, self.sp))) == @as(c_int, 255)) return 0;
                    self.pc = @as(c_ushort, @bitCast(@as(c_ushort, self.mem[
                        @as(c_uint, @intCast(@as(c_int, 256) + @as(c_int, @bitCast(@as(c_uint, blk: {
                            const ref = &self.sp;
                            ref.* +%= 1;
                            break :blk ref.*;
                        })))))
                    ])));
                    self.pc |= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, @bitCast(@as(c_uint, self.mem[
                        @as(c_uint, @intCast(@as(c_int, 256) + @as(c_int, @bitCast(@as(c_uint, blk: {
                            const ref = &self.sp;
                            ref.* +%= 1;
                            break :blk ref.*;
                        })))))
                    ]))) << @intCast(8)))));
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 233), @as(c_int, 235) => {
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[self.pc])));
                        _ = &tempval;
                        temp = (@as(c_uint, @bitCast(@as(c_uint, self.a))) -% tempval) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            var tempval2: c_uint = undefined;
                            _ = &tempval2;
                            tempval2 = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 16)))) != 0) {
                                tempval2 = ((tempval2 -% @as(c_uint, @bitCast(@as(c_int, 6)))) & @as(c_uint, @bitCast(@as(c_int, 15)))) | ((@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) -% @as(c_uint, @bitCast(@as(c_int, 16))));
                            } else {
                                tempval2 = (tempval2 & @as(c_uint, @bitCast(@as(c_int, 15)))) | (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240)))));
                            }
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                                tempval2 -%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(tempval2))));
                        } else {
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 229) => {
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))])));
                        _ = &tempval;
                        temp = (@as(c_uint, @bitCast(@as(c_uint, self.a))) -% tempval) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            var tempval2: c_uint = undefined;
                            _ = &tempval2;
                            tempval2 = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 16)))) != 0) {
                                tempval2 = ((tempval2 -% @as(c_uint, @bitCast(@as(c_int, 6)))) & @as(c_uint, @bitCast(@as(c_int, 15)))) | ((@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) -% @as(c_uint, @bitCast(@as(c_int, 16))));
                            } else {
                                tempval2 = (tempval2 & @as(c_uint, @bitCast(@as(c_int, 15)))) | (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240)))));
                            }
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                                tempval2 -%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(tempval2))));
                        } else {
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 245) => {
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))])));
                        _ = &tempval;
                        temp = (@as(c_uint, @bitCast(@as(c_uint, self.a))) -% tempval) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            var tempval2: c_uint = undefined;
                            _ = &tempval2;
                            tempval2 = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 16)))) != 0) {
                                tempval2 = ((tempval2 -% @as(c_uint, @bitCast(@as(c_int, 6)))) & @as(c_uint, @bitCast(@as(c_int, 15)))) | ((@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) -% @as(c_uint, @bitCast(@as(c_int, 16))));
                            } else {
                                tempval2 = (tempval2 & @as(c_uint, @bitCast(@as(c_int, 15)))) | (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240)))));
                            }
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                                tempval2 -%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(tempval2))));
                        } else {
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 237) => {
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))])));
                        _ = &tempval;
                        temp = (@as(c_uint, @bitCast(@as(c_uint, self.a))) -% tempval) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            var tempval2: c_uint = undefined;
                            _ = &tempval2;
                            tempval2 = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 16)))) != 0) {
                                tempval2 = ((tempval2 -% @as(c_uint, @bitCast(@as(c_int, 6)))) & @as(c_uint, @bitCast(@as(c_int, 15)))) | ((@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) -% @as(c_uint, @bitCast(@as(c_int, 16))));
                            } else {
                                tempval2 = (tempval2 & @as(c_uint, @bitCast(@as(c_int, 15)))) | (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240)))));
                            }
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                                tempval2 -%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(tempval2))));
                        } else {
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 253) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))])));
                        _ = &tempval;
                        temp = (@as(c_uint, @bitCast(@as(c_uint, self.a))) -% tempval) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            var tempval2: c_uint = undefined;
                            _ = &tempval2;
                            tempval2 = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 16)))) != 0) {
                                tempval2 = ((tempval2 -% @as(c_uint, @bitCast(@as(c_int, 6)))) & @as(c_uint, @bitCast(@as(c_int, 15)))) | ((@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) -% @as(c_uint, @bitCast(@as(c_int, 16))));
                            } else {
                                tempval2 = (tempval2 & @as(c_uint, @bitCast(@as(c_int, 15)))) | (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240)))));
                            }
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                                tempval2 -%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(tempval2))));
                        } else {
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 249) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])));
                        _ = &tempval;
                        temp = (@as(c_uint, @bitCast(@as(c_uint, self.a))) -% tempval) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            var tempval2: c_uint = undefined;
                            _ = &tempval2;
                            tempval2 = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 16)))) != 0) {
                                tempval2 = ((tempval2 -% @as(c_uint, @bitCast(@as(c_int, 6)))) & @as(c_uint, @bitCast(@as(c_int, 15)))) | ((@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) -% @as(c_uint, @bitCast(@as(c_int, 16))));
                            } else {
                                tempval2 = (tempval2 & @as(c_uint, @bitCast(@as(c_int, 15)))) | (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240)))));
                            }
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                                tempval2 -%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(tempval2))));
                        } else {
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                        }
                    }
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 225) => {
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))))])));
                        _ = &tempval;
                        temp = (@as(c_uint, @bitCast(@as(c_uint, self.a))) -% tempval) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            var tempval2: c_uint = undefined;
                            _ = &tempval2;
                            tempval2 = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 16)))) != 0) {
                                tempval2 = ((tempval2 -% @as(c_uint, @bitCast(@as(c_int, 6)))) & @as(c_uint, @bitCast(@as(c_int, 15)))) | ((@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) -% @as(c_uint, @bitCast(@as(c_int, 16))));
                            } else {
                                tempval2 = (tempval2 & @as(c_uint, @bitCast(@as(c_int, 15)))) | (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240)))));
                            }
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                                tempval2 -%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(tempval2))));
                        } else {
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 241) => {
                    self.cpucycles +%= @as(c_uint, @bitCast(if ((((((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, 0)) & @as(c_int, 65535)) ^ (((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535))) & @as(c_int, 65280)) != 0) @as(c_int, 1) else @as(c_int, 0)));
                    {
                        var tempval: c_uint = @as(c_uint, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))])));
                        _ = &tempval;
                        temp = (@as(c_uint, @bitCast(@as(c_uint, self.a))) -% tempval) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                        if ((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 8)) != 0) {
                            var tempval2: c_uint = undefined;
                            _ = &tempval2;
                            tempval2 = (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 15))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 15))))) -% @as(c_uint, @bitCast((@as(c_int, @bitCast(@as(c_uint, self.flags))) & @as(c_int, 1)) ^ @as(c_int, 1)));
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 16)))) != 0) {
                                tempval2 = ((tempval2 -% @as(c_uint, @bitCast(@as(c_int, 6)))) & @as(c_uint, @bitCast(@as(c_int, 15)))) | ((@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240))))) -% @as(c_uint, @bitCast(@as(c_int, 16))));
                            } else {
                                tempval2 = (tempval2 & @as(c_uint, @bitCast(@as(c_int, 15)))) | (@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 240))) -% (tempval & @as(c_uint, @bitCast(@as(c_int, 240)))));
                            }
                            if ((tempval2 & @as(c_uint, @bitCast(@as(c_int, 256)))) != 0) {
                                tempval2 -%= @as(c_uint, @bitCast(@as(c_int, 96)));
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(tempval2))));
                        } else {
                            {
                                if (!((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) != 0)) {
                                    self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                                } else {
                                    self.flags = @as(u8, @bitCast(@as(u8, @truncate(@as(c_uint, @bitCast(@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2)))) | ((temp & @as(c_uint, @bitCast(@as(c_int, 255)))) & @as(c_uint, @bitCast(@as(c_int, 128))))))));
                                }
                            }
                            if (temp < @as(c_uint, @bitCast(@as(c_int, 256)))) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 1)))));
                            }
                            if ((((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ temp) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0) and (((@as(c_uint, @bitCast(@as(c_uint, self.a))) ^ tempval) & @as(c_uint, @bitCast(@as(c_int, 128)))) != 0)) {
                                self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 64)))));
                            } else {
                                self.flags &= @as(u8, @bitCast(@as(i8, @truncate(~@as(c_int, 64)))));
                            }
                            self.a = @as(u8, @bitCast(@as(u8, @truncate(temp))));
                        }
                    }
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 56) => {
                    self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 1)))));
                    break;
                },
                @as(c_int, 248) => {
                    self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 8)))));
                    break;
                },
                @as(c_int, 120) => {
                    self.flags |= @as(u8, @bitCast(@as(i8, @truncate(@as(c_int, 4)))));
                    break;
                },
                @as(c_int, 133) => {
                    self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] = self.a;
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 149) => {
                    self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] = self.a;
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 141) => {
                    self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] = self.a;
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 157) => {
                    self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 65535)))] = self.a;
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 153) => {
                    self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))] = self.a;
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 129) => {
                    self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))))] = self.a;
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 145) => {
                    self.mem[@as(c_uint, @intCast(((@as(c_int, @bitCast(@as(c_uint, self.mem[self.mem[self.pc]]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, 1)) & @as(c_int, 255)))]))) << @intCast(8))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 65535)))] = self.a;
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 134) => {
                    self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] = self.x;
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 150) => {
                    self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.y)))) & @as(c_int, 255)))] = self.x;
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 142) => {
                    self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] = self.x;
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 132) => {
                    self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) & @as(c_int, 255)))] = self.y;
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 148) => {
                    self.mem[@as(c_uint, @intCast((@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) + @as(c_int, @bitCast(@as(c_uint, self.x)))) & @as(c_int, 255)))] = self.y;
                    {}
                    self.pc +%= 1;
                    break;
                },
                @as(c_int, 140) => {
                    self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.mem[self.pc]))) | (@as(c_int, @bitCast(@as(c_uint, self.mem[@as(c_uint, @intCast(@as(c_int, @bitCast(@as(c_uint, self.pc))) + @as(c_int, 1)))]))) << @intCast(8))))] = self.y;
                    {}
                    self.pc +%= @as(c_ushort, @bitCast(@as(c_short, @truncate(@as(c_int, 2)))));
                    break;
                },
                @as(c_int, 170) => {
                    {
                        self.x = self.a;
                        if (!(self.x != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.x))) & @as(c_int, 128))))));
                        }
                    }
                    break;
                },
                @as(c_int, 186) => {
                    {
                        self.x = self.sp;
                        if (!(self.x != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.x))) & @as(c_int, 128))))));
                        }
                    }
                    break;
                },
                @as(c_int, 138) => {
                    {
                        self.a = self.x;
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    break;
                },
                @as(c_int, 154) => {
                    self.sp = self.x;
                    break;
                },
                @as(c_int, 152) => {
                    {
                        self.a = self.y;
                        if (!(self.a != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.a))) & @as(c_int, 128))))));
                        }
                    }
                    break;
                },
                @as(c_int, 168) => {
                    {
                        self.y = self.a;
                        if (!(self.y != 0)) {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~@as(c_int, 128)) | @as(c_int, 2)))));
                        } else {
                            self.flags = @as(u8, @bitCast(@as(i8, @truncate((@as(c_int, @bitCast(@as(c_uint, self.flags))) & ~(@as(c_int, 128) | @as(c_int, 2))) | (@as(c_int, @bitCast(@as(c_uint, self.y))) & @as(c_int, 128))))));
                        }
                    }
                    break;
                },
                @as(c_int, 0) => return 0,
                @as(c_int, 2) => break,
                else => break,
            }
            break;
        }
        return 1;
    }

    const cpucycles_table: [256]c_int = [256]c_int{
        7,
        6,
        0,
        8,
        3,
        3,
        5,
        5,
        3,
        2,
        2,
        2,
        4,
        4,
        6,
        6,
        2,
        5,
        0,
        8,
        4,
        4,
        6,
        6,
        2,
        4,
        2,
        7,
        4,
        4,
        7,
        7,
        6,
        6,
        0,
        8,
        3,
        3,
        5,
        5,
        4,
        2,
        2,
        2,
        4,
        4,
        6,
        6,
        2,
        5,
        0,
        8,
        4,
        4,
        6,
        6,
        2,
        4,
        2,
        7,
        4,
        4,
        7,
        7,
        6,
        6,
        0,
        8,
        3,
        3,
        5,
        5,
        3,
        2,
        2,
        2,
        3,
        4,
        6,
        6,
        2,
        5,
        0,
        8,
        4,
        4,
        6,
        6,
        2,
        4,
        2,
        7,
        4,
        4,
        7,
        7,
        6,
        6,
        0,
        8,
        3,
        3,
        5,
        5,
        4,
        2,
        2,
        2,
        5,
        4,
        6,
        6,
        2,
        5,
        0,
        8,
        4,
        4,
        6,
        6,
        2,
        4,
        2,
        7,
        4,
        4,
        7,
        7,
        2,
        6,
        2,
        6,
        3,
        3,
        3,
        3,
        2,
        2,
        2,
        2,
        4,
        4,
        4,
        4,
        2,
        6,
        0,
        6,
        4,
        4,
        4,
        4,
        2,
        5,
        2,
        5,
        5,
        5,
        5,
        5,
        2,
        6,
        2,
        6,
        3,
        3,
        3,
        3,
        2,
        2,
        2,
        2,
        4,
        4,
        4,
        4,
        2,
        5,
        0,
        5,
        4,
        4,
        4,
        4,
        2,
        4,
        2,
        4,
        4,
        4,
        4,
        4,
        2,
        6,
        2,
        8,
        3,
        3,
        5,
        5,
        2,
        2,
        2,
        2,
        4,
        4,
        6,
        6,
        2,
        5,
        0,
        8,
        4,
        4,
        6,
        6,
        2,
        4,
        2,
        7,
        4,
        4,
        7,
        7,
        2,
        6,
        2,
        8,
        3,
        3,
        5,
        5,
        2,
        2,
        2,
        2,
        4,
        4,
        6,
        6,
        2,
        5,
        0,
        8,
        4,
        4,
        6,
        6,
        2,
        4,
        2,
        7,
        4,
        4,
        7,
        7,
    };
};
