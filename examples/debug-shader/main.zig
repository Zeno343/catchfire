const std = @import("std");
const Window = @import("sdl").Window;
const Render = @import("opengl");

const name = "debug-shader";

const vert_src = @embedFile("shader.vert");
const frag_src = @embedFile("shader.frag");

pub fn main() !void {
    std.debug.print("{s}\n", .{name});
    const window = try Window.init(name, .{ 800, 640 });
    defer window.drop();

    const fs_shader = Render.Shader.compile(vert_src, frag_src);
    defer fs_shader.drop();

    const fs_mesh = Render.Mesh.new();

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
        fs_mesh.draw(3, Render.Topology.Triangles);

        window.swap();
    }

    std.debug.print("exited main loop\n", .{});
}
