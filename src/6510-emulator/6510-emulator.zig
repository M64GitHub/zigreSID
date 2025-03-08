const std = @import("std");

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

    fn mem(self: *CPU, address: u16) u8 {
        return self.mem[address];
    }

    fn lo(self: *CPU) u8 {
        return self.mem[self.pc];
    }

    fn hi(self: *CPU) u8 {
        return self.mem[self.pc + 1];
    }

    fn fetch(self: *CPU) u8 {
        defer self.pc += 1;
        return self.mem[self.pc];
    }

    fn setPC(self: *CPU, newpc: u16) void {
        self.pc = newpc;
    }

    fn push(self: *CPU, data: u8) void {
        self.mem[0x100 + @as(u16, self.sp)] = data;
        self.sp -%= 1;
    }

    fn pop(self: *CPU) u8 {
        self.sp +%= 1;
        return self.mem[0x100 + @as(u16, self.sp)];
    }

    fn immediate(self: *CPU) u8 {
        return self.lo();
    }

    fn absolute(self: *CPU) u16 {
        return @as(u16, self.lo()) | (@as(u16, self.hi()) << 8);
    }

    fn absoluteX(self: *CPU) u16 {
        return (self.absolute() + self.x) & 0xffff;
    }

    fn setFlags(self: *CPU, data: u8) void {
        if (data == 0) {
            self.flags = (self.flags & ~@as(u8, 0x80)) | 0x02;
        } else {
            self.flags = (self.flags & ~@as(u8, (0x80 | 0x02))) | (data & 0x80);
        }
    }

    fn adc(self: *CPU, data: u8) void {
        const carry: u8 = self.flags & 0x01;
        const temp: u16 = @as(u16, data) + @as(u16, self.a) + @as(u16, carry);
        self.setFlags(@truncate(temp));
        self.a = @truncate(temp);
    }

    fn sbc(self: *CPU, data: u8) void {
        const carry: u8 = (self.flags & 0x01) ^ 0x01;
        const temp: u16 = @as(u16, self.a) - @as(u16, data) - @as(u16, carry);
        self.setFlags(@truncate(temp));
        self.a = @truncate(temp);
    }

    fn cmp(self: *CPU, src: u8, data: u8) void {
        const temp = src - data;
        self.flags = (self.flags & ~(@as(u8, 0x01 | 0x80 | 0x02))) | (temp & 0x80);
        if (temp == 0) self.flags |= 0x02;
        if (src >= data) self.flags |= 0x01;
    }

    pub fn run(self: *CPU) void {
        while (true) {
            const op: u8 = self.fetch();
            self.cpucycles += 2; // Simplified cycle counting

            switch (op) {
                0x69 => {
                    self.adc(self.immediate());
                    self.pc += 1;
                },
                0xE9 => {
                    self.sbc(self.immediate());
                    self.pc += 1;
                },
                0xC9 => {
                    self.cmp(self.a, self.immediate());
                    self.pc += 1;
                },
                0xE0 => {
                    self.cmp(self.x, self.immediate());
                    self.pc += 1;
                },
                0xC0 => {
                    self.cmp(self.y, self.immediate());
                    self.pc += 1;
                },
                else => std.debug.print("Unknown opcode {x}\n", .{op}),
            }
        }
    }
};
