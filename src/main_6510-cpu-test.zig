const std = @import("std");
const CPU = @import("6510/6510.zig").CPU;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("[MAIN] Initializing CPU\n", .{});

    var cpu = CPU.Init(0x800);
    cpu.PrintStatus();

    try stdout.print("[MAIN] Writing program ...\n", .{});

    // 0800: A9 0A                       LDA #$0A        ; 2
    // 0802: AA                          TAX             ; 2
    // 0803: 69 1E                       ADC #$1E        ; 2 loop start:
    // 0805: 9D 00 D4                    STA $D400,X     ; 5 write SID register X
    // 0808: E8                          INX             ; 2
    // 0809: E0 19                       CPX #$19        ; 2
    // 080B: D0 F6                       BNE $0803       ; 2/3 loop
    // 080D: 60                          RTS             ; 6

    cpu.WriteByte(0xa9, 0x0800); //         LDA
    cpu.WriteByte(0x0a, 0x0801); //             #0A     ; 10
    cpu.WriteByte(0xaa, 0x0802); //         TAX
    cpu.WriteByte(0x69, 0x0803); //         ADC
    cpu.WriteByte(0x1e, 0x0804); //             #$1E
    cpu.WriteByte(0x9d, 0x0805); //         STA $
    cpu.WriteByte(0x00, 0x0806); //                00
    cpu.WriteByte(0xd4, 0x0807); //              D4
    cpu.WriteByte(0xe8, 0x0808); //         INX
    cpu.WriteByte(0xe0, 0x0809); //         CPX
    cpu.WriteByte(0x19, 0x080A); //             #19
    cpu.WriteByte(0xd0, 0x080B); //         BNE
    cpu.WriteByte(0xf6, 0x080C); //             $0803 (-10)
    cpu.WriteByte(0x60, 0x080D); //         RTS
    cpu.PrintStatus();

    try stdout.print("[MAIN] Executing program ...\n", .{});
    const SID_volume_old = cpu.GetSIDRegisters()[24];
    while (cpu.RunStep() != 0) {
        cpu.PrintStatus();
        if (cpu.SIDRegWritten()) {
            try stdout.print("[MAIN] SID register written!\n", .{});
            cpu.PrintSIDRegisters();

            const sid_registers = cpu.GetSIDRegisters();
            if (SID_volume_old != sid_registers[24])
                try stdout.print("[MAIN] SID volume changed: {X:0>2}\n", .{sid_registers[24]});
        }
    }

    cpu.HardReset();
}
