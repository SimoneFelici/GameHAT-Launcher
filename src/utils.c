#include "GameHAT-Launcher.h"
#include <SDL3/SDL_stdinc.h>

int startGame(Games *games)
{
    char *game_path;
    size_t len = SDL_strlen(games->path) + SDL_strlen(games->list[games->current]) + 2;
    game_path = (char *)SDL_calloc(1, len);
    SDL_snprintf(game_path, len, "%s/%s", games->path, games->list[games->current]);
    SDL_Log("Game path: %s", game_path);

    SDL_free(game_path);
    return(0);
}

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
    // SDL_Log("%s\n", fps_text);
}

void printGames(SDL_Renderer *renderer, Games *games) {
    int start = games->scroll;
    int end = start + MAX_VISIBLE;
    float scale = 2.0f;
    float char_w = 8.0f;
    float char_h = 8.0f;
    float spacing = 24.0f;

    if (end > games->num)
        end = games->num;

    int visible = end - start;
    float total_h = visible * spacing - (spacing - char_h);
    float start_y = (HEIGHT / scale - total_h) / 2.0f;

    SDL_SetRenderScale(renderer, scale, scale);

    for (int i = start; i < end; ++i) {
        float text_w = strlen(games->list[i]) * char_w;
        float x = (WIDTH / scale - text_w) / 2.0f;
        float y = start_y + (i - start) * spacing;

        if (i == games->current)
            SDL_SetRenderDrawColor(renderer, 255, 0, 144, SDL_ALPHA_OPAQUE);
        else
            SDL_SetRenderDrawColor(renderer, 255, 255, 255, SDL_ALPHA_OPAQUE);

        SDL_RenderDebugText(renderer, x, y, games->list[i]);
    }

    SDL_SetRenderScale(renderer, 1.0f, 1.0f);
}
