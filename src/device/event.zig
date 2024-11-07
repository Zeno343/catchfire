const sdl = @import("sdl.zig");

pub const Event = union(EventType) {
    Quit: void,
    KeyDown: KeyCode,
};

pub const EventType = enum(u32) {
    Quit = sdl.SDL_QUIT,
    KeyDown = sdl.SDL_KEYDOWN,
};

pub const KeyCode = enum(u32) {
    Esc = sdl.SDLK_ESCAPE,
};
