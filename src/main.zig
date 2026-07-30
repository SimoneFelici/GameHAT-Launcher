const std = @import("std");
const rl = @import("raylib");
const Context = @import("context.zig").Context;

pub fn main(init: std.process.Init) anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    var ctx: Context = .{
        .io = init.io,
        .gpa = init.gpa,
        .environ = init.environ_map,
    };
    ctx.loadConfig();
    const config = &ctx.config;

    try ctx.listGames();
    // game_list = listGames(config.games_dir);
    // defer ctx.gpa.free(game_list);

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
