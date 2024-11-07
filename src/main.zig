const std = @import("std");
const lib = @import("lib.zig");

const NAME = "catchfire v0.1";
pub fn main() !void {
    const engine = try lib.Engine.init(NAME);
    std.debug.print("runtime initialized, entering main loop\n", .{});
    while (engine.run()) {}

    std.debug.print("exited main loop\n", .{});
}
