const std = @import("std");
const tk1 = @import("tk1_mmio.zig");

pub export fn main() void {
    tk1.timer.stop();
    tk1.timer.PRESCALER = 18000000; // 18000000: 1 sec/tick

    while (true) {
        tk1.timer.TIMER = 1;
        tk1.timer.start();

        tk1.qemu.puts("Hello world!\n");

        while (!tk1.trng.entropy_is_ready()) {}
        tk1.qemu.puts("Enropy is: ");
        tk1.qemu.puthexu32(tk1.trng.ENTROPY);
        tk1.qemu.puts(".\n");

        while (tk1.timer.is_running()) {}
    }
}
