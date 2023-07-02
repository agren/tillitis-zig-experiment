// zig fmt: off
const MMIO_BASE       = 0xc0000000;
const MMIO_QEMU_BASE  = MMIO_BASE | 0x3e000000;
const MMIO_TIMER_BASE = MMIO_BASE | 0x01000000;
// zig fmt: on

pub const timer = map_device_struct(Timer, MMIO_TIMER_BASE);
pub const qemu = map_device_struct(QEmu, MMIO_QEMU_BASE);

fn map_device_struct(comptime T: type, base_address: u32) *volatile T {
    return @intToPtr(*volatile T, base_address);
}

const Timer = packed struct {
    _unused: u256,
    CTRL: u32,
    STATUS: u32,
    PRESCALER: u32,
    TIMER: u32,

    // zig fmt: off
    const CTRL_START_BIT     = 0;
    const CTRL_STOP_BIT      = 1;
    const STATUS_RUNNING_BIT = 0;
    // zig fmt: on

    pub fn start(self: *volatile Timer) void {
        self.CTRL = (1 << CTRL_START_BIT);
    }

    pub fn stop(self: *volatile Timer) void {
        self.CTRL = (1 << CTRL_STOP_BIT);
    }

    pub fn is_running(self: *volatile Timer) bool {
        return (self.STATUS & (1 << STATUS_RUNNING_BIT)) != 0;
    }
};

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

    fn hex_nibble(nibble: u4) u8 {
        return switch (nibble) {
            0...9 => @intCast(u8, nibble) + '0',
            10...15 => @intCast(u8, nibble) - 10 + 'A',
        };
    }

    pub fn puthexu32(self: *volatile QEmu, value: u32) void {
        for ([_]u5{ 3, 2, 1, 0 }) |i| {
            const byte_value = @truncate(u8, value >> (8 * i));
            self.putc(hex_nibble(@truncate(u4, (byte_value >> 4))));
            self.putc(hex_nibble(@truncate(u4, (byte_value))));
        }
    }
};
