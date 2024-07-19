const Window = @This();
const std = @import("std");
const sdl = @import("sys.zig");

window: *sdl.SDL_Window,
gfx: sdl.SDL_GLContext,

pub const Error = error{WindowInitFailed};

pub fn init(name: [*]const u8, dim: ?[2]i32) !Window {
    const x = sdl.SDL_WINDOWPOS_UNDEFINED;
    const y = sdl.SDL_WINDOWPOS_UNDEFINED;

    const w = if (dim) |_dim| _dim[0] else 0;
    const h = if (dim) |_dim| _dim[1] else 0;

    const win_type: u32 = if (dim) |_| 0 else sdl.SDL_WINDOW_FULLSCREEN_DESKTOP;
    const attrs: u32 = @as(u32, sdl.SDL_WINDOW_OPENGL) | win_type;

    if (sdl.SDL_CreateWindow(name, x, y, w, h, attrs)) |window| {
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MAJOR_VERSION, 4);
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MINOR_VERSION, 6);
        const gfx = sdl.SDL_GL_CreateContext(window);
        std.debug.print("window created\n", .{});

        return Window{
            .window = window,
            .gfx = gfx,
        };
    } else return Error.WindowInitFailed;
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

    std.debug.print("window dropped\n", .{});
}

pub fn size(self: *const Window) [2]i32 {
    var w: i32 = 0;
    var h: i32 = 0;

    sdl.SDL_GL_GetDrawableSize(self.window, &w, &h);
    return .{ w, h };
}
