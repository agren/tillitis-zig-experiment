const std = @import("std");
const tk1 = @import("tk1_mmio.zig");

pub export fn main() void {
    tk1.qemu.puts("Hello world!\n");

    while (true) {}
}
