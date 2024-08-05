const std = @import("std");
const Event = @import("event.zig");
const Window = @import("window.zig").Window;
const Render = @import("render/mod.zig").Render;

const NAME = "catchfire v0.1";
const VERT = @embedFile("shaders/rgb.vert");
const FRAG = @embedFile("shaders/rgb.frag");

pub const Runtime = extern struct {
    const SDL = @import("c").SDL;
    pub const Err = error{
        SdlInit,
        WindowInit,
    };

    window: Window,

    pub fn init() !Runtime {
        if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO) != 0) return Err.SdlInit;

        const window = Window.init(NAME, null) catch {
            std.debug.print("window creation failed\n", .{});
            return Err.WindowInit;
        };

        std.debug.print("{s} window created\n", .{NAME});
        return .{ .window = window };
    }

    pub fn run(self: Runtime) bool {
        while (Event.poll()) |event| {
            switch (event) {
                .Quit => {
                    self.drop();
                    return false;
                },

                .KeyDown => |keycode| {
                    switch (keycode) {
                        .Esc => {
                            self.drop();
                            return false;
                        },
                    }
                },
            }
        }

        return true;
    }

    fn drop(self: Runtime) void {
        std.debug.print("exiting\n", .{});
        self.window.drop();
        SDL.SDL_Quit();
    }
};

var EM_RT: Runtime = undefined;

pub export fn em_init() i32 {
    EM_RT = Runtime.init() catch {
        std.debug.print("runtime init failed\n", .{});
        return 1;
    };

    std.debug.print("runtime initialized\n", .{});
    return 0;
}

pub export fn em_run() bool {
    return EM_RT.run();
}
