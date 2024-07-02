const std = @import("std");
const Window = @import("window.zig");
const Render = @import("render/mod.zig");

const name = "catchfire v0.2.dev";

const vert_src = @embedFile("shaders/rgb.vert");
const frag_src = @embedFile("shaders/rgb.frag");

pub fn main() !void {
    std.debug.print("{s}\n", .{name});
    const window = try Window.init(name);
    var draw_size = window.size();
    std.debug.print("window size: ({d}, {d})\n", .{ draw_size[0], draw_size[1] });
    defer window.drop();

    const fs_shader = Render.Shader.compile(vert_src, frag_src);
    defer fs_shader.drop();

    const verts = Render.Buffer(f32).from_verts(&.{ 0.5, -0.5, 1.0, 0.0, 0.0, -0.5, -0.5, 0.0, 1.0, 0.0, 0.0, 0.5, 0.0, 0.0, 1.0 });
    verts.bind();
    const mesh = Render.Mesh.new().with_vertex_attrs(&.{ Render.VertexAttr{ .n_components = 2, .type = Render.VertexType.Float }, Render.VertexAttr{ .n_components = 3, .type = Render.VertexType.Float } });

    main: while (true) {
        while (window.poll()) |event| {
            switch (event) {
                .Quit => {
                    std.debug.print("quit event received\n", .{});
                    break :main;
                },
            }
        }

        draw_size = window.size();
        Render.viewport(0, 0, draw_size[0], draw_size[1]);
        Render.clear();

        fs_shader.bind();
        mesh.draw(3, Render.Topology.Triangles);

        window.swap();
    }

    std.debug.print("exited main loop\n", .{});
}
