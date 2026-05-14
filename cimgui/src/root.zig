const std = @import("std");
pub const cimgui = @cImport({
    @cDefine("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", "1");
    @cDefine("CIMGUI_USE_SDL3", "1");
    @cDefine("CIMGUI_USE_OPENGL3", "1");
    @cInclude("cimgui.h");
    @cInclude("cimgui_impl.h");
});
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_opengl.h");
});

pub const Gui = struct {
    ctx: *cimgui.ImGuiContext,
    io: *cimgui.ImGuiIO,

    pub fn init(window: *anyopaque, gfx: *anyopaque) !Gui {
        const ctx = cimgui.igCreateContext(null).?;
        _ = cimgui.ImGui_ImplSDL3_InitForOpenGL(@ptrCast(window), @ptrCast(gfx));
        _ = cimgui.ImGui_ImplOpenGL3_Init("#version 330");
        const io = cimgui.igGetIO_Nil();
        io.*.DisplaySize = .{
            .x = 1920,
            .y = 1080,
        };

        return .{
            .ctx = ctx,
            .io = io,
        };
    }

    pub fn handleEvent(_: Gui, event: *anyopaque) void {
        _ = cimgui.ImGui_ImplSDL3_ProcessEvent(@ptrCast(event));
    }

    pub fn frame(_: Gui) void {
        cimgui.ImGui_ImplOpenGL3_NewFrame();
        cimgui.ImGui_ImplSDL3_NewFrame();
        cimgui.igNewFrame();
    }

    pub fn rgbSlider(_: Gui, rgb: *[3]f32) void {
        _ = cimgui.igBegin("rgb", null, 0);
        _ = cimgui.igSliderFloat("r:", &rgb[0], 0.0, 1.0, "%.3f", 1.0);
        _ = cimgui.igSliderFloat("g:", &rgb[1], 0.0, 1.0, "%.3f", 1.0);
        _ = cimgui.igSliderFloat("b:", &rgb[2], 0.0, 1.0, "%.3f", 1.0);
        cimgui.igEnd();
    }

    pub fn fileMenu(_: Gui, name: [*]const u8, dir: std.fs.Dir) ?std.fs.File {
        _ = cimgui.igBegin(name, null, 0);
        var iter = dir.iterate();
        var selection: ?std.fs.File = null;
        while (iter.next()) |file| {
            const filename = (file orelse break).name;
            var buf = [_]u8{0} ** 100;
            const result = std.fmt.bufPrint(&buf, "{s}\n", .{filename}) catch |err| log_error: {
                std.debug.print("{}\n", .{err});
                break :log_error "error";
            };

            if (cimgui.igButton(result.ptr, .{ .x = 0, .y = 0})) {
                std.debug.print("file selected: {s}\n", .{filename});
                selection = std.fs.cwd().openFile(filename, .{}) catch null;
            }
        } else |err| {
            std.debug.print("{}\n", .{err});
        }
        _ = cimgui.igEnd();
        return selection;
    }

    pub fn draw(_: Gui) void {
        cimgui.igRender();
        cimgui.ImGui_ImplOpenGL3_RenderDrawData(cimgui.igGetDrawData());
    }

    pub fn deinit(self: Gui) void {
        cimgui.ImGui_ImplOpenGL3_Shutdown();
        cimgui.ImGui_ImplSDL3_Shutdown();
        cimgui.igShutdown();
        cimgui.igDestroyContext(self.ctx);
    }
};
