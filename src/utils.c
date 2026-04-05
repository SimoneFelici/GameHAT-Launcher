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
    SDL_SetRenderScale(renderer, 1.5f, 1.5f);
    SDL_RenderDebugText(renderer, 5, 5, fps_text);
    SDL_SetRenderScale(renderer, 1.0f, 1.0f);
    // SDL_Log("%s\n", fps_text);
}

void printGames(SDL_Renderer *renderer, Games *games) {
    int max_visible = 5;
    
    int start = 0;
    if (games->current >= max_visible)
        start = games->current - max_visible + 1;

    int end = start + max_visible;
    if (end > games->num)
        end = games->num;

    float scale = 2.0f;
    float char_w = 8.0f;
    float spacing = 24.0f;

    int visible = end - start;
    float total_h = visible * spacing - (spacing - 8.0f);
    float start_y = (HEIGHT / scale - total_h) / 2.0f;

    SDL_SetRenderScale(renderer, scale, scale);

    for (int i = start; i < end; ++i) {
        float text_w = strlen(games->list[i]) * char_w;
        float x = (WIDTH / scale - text_w) / 2.0f;
        float y = start_y + (i - start) * spacing;

        if (i == games->current)
            SDL_SetRenderDrawColor(renderer, 255, 0, 144, SDL_ALPHA_OPAQUE);
            // SDL_SetRenderDrawColor(renderer, 0, 255, 0, SDL_ALPHA_OPAQUE);
        else
            SDL_SetRenderDrawColor(renderer, 255, 255, 255, SDL_ALPHA_OPAQUE);

        SDL_RenderDebugText(renderer, x, y, games->list[i]);
    }

    SDL_SetRenderScale(renderer, 1.0f, 1.0f);
}
