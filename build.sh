#!/bin/bash

mkdir -p out/
gcc src/*.c -O3 -I/usr/include/SDL3 -lSDL3 -o out/GameHAT-Launcher
sudo cp out/GameHAT-Launcher /usr/local/bin/
sudo setcap cap_sys_tty_config+ep /usr/local/bin/GameHAT-Launcher
