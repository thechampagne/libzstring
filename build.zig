const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    const staticLib = b.addStaticLibrary(.{
        .name = "zstring",
        .root_source_file = .{ .path = "src/zstring.zig" },
        .optimize = optimize,
        .target = target,
    });
    staticLib.linkLibC();
    b.installArtifact(staticLib);

    const sharedLib = b.addSharedLibrary(.{
        .name = "zstring",
        .root_source_file = .{ .path = "src/zstring.zig" },
        .optimize = optimize,
        .target = target,
    });
    sharedLib.linkLibC();
    b.installArtifact(sharedLib);

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/zstring.zig" },
        .optimize = optimize,
    });
    main_tests.linkLibC();

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
