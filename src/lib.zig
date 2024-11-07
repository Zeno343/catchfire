const std = @import("std");

const Device = @import("device/mod.zig");
pub const Event = Device.Event;
pub const Window = Device.Window;
pub const Render = @import("render/mod.zig");

const VERT_SRC = @embedFile("shaders/rgb.vert");
const FRAG_SRC = @embedFile("shaders/rgb.frag");

const VertexType = struct { [2]f32, [3]f32 }; // XY and RGB

pub const Engine = extern struct {
    window: Window,
    verts: Render.Buffer(VertexType),
    shader: Render.Shader,
    mesh: Render.Mesh,

    pub fn init(name: [*:0]const u8) !Engine {
        std.debug.print("{s}\n", .{name});
        const window = Window.init(name, null) catch return error.WindowInitFailed;
        const draw_size = window.size();
        std.debug.print("window size: ({d}, {d})\n", .{ draw_size[0], draw_size[1] });

        const shader = Render.Shader.compile(VERT_SRC, FRAG_SRC);

        const verts = Render.Buffer(VertexType).from_verts(&.{
            .{ .{ 0.5, -0.5 }, .{ 1.0, 0.0, 0.0 } },
            .{ .{ -0.5, -0.5 }, .{ 0.0, 1.0, 0.0 } },
            .{ .{ 0.0, 0.5 }, .{ 0.0, 0.0, 1.0 } },
        });
        verts.bind();

        const mesh = Render.Mesh.new().with_vertex_attrs(&.{
            Render.VertexAttr{ .n_components = 2, .type = Render.VertexType.Float },
            Render.VertexAttr{ .n_components = 3, .type = Render.VertexType.Float },
        });

        return Engine{
            .window = window,
            .shader = shader,
            .mesh = mesh,
            .verts = verts,
        };
    }

    pub fn run(self: Engine) bool {
        const draw_size = self.window.size();
        Render.viewport(0, 0, draw_size[0], draw_size[1]);
        Render.clear();
        self.shader.bind();
        self.mesh.draw(3, Render.Topology.Triangles);
        self.window.swap();

        while (Device.poll()) |event| {
            switch (event) {
                .Quit => {
                    self.drop();
                    return false;
                },

                .KeyDown => |keycode| {
                    switch (keycode) {
                        .Esc => {
                            self.drop();
                            return false;
                        },
                    }
                },
            }
        }
        return true;
    }

    fn drop(self: Engine) void {
        std.debug.print("exiting\n", .{});
        self.shader.drop();
        self.window.drop();
    }
};

var EM_RT: Engine = undefined;

pub export fn em_init() i32 {
    EM_RT = Engine.init("catchfireWeb v24.11.07") catch {
        std.debug.print("runtime init failed\n", .{});
        return 1;
    };

    std.debug.print("runtime initialized\n", .{});
    return 0;
}

pub export fn em_run() bool {
    return EM_RT.run();
}
