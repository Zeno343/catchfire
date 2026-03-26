const std = @import("std");
const ctcf = @import("catchfire");
const Render = ctcf.Render;
const Engine = ctcf.Engine;
const GlWindow = ctcf.GlWindow;

const VERT_SOURCE = @embedFile("shaders/rgb.vert");
const FRAG_SOURCE = @embedFile("shaders/rgb.frag");

const VertexType = struct { [2]f32, [3]f32 };

pub fn main() !void {
    const engine = try Engine.init();
    defer engine.deinit();

    const window = try GlWindow.init("catchfire", .{ 1920, 1080 });
    std.debug.print("window size: {}x{}\n", .{ window.size[0], window.size[1] });
    defer window.deinit();

    const shader = try Render.Shader.compile(VERT_SOURCE, FRAG_SOURCE);
    defer shader.deinit();

    const verts = [_]VertexType{
      .{ .{ 0.0, 0.5, }, .{ 1.0, 0.0, 0.0 } }, 
      .{ .{ -0.5, -0.5, }, .{ 0.0, 1.0, 0.0 } }, 
      .{ .{ 0.5, -0.5, }, .{ 0.0, 0.0, 1.0 } },
    };
    const vert_buf = Render.Buffer(VertexType).from_verts(&verts);
    defer vert_buf.drop();

    const mesh = Render.Mesh.new().with_vertex_attrs(&.{
        Render.VertexAttr{ .n_components = 2, .type = Render.GlVertexType.Float },
        Render.VertexAttr{ .n_components = 3, .type = Render.GlVertexType.Float },
    });
    defer mesh.drop();

    var quit = false;
    while (!quit) {
        Render.clear();
        vert_buf.bind();
        mesh.bind();
        shader.bind();
        mesh.draw(0, 3, Render.Topology.Triangles);

        try window.swap();
        while (engine.poll()) |event| {
            switch (event.type) {
                .Quit => quit = true,
                _ => {},
            }
        }
    }
}
