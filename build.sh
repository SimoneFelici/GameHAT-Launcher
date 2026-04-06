#!/bin/bash

mkdir out/

gcc src/*.c -O3 -I/usr/include/SDL3 -lSDL3 -o out/GameHAT-Launcher

sudo rm /usr/local/bin/GameHAT-Launcher && sudo cp out/GameHAT-Launcher /usr/local/bin/
