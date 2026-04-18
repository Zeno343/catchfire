const cimgui = @cImport({
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

    pub fn init(window: *anyopaque, gfx: *anyopaque) !Gui {
        const ctx = cimgui.igCreateContext(null).?;
        _ = cimgui.ImGui_ImplSDL3_InitForOpenGL(@ptrCast(window), @ptrCast(gfx));
        _ = cimgui.ImGui_ImplOpenGL3_Init("#version 330 ES");

        return .{
            .ctx = ctx,
        };
    }

    pub fn deinit(self: Gui) void {
        cimgui.ImGui_ImplOpenGL3_Shutdown();
        cimgui.ImGui_ImplSDL3_Shutdown();
        cimgui.igDestroyContext(self.ctx);
    }
};
