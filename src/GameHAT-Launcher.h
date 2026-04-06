#pragma once

#include <SDL3/SDL.h>
#include <SDL3/SDL_init.h>
#include <dirent.h>

#define WIDTH 1280.0f
#define HEIGHT 720.0f

typedef struct Games {
    int num;
    int current;
    char **list;
    char *path;
} Games;

// utils.c
void FPS_Counter(SDL_Renderer *renderer);
void printGames(SDL_Renderer *renderer, Games *games);
