#include "GameHAT-Launcher.h"

int main()
{
    // INIT
    SDL_SetAppMetadata("GameHAT-Launcher", "v0.1", "com.eternalblue.gamehatlauncher");

    // wait for the issue to be resolved: https://github.com/libsdl-org/sdl/issues/15166 
    FILE *f = fopen("/sys/class/tty/tty0/active", "r");
    char tty_path[32] = "/dev/tty0";
    if (f) {
        char name[16];
        if (fscanf(f, "%15s", name) == 1)
            SDL_snprintf(tty_path, sizeof(tty_path), "/dev/%s", name);
        fclose(f);
    }

    int tty_fd = open(tty_path, O_RDWR);
    fprintf(stderr, "tty: %s fd=%d\n", tty_path, tty_fd);
    // if (tty_fd >= 0) {
    //     int ret = ioctl(tty_fd, KDSKBMODE, K_OFF);
    //     fprintf(stderr, "KDSKBMODE: ret=%d err=%s\n", ret, ret < 0 ? strerror(errno) : "ok");
    // }

    Games games;
    games.path = "/usr/local/games";
    games.current = 0;
    games.scroll = 0;

    if (!(games.list = SDL_GlobDirectory(games.path, NULL, SDL_GLOB_CASEINSENSITIVE, &games.num))) {
        SDL_Log("Couldn't read games directory: %s", SDL_GetError());
        return 1;
    }

    if (!SDL_Init(SDL_INIT_VIDEO)) {
        SDL_Log("Couldn't initialize SDL: %s", SDL_GetError());
        return 1;
    }

    if (tty_fd >= 0)
        ioctl(tty_fd, KDSKBMODE, K_OFF);

    SDL_Window *window = NULL;
    SDL_Renderer *renderer = NULL;

    if (!SDL_CreateWindowAndRenderer("Launcher", WIDTH, HEIGHT, SDL_WINDOW_FULLSCREEN | SDL_WINDOW_INPUT_FOCUS | SDL_WINDOW_KEYBOARD_GRABBED, &window, &renderer)) {
        SDL_Log("Couldn't create window/renderer: %s", SDL_GetError());
        return 1;
    }

    if (!SDL_SetRenderVSync(renderer, 1))
        SDL_Log("Couldn't enable VSync: %s", SDL_GetError());
    if (!SDL_HideCursor())
        SDL_Log("Couldn't hide cursor: %s", SDL_GetError());

    SDL_SetRenderLogicalPresentation(renderer, WIDTH, HEIGHT, SDL_LOGICAL_PRESENTATION_LETTERBOX);

    SDL_SetRenderDrawColor(renderer, 0, 0, 255, SDL_ALPHA_OPAQUE);
    SDL_RenderClear(renderer);
    FPS_Counter(renderer);
    printGames(renderer, &games);
    SDL_RenderPresent(renderer);

    // MAIN

    SDL_Event event;
    while (SDL_WaitEvent(&event)) {
        if (event.type == SDL_EVENT_QUIT)
            break;

        if (event.type == SDL_EVENT_KEY_DOWN) {
            // SDL_Log("%d", event.key.scancode);
            switch (event.key.scancode) {
                case SDL_SCANCODE_UP:
                    if (games.current > 0) {
                        games.current--;
                        if (games.current < games.scroll)
                            games.scroll = games.current;
                    }
                    break;
                case SDL_SCANCODE_DOWN:
                    if (games.current < games.num - 1) {
                        games.current++;
                        if (games.current >= games.scroll + MAX_VISIBLE)
                            games.scroll = games.current - MAX_VISIBLE + 1;
                    }
                    break;
                case SDL_SCANCODE_RETURN:
                    break;
                default:
                    break;
            }
        }
        if (event.type == SDL_EVENT_KEY_DOWN || event.type == SDL_EVENT_WINDOW_ENTER_FULLSCREEN || event.type == SDL_EVENT_WINDOW_EXPOSED)
        {
            SDL_SetRenderDrawColor(renderer, 0, 0, 255, SDL_ALPHA_OPAQUE);
            SDL_RenderClear(renderer);
            FPS_Counter(renderer);
            printGames(renderer, &games);
            SDL_RenderPresent(renderer);
        }
    }

    if (tty_fd >= 0) {
        ioctl(tty_fd, KDSKBMODE, K_UNICODE);
        close(tty_fd);
    }

    SDL_free(games.list);

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}
