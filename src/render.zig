const std = @import("std");
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

pub const Shader = struct {
    id: gl.GLuint,

    const Source = struct {
        id: gl.GLuint,
        stage: Stage,

        const Stage = enum(gl.GLenum) {
            Vertex = gl.GL_VERTEX_SHADER,
            Fragment = gl.GL_FRAGMENT_SHADER,
        };

        pub fn compile(src: [*]const u8, stage: Stage) !Source {
            const id = gl.glCreateShader(@intFromEnum(stage));
            gl.glShaderSource(id, 1, &[_][*]const u8{src}, null);
            gl.glCompileShader(id);

            var isCompiled: gl.GLint = 0;
            gl.glGetShaderiv(id, gl.GL_COMPILE_STATUS, &isCompiled);
            if (isCompiled == gl.GL_FALSE) {
                return error.ShaderCompilationError;
            }

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

    pub fn compile(vert: [*]const u8, frag: [*]const u8) !Shader {
        const id = gl.glCreateProgram();
        const vert_shader = try Source.compile(vert, Source.Stage.Vertex);
        const frag_shader = try Source.compile(frag, Source.Stage.Fragment);
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

pub const Uniform = struct {
    pub fn float(location: gl.GLunit, uniform: f32) void {
        gl.glUniform1f(location, uniform);
    }
};
