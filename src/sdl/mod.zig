const SDL = @This();

pub const Window = @import("window.zig");
const sdl = @import("sys.zig");

pub const Error = error{
    SdlInitFailed,
    TtfInitFailed,
};

pub fn init() !SDL {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) return Error.SdlInitFailed;
    return .{};
}

pub fn drop(self: SDL) void {
    _ = self;
    sdl.SDL_Quit();
}
