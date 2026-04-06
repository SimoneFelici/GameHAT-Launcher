#pragma once

#include <SDL3/SDL.h>
#include <SDL3/SDL_init.h>
#include <dirent.h>

#define WIDTH 640.0f
#define HEIGHT 480.0f

typedef struct Games {
    int num;
    int current;
    char **list;
    char *path;
} Games;

// utils.c
void FPS_Counter(SDL_Renderer *renderer);
void printGames(SDL_Renderer *renderer, Games *games);
