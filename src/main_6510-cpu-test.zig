const std = @import("std");
const CPU = @import("6510-emulator/6510-emulator.zig").CPU;

pub fn main() void {
    var cpu = CPU{};
    std.debug.print("Initializing CPU...\n", .{});
    cpu.init(0x0800, 0x00, 0x00, 0x00);

    std.debug.print("Running CPU...\n", .{});
    _ = cpu.run();

    std.debug.print("Execution finished.\n", .{});
}
