const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const bin = b.addExecutable(.{ 
        .name = "catchfire", 
        .root_module = b.addModule("catchfire", .{ 
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const lib = b.addLibrary(.{ 
        .name = "catchfire", 
        .root_module = b.addModule("catchfire", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
      }), 
    });
    lib.linkSystemLibrary("sdl3");
    lib.linkSystemLibrary("gl");
    lib.linkLibC();

    bin.linkSystemLibrary("sdl3");
    bin.linkSystemLibrary("gl");
    bin.root_module.addImport("catchfire", lib.root_module);
    bin.linkLibC();

    const install = b.addInstallArtifact(bin, .{});
    const install_lib = b.addInstallArtifact(lib, .{});

    b.getInstallStep().dependOn(&install_lib.step);
    b.getInstallStep().dependOn(&install.step);

    const run = b.addRunArtifact(bin);
    run.step.dependOn(&install.step);
    b.step("run", "run the editor").dependOn(&run.step);
}
