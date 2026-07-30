const std = @import("std");
const rl = @import("raylib");
const Config = @import("config.zig").Config;

pub fn main(init: std.process.Init) anyerror!void {
    const gpa = init.gpa;
    const io = init.io;
    const environ = init.environ_map;

    const screenWidth = 800;
    const screenHeight = 450;

    const config = Config.init(io, gpa, environ);

    rl.initWindow(screenWidth, screenHeight, "Game-Hat Launcher");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(config.bg_color);
        rl.drawText(
            "Congrats! You created your first window!",
            190,
            200,
            20,
            config.txt_color,
        );
    }
}
