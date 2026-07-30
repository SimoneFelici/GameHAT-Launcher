const std = @import("std");
const rl = @import("raylib");
const Context = @import("context.zig").Context;

pub fn main(init: std.process.Init) anyerror!void {
    var font_size: f32 = 48;
    const spacing: f32 = 5;

    var ctx: Context = .{
        .io = init.io,
        .gpa = init.gpa,
        .arena = init.arena.allocator(),
        .environ = init.environ_map,
    };
    ctx.loadConfig();
    try ctx.listGames();
    const config = &ctx.config;

    rl.setConfigFlags(.{ .fullscreen_mode = true });
    rl.initWindow(800, 450, "Game-Hat Launcher");
    defer rl.closeWindow();

    rl.setWindowFocused();
    rl.hideCursor();
    rl.enableEventWaiting();

    const monitor = rl.getCurrentMonitor();
    const screenW = rl.getMonitorWidth(monitor);
    const screenH = rl.getMonitorHeight(monitor);
    const screenWidth: f32 = @floatFromInt(screenW);
    const screenHeight: f32 = @floatFromInt(screenH);
    const font = try rl.getFontDefault();

    font_size = @divExact((screenWidth + screenHeight), 20);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(config.bg_color);

        for (ctx.games.items, 0..) |game, i| {
            const size = rl.measureTextEx(font, game.name, font_size, spacing);
            const pos: rl.Vector2 = .{
                .x = (screenWidth - size.x) / 2,
                .y = @as(f32, @floatFromInt(i)) * (size.y + 5),
            };
            rl.drawTextEx(font, game.name, pos, font_size, spacing, config.txt_color);
        }
        rl.drawFPS(0, 0);
    }
}
