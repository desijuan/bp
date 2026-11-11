const std = @import("std");

pub fn build(b: *std.Build) void {
    const mod_lib = b.addModule("bp", .{
        .root_source_file = b.path("src/root.zig"),
    });

    const mod_tests = b.createModule(.{
        .root_source_file = b.path("test/test.zig"),
        .target = b.standardTargetOptions(.{}),
    });
    mod_tests.addImport("bp", mod_lib);

    const tests = b.addTest(.{
        .root_module = mod_tests,
    });
    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
