// zig fmt: off
const MMIO_BASE      = 0xc0000000;
const MMIO_QEMU_BASE = MMIO_BASE | 0x3e000000;
// zig fmt: on

pub const qemu = map_device_struct(QEmu, MMIO_QEMU_BASE);

fn map_device_struct(comptime T: type, base_address: u32) *volatile T {
    return @intToPtr(*volatile T, base_address);
}

const QEmu = packed struct {
    _unused: u32768,
    debug_tx: u8,

    pub fn putc(self: *volatile QEmu, c: u8) void {
        self.debug_tx = c;
    }

    pub fn puts(self: *volatile QEmu, s: []const u8) void {
        for (s) |c| {
            self.putc(c);
        }
    }
};
