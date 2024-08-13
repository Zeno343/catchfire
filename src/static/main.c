#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <emscripten.h>
#include <emscripten/stack.h>
#include "SDL2/SDL.h"

extern int em_init();
extern bool em_run();

int main() {
    em_init();
    emscripten_set_main_loop((void*)em_run, 0, 1);
    return 0;
}
