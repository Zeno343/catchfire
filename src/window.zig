const SDL = @import("c").SDL;
const std = @import("std");
const Render = @import("render/mod.zig");

pub const Window = extern struct {
    window: *SDL.SDL_Window,

    pub const Err = error{WindowInitFailed};
    pub fn init(name: [*]const u8, dim: ?[2]i32) !Window {
        const x = SDL.SDL_WINDOWPOS_UNDEFINED;
        const y = SDL.SDL_WINDOWPOS_UNDEFINED;

        const w = if (dim) |_dim| _dim[0] else 0;
        const h = if (dim) |_dim| _dim[1] else 0;

        const win_type: u32 = if (dim) |_| 0 else SDL.SDL_WINDOW_FULLSCREEN_DESKTOP;
        const attrs: u32 = @as(u32, SDL.SDL_WINDOW_OPENGL) | win_type;

        if (SDL.SDL_CreateWindow(name, x, y, w, h, attrs)) |window| {
            std.debug.print("window created\n", .{});
            return .{
                .window = window,
            };
        } else {
            std.debug.print("window creation failed\n", .{});
            return Err.WindowInitFailed;
        }
    }

    pub const RenderTarget = struct {
        ctx: SDL.SDL_GLContext,
        win: *SDL.SDL_Window,
        dim: [2]i32,
    };

    pub fn getRenderTarget(self: Window) RenderTarget {
        const ctx = SDL.SDL_GL_CreateContext(self.window);

        var w: i32 = 0;
        var h: i32 = 0;
        SDL.SDL_GL_GetDrawableSize(self.window, &w, &h);

        return .{
            .ctx = ctx,
            .win = self.win,
            .dim = .{ w, h },
        };
    }

    pub fn drop(self: Window) void {
        SDL.SDL_DestroyWindow(self.window);
        std.debug.print("window dropped\n", .{});
    }
};
