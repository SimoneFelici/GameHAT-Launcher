# GameHAT-Launcher
Very simple game launcher

## Install

## Build from source

```bash
zig build
```

### Cross Building

```bash
mkdir ~/sysroot-gamehat

docker run --rm -it --platform linux/arm64 -v ~/sysroot-gamehat:/sysroot debian:trixie bash

apt update
apt install -y libgl1-mesa-dev libx11-dev libxrandr-dev libxinerama-dev libxi-dev libxcursor-dev libxext-dev libxfixes-dev libwayland-dev libxkbcommon-dev
mkdir -p /sysroot/usr/include /sysroot/usr/lib/aarch64-linux-gnu
cp -r /usr/include/* /sysroot/usr/include/
cp -r /usr/lib/aarch64-linux-gnu/* /sysroot/usr/lib/aarch64-linux-gnu/
```
