const std = @import("std");
const mmio = @import("tk1_mmio.zig");

const tk1 = mmio.tk1;
const trng = mmio.trng;
const timer = mmio.timer;
const touch = mmio.touch;
const qemu = mmio.qemu;

pub export fn main() void {
    qemu.puts("Running on: '");
    qemu.puts(&tk1.name());
    qemu.puts("', version: 0x");
    qemu.puthexu32(tk1.VERSION);
    qemu.puts(".\n");

    timer.CTRL.fields.STOP = true;
    timer.PRESCALER = 18000000; // 18000000: 1 sec/tick

    while (true) {
        if (!timer.STATUS.fields.RUNNING) {
            timer.TIMER = 1;
            timer.CTRL.fields.START = true;

            qemu.puts("Hello world!\n");

            while (!trng.STATUS.fields.READY) {}
            qemu.puts("Entropy is: ");
            qemu.puthexu32(trng.ENTROPY);
            qemu.puts(".\n\n");
        }

        if (touch.STATUS.fields.EVENT) {
            qemu.puts("Touch sensor touched.\n\n");
            touch.STATUS.word = 0;
        }
    }
}
