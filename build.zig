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

    const tris = b.addExecutable(.{
        .name = "2_triangles",
        .root_module = b.addModule("2_triangles", .{
            .root_source_file = b.path("examples/2_triangles.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    tris.linkSystemLibrary("sdl3");
    tris.linkSystemLibrary("gl");
    tris.root_module.addImport("catchfire", lib.root_module);
    tris.linkLibC();

    bin.linkSystemLibrary("sdl3");
    bin.linkSystemLibrary("gl");
    bin.root_module.addImport("catchfire", lib.root_module);
    bin.linkLibC();

    const install = b.addInstallArtifact(bin, .{});
    const install_lib = b.addInstallArtifact(lib, .{});
    const install_2_tris = b.addInstallArtifact(tris, .{});

    b.getInstallStep().dependOn(&install_lib.step);
    b.getInstallStep().dependOn(&install_2_tris.step);
    b.getInstallStep().dependOn(&install.step);

    const run = b.addRunArtifact(bin);
    const run_2_tris = b.addRunArtifact(tris);
    run.step.dependOn(&install.step);
    run_2_tris.step.dependOn(&install.step);

    b.step("2_tris", "2 triangles").dependOn(&run_2_tris.step);
    b.step("run", "run the editor").dependOn(&run.step);
}
