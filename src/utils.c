#include "GameHAT-Launcher.h"

void FPS_Counter(SDL_Renderer *renderer) {
    static Uint64 last = 0;
    static int frames = 0;
    static char fps_text[16] = "FPS: 0";
    
    Uint64 now = SDL_GetPerformanceCounter();
    frames++;

    double elapsed = (double)(now - last) / SDL_GetPerformanceFrequency();
    if (elapsed >= 1.0) {
        SDL_snprintf(fps_text, sizeof(fps_text), "FPS: %d", frames);
        frames = 0;
        last = now;
    }

    SDL_SetRenderDrawColor(renderer, 255, 255, 255, SDL_ALPHA_OPAQUE);
    SDL_RenderDebugText(renderer, 5, 5, fps_text);
    SDL_Log("%s\n", fps_text);
}

