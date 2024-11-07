const std = @import("std");
const sdl = @import("sdl.zig");

pub const Window = extern struct {
    window: *sdl.SDL_Window,
    gfx: sdl.SDL_GLContext,

    pub const Error = error{
        InitSdl,
        CreateWindow,
    };

    pub fn init(name: [*]const u8, dim: ?[2]i32) !Window {
        if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) return Error.InitSdl;
        const x = sdl.SDL_WINDOWPOS_UNDEFINED;
        const y = sdl.SDL_WINDOWPOS_UNDEFINED;

        const w = if (dim) |_dim| _dim[0] else 0;
        const h = if (dim) |_dim| _dim[1] else 0;

        const win_type: u32 = if (dim) |_| 0 else sdl.SDL_WINDOW_FULLSCREEN_DESKTOP;
        const attrs: u32 = @as(u32, sdl.SDL_WINDOW_OPENGL) | win_type;

        if (sdl.SDL_CreateWindow(name, x, y, w, h, attrs)) |window| {
            // _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
            // _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MINOR_VERSION, 3);
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
};
