const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const opts = b.standardOptimizeOption(.{});

    // Build wasm dependencies
    const web_deps = b.addSystemCommand(&.{"emcc"});
    web_deps.addArg("-c");
    _ = web_deps.addFileArg(b.path("src/static/main.c"));
    web_deps.addArg("--cache");
    web_deps.addArg("cache");
    web_deps.addArg("-sUSE_SDL=2");
    web_deps.addArg("-o");
    const main_o = web_deps.addOutputFileArg("main.o");

    const web_main = b.addInstallLibFile(main_o, "main.o");
    web_main.step.dependOn(&web_deps.step);

    const web_headers = b.addInstallDirectory(
        .{
            .source_dir = b.path(b.pathJoin(&.{ "cache", "sysroot", "include" })),
            .install_dir = .header,
            .install_subdir = "",
        },
    );
    web_headers.step.dependOn(&web_deps.step);

    const web_libs = b.addInstallDirectory(.{
        .source_dir = b.path(b.pathJoin(&.{ "cache", "sysroot", "lib", "wasm32-emscripten" })),
        .install_dir = .lib,
        .install_subdir = "",
    });
    web_libs.step.dependOn(&web_deps.step);

    const c_deps = b.addModule(
        "c",
        .{
            .root_source_file = b.path("src/c.zig"),
        },
    );
    c_deps.addIncludePath(b.path("zig-out/include/"));

    const lib = b.addStaticLibrary(.{
        .name = "catchfire",
        .root_source_file = b.path("src/lib.zig"),
        .target = b.resolveTargetQuery(
            .{
                .cpu_arch = .wasm32,
                .os_tag = .emscripten,
            },
        ),
        .optimize = opts,
    });
    lib.linkLibC();
    lib.root_module.addImport("c", c_deps);
    lib.step.dependOn(&web_headers.step);
    lib.step.dependOn(&web_libs.step);
    lib.addIncludePath(b.path("zig-out/include/"));
    lib.addLibraryPath(b.path("zig-out/lib"));
    b.installArtifact(lib);

    const web = b.addSystemCommand(&.{"emcc"});
    web.addFileArg(b.path("zig-out/lib/main.o"));
    web.addArtifactArg(lib);
    web.addArg("-o");
    web.addArg("index.html");
    web.addArg("-sUSE_SDL=2");
    web.addArg("--cache");
    web.addArg("cache");

    web.step.dependOn(&lib.step);
    web.step.dependOn(&web_main.step);
    b.step("web", "build wasm").dependOn(&web.step);

    const bin = b.addExecutable(.{
        .name = "catchfire",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = opts,
    });

    bin.linkSystemLibrary("GL");
    bin.linkSystemLibrary("SDL2");
    bin.linkLibC();

    b.step("run", "run the catchfire engine").dependOn(&b.addRunArtifact(bin).step);
}
