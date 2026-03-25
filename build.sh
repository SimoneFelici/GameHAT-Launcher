#!/bin/bash

mkdir out/

gcc src/*.c -O3 -I/usr/include/SDL3 -lSDL3 -o out/GameHAT-Launcher
