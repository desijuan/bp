const std = @import("std");

pub fn build(b: *std.Build) void {
    const lib_mod = b.addModule("bp", .{
        .root_source_file = b.path("src/root.zig"),
    });

    const tests = b.addTest(.{
        .root_source_file = b.path("test/test.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });
    tests.root_module.addImport("bp", lib_mod);
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
