const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const opts = b.standardOptimizeOption(.{});

    const render = b.createModule(.{ .root_source_file = .{ .path = "src/render/mod.zig" } });
    const window = b.createModule(.{ .root_source_file = .{ .path = "src/window.zig" } });

    const bin = b.addExecutable(.{ .name = "catchfire", .root_source_file = .{ .path = "src/main.zig" }, .target = target, .optimize = opts });

    const dbg_shader = b.addExecutable(.{
        .name = "debug-shader",
        .root_source_file = .{ .path = "examples/debug-shader/main.zig" },
        .target = target,
        .optimize = opts,
    });

    for ([_]*std.Build.Step.Compile{ bin, dbg_shader }) |exe| {
        exe.root_module.addImport("render", render);
        exe.root_module.addImport("window", window);

        exe.linkLibC();
        for ([_][]const u8{ "SDL2", "GL" }) |sys_lib| {
            exe.linkSystemLibrary(sys_lib);
        }

        b.installArtifact(exe);
    }

    b.step("run", "run the catchfire engine").dependOn(&b.addRunArtifact(bin).step);
    b.step("debug-shader", "examples/debug-shader").dependOn(&b.addRunArtifact(dbg_shader).step);
}
