const sdl = @import("sdl.zig");
pub usingnamespace @import("window.zig");
pub usingnamespace @import("event.zig");

const Event = @This().Event;

pub fn poll() ?Event {
    var event: sdl.SDL_Event = undefined;
    if (sdl.SDL_PollEvent(&event) == 0) {
        return null;
    } else {
        return switch (event.type) {
            sdl.SDL_QUIT => .Quit,
            sdl.SDL_KEYDOWN => switch (event.key.keysym.sym) {
                sdl.SDLK_ESCAPE => Event{
                    .KeyDown = .Esc,
                },
                else => null,
            },
            else => null,
        };
    }
}
