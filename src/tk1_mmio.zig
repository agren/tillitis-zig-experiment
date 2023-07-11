// zig fmt: off
const MMIO_BASE       = 0xc0000000;
const MMIO_TRNG_BASE  = MMIO_BASE;
const MMIO_QEMU_BASE  = MMIO_BASE | 0x3e000000;
const MMIO_TIMER_BASE = MMIO_BASE | 0x01000000;
const MMIO_TOUCH_BASE = MMIO_BASE | 0x04000000;
const MMIO_TK1_BASE   = MMIO_BASE | 0x3f000000;
// zig fmt: on

pub const tk1 = map_device_struct(Tk1, MMIO_TK1_BASE);
pub const trng = map_device_struct(Trng, MMIO_TRNG_BASE);
pub const timer = map_device_struct(Timer, MMIO_TIMER_BASE);
pub const touch = map_device_struct(Touch, MMIO_TOUCH_BASE);
pub const qemu = map_device_struct(QEmu, MMIO_QEMU_BASE);

fn map_device_struct(comptime T: type, base_address: u32) *volatile T {
    return @intToPtr(*volatile T, base_address);
}

const Tk1 = packed struct {
    NAME0: u32,
    NAME1: u32,
    VERSION: u32,

    pub fn name(self: *volatile Tk1) [8]u8 {
        return .{
            @truncate(u8, self.NAME0 >> 24),
            @truncate(u8, self.NAME0 >> 16),
            @truncate(u8, self.NAME0 >> 8),
            @truncate(u8, self.NAME0),
            @truncate(u8, self.NAME1 >> 24),
            @truncate(u8, self.NAME1 >> 16),
            @truncate(u8, self.NAME1 >> 8),
            @truncate(u8, self.NAME1),
        };
    }
};

const Trng = packed struct {
    _unused_0: u288,
    STATUS: packed union {
        word: u32,
        fields: packed struct(u32) {
            READY: bool,
            _unused: u31,
        },
    },
    _unused_1: u704,
    ENTROPY: u32,
};

const Timer = packed struct {
    _unused: u256,
    CTRL: packed union {
        word: u32,
        fields: packed struct(u32) {
            START: bool,
            STOP: bool,
            _unused: u30,
        },
    },
    STATUS: packed union {
        word: u32,
        fields: packed struct(u32) {
            RUNNING: bool,
            _unused: u31,
        },
    },
    PRESCALER: u32,
    TIMER: u32,
};

const Touch = packed struct {
    _unused: u288,
    STATUS: packed union {
        word: u32,
        fields: packed struct(u32) {
            EVENT: bool,
            _unused: u31,
        },
    },
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
