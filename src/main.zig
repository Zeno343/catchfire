const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_opengl.h");
});

const VERT_SOURCE = @embedFile("shaders/rgb.vert");
const FRAG_SOURCE = @embedFile("shaders/rgb.frag");

const Engine = struct {
    const Event = struct {
        event: sdl.SDL_Event,
        type: enum(u32) {
            Quit = sdl.SDL_EVENT_QUIT,
            _,
        },
    };

    pub fn init() !Engine {
        if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) return error.InitSdl else {
            std.debug.print("system initialized\n", .{});
            return .{};
        }
    }

    pub fn deinit(_: *const Engine) void {
        sdl.SDL_Quit();
        std.debug.print("system deinitialized\n", .{});
    }

    pub fn poll(_: *const Engine) ?Event {
        var event: sdl.SDL_Event = undefined;
        if (sdl.SDL_PollEvent(&event)) {
            return .{
                .event = event,
                .type = @enumFromInt(event.type),
            };
        } else {
            return null;
        }
    }
};

pub const GlWindow = extern struct {
    window: *sdl.SDL_Window,
    gfx: sdl.SDL_GLContext,
    size: [2]i32,

    pub const Error = error{
        InitFailed,
        DeinitFailed,
        SwapFailed,
        SizeError,
    };

    pub fn init(name: [*]const u8, size: ?[2]i32) !GlWindow {
        const _size = size orelse .{ 0, 0 };
        var w = _size[0];
        var h = _size[1];

        const win_type: u32 = if (size) |_| 0 else sdl.SDL_WINDOW_FULLSCREEN;
        const attrs: u32 = @as(u32, sdl.SDL_WINDOW_OPENGL) | win_type;

        if (sdl.SDL_CreateWindow(name, w, h, attrs)) |window| {
            _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
            _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MINOR_VERSION, 3);
            const gfx = sdl.SDL_GL_CreateContext(window);
            std.debug.print("window initialized\n", .{});

            _ = sdl.SDL_SyncWindow(window);
            if (!sdl.SDL_GetWindowSizeInPixels(window, &w, &h) or (w != _size[0]) or (h != _size[1]))
                return Error.SizeError;

            return GlWindow{
                .window = window,
                .size = .{ w, h },
                .gfx = gfx,
            };
        } else return Error.InitFailed;
    }

    pub fn swap(self: *const GlWindow) !void {
        if (sdl.SDL_GL_SwapWindow(self.window)) return else return Error.SwapFailed;
    }

    pub fn deinit(self: *const GlWindow) void {
        if (sdl.SDL_GL_DestroyContext(self.gfx)) {
            sdl.SDL_DestroyWindow(self.window);
            std.debug.print("window deinitialized\n", .{});
        } else {
            @panic("Error deinitializing Gl context");
        }
    }
};

