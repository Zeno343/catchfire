const std = @import("std");

pub fn build(b: *std.Build) void {
    const bin = b.addExecutable(.{
        .name = "catchfire",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });

    bin.linkLibC();
    for ([_][]const u8{ "SDL2", "GL" }) |sys_lib| {
        bin.linkSystemLibrary(sys_lib);
    }

    b.installArtifact(bin);
    b.step("run", "run the catchfire engine").dependOn(&b.addRunArtifact(bin).step);
}
