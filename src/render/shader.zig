const std = @import("std");
const gl = @import("gl.zig");

pub const Shader = packed struct {
    id: gl.GLuint,

    const Source = struct {
        id: gl.GLuint,
        stage: Stage,

        pub const Stage = enum(gl.GLenum) {
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

    pub fn bind(self: *const Shader) void {
        gl.glUseProgram(self.id);
    }

    pub fn drop(self: *const Shader) void {
        gl.glDeleteProgram(self.id);
    }
};
