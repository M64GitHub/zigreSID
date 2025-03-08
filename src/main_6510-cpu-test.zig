const std = @import("std");
const CPU = @import("6510-emulator/6510-emulator.zig").CPU;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var cpu = CPU{};

    try stdout.print("Initializing CPU\n", .{});
    cpu.init(0x0800, 0x00, 0x00, 0x00);
    cpu.writeByte(0x0800, 0xa9); //         LDA
    cpu.writeByte(0x0801, 0x0a); //             #0A     ; 10
    cpu.writeByte(0x0802, 0xaa); //         TAX
    cpu.writeByte(0x0803, 0xe8); // LOOP:   INX
    cpu.writeByte(0x0804, 0xe0); //         CPX
    cpu.writeByte(0x0805, 0x14); //             #$14    ; 20
    cpu.writeByte(0x0806, 0xd0); //         BNE
    cpu.writeByte(0x0807, 0xfb); //             LOOP
    cpu.writeByte(0x0808, 0x60); //         RTS

    try stdout.print("Running CPU\n", .{});
    while (try cpu.run() != 0) {}

    try stdout.print("a: {d}\n", .{cpu.a});
    try stdout.print("x: {d}\n", .{cpu.x});

    std.debug.print("Execution finished.\n", .{});
}
