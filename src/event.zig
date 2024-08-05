const SDL = @import("c").SDL;

pub const Event = union(EventType) {
    Quit: void,
    KeyDown: KeyCode,
};

pub const EventType = enum(u32) {
    Quit = SDL.SDL_QUIT,
    KeyDown = SDL.SDL_KEYDOWN,
};

pub const KeyCode = enum(u32) {
    Esc = SDL.SDLK_ESCAPE,
};

pub fn poll() ?Event {
    var event: SDL.SDL_Event = undefined;
    if (SDL.SDL_PollEvent(&event) == 0) {
        return null;
    } else {
        return switch (event.type) {
            SDL.SDL_QUIT => .Quit,
            SDL.SDL_KEYDOWN => switch (event.key.keysym.sym) {
                SDL.SDLK_ESCAPE => Event{
                    .KeyDown = .Esc,
                },
                else => null,
            },
            else => null,
        };
    }
}
