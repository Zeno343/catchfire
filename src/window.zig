const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_opengl.h");
});

const Window = @This();

window: *sdl.SDL_Window,
gfx: sdl.SDL_GLContext,

pub const Error = error{
    InitSdl,
    CreateWindow,
};

pub fn init(name: [*]const u8) !Window {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) return Error.InitSdl;
    const pos = .{ sdl.SDL_WINDOWPOS_UNDEFINED, sdl.SDL_WINDOWPOS_UNDEFINED };
    const attrs = sdl.SDL_WINDOW_SHOWN | sdl.SDL_WINDOW_OPENGL | sdl.SDL_WINDOW_FULLSCREEN_DESKTOP;
    if (sdl.SDL_CreateWindow(name, pos[0], pos[1], 0, 0, attrs)) |window| {
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MAJOR_VERSION, 4);
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MINOR_VERSION, 6);
        const gfx = sdl.SDL_GL_CreateContext(window);
        std.debug.print("window created\n", .{});

        return Window{
            .window = window,
            .gfx = gfx,
        };
    } else return Error.CreateWindow;
}

pub fn swap(self: *const Window) void {
    sdl.SDL_GL_SwapWindow(self.window);
}

pub const Event = enum {
    Quit,
};

pub fn poll(_: *const Window) ?Event {
    var event: sdl.SDL_Event = undefined;
    if (sdl.SDL_PollEvent(&event) == 0) {
        return null;
    } else {
        return switch (event.type) {
            sdl.SDL_QUIT => Event.Quit,
            else => null,
        };
    }
}

pub fn drop(self: *const Window) void {
    sdl.SDL_GL_DeleteContext(self.gfx);
    sdl.SDL_DestroyWindow(self.window);
    sdl.SDL_Quit();

    std.debug.print("window dropped\n", .{});
}

pub fn size(self: *const Window) [2]i32 {
    var w: i32 = 0;
    var h: i32 = 0;

    sdl.SDL_GL_GetDrawableSize(self.window, &w, &h);
    return .{ w, h };
}
