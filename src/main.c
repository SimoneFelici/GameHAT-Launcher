#include "GameHAT-Launcher.h"
#include <SDL3/SDL_init.h>

int main(int argc, char *argv[])
{
    // INIT
    SDL_SetAppMetadata("GameHAT-Launcher", "v0.1", "com.eternalblue.gamehatlauncher");

    if (!SDL_Init(SDL_INIT_VIDEO)) {
        SDL_Log("Couldn't initialize SDL: %s", SDL_GetError());
        return SDL_APP_FAILURE;
    }

    SDL_Window *window = NULL;
    SDL_Renderer *renderer = NULL;

    if (!SDL_CreateWindowAndRenderer("Launcher", 480, 320, SDL_WINDOW_FULLSCREEN, &window, &renderer)) {
        SDL_Log("Couldn't create window/renderer: %s", SDL_GetError());
        return SDL_APP_FAILURE;
    }

    if (!SDL_SetRenderVSync(renderer, 1))
        SDL_Log("Couldn't enable VSync: %s", SDL_GetError());
    if (!SDL_HideCursor())
        SDL_Log("Couldn't hide cursor: %s", SDL_GetError());

    SDL_SetRenderLogicalPresentation(renderer, 480, 320, SDL_LOGICAL_PRESENTATION_DISABLED);

    // MAIN
    SDL_SetRenderDrawColor(renderer, 0, 0, 255, SDL_ALPHA_OPAQUE);
    SDL_RenderClear(renderer);
    FPS_Counter(renderer);
    SDL_RenderPresent(renderer);

    SDL_Event event;
    while (SDL_WaitEvent(&event)) {
        if (event.type == SDL_EVENT_QUIT)
            break;

        if (event.type == SDL_EVENT_KEY_DOWN ||
            event.type == SDL_EVENT_WINDOW_RESIZED ||
            event.type == SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED ||
            event.type == SDL_EVENT_WINDOW_EXPOSED)
        {
            SDL_SetRenderDrawColor(renderer, 0, 0, 255, SDL_ALPHA_OPAQUE);
            SDL_RenderClear(renderer);
            FPS_Counter(renderer);
            SDL_RenderPresent(renderer);
        }
    }

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}
