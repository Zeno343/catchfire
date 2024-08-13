pub const Window = extern struct {
    const std = @import("std");
    const sdl = @import("sdl.zig");

    window: *sdl.SDL_Window,

    pub const Err = error{WindowInitFailed};
    pub fn init(name: [*]const u8, dim: ?[2]i32) !Window {
        const x = sdl.SDL_WINDOWPOS_UNDEFINED;
        const y = sdl.SDL_WINDOWPOS_UNDEFINED;

        const w = if (dim) |_dim| _dim[0] else 0;
        const h = if (dim) |_dim| _dim[1] else 0;

        const win_type: u32 = if (dim) |_| 0 else sdl.SDL_WINDOW_FULLSCREEN_DESKTOP;
        const attrs: u32 = @as(u32, sdl.SDL_WINDOW_OPENGL) | win_type;

        if (sdl.SDL_CreateWindow(name, x, y, w, h, attrs)) |window| {
            std.debug.print("window created\n", .{});
            return .{
                .window = window,
            };
        } else {
            std.debug.print("window creation failed\n", .{});
            return Err.WindowInitFailed;
        }
    }

    pub fn clear(self: Window) void {
        const surface = sdl.SDL_GetWindowSurface(self.window);
        _ = sdl.SDL_FillRect(surface, null, sdl.SDL_MapRGB(surface.*.format, 0xFF, 0xFF, 0xFF));
    }

    pub fn present(self: Window) void {
        _ = sdl.SDL_UpdateWindowSurface(self.window);
    }

    pub fn drop(self: Window) void {
        sdl.SDL_DestroyWindow(self.window);
        std.debug.print("window dropped\n", .{});
    }
};
