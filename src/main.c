#include "GameHAT-Launcher.h"
#include <stdio.h>

int main(int argc, char *argv[])
{
    // INIT
    SDL_SetAppMetadata("GameHAT-Launcher", "v0.1", "com.eternalblue.gamehatlauncher");

    Games games;
    games.path = "/usr/local/games";
    games.current = 0;

    if (!(games.list = SDL_GlobDirectory(games.path, NULL, SDL_GLOB_CASEINSENSITIVE, &games.num))) {
        SDL_Log("Couldn't read games directory: %s", SDL_GetError());
        return 1;
    }

    if (!SDL_Init(SDL_INIT_VIDEO)) {
        SDL_Log("Couldn't initialize SDL: %s", SDL_GetError());
        return 1;
    }

    SDL_Window *window = NULL;
    SDL_Renderer *renderer = NULL;

    if (!SDL_CreateWindowAndRenderer("Launcher", WIDTH, HEIGHT, SDL_WINDOW_FULLSCREEN, &window, &renderer)) {
        SDL_Log("Couldn't create window/renderer: %s", SDL_GetError());
        return 1;
    }

    if (!SDL_SetRenderVSync(renderer, 1))
        SDL_Log("Couldn't enable VSync: %s", SDL_GetError());
    if (!SDL_HideCursor())
        SDL_Log("Couldn't hide cursor: %s", SDL_GetError());

    SDL_SetRenderLogicalPresentation(renderer, WIDTH, HEIGHT, SDL_LOGICAL_PRESENTATION_LETTERBOX);

    // MAIN
    SDL_SetRenderDrawColor(renderer, 0, 0, 255, SDL_ALPHA_OPAQUE);
    SDL_RenderClear(renderer);
    FPS_Counter(renderer);
    printGames(renderer, &games);
    SDL_RenderPresent(renderer);

    SDL_Event event;
    while (SDL_WaitEvent(&event)) {
        if (event.type == SDL_EVENT_QUIT)
            break;

        if (event.type == SDL_EVENT_KEY_DOWN) {
            switch (event.key.scancode) {
                case SDL_SCANCODE_UP:
                    if (games.current > 0) games.current--;
                    break;
                case SDL_SCANCODE_DOWN:
                    if (games.current < games.num - 1) games.current++;
                    break;
                case SDL_SCANCODE_RETURN:
                    break;
                default:
                    break;
            }
            SDL_SetRenderDrawColor(renderer, 0, 0, 255, SDL_ALPHA_OPAQUE);
            SDL_RenderClear(renderer);
            FPS_Counter(renderer);
            printGames(renderer, &games);
            SDL_RenderPresent(renderer);
        }
    }

    SDL_free(games.list);

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}
