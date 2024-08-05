pub const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_opengl.h");
});

pub const GL = @cImport({
    @cDefine("GL_GLEXT_PROTOTYPES", "");
    @cInclude("GL/gl.h");
    @cInclude("GL/glext.h");
});
