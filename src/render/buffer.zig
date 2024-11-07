const std = @import("std");
const gl = @import("gl.zig");

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
