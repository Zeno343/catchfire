const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const main = b.addModule("engine", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const bin = b.addExecutable(.{
        .name = "catchfire",
        .root_module = main,
    });
    bin.linkSystemLibrary("sdl3");
    bin.linkSystemLibrary("gl");
    bin.linkLibC();

    const install = b.addInstallArtifact(bin, .{});
    b.getInstallStep().dependOn(&install.step);

    const run = b.addRunArtifact(bin);
    run.step.dependOn(&install.step);
    b.step("run", "run the editor").dependOn(&run.step);
}
