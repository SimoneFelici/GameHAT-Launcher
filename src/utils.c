#include "GameHAT-Launcher.h"

void FPS_Counter() {
    static Uint64 last = 0;
    static int frames = 0;
    
    Uint64 now = SDL_GetPerformanceCounter();
    frames++;

    double elapsed = (double)(now - last) / SDL_GetPerformanceFrequency();
    if (elapsed >= 1.0) {
        SDL_Log("FPS: %d", frames);
        frames = 0;
        last = now;
    }
}
