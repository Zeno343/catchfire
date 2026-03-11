const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_opengl.h");
});

const Engine = struct {
    const Event = struct {
        event: sdl.SDL_Event,
        type: enum(u32) {
            Quit = sdl.SDL_EVENT_QUIT,
            _,
        },
    };

    pub fn init() !Engine {
        if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) return error.InitSdl else {
            std.debug.print("system initialized\n", .{});
            return .{};
        }
    }

    pub fn deinit(_: *const Engine) void {
        sdl.SDL_Quit();
        std.debug.print("system deinitialized\n", .{});
    }

    pub fn poll(_: *const Engine) ?Event {
        var event: sdl.SDL_Event = undefined;
        if (sdl.SDL_PollEvent(&event)) {
            return .{
                .event = event,
                .type = @enumFromInt(event.type),
            };
        } else {
            return null;
        }
    }
};

pub const GlWindow = extern struct {
    window: *sdl.SDL_Window,
    gfx: sdl.SDL_GLContext,
    size: [2]i32,

    pub const Error = error{
        InitFailed,
        DeinitFailed,
        SwapFailed,
        SizeError,
    };

    pub fn init(name: [*]const u8, size: ?[2]i32) !GlWindow {
        const _size = size orelse .{ 0, 0 };
        var w = _size[0];
        var h = _size[1];

        const win_type: u32 = if (size) |_| 0 else sdl.SDL_WINDOW_FULLSCREEN;
        const attrs: u32 = @as(u32, sdl.SDL_WINDOW_OPENGL) | win_type;

        if (sdl.SDL_CreateWindow(name, w, h, attrs)) |window| {
            _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
            _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MINOR_VERSION, 3);
            const gfx = sdl.SDL_GL_CreateContext(window);
            std.debug.print("window initialized\n", .{});

            _ = sdl.SDL_SyncWindow(window);
            if (!sdl.SDL_GetWindowSizeInPixels(window, &w, &h) or (w != _size[0]) or (h != _size[1]))
                return Error.SizeError;

            return GlWindow{
                .window = window,
                .size = .{ w, h },
                .gfx = gfx,
            };
        } else return Error.InitFailed;
    }

    pub fn swap(self: *const GlWindow) !void {
        if (sdl.SDL_GL_SwapWindow(self.window)) return else return Error.SwapFailed;
    }

    pub fn deinit(self: *const GlWindow) void {
        if (sdl.SDL_GL_DestroyContext(self.gfx)) {
            sdl.SDL_DestroyWindow(self.window);
            std.debug.print("window deinitialized\n", .{});
        } else {
            @panic("Error deinitializing Gl context");
        }
    }
};

const Render = struct {
    const gl = @cImport({
        @cDefine("GL_GLEXT_PROTOTYPES", "");
        @cInclude("SDL3/SDL_opengl.h");
        @cInclude("GL/gl.h");
        @cInclude("GL/glext.h");
    });

    pub fn clear() void {
        gl.glClearColor(1.0, 0.0, 0.0, 0.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);
    }

    pub fn viewport(x: i32, y: i32, w: i32, h: i32) void {
        gl.glViewport(x, y, w, h);
    }
};

pub fn main() !void {
    const engine = try Engine.init();
    defer engine.deinit();

    const window = try GlWindow.init("catchfire", .{ 1920, 1080 });
    std.debug.print("window size: {}x{}\n", .{ window.size[0], window.size[1] });
    defer window.deinit();

    Render.clear();
    try window.swap();

    var quit = false;
    while (!quit) {
        while (engine.poll()) |event| {
            switch (event.type) {
                .Quit => quit = true,
                _ => {},
            }
        }
    }
}
