const std = @import("std");
const gl = @import("gl.zig");
const Buffer = @import("buffer.zig");

pub const Topology = enum(gl.GLenum) {
    Triangles = gl.GL_TRIANGLES,
};

pub const VertexType = enum(gl.GLenum) { Float = gl.GL_FLOAT };

pub const VertexAttr = struct {
    n_components: gl.GLint,
    type: VertexType,

    fn size(self: *const VertexAttr) gl.GLint {
        return self.n_components * switch (self.type) {
            VertexType.Float => @sizeOf(f32),
        };
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
            gl.glVertexAttribPointer(@intCast(idx), attr.n_components, @intFromEnum(attr.type), gl.GL_FALSE, stride, @ptrFromInt(offset));
            gl.glEnableVertexAttribArray(@intCast(idx));

            std.debug.print("enabled vertex with {d} components and offset {d}\n", .{ attr.n_components, offset });
            offset += @intCast(attr.size());
        }
        return self;
    }

    pub fn bind(self: *const Mesh) void {
        gl.glBindVertexArray(self.id);
    }

    pub fn draw(self: *const Mesh, n: i32, topo: Topology) void {
        self.bind();
        gl.glDrawArrays(@intFromEnum(topo), 0, n);
    }

    pub fn drop(self: *const Mesh) void {
        gl.glDeleteVertexArrays(1, self.id);
    }
};
