const std = @import("std"); // for printing status

const SIDBase = 0xD400;
const FramesPerVsyncPAL = 19656;
const FramesPerVsyncNTSC = 17734;

pub const CPU = struct {
    allocator: std.mem.Allocator,

    PC: u16,
    SP: u8,
    A: u8,
    X: u8,
    Y: u8,
    Status: u8,
    Flags: CPUFlags,
    mem: MEM64K,
    cycles_executed: u32,
    cycles_last_step: u32,
    opcode_last: u8,
    frame_ctr_PAL: u32,
    frame_ctr_NTSC: u32,
    sid_reg_written: bool,
    ext_sid_reg_written: bool,
    dbg_enabled: bool,
    sid_dbg_enabled: bool,

    pub const MEM64K = struct {
        Data: [0x10000]u8,

        pub fn clear(self: *MEM64K) void {
            for (0..0x10000) |i| {
                self.Data[i] = 0x00;
            }
        }
    };

    const CPUFlags = struct {
        C: u1,
        Z: u1,
        I: u1,
        D: u1,
        B: u1,
        Unused: u1,
        V: u1,
        N: u1,
    };

    const FB_Negative = 0b10000000;
    const FB_Overflow = 0b01000000;
    const FB_Unused = 0b000100000;
    const FB_Break = 0b000010000;
    const FB_Decimal = 0b000001000;
    const FB_InterruptDisable = 0b000000100;
    const FB_Zero = 0b000000010;
    const FB_Carry = 0b000000001;

    const stdout = std.io.getStdOut().writer();

    pub fn Init(allocator: std.mem.Allocator, PC_init: u16) CPU {
        return CPU{
            .PC = PC_init,
            .SP = 0xFF,
            .A = 0,
            .X = 0,
            .Y = 0,
            .Status = 0x24, // Default status flags (Interrupt disable set)
            .Flags = CPUFlags{
                .C = 0,
                .Z = 0,
                .I = 1, // Interrupt Disable set on boot
                .D = 0,
                .B = 0,
                .Unused = 1, // Always 1 in 6502
                .V = 0,
                .N = 0,
            },
            .mem = MEM64K{ .Data = [_]u8{0} ** 65536 }, // Clear memory
            .cycles_executed = 0,
            .cycles_last_step = 0,
            .opcode_last = 0x00, // No opcode executed yet
            .sid_reg_written = false,
            .ext_sid_reg_written = false,
            .frame_ctr_PAL = 0,
            .frame_ctr_NTSC = 0,
            .dbg_enabled = false,
            .sid_dbg_enabled = false,
            .allocator = allocator,
        };
    }

    pub fn Reset(cpu: *CPU) void {
        // leaves memory unchanged
        cpu.A = 0;
        cpu.X = 0;
        cpu.Y = 0;
        cpu.SP = 0xFD;
        cpu.Status = 0x24;
        cpu.PC = 0xFFFC;
        cpu.Flags = CPUFlags{
            .C = 0,
            .Z = 0,
            .I = 1,
            .D = 0,
            .B = 0,
            .Unused = 1,
            .V = 0,
            .N = 0,
        };

        cpu.cycles_executed = 0;
        cpu.cycles_last_step = 0;
        cpu.opcode_last = 0x00;
    }

    // Reset CPU and clear memory
    pub fn HardReset(cpu: *CPU) void {
        cpu.Reset();
        cpu.mem.clear();
    }

    pub fn RunPALFrames(cpu: *CPU, frame_count: u32) u32 {
        var frames_now = cpu.frame_ctr_PAL;
        var frames_executed: u32 = 0;

        while (cpu.RunStep() != 0) {
            if (cpu.frame_ctr_PAL > frames_now) frames_executed += 1;
            if (frames_executed == frame_count) break;
            frames_now = cpu.frame_ctr_PAL;
        }
        return frames_executed;
    }

    pub fn RunNTSCFrames(cpu: *CPU, frame_count: u32) u32 {
        var frames_now = cpu.frame_ctr_NTSC;
        var frames_executed = 0;

        while (cpu.RunStep() != 0) {
            if (cpu.frame_ctr_NTSC > frames_now) frames_executed += 1;
            if (frames_executed == frame_count) break;
            frames_now = cpu.frame_ctr_NTSC;
        }
        return frames_executed;
    }

    pub fn Call(cpu: *CPU, Address: u16) void {
        cpu.PC = Address;
        cpu.ext_sid_reg_written = false;
        while (cpu.RunStep() != 0) {}
    }

    pub fn LoadPrg(cpu: *CPU, Filename: []const u8, setPC: bool) !u16 {
        var file = try std.fs.cwd().openFile(Filename, .{});
        defer file.close();

        const stat = try file.stat();
        const file_size = stat.size;

        const buffer = try cpu.allocator.alloc(u8, file_size);

        _ = try file.readAll(buffer);

        return SetPrg(cpu, buffer, setPC);
    }

    pub fn SetPrg(cpu: *CPU, Program: []const u8, setPC: bool) u16 {
        var LoadAddress: u16 = 0;
        if ((Program.len != 0) and (Program.len > 2)) {
            var offs: u32 = 0;
            const Lo: u16 = Program[offs];
            offs += 1;
            const Hi: u16 = @as(u16, Program[offs]) << 8;
            offs += 1;
            LoadAddress = @as(u16, Lo) | @as(u16, Hi);

            var i: u16 = LoadAddress;
            while (i < (LoadAddress +% Program.len -% 2)) : (i +%= 1) {
                cpu.mem.Data[i] = Program[offs];
                offs += 1;
            }
        }
        if (setPC) cpu.PC = LoadAddress;
        return LoadAddress;
    }

    pub fn WriteMem(cpu: *CPU, data: []const u8, Address: u16) void {
        var offs: u32 = 0;
        var i: u16 = Address;
        while (offs < data.len) : (i +%= 1) {
            cpu.mem.Data[i] = data[offs];
            offs += 1;
        }
    }

    pub fn PrintStatus(cpu: *CPU) void {
        stdout.print("[CPU ] PC: {X:0>4} | A: {X:0>2} | X: {X:0>2} | Y: {X:0>2} | Last Opc: {X:0>2} | Last Cycl: {d} | Cycl-TT: {d} | ", .{
            cpu.PC,
            cpu.A,
            cpu.X,
            cpu.Y,
            cpu.opcode_last,
            cpu.cycles_last_step,
            cpu.cycles_executed,
        }) catch {};
        PrintFlags(cpu);
        stdout.print("\n", .{}) catch {};
    }

    pub fn PrintFlags(cpu: *CPU) void {
        cpu.CPU_FlagsToPS();
        stdout.print("F: {b:0>8}", .{cpu.Status}) catch {};
    }

    pub fn ReadByte(cpu: *CPU, Address: u16) u8 {
        cpu.cycles_executed +%= 1;
        return cpu.mem.Data[Address];
    }

    pub fn ReadWord(cpu: *CPU, Address: u16) u16 {
        const LoByte: u8 = ReadByte(cpu, Address);
        const HiByte: u8 = ReadByte(cpu, Address + 1);
        return @as(u16, LoByte) | (@as(u16, HiByte) << 8);
    }

    pub fn WriteByte(cpu: *CPU, Value: u8, Address: u16) void {
        if ((Address >= SIDBase) and (Address <= (SIDBase + 25))) {
            cpu.sid_reg_written = true;
            // ext flag only when value changed
            if (cpu.mem.Data[Address] != Value) {
                cpu.ext_sid_reg_written = true;
            }
        }
        cpu.mem.Data[Address] = Value;
        cpu.cycles_executed +%= 1;
    }

    pub fn WriteWord(cpu: *CPU, Value: u16, Address: u16) void {
        cpu.mem.Data[Address] = @truncate(Value & 0xFF);
        cpu.mem.Data[Address + 1] = @truncate(Value >> 8);
        cpu.cycles_executed +%= 2;
    }

    pub fn SIDRegWritten(cpu: *CPU) bool {
        return cpu.sid_reg_written;
    }

    pub fn GetSIDRegisters(cpu: *CPU) [25]u8 {
        var sid_registers: [25]u8 = undefined;
        @memcpy(&sid_registers, cpu.mem.Data[SIDBase .. SIDBase + 25]);
        return sid_registers;
    }

    pub fn PrintSIDRegisters(cpu: *CPU) void {
        stdout.print("[CPU ] SID Registers: ", .{}) catch {};
        const sid_registers = cpu.GetSIDRegisters();
        for (sid_registers) |v| {
            stdout.print("{X:0>2} ", .{v}) catch {};
        }
        stdout.print("\n", .{}) catch {};
    }

    fn CPU_FlagsToPS(cpu: *CPU) void {
        var ps: u8 = 0;
        if (cpu.Flags.Unused != 0) {
            ps |= FB_Unused;
        }
        if (cpu.Flags.C != 0) {
            ps |= FB_Carry;
        }
        if (cpu.Flags.Z != 0) {
            ps |= FB_Zero;
        }
        if (cpu.Flags.I != 0) {
            ps |= FB_InterruptDisable;
        }
        if (cpu.Flags.D != 0) {
            ps |= FB_Decimal;
        }
        if (cpu.Flags.B != 0) {
            ps |= FB_Break;
        }
        if (cpu.Flags.V != 0) {
            ps |= FB_Overflow;
        }
        if (cpu.Flags.N != 0) {
            ps |= FB_Negative;
        }
        cpu.Status = ps;
    }

    fn CPU_PSToFlags(cpu: *CPU) void {
        cpu.Flags.Unused = @intFromBool((cpu.Status & FB_Unused) != 0);
        cpu.Flags.C = @intFromBool((cpu.Status & FB_Carry) != 0);
        cpu.Flags.Z = @intFromBool((cpu.Status & FB_Zero) != 0);
        cpu.Flags.I = @intFromBool((cpu.Status & FB_InterruptDisable) != 0);
        cpu.Flags.D = @intFromBool((cpu.Status & FB_Decimal) != 0);
        cpu.Flags.B = @intFromBool((cpu.Status & FB_Break) != 0);
        cpu.Flags.V = @intFromBool((cpu.Status & FB_Overflow) != 0);
        cpu.Flags.N = @intFromBool((cpu.Status & FB_Negative) != 0);
    }

    fn CPU_FetchByte(cpu: *CPU) i8 {
        return @as(i8, @bitCast(CPU_FetchUByte(cpu)));
    }

    fn CPU_FetchUByte(cpu: *CPU) u8 {
        const Data: u8 = cpu.mem.Data[cpu.PC];
        cpu.PC +%= 1;
        cpu.cycles_executed +%= 1;
        return Data;
    }

    fn CPU_FetchWord(cpu: *CPU) u16 {
        var Data: u16 = cpu.mem.Data[cpu.PC];
        cpu.PC +%= 1;
        Data |= @as(u16, cpu.mem.Data[cpu.PC]) << 8;
        cpu.PC +%= 1;
        cpu.cycles_executed +%= 2;
        return Data;
    }

    fn CPU_SPToAddress(cpu: *CPU) u16 {
        return @as(u16, cpu.SP) | 0x100;
    }

    fn CPU_PushWordToStack(cpu: *CPU, Value: u16) void {
        WriteByte(cpu, @truncate(Value >> 8), CPU_SPToAddress(cpu));
        cpu.SP -%= 1;
        WriteByte(cpu, @truncate(Value & 0xff), CPU_SPToAddress(cpu));
        cpu.SP -%= 1;
    }

    fn CPU_PushPCToStack(cpu: *CPU) void {
        CPU_PushWordToStack(cpu, cpu.PC);
    }

    fn CPU_PushByteOntoStack(cpu: *CPU, Value: u8) void {
        const SPWord: u16 = CPU_SPToAddress(cpu);
        cpu.mem.Data[SPWord] = Value;
        cpu.cycles_executed +%= 1;
        cpu.SP -%= 1;
        cpu.cycles_executed +%= 1;
    }

    fn CPU_PopByteFromStack(cpu: *CPU) u8 {
        cpu.SP +%= 1;
        cpu.cycles_executed +%= 1;
        const SPWord: u16 = CPU_SPToAddress(cpu);
        const Value: u8 = cpu.mem.Data[SPWord];
        cpu.cycles_executed +%= 1;
        return Value;
    }

    fn CPU_PopWordFromStack(cpu: *CPU) u16 {
        const ValueFromStack: u16 = ReadWord(cpu, CPU_SPToAddress(cpu) + 1);
        cpu.SP +%= 2;
        cpu.cycles_executed +%= 1;
        return ValueFromStack;
    }

    fn CPU_UpdateFlags(cpu: *CPU, Register: u8) void {
        cpu.Flags.Z = 0;
        if (Register == 0) cpu.Flags.Z = 1;
        cpu.Flags.N = 0;
        if ((Register & FB_Negative) != 0) cpu.Flags.N = 1;
    }

    fn CPU_LoadRegister(cpu: *CPU, Address: u16, Register: *u8) void {
        Register.* = ReadByte(cpu, Address);
        CPU_UpdateFlags(cpu, Register.*);
    }

    fn CPU_And(cpu: *CPU, Address: u16) void {
        cpu.A &= ReadByte(cpu, Address);
        CPU_UpdateFlags(cpu, cpu.A);
    }

    fn CPU_Ora(cpu: *CPU, Address: u16) void {
        cpu.A |= ReadByte(cpu, Address);
        CPU_UpdateFlags(cpu, cpu.A);
    }

    fn CPU_Xor(cpu: *CPU, Address: u16) void {
        cpu.A ^= ReadByte(cpu, Address);
        CPU_UpdateFlags(cpu, cpu.A);
    }

    fn CPU_Branch(cpu: *CPU, Test: u8, Expected: u8) void {
        const offs: i8 = CPU_FetchByte(cpu);
        if (Test == Expected) {
            const PCOld: u16 = cpu.PC;
            var sPC = @as(i32, cpu.PC);
            sPC += @as(i32, offs);
            const uPC = @as(u32, @bitCast(sPC));
            cpu.PC = @as(u16, @truncate(uPC));
            cpu.cycles_executed +%= 1;
            if ((cpu.PC >> 8) != (PCOld >> 8)) {
                cpu.cycles_executed +%= 1;
            }
        }
    }

    fn CPU_ADC(cpu: *CPU, Operand: u8) void {
        const AreSignBitsTheSame: bool = ((cpu.A ^ Operand) & FB_Negative) == 0;
        var Sum: u16 = @as(u16, @bitCast(@as(u16, cpu.A)));
        Sum +%= @as(u16, Operand);
        Sum +%= @as(u16, cpu.Flags.C);
        cpu.A = @as(u8, @truncate(Sum & 0xff));
        CPU_UpdateFlags(cpu, cpu.A);
        cpu.Flags.C = @intFromBool(Sum > 0xff);
        const x: bool = AreSignBitsTheSame and (((cpu.A ^ Operand) & FB_Negative) == 0);
        cpu.Flags.V = @intFromBool(x);
    }

    fn CPU_SBC(cpu: *CPU, Operand: u8) void {
        CPU_ADC(cpu, ~Operand);
    }

    fn CPU_ASL(cpu: *CPU, Operand: u8) u8 {
        cpu.Flags.C = @as(u1, @intFromBool(Operand & FB_Negative > 0));
        const Result: u8 = Operand << 1;
        CPU_UpdateFlags(cpu, Result);
        cpu.cycles_executed +%= 1;
        return Result;
    }

    fn CPU_LSR(cpu: *CPU, Operand: u8) u8 {
        cpu.Flags.C = @as(u1, @intFromBool(Operand & FB_Carry > 0));
        const Result: u8 = Operand >> 1;
        CPU_UpdateFlags(cpu, Result);
        cpu.cycles_executed +%= 1;
        return Result;
    }

    fn CPU_ROL(cpu: *CPU, Operand: u8) u8 {
        const OldCarry: u8 = cpu.Flags.C;
        cpu.Flags.C = @intFromBool((Operand & FB_Negative) != 0); // Store bit 7 in Carry flag
        const Result: u8 = (Operand << 1) | OldCarry; // Rotate left, inserting old Carry
        CPU_UpdateFlags(cpu, Result);
        cpu.cycles_executed +%= 1;
        return Result;
    }

    fn CPU_ROR(cpu: *CPU, Operand: u8) u8 {
        const OldCarry: u8 = cpu.Flags.C; // Store the old carry bit before shifting
        cpu.Flags.C = @intFromBool((Operand & FB_Carry) != 0); // Store bit 0 in Carry flag
        const Result: u8 = (Operand >> 1) | (OldCarry << 7); // Rotate right, inserting old Carry
        CPU_UpdateFlags(cpu, Result);
        cpu.cycles_executed +%= 1;
        return Result;
    }

    fn CPU_PushPSToStack(cpu: *CPU) void {
        CPU_FlagsToPS(cpu);
        const PSStack: u8 = cpu.Status | FB_Break | FB_Unused;
        CPU_PushByteOntoStack(cpu, @as(u8, @bitCast(PSStack)));
    }

    fn CPU_PopPSFromStack(cpu: *CPU) void {
        cpu.Status = CPU_PopByteFromStack(cpu);
        CPU_PSToFlags(cpu);
        cpu.Flags.B = 0;
        cpu.Flags.Unused = 0;
    }

    fn CPU_AddrZeroPage(cpu: *CPU) u16 {
        const ZeroPageAddr = CPU_FetchUByte(cpu);
        return @as(u16, ZeroPageAddr);
    }

    fn CPU_AddrZeroPageX(cpu: *CPU) u16 {
        var ZeroPageAddr: u8 = CPU_FetchUByte(cpu);
        ZeroPageAddr +%= cpu.X;
        cpu.cycles_executed +%= 1;
        return @as(u16, ZeroPageAddr);
    }

    fn CPU_AddrZeroPageY(cpu: *CPU) u16 {
        var ZeroPageAddr: u8 = CPU_FetchUByte(cpu);
        ZeroPageAddr +%= cpu.Y;
        cpu.cycles_executed +%= 1;
        return @as(u16, ZeroPageAddr);
    }

    fn CPU_AddrAbsolute(cpu: *CPU) u16 {
        const AbsAddress: u16 = CPU_FetchWord(cpu);
        return AbsAddress;
    }

    fn CPU_AddrAbsoluteX(cpu: *CPU) u16 {
        const AbsAddress: u16 = CPU_FetchWord(cpu);
        const AbsAddressX: u16 = AbsAddress + cpu.X;
        const CrossedPageBoundary: u16 = (AbsAddress ^ AbsAddressX) >> 8;
        if (CrossedPageBoundary != 0) {
            cpu.cycles_executed +%= 1;
        }
        return AbsAddressX;
    }

    pub export fn CPU_AddrAbsoluteX_5(cpu: *CPU) u16 {
        const AbsAddress: u16 = CPU_FetchWord(cpu);
        const AbsAddressX: u16 = AbsAddress + cpu.X;
        cpu.cycles_executed +%= 1;
        return AbsAddressX;
    }

    fn CPU_AddrAbsoluteY(cpu: *CPU) u16 {
        const AbsAddress: u16 = CPU_FetchWord(cpu);
        const AbsAddressY: u16 = AbsAddress + cpu.Y;
        const CrossedPageBoundary: u16 = (AbsAddress ^ AbsAddressY) >> 8;
        if (CrossedPageBoundary != 0) {
            cpu.cycles_executed +%= 1;
        }
        return AbsAddressY;
    }

    fn CPU_AddrAbsoluteY_5(cpu: *CPU) u16 {
        const AbsAddress: u16 = CPU_FetchWord(cpu);
        const AbsAddressY: u16 = AbsAddress + cpu.Y;
        cpu.cycles_executed +%= 1;
        return AbsAddressY;
    }

    fn CPU_AddrIndirectX(cpu: *CPU) u16 {
        var ZPAddress: u8 = CPU_FetchUByte(cpu);
        ZPAddress +%= cpu.X;
        cpu.cycles_executed +%= 1;
        const EffectiveAddr: u16 = ReadWord(cpu, ZPAddress);
        return EffectiveAddr;
    }

    fn CPU_AddrIndirectY(cpu: *CPU) u16 {
        const ZPAddress: u8 = CPU_FetchUByte(cpu);
        const EffectiveAddr: u16 = ReadWord(cpu, ZPAddress);
        const EffectiveAddrY: u16 = EffectiveAddr + cpu.Y;
        const CrossedPageBoundary: u16 = (EffectiveAddr ^ EffectiveAddrY) >> 8;
        if (CrossedPageBoundary != 0) {
            cpu.cycles_executed +%= 1;
        }
        return EffectiveAddrY;
    }

    fn CPU_AddrIndirectY_6(cpu: *CPU) u16 {
        const ZPAddress: u8 = CPU_FetchUByte(cpu);
        const EffectiveAddr: u16 = ReadWord(cpu, ZPAddress);
        const EffectiveAddrY: u16 = EffectiveAddr + cpu.Y;
        return EffectiveAddrY;
    }

    fn CPU_RegisterCompare(cpu: *CPU, Operand: u8, RegisterValue: u8) void {
        const Temp: i8 = @as(i8, @bitCast(RegisterValue -% Operand));
        cpu.Flags.N = @intFromBool((@as(u8, @bitCast(Temp)) & FB_Negative) != 0);
        cpu.Flags.Z = @intFromBool(RegisterValue == Operand);
        cpu.Flags.C = @intFromBool(RegisterValue >= Operand);
    }

    pub fn EmulateD012(cpu: *CPU) void {
        cpu.mem.Data[0xD012] = cpu.mem.Data[0xD012] +% 1;
        if ((cpu.mem.Data[0xD012] == 0) or (((cpu.mem.Data[0xD011] & 0x80) != 0) and
            (cpu.mem.Data[0xD012] >= 0x38)))
        {
            cpu.mem.Data[0xD011] ^= 0x80;
            cpu.mem.Data[0xD012] = 0x00;
        }
    }

    pub fn RunStep(cpu: *CPU) u8 {
        const cycles_now: u32 = cpu.cycles_executed;
        const opcode: u8 = CPU_FetchUByte(cpu);
        cpu.opcode_last = opcode;
        cpu.sid_reg_written = false;

        cpu.EmulateD012();

        switch (opcode) {
            41 => {
                cpu.A &= CPU_FetchUByte(cpu);
                CPU_UpdateFlags(cpu, cpu.A);
            },
            9 => {
                cpu.A |= CPU_FetchUByte(cpu);
                CPU_UpdateFlags(cpu, cpu.A);
            },
            73 => {
                cpu.A ^= CPU_FetchUByte(cpu);
                CPU_UpdateFlags(cpu, cpu.A);
            },
            37 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    CPU_And(cpu, Address);
                }
            },
            5 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    CPU_Ora(cpu, Address);
                }
            },
            69 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    CPU_Xor(cpu, Address);
                }
            },
            53 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    CPU_And(cpu, Address);
                }
            },
            21 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    CPU_Ora(cpu, Address);
                }
            },
            85 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    CPU_Xor(cpu, Address);
                }
            },
            45 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    CPU_And(cpu, Address);
                }
            },
            13 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    CPU_Ora(cpu, Address);
                }
            },
            77 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    CPU_Xor(cpu, Address);
                }
            },
            61 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX(cpu);
                    CPU_And(cpu, Address);
                }
            },
            29 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX(cpu);
                    CPU_Ora(cpu, Address);
                }
            },
            93 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX(cpu);
                    CPU_Xor(cpu, Address);
                }
            },
            57 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteY(cpu);
                    CPU_And(cpu, Address);
                }
            },
            25 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteY(cpu);
                    CPU_Ora(cpu, Address);
                }
            },
            89 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteY(cpu);
                    CPU_Xor(cpu, Address);
                }
            },
            33 => {
                {
                    const Address: u16 = CPU_AddrIndirectX(cpu);
                    CPU_And(cpu, Address);
                }
            },
            1 => {
                {
                    const Address: u16 = CPU_AddrIndirectX(cpu);
                    CPU_Ora(cpu, Address);
                }
            },
            65 => {
                {
                    const Address: u16 = CPU_AddrIndirectX(cpu);
                    CPU_Xor(cpu, Address);
                }
            },
            49 => {
                {
                    const Address: u16 = CPU_AddrIndirectY(cpu);
                    CPU_And(cpu, Address);
                }
            },
            17 => {
                {
                    const Address: u16 = CPU_AddrIndirectY(cpu);
                    CPU_Ora(cpu, Address);
                }
            },
            81 => {
                {
                    const Address: u16 = CPU_AddrIndirectY(cpu);
                    CPU_Xor(cpu, Address);
                }
            },
            36 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    const Value: u8 = ReadByte(cpu, Address);
                    cpu.Flags.Z = @intFromBool(!((cpu.A & Value) != 0));
                    cpu.Flags.N = @intFromBool((Value & 128) != 0);
                    cpu.Flags.V = @intFromBool((Value & 64) != 0);
                }
            },
            44 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    const Value: u8 = ReadByte(cpu, Address);
                    cpu.Flags.Z = @intFromBool(!((cpu.A & Value) != 0));
                    cpu.Flags.N = @intFromBool((Value & 128) != 0);
                    cpu.Flags.V = @intFromBool((Value & 64) != 0);
                }
            },
            169 => {
                {
                    cpu.A = CPU_FetchUByte(cpu);
                    CPU_UpdateFlags(cpu, cpu.A);
                }
            },
            162 => {
                {
                    cpu.X = CPU_FetchUByte(cpu);
                    CPU_UpdateFlags(cpu, cpu.X);
                }
            },
            160 => {
                {
                    cpu.Y = CPU_FetchUByte(cpu);
                    CPU_UpdateFlags(cpu, cpu.Y);
                }
            },
            165 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.A);
                }
            },
            166 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.X);
                }
            },
            182 => {
                {
                    const Address: u16 = CPU_AddrZeroPageY(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.X);
                }
            },
            164 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.Y);
                }
            },
            181 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.A);
                }
            },
            180 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.Y);
                }
            },
            173 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.A);
                }
            },
            174 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.X);
                }
            },
            172 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.Y);
                }
            },
            189 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.A);
                }
            },
            188 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.Y);
                }
            },
            185 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteY(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.A);
                }
            },
            190 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteY(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.X);
                }
            },
            161 => {
                {
                    const Address: u16 = CPU_AddrIndirectX(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.A);
                }
            },
            129 => {
                {
                    const Address: u16 = CPU_AddrIndirectX(cpu);
                    WriteByte(cpu, cpu.A, Address);
                }
            },
            177 => {
                {
                    const Address: u16 = CPU_AddrIndirectY(cpu);
                    CPU_LoadRegister(cpu, Address, &cpu.A);
                }
            },
            145 => {
                {
                    const Address: u16 = CPU_AddrIndirectY_6(cpu);
                    WriteByte(cpu, cpu.A, Address);
                }
            },
            133 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    WriteByte(cpu, cpu.A, Address);
                }
            },
            134 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    WriteByte(cpu, cpu.X, Address);
                }
            },
            150 => {
                {
                    const Address: u16 = CPU_AddrZeroPageY(cpu);
                    WriteByte(cpu, cpu.X, Address);
                }
            },
            132 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    WriteByte(cpu, cpu.Y, Address);
                }
            },
            141 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    WriteByte(cpu, cpu.A, Address);
                }
            },
            142 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    WriteByte(cpu, cpu.X, Address);
                }
            },
            140 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    WriteByte(cpu, cpu.Y, Address);
                }
            },
            149 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    WriteByte(cpu, cpu.A, Address);
                }
            },
            148 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    WriteByte(cpu, cpu.Y, Address);
                }
            },
            157 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX_5(cpu);
                    WriteByte(cpu, cpu.A, Address);
                }
            },
            153 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteY_5(cpu);
                    WriteByte(cpu, cpu.A, Address);
                }
            },
            32 => {
                {
                    const SubAddr: u16 = CPU_FetchWord(cpu);
                    CPU_PushWordToStack(cpu, cpu.PC - 1);
                    cpu.PC = SubAddr;
                    cpu.cycles_executed +%= 1;
                }
            },
            96 => {
                {
                    const ReturnAddress: u16 = CPU_PopWordFromStack(cpu);
                    cpu.PC = ReturnAddress + 1;
                    cpu.cycles_executed +%= 2;
                }
            },
            76 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    cpu.PC = Address;
                }
            },
            108 => {
                {
                    var Address: u16 = CPU_AddrAbsolute(cpu);
                    Address = ReadWord(cpu, Address);
                    cpu.PC = Address;
                }
            },
            186 => {
                {
                    cpu.X = cpu.SP;
                    cpu.cycles_executed +%= 1;
                    CPU_UpdateFlags(cpu, cpu.X);
                }
            },
            154 => {
                {
                    cpu.SP = cpu.X;
                    cpu.cycles_executed +%= 1;
                }
            },
            72 => {
                {
                    CPU_PushByteOntoStack(cpu, cpu.A);
                }
            },
            104 => {
                {
                    cpu.A = CPU_PopByteFromStack(cpu);
                    CPU_UpdateFlags(cpu, cpu.A);
                    cpu.cycles_executed +%= 1;
                }
            },
            8 => {
                {
                    CPU_PushPSToStack(cpu);
                }
            },
            40 => {
                {
                    CPU_PopPSFromStack(cpu);
                    cpu.cycles_executed +%= 1;
                }
            },
            170 => {
                {
                    cpu.X = cpu.A;
                    cpu.cycles_executed +%= 1;
                    CPU_UpdateFlags(cpu, cpu.X);
                }
            },
            168 => {
                {
                    cpu.Y = cpu.A;
                    cpu.cycles_executed +%= 1;
                    CPU_UpdateFlags(cpu, cpu.Y);
                }
            },
            138 => {
                {
                    cpu.A = cpu.X;
                    cpu.cycles_executed +%= 1;
                    CPU_UpdateFlags(cpu, cpu.A);
                }
            },
            152 => {
                {
                    cpu.A = cpu.Y;
                    cpu.cycles_executed +%= 1;
                    CPU_UpdateFlags(cpu, cpu.A);
                }
            },
            232 => {
                {
                    cpu.X +%= 1;
                    cpu.cycles_executed +%= 1;
                    CPU_UpdateFlags(cpu, cpu.X);
                }
            },
            200 => {
                {
                    cpu.Y +%= 1;
                    cpu.cycles_executed +%= 1;
                    CPU_UpdateFlags(cpu, cpu.Y);
                }
            },
            202 => {
                {
                    cpu.X -%= 1;
                    cpu.cycles_executed +%= 1;
                    CPU_UpdateFlags(cpu, cpu.X);
                }
            },
            136 => {
                {
                    cpu.Y -%= 1;
                    cpu.cycles_executed +%= 1;
                    CPU_UpdateFlags(cpu, cpu.Y);
                }
            },
            198 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    var Value: u8 = ReadByte(cpu, Address);
                    Value -%= 1;
                    cpu.cycles_executed +%= 1;
                    WriteByte(cpu, Value, Address);
                    CPU_UpdateFlags(cpu, Value);
                }
            },
            214 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    var Value: u8 = ReadByte(cpu, Address);
                    Value -%= 1;
                    cpu.cycles_executed +%= 1;
                    WriteByte(cpu, Value, Address);
                    CPU_UpdateFlags(cpu, Value);
                }
            },
            206 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    var Value: u8 = ReadByte(cpu, Address);
                    Value -%= 1;
                    cpu.cycles_executed +%= 1;
                    WriteByte(cpu, Value, Address);
                    CPU_UpdateFlags(cpu, Value);
                }
            },
            222 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX_5(cpu);
                    var Value: u8 = ReadByte(cpu, Address);
                    Value -%= 1;
                    cpu.cycles_executed +%= 1;
                    WriteByte(cpu, Value, Address);
                    CPU_UpdateFlags(cpu, Value);
                }
            },
            230 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    var Value: u8 = ReadByte(cpu, Address);
                    Value +%= 1;
                    cpu.cycles_executed +%= 1;
                    WriteByte(cpu, Value, Address);
                    CPU_UpdateFlags(cpu, Value);
                }
            },
            246 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    var Value: u8 = ReadByte(cpu, Address);
                    Value +%= 1;
                    cpu.cycles_executed +%= 1;
                    WriteByte(cpu, Value, Address);
                    CPU_UpdateFlags(cpu, Value);
                }
            },
            238 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    var Value: u8 = ReadByte(cpu, Address);
                    Value +%= 1;
                    cpu.cycles_executed +%= 1;
                    WriteByte(cpu, Value, Address);
                    CPU_UpdateFlags(cpu, Value);
                }
            },
            254 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX_5(cpu);
                    var Value: u8 = ReadByte(cpu, Address);
                    Value +%= 1;
                    cpu.cycles_executed +%= 1;
                    WriteByte(cpu, Value, Address);
                    CPU_UpdateFlags(cpu, Value);
                }
            },
            240 => {
                {
                    CPU_Branch(cpu, @as(u8, cpu.Flags.Z), 1);
                }
            },
            208 => {
                {
                    CPU_Branch(cpu, @as(u8, cpu.Flags.Z), 0);
                }
            },
            176 => {
                {
                    CPU_Branch(cpu, @as(u8, cpu.Flags.C), 1);
                }
            },
            144 => {
                {
                    CPU_Branch(cpu, @as(u8, cpu.Flags.C), 0);
                }
            },
            48 => {
                {
                    CPU_Branch(cpu, @as(u8, cpu.Flags.N), 1);
                }
            },
            16 => {
                {
                    CPU_Branch(cpu, @as(u8, cpu.Flags.N), 0);
                }
            },
            80 => {
                {
                    CPU_Branch(cpu, @as(u8, cpu.Flags.V), 0);
                }
            },
            112 => {
                {
                    CPU_Branch(cpu, @as(u8, cpu.Flags.V), 1);
                }
            },
            24 => {
                {
                    cpu.Flags.C = 0;
                    cpu.cycles_executed +%= 1;
                }
            },
            56 => {
                {
                    cpu.Flags.C = 1;
                    cpu.cycles_executed +%= 1;
                }
            },
            216 => {
                {
                    cpu.Flags.D = 0;
                    cpu.cycles_executed +%= 1;
                }
            },
            248 => {
                {
                    cpu.Flags.D = 1;
                    cpu.cycles_executed +%= 1;
                }
            },
            88 => {
                {
                    cpu.Flags.I = 0;
                    cpu.cycles_executed +%= 1;
                }
            },
            120 => {
                {
                    cpu.Flags.I = 1;
                    cpu.cycles_executed +%= 1;
                }
            },
            184 => {
                {
                    cpu.Flags.V = 0;
                    cpu.cycles_executed +%= 1;
                }
            },
            234 => {
                {
                    cpu.cycles_executed +%= 1;
                }
            },
            109 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_ADC(cpu, Operand);
                }
            },
            125 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_ADC(cpu, Operand);
                }
            },
            121 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteY(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_ADC(cpu, Operand);
                }
            },
            101 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_ADC(cpu, Operand);
                }
            },
            117 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_ADC(cpu, Operand);
                }
            },
            97 => {
                {
                    const Address: u16 = CPU_AddrIndirectX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_ADC(cpu, Operand);
                }
            },
            113 => {
                {
                    const Address: u16 = CPU_AddrIndirectY(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_ADC(cpu, Operand);
                }
            },
            105 => {
                {
                    const Operand: u8 = CPU_FetchUByte(cpu);
                    CPU_ADC(cpu, Operand);
                }
            },
            233 => {
                {
                    const Operand: u8 = CPU_FetchUByte(cpu);
                    CPU_SBC(cpu, Operand);
                }
            },
            237 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_SBC(cpu, Operand);
                }
            },
            229 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_SBC(cpu, Operand);
                }
            },
            245 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_SBC(cpu, Operand);
                }
            },
            253 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_SBC(cpu, Operand);
                }
            },
            249 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteY(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_SBC(cpu, Operand);
                }
            },
            225 => {
                {
                    const Address: u16 = CPU_AddrIndirectX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_SBC(cpu, Operand);
                }
            },
            241 => {
                {
                    const Address: u16 = CPU_AddrIndirectY(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_SBC(cpu, Operand);
                }
            },
            224 => {
                {
                    const Operand: u8 = CPU_FetchUByte(cpu);
                    CPU_RegisterCompare(cpu, Operand, cpu.X);
                }
            },
            192 => {
                {
                    const Operand: u8 = CPU_FetchUByte(cpu);
                    CPU_RegisterCompare(cpu, Operand, cpu.Y);
                }
            },
            228 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_RegisterCompare(cpu, Operand, cpu.X);
                }
            },
            196 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_RegisterCompare(cpu, Operand, cpu.Y);
                }
            },
            236 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_RegisterCompare(cpu, Operand, cpu.X);
                }
            },
            204 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_RegisterCompare(cpu, Operand, cpu.Y);
                }
            },
            201 => {
                {
                    const Operand: u8 = CPU_FetchUByte(cpu);
                    CPU_RegisterCompare(cpu, Operand, cpu.A);
                }
            },
            197 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_RegisterCompare(cpu, Operand, cpu.A);
                }
            },
            213 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_RegisterCompare(cpu, Operand, cpu.A);
                }
            },
            205 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_RegisterCompare(cpu, Operand, cpu.A);
                }
            },
            221 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_RegisterCompare(cpu, Operand, cpu.A);
                }
            },
            217 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteY(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_RegisterCompare(cpu, Operand, cpu.A);
                }
            },
            193 => {
                {
                    const Address: u16 = CPU_AddrIndirectX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_RegisterCompare(cpu, Operand, cpu.A);
                }
            },
            209 => {
                {
                    const Address: u16 = CPU_AddrIndirectY(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    CPU_RegisterCompare(cpu, Operand, cpu.A);
                }
            },
            10 => {
                {
                    cpu.A = CPU_ASL(cpu, cpu.A);
                }
            },
            6 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_ASL(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            22 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_ASL(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            14 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_ASL(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            30 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX_5(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_ASL(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            74 => {
                {
                    cpu.A = CPU_LSR(cpu, cpu.A);
                }
            },
            70 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_LSR(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            86 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_LSR(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            78 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_LSR(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            94 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX_5(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_LSR(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            42 => {
                {
                    cpu.A = CPU_ROL(cpu, cpu.A);
                }
            },
            38 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_ROL(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            54 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_ROL(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            46 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_ROL(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            62 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX_5(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_ROL(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            106 => {
                {
                    cpu.A = CPU_ROR(cpu, cpu.A);
                }
            },
            102 => {
                {
                    const Address: u16 = CPU_AddrZeroPage(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_ROR(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            118 => {
                {
                    const Address: u16 = CPU_AddrZeroPageX(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_ROR(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            110 => {
                {
                    const Address: u16 = CPU_AddrAbsolute(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_ROR(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            126 => {
                {
                    const Address: u16 = CPU_AddrAbsoluteX_5(cpu);
                    const Operand: u8 = ReadByte(cpu, Address);
                    const Result: u8 = CPU_ROR(cpu, Operand);
                    WriteByte(cpu, Result, Address);
                }
            },
            0 => {
                {
                    CPU_PushWordToStack(cpu, cpu.PC + 1);
                    CPU_PushPSToStack(cpu);
                    cpu.PC = ReadWord(cpu, 65534);
                    cpu.Flags.B = 1;
                    cpu.Flags.I = 1;
                    return 0;
                }
            },
            64 => {
                {
                    CPU_PopPSFromStack(cpu);
                    cpu.PC = CPU_PopWordFromStack(cpu);
                }
            },
            else => return 0,
        }
        cpu.cycles_last_step = cpu.cycles_executed -% cycles_now;

        if (cpu.cycles_executed % FramesPerVsyncPAL == 0) cpu.frame_ctr_PAL += 1;
        if (cpu.cycles_executed % FramesPerVsyncNTSC == 0) cpu.frame_ctr_NTSC += 1;

        if (cpu.dbg_enabled) {
            cpu.PrintStatus();
        }

        if (cpu.sid_dbg_enabled and cpu.sid_reg_written) {
            cpu.PrintSIDRegisters();
        }

        return @as(u8, @truncate(cpu.cycles_last_step));
    }
};