const Render = struct {
    const gl = @cImport({
        @cDefine("GL_GLEXT_PROTOTYPES", "");
        @cInclude("SDL3/SDL_opengl.h");
        @cInclude("GL/gl.h");
        @cInclude("GL/glext.h");
    });

    pub fn clear() void {
        gl.glClearColor(0.0, 0.0, 0.0, 0.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);
    }

    pub fn viewport(x: i32, y: i32, w: i32, h: i32) void {
        gl.glViewport(x, y, w, h);
    }

    const Shader = struct {
        id: gl.GLuint,

        const Source = struct {
            id: gl.GLuint,
            stage: Stage,

            const Stage = enum(gl.GLenum) {
                Vertex = gl.GL_VERTEX_SHADER,
                Fragment = gl.GL_FRAGMENT_SHADER,
            };

            pub fn compile(src: [*]const u8, stage: Stage) Source {
                const id = gl.glCreateShader(@intFromEnum(stage));
                gl.glShaderSource(id, 1, &[_][*]const u8{src}, null);
                gl.glCompileShader(id);

                std.debug.print("compiled shader {d}\n", .{id});
                return Source{
                    .id = id,
                    .stage = stage,
                };
            }

            pub fn drop(self: Source) void {
                gl.glDeleteShader(self.id);
            }
        };

        pub fn compile(vert: [*]const u8, frag: [*]const u8) Shader {
            const id = gl.glCreateProgram();
            const vert_shader = Source.compile(vert, Source.Stage.Vertex);
            const frag_shader = Source.compile(frag, Source.Stage.Fragment);
            defer vert_shader.drop();
            defer frag_shader.drop();

            gl.glAttachShader(id, vert_shader.id);
            gl.glAttachShader(id, frag_shader.id);
            gl.glLinkProgram(id);

            std.debug.print("compiled shader {d}\n", .{id});
            return Shader{
                .id = id,
            };
        }

        pub fn getUniformLocation(self: Shader, uniform: [:0]const u8) c_int {
            return gl.glGetUniformLocation(self.id, uniform);
        }

        pub fn bind(self: *const Shader) void {
            gl.glUseProgram(self.id);
        }

        pub fn deinit(self: *const Shader) void {
            gl.glDeleteProgram(self.id);
        }
    };

    pub fn Buffer(comptime data: anytype) type {
        return packed struct {
            const Self = @This();

            const Id = gl.GLuint;
            id: Id,

            pub fn new() Self {
                var id: Id = 0;
                gl.glGenBuffers(1, &id);
                std.debug.print("created buffer {d}\n", .{id});
                return Self{ .id = id };
            }

            pub fn from_verts(verts: []const data) Self {
                const buf = Self.new();
                buf.bind();

                gl.glBufferData(gl.GL_ARRAY_BUFFER, @intCast(verts.len * @sizeOf(data)), verts.ptr, gl.GL_STATIC_DRAW);
                return buf;
            }

            pub fn bind(self: *const Self) void {
                gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.id);
            }

            pub fn drop(self: *const Self) void {
                gl.glDeleteBuffers(1, &self.id);
            }
        };
    }

    pub const Topology = enum(gl.GLenum) {
        Triangles = gl.GL_TRIANGLES,
        TriangleStrip = gl.GL_TRIANGLE_STRIP,
        Points = gl.GL_POINTS,
    };

    pub const GlVertexType = enum(gl.GLenum) { Float = gl.GL_FLOAT, Uint = gl.GL_UNSIGNED_INT };

    pub const VertexAttr = struct {
        n_components: gl.GLint,
        type: GlVertexType,

        fn size(self: *const VertexAttr) gl.GLint {
            const size_per_component: gl.GLint = switch (self.type) {
                GlVertexType.Float => @sizeOf(f32),
                GlVertexType.Uint => @sizeOf(u32),
            };
            return self.n_components * size_per_component;
        }
    };

    pub const Mesh = packed struct {
        const Id = gl.GLuint;
        id: Id,

        pub fn new() Mesh {
            var id: Id = 0;
            gl.glGenVertexArrays(1, &id);

            return Mesh{ .id = id };
        }

        pub fn with_vertex_attrs(self: Mesh, attrs: []const VertexAttr) Mesh {
            self.bind();

            var stride: gl.GLint = 0;
            for (attrs) |attr| {
                stride += attr.size();
            }
            std.debug.print("calculated vertex stride: {d}\n", .{stride});

            var offset: usize = 0;
            for (0.., attrs) |idx, attr| {
                switch (attr.type) {
                    GlVertexType.Float => gl.glVertexAttribPointer(
                        @intCast(idx),
                        attr.n_components,
                        @intFromEnum(attr.type),
                        gl.GL_FALSE,
                        stride,
                        @ptrFromInt(offset),
                    ),
                    GlVertexType.Uint => gl.glVertexAttribIPointer(
                        @intCast(idx),
                        attr.n_components,
                        @intFromEnum(attr.type),
                        stride,
                        @ptrFromInt(offset),
                    ),
                }
                gl.glEnableVertexAttribArray(@intCast(idx));

                std.debug.print(
                    "enabled vertex with {d} components and offset {d}\n",
                    .{ attr.n_components, offset },
                );
                offset += @intCast(attr.size());
            }
            return self;
        }

        pub fn bind(self: *const Mesh) void {
            gl.glBindVertexArray(self.id);
        }

        pub fn draw(self: *const Mesh, start: i32, n: i32, topo: Topology) void {
            self.bind();
            if (topo == .Points) {
                gl.glPointSize(50);
            }
            gl.glDrawArrays(@intFromEnum(topo), start, n);
        }

        pub fn drop(self: *const Mesh) void {
            gl.glDeleteVertexArrays(1, &self.id);
        }
    };
};

const VertexType = struct { [2]f32, [3]f32 };

pub fn main() !void {
    const engine = try Engine.init();
    defer engine.deinit();

    const window = try GlWindow.init("catchfire", .{ 1920, 1080 });
    std.debug.print("window size: {}x{}\n", .{ window.size[0], window.size[1] });
    defer window.deinit();

    const shader = Render.Shader.compile(VERT_SOURCE, FRAG_SOURCE);
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
