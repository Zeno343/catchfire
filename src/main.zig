const std = @import("std");
const CTCF = @import("lib.zig");

const name = "catchfire v0.1";

pub fn main() !void {
    const rt = try CTCF.Runtime.init();
    main: while (true) {
        if (!rt.run()) {
            break :main;
        }
    }
}
