const std = @import("std");
const tk1 = @import("tk1_mmio.zig");

pub export fn main() void {
    tk1.timer.stop();
    tk1.timer.PRESCALER = 18000000;
    while (true) {
        tk1.qemu.puts("Hello world!\n");
        tk1.timer.TIMER = 1;
        tk1.timer.start();
        while (tk1.timer.is_running()) {}
    }
}
