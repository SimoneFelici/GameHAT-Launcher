#include "GameHAT-Launcher.h"
#include <SDL3/SDL_render.h>

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
    SDL_SetRenderScale(renderer, 1.5f, 1.5f);
    SDL_RenderDebugText(renderer, 5, 5, fps_text);
    SDL_SetRenderScale(renderer, 1.0f, 1.0f);
    // SDL_Log("%s\n", fps_text);
}

