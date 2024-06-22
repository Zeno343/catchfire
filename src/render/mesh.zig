const Mesh = @This();
const gl = @import("gl_sys.zig");

const Id = gl.GLuint;
id: Id,

pub fn new() Mesh {
    var id: Id = 0;
    gl.glGenVertexArrays(1, &id);

    return Mesh{ .id = id };
}

pub fn draw(self: *const Mesh, n: i32) void {
    gl.glBindVertexArray(self.id);
    gl.glDrawArrays(gl.GL_TRIANGLES, 0, n);
}

pub fn drop(self: *const Mesh) void {
    gl.glDeleteVertexArrays(1, self.id);
}
