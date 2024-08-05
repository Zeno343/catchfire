pub usingnamespace @import("shader.zig");
pub usingnamespace @import("mesh.zig");
pub usingnamespace @import("buffer.zig");

const sdl = @import("c").SDL;
const gl = @import("c").GL;

pub fn clear() void {
    gl.glClearColor(0.0, 0.0, 0.0, 0.0);
    gl.glClear(.GL_COLOR_BUFFER_BIT);
}

pub fn viewport(x: i32, y: i32, w: i32, h: i32) void {
    gl.glViewport(x, y, w, h);
}
