#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <emscripten.h>
#include <emscripten/stack.h>

#define GL_GLEXT_PROTOTYPES
#include "SDL2/SDL.h"
#include "SDL2/SDL_opengl.h"
#include "SDL2/SDL_opengl_glext.h"

extern int em_init();
extern bool em_run();

int main() {
    em_init();
    emscripten_set_main_loop((void*)em_run, 0, 1);
    return 0;
}
