const std = @import("std");
const Window = @import("window.zig");
const Render = @import("render/mod.zig");

const name = "catchfire v0.1";

const vert_src = @embedFile("shaders/xy_debug.vert");
const frag_src = @embedFile("shaders/xy_debug.frag");

pub fn main() !void {
    std.debug.print("{s}\n", .{name});
    const window = try Window.init(name);
    defer window.drop();

    const fs_shader = Render.Shader.compile(vert_src, frag_src);
    defer fs_shader.drop();

    const fullscreen = Render.Mesh.new();

    main: while (true) {
        while (window.poll()) |event| {
            switch (event) {
                .Quit => {
                    std.debug.print("quit event received\n", .{});
                    break :main;
                },
            }
        }
        Render.clear();

        fs_shader.bind();
        fullscreen.draw(3);

        window.swap();
    }

    std.debug.print("exited main loop\n", .{});
}
