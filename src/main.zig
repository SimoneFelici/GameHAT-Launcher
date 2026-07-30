const std = @import("std");
const rl = @import("raylib");
const Context = @import("context.zig").Context;

pub fn main(init: std.process.Init) anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    var ctx: Context = .{
        .io = init.io,
        .gpa = init.gpa,
        .arena = init.arena.allocator(),
        .environ = init.environ_map,
    };

    ctx.loadConfig();
    try ctx.listGames();

    const config = &ctx.config;

    rl.initWindow(screenWidth, screenHeight, "Game-Hat Launcher");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(config.bg_color);

        var y: i32 = 40;
        for (ctx.games.items) |game| {
            rl.drawText(game.name, 40, y, 20, config.txt_color);
            y += 30;
        }
    }
}
