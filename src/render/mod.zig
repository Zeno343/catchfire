pub const Shader = @import("shader.zig");
pub const Mesh = @import("mesh.zig");

pub fn clear() void {
    const gl = @import("gl_sys.zig");
    gl.glClearColor(0.0, 0.0, 0.0, 0.0);
    gl.glClear(gl.GL_COLOR_BUFFER_BIT);
}
