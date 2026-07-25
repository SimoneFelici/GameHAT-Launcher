#pragma once

#include <SDL3/SDL.h>
#include <SDL3/SDL_init.h>
#include <dirent.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>

#define WIDTH 480.0f
#define HEIGHT 320.0f
#define MAX_VISIBLE 5

typedef struct Games {
    int num;
    int current;
    int scroll;
    char **list;
    char *path;
} Games;

typedef enum Action {
    ACT_NONE,
    ACT_UP,
    ACT_DOWN,
    ACT_RELOAD,
    ACT_START
} Action;

// utils.c

int startGame(Games *games);
int reloadFolder(Games *games);
void FPS_Counter(SDL_Renderer *renderer);
void printGames(SDL_Renderer *renderer, Games *games);
