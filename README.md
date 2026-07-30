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

```bash
zig build gamehat -Dsysroot=<sysroot_path>

scp zig-out/gamehat/GameHAT_Launcher zig-out/gamehat/libraylib.so <dietpi>:/tmp

ssh dietpi

cp /tmp/libraylib.so /usr/local/lib/
cp /tmp/GameHAT_Launcher /usr/local/bin/
```
