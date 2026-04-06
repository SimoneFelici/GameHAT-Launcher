#pragma once

#include <SDL3/SDL.h>
#include <SDL3/SDL_init.h>
#include <dirent.h>
#include <linux/kd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

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

// utils.c
void FPS_Counter(SDL_Renderer *renderer);
void printGames(SDL_Renderer *renderer, Games *games);
