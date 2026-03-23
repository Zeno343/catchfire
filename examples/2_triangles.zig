const std = @import("std");

const ctcf = @import("catchfire");
const Engine = ctcf.Engine;
const Render = ctcf.Render;
const GlWindow = ctcf.GlWindow;

const VERT_SOURCE = @embedFile("passthru.vert");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();

    var args = std.process.args();
    _ = args.next();
    const file_name = if (args.next()) |file| file else "uv.frag";

    const file = try std.fs.cwd().openFile(file_name, .{});
    const contents = try file.readToEndAlloc(arena.allocator(), std.math.maxInt(usize));
    var stat = try std.fs.cwd().statFile(file_name);
    defer file.close();

    const engine = try Engine.init();
    defer engine.deinit();

    const window = try GlWindow.init("2_triangles", .{ 600, 480 });
    std.debug.print("window size: {}x{}\n", .{ window.size[0], window.size[1] });
    defer window.deinit();

    var shader = Render.Shader.compile(VERT_SOURCE, contents.ptr);
    defer shader.deinit();

    const verts = [_][2]f32{
        .{ -1.0, 1.0 },
        .{ 5.0, 1.0 },
        .{ -5.0, -5.0 },
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

        const _file = try std.fs.cwd().openFile(file_name, .{});
        const new_stat = try std.fs.cwd().statFile(file_name);
        defer _file.close();
        if (new_stat.mtime != stat.mtime) {
            stat = new_stat;
            std.debug.print("file changed\n", .{});

            shader.deinit();
            const _contents = try _file.readToEndAlloc(arena.allocator(), std.math.maxInt(usize));
            shader = Render.Shader.compile(VERT_SOURCE, _contents.ptr);
        }
    }
}
