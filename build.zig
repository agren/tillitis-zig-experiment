const std = @import("std");
const featureSet = std.Target.riscv.featureSet;
const RiscVFeature = std.Target.riscv.Feature;

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target: std.zig.CrossTarget = .{
        .cpu_arch = .riscv32,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.generic_rv32 },
        .cpu_features_add = featureSet(&[_]RiscVFeature{
            .c,
            .zmmul,
        }),
        .os_tag = .freestanding,
        .abi = .gnuilp32,
    };

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("tillitis-zig-experiment", "src/main.zig");
    exe.setTarget(target);
    exe.setLinkerScriptPath(std.build.FileSource.relative("lib/tkey-libs/app.lds"));
    exe.setBuildMode(mode);
    exe.addAssemblyFile("./lib/tkey-libs/libcrt0/crt0.S");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
