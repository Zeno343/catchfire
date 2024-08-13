const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const opts = b.standardOptimizeOption(.{});

    const cache = std.process.getEnvVarOwned(gpa.allocator(), "EM_CACHE") catch ".cache";

    const build_wasm_main = b.addSystemCommand(&.{ "emcc", "--cache", cache });
    build_wasm_main.addArgs(&.{ "--use-ports", "sdl2" });
    build_wasm_main.addArg("-c");
    build_wasm_main.addFileArg(b.path("src/static/main.c"));
    build_wasm_main.addArg("-o");
    const wasm_main = build_wasm_main.addOutputFileArg("main.wasm");

    const ctcf_web = b.addStaticLibrary(.{
        .name = "catchfire_web",
        .root_source_file = b.path("src/lib.zig"),
        .target = b.resolveTargetQuery(
            .{
                .cpu_arch = .wasm32,
                .os_tag = .emscripten,
            },
        ),
        .optimize = opts,
    });
    ctcf_web.linkLibC();
    ctcf_web.addIncludePath(.{ .cwd_relative = b.pathJoin(&.{
        cache,
        "sysroot",
        "include",
    }) });
    ctcf_web.addLibraryPath(.{ .cwd_relative = b.pathJoin(&.{
        cache,
        "sysroot",
        "lib",
        "wasm32-emscripten",
    }) });
    ctcf_web.step.dependOn(&build_wasm_main.step);
    b.installArtifact(ctcf_web);

    const web = b.addSystemCommand(&.{ "emcc", "--cache", cache });
    web.addArgs(&.{ "--use-ports", "sdl2" });
    web.addFileArg(wasm_main);
    web.addArtifactArg(ctcf_web);
    web.addArg("-o");
    web.addArg("zig-out/index.html");
    web.step.dependOn(&build_wasm_main.step);
    web.step.dependOn(&ctcf_web.step);
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
    b.installArtifact(bin);

    b.step("run", "run the catchfire engine").dependOn(&b.addRunArtifact(bin).step);
}
