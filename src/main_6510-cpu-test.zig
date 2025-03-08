const std = @import("std");
const CPU = @import("6510-emulator/6510-emulator.zig").CPU;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var cpu = CPU{};

    try stdout.print("Initializing CPU\n", .{});
    cpu.init(0x0800, 0x00, 0x00, 0x00);
    cpu.writeByte(0x0800, 0xa9);
    cpu.writeByte(0x0801, 0x0a);

    try stdout.print("Running CPU\n", .{});
    _ = try cpu.run();

    try stdout.print("a: {d}\n", .{cpu.a});

    std.debug.print("Execution finished.\n", .{});
}
