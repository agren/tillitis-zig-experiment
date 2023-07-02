const std = @import("std");
const mmio = @import("tk1_mmio.zig");

pub export fn main() void {
    mmio.qemu.puts("Running on: '");
    mmio.qemu.puts(&mmio.tk1.name());
    mmio.qemu.puts("', version: 0x");
    mmio.qemu.puthexu32(mmio.tk1.VERSION);
    mmio.qemu.puts(".\n");

    mmio.timer.stop();
    mmio.timer.PRESCALER = 18000000; // 18000000: 1 sec/tick

    while (true) {
        mmio.timer.TIMER = 1;
        mmio.timer.start();

        mmio.qemu.puts("Hello world!\n");

        while (!mmio.trng.entropy_is_ready()) {}
        mmio.qemu.puts("Enropy is: ");
        mmio.qemu.puthexu32(mmio.trng.ENTROPY);
        mmio.qemu.puts(".\n");

        while (mmio.timer.is_running()) {}
    }
}
