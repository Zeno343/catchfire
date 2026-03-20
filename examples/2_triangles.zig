const std = @import("std");

const ctcf = @import("catchfire");
const Engine = ctcf.Engine;
const Render = ctcf.Render;
const GlWindow = ctcf.GlWindow;

const VERT_SOURCE = @embedFile("passthru.vert");
const FRAG_SOURCE = @embedFile("uv.frag");

pub fn main() !void {
    const engine = try Engine.init();
    defer engine.deinit();

    const window = try GlWindow.init("2_triangles", .{ 1920, 1080 });
    std.debug.print("window size: {}x{}\n", .{ window.size[0], window.size[1] });
    defer window.deinit();

    const shader = Render.Shader.compile(VERT_SOURCE, FRAG_SOURCE);
    defer shader.deinit();

    const verts = [_][2]f32{
       .{ -1.0, 1.0 }, 
       .{ 5.0, 1.0 }, 
       .{ -5.0, -5.0, }, 
    };

    const vert_buf = Render.Buffer([2]f32).from_verts(&verts);
    defer vert_buf.drop();

    const mesh = Render.Mesh.new().with_vertex_attrs(&.{
        Render.VertexAttr{ .n_components = 2, .type = Render.GlVertexType.Float },
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
