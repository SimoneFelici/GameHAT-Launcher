const std = @import("std");
const rl = @import("raylib");
const Context = @import("context.zig").Context;

pub fn main(init: std.process.Init) anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;
    const font_size: f32 = 20;
    const spacing: f32 = 2;

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

        for (ctx.games.items, 0..) |game, i| {
            const size = rl.measureTextEx(try rl.getFontDefault(), game.name, font_size, spacing);
            const pos: rl.Vector2 = .{
                .x = (@as(f32, screenWidth) - size.x) / 2,
                .y = @as(f32, @floatFromInt(i)) * (size.y + 5),
            };
            rl.drawTextEx(try rl.getFontDefault(), game.name, pos, font_size, spacing, config.txt_color);
        }
    }
}
