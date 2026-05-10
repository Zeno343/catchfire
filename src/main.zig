const std = @import("std");
const ctcf = @import("catchfire");
const Render = ctcf.Render;
const Uniform = Render.Uniform;
const KeyboardEvent = ctcf.KeyboardEvent;
const Engine = ctcf.Engine;
const GlWindow = ctcf.GlWindow;

const Gui = @import("cimgui").Gui;
const cimgui = @import("cimgui").cimgui;

const VERT_SOURCE = @embedFile("shaders/rgb.vert");
const RESOLUTION = [2]i32{ 600, 480 };

const VertexType = struct { [2]f32, [3]f32 };

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();

    var args = std.process.args();
    _ = args.next();
    const file_name = if (args.next()) |file| file else "src/shaders/color.frag";

    const engine = try Engine.init();
    defer engine.deinit();

    const window = try GlWindow.init("catchfire", &RESOLUTION);
    std.debug.print("window size: {}x{}\n", .{ window.size[0], window.size[1] });
    defer window.deinit();

    const gui = try Gui.init(@ptrCast(window.window), @ptrCast(window.gfx));
    defer gui.deinit();

    const file = try std.fs.cwd().openFile(file_name, .{});
    const contents = try file.readToEndAlloc(arena.allocator(), std.math.maxInt(usize));
    var shader = try Render.Shader.compile(VERT_SOURCE, contents.ptr);
    defer shader.deinit();
    file.close();

    const verts = [_]VertexType{
        .{ .{ -1.0, 1.0 },  .{ 1.0, 0.0, 0.0 } },
        .{ .{ 5.0, 1.0 },   .{ 0.0, 1.0, 0.0 } },
        .{ .{ -5.0, -5.0 }, .{ 0.0, 0.0, 1.0 } },
    };

    const vert_buf = Render.Buffer(VertexType).from_verts(&verts);
    defer vert_buf.drop();

    const mesh = Render.Mesh.new().with_vertex_attrs(&.{
        Render.VertexAttr{ .n_components = 2, .type = Render.GlVertexType.Float },
        Render.VertexAttr{ .n_components = 3, .type = Render.GlVertexType.Float },
    });
    defer mesh.drop();

    var quit = false;
    // var position = [2]f32{ 0.0, 0.0 };
    var rgb = [3]f32{ 0.0, 0.0, 0.0 };
    var mtime: i128 = 0;
    while (!quit) {
        const stat = try std.fs.cwd().statFile(file_name);

        if (mtime != stat.mtime) {
            mtime = stat.mtime;
            std.debug.print("file changed\n", .{});

            const _file = try std.fs.cwd().openFile(file_name, .{});
            const _contents = try file.readToEndAlloc(arena.allocator(), std.math.maxInt(usize));
            shader = Render.Shader.compile(VERT_SOURCE, _contents.ptr) catch shader;
            _file.close();
        }

        Render.clear();
        vert_buf.bind();
        mesh.bind();
        shader.bind();
        shader.vec3("rgb", &rgb);
        shader.ivec2("resolution", &RESOLUTION);
        mesh.draw(0, 3, Render.Topology.Triangles);

        gui.frame();
        gui.rgbSlider(&rgb);
        gui.draw();

        try window.swap();
        while (engine.poll()) |event| {
            switch (event.type) {
                .Quit => quit = true,
                .KeyDown => {
                    const key: ctcf.Keycode = @enumFromInt(event.event.key.key);
                    std.debug.print("key down: {}\n", .{key});
                    switch (key) {
                        .RIGHT => {
                            // position[0] += 0.1;
                        },
                        .LEFT => {
                            // position[0] -= 0.1;
                        },
                        .UP => {
                            // position[1] += 0.1;
                        },
                        .DOWN => {
                            // position[1] -= 0.1;
                        },

                        else => {},
                    }
                },

                _ => {},
            }

            gui.handleEvent(@constCast(&event.event));
        }
    }
}
