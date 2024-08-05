const Font = @This();

const std = @import("std");
usingnamespace @import("sys.zig");

const Error = error{TtfError};
ttf: *.TTF_Font,

pub fn from_file(path: [*:0]u8, size: i32) !Font {
    if (.TTF_OpenFont(path, size)) |ttf| {
        return Font{ .ttf = ttf };
    } else return Error.TtfError;
}

pub fn drop(self: Font) void {
    .TTF_CloseFont(self.ttf);
}
