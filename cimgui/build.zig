const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const imgui = b.dependency("imgui", .{});

    // Build imgui
    const root = b.addModule("cimgui", .{
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
        .root_source_file = b.path("src/root.zig"),
    });
    root.addIncludePath(imgui.path(""));
    root.addIncludePath(imgui.path("backends"));
    root.addCSourceFiles(.{
        .root = imgui.path(""),
        .flags = &.{"-DIMGUI_IMPL_API=extern \"C\" "},
        .files = &.{
            "imgui.cpp",
            "imgui_tables.cpp",
            "imgui_draw.cpp",
            "imgui_demo.cpp",
            "imgui_widgets.cpp",
            "backends/imgui_impl_sdl3.cpp",
            "backends/imgui_impl_opengl3.cpp",
        },
    });
    root.addIncludePath(b.path(""));
    root.addCSourceFiles(.{
        .files = &.{
            "cimgui.cpp",
        },
    });

    // Build library
    const lib = b.addLibrary(.{
        .name = "cimgui",
        .root_module = root,
    });
    lib.linkSystemLibrary("sdl3");
    lib.installHeader(b.path("cimgui.h"), "include/cimgui.h");
    lib.installHeader(b.path("cimgui_impl.h"), "include/cimgui_impl.h");

    // Install
    b.installArtifact(lib);
}
