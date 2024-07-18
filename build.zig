const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const opts = b.standardOptimizeOption(.{});

    const opengl = b.createModule(.{
        .target = target,
        .root_source_file = .{ .path = "src/opengl/mod.zig" },
    });
    opengl.linkSystemLibrary("gl", .{});

    const sdl = b.createModule(.{
        .target = target,
        .root_source_file = .{ .path = "src/sdl/mod.zig" },
    });
    sdl.linkSystemLibrary("sdl2", .{});

    const bin = b.addExecutable(.{
        .name = "catchfire",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = opts,
    });

    const dbg_shader = b.addExecutable(.{
        .name = "debug-shader",
        .root_source_file = .{ .path = "examples/debug-shader/main.zig" },
        .target = target,
        .optimize = opts,
    });

    for ([_]*std.Build.Step.Compile{ bin, dbg_shader }) |exe| {
        exe.root_module.addImport("opengl", opengl);
        exe.root_module.addImport("sdl", sdl);
        exe.linkLibC();
        b.installArtifact(exe);
    }

    b.step("run", "run the catchfire engine").dependOn(&b.addRunArtifact(bin).step);
    b.step("debug-shader", "examples/debug-shader").dependOn(&b.addRunArtifact(dbg_shader).step);
}
