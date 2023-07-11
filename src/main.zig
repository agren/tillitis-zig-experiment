const std = @import("std");
const mmio = @import("tk1_mmio.zig");

pub export fn main() void {
    mmio.qemu.puts("Running on: '");
    mmio.qemu.puts(&mmio.tk1.name());
    mmio.qemu.puts("', version: 0x");
    mmio.qemu.puthexu32(mmio.tk1.VERSION);
    mmio.qemu.puts(".\n");

    mmio.timer.CTRL.fields.STOP = true;
    mmio.timer.PRESCALER = 18000000; // 18000000: 1 sec/tick

    while (true) {
        if (!mmio.timer.STATUS.fields.RUNNING) {
            mmio.timer.TIMER = 1;
            mmio.timer.CTRL.fields.START = true;

            mmio.qemu.puts("Hello world!\n");

            while (!mmio.trng.STATUS.fields.READY) {}
            mmio.qemu.puts("Entropy is: ");
            mmio.qemu.puthexu32(mmio.trng.ENTROPY);
            mmio.qemu.puts(".\n\n");
        }

        if (mmio.touch.STATUS.fields.EVENT) {
            mmio.qemu.puts("Touch sensor touched.\n\n");
            mmio.touch.STATUS.word = 0;
        }
    }
}
