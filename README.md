# GameHAT-Launcher

Very simple game launcher

## Prerequisites

- install dietpi and enable autologin in "dietpi-autostart"
- install the dependencies:

```bash
apt install -y cage
```
> [!NOTE]
> In the future I probably could create a DRM build, but using cage for running the launcher and games ensure more compatibility

- configure the GameHAT controller
This step is only necessary if you are using a GameHAT, you can follow the instructions [here](https://github.com/SimoneFelici/mk_arcade_joystick_rpi)
- start
To start the launcher at startup you can copy the following `.bash_profile` in your user home directory:
```bash
if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
    export XDG_RUNTIME_DIR=/tmp/runtime-$(id -u)
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 700 "$XDG_RUNTIME_DIR"
    exec cage -- /usr/local/bin/GameHAT_Launcher > /tmp/gamehat.log 2>&1
fi
```

## Install
You can get the latest binaries here

## Build from source
Requires zig 0.16 and *some* of the following [system libraries](https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux)

```bash
git clone https://github.com/SimoneFelici/GameHAT-Launcher.git
cd GameHAT-Launcher

zig build
```

### Cross Building

```bash
mkdir <sysroot-gamehat-path>

docker run --rm -it --platform linux/arm64 -v <sysroot-gamehat-path>:/sysroot debian:trixie bash

apt update
apt install -y libwayland-dev libxkbcommon-dev libegl1-mesa-dev libgles2-mesa-dev
mkdir -p /sysroot/usr/include /sysroot/usr/lib/aarch64-linux-gnu
cp -r /usr/include/* /sysroot/usr/include/
cp -r /usr/lib/aarch64-linux-gnu/* /sysroot/usr/lib/aarch64-linux-gnu/
```

```bash
zig build gamehat -Dsysroot=<sysroot-gamehat-path> -Doptimize=ReleaseSmall
scp zig-out/gamehat/GameHAT_Launcher zig-out/gamehat/libraylib.so <dietpi-ip>:/tmp

ssh dietpi

cp /tmp/libraylib.so /usr/local/lib/
cp /tmp/GameHAT_Launcher /usr/local/bin/
sudo ldconfig
```
> [!IMPORTANT]
You only need to copy the .so and launch ldconfig for the first time, or if the build.zig changes the raylib build

## Configuration
You can configure the GameHAT-Launcher by creating a config.txt file in `~/.config/GameHAT-Launcher`
Here is the default configuration:

```bash
# Only Hex code are currently supported, I plan to support RGB in the near future!
background_color = #002b36
text_color = #839496
highlight_color = #cb4b16

# Directory where you store your games, the games needs to be in a folder
games_directory = /usr/local/games
# How many items are viewable in the screen
max_viewable_items = 5

# Text dimensions smaller value = bigger text :)
text_scale = 10
# Spacing between characters
text_spacing = 5
```

You can also customize how the game will be launched by creating a `.launchopts` file in one of your game directory.
For example:

```bash
exec = /usr/local/games/so_long/so_long
arg = maps/map.txt
arg = --fullscreen
env = TEST=test
```
