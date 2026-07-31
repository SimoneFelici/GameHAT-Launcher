const std = @import("std");
const rl = @import("raylib");
const Context = @import("context.zig").Context;

pub fn main(init: std.process.Init) anyerror!void {
    const spacing: f32 = 5;
    var select: usize = 0;
    var start: usize = 0;

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
    rl.initWindow(480, 320, "Game-Hat Launcher");
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
    const font_size = @divTrunc(@min(screenWidth, screenHeight), config.text_scale);

    while (!rl.windowShouldClose()) {
        if (ctx.games.items.len > 0) {
            if (rl.isKeyPressed(.enter)) {
                std.log.info("Launched game: {s}", .{ctx.games.items[select].name});
            }
            if (rl.isKeyDown(.down)) {
                select = (select + 1) % ctx.games.items.len;
            }
            if (rl.isKeyDown(.up)) {
                select = if (select == 0) ctx.games.items.len - 1 else select - 1;
            }

            if (select < start) {
                start = select;
            } else if (select >= start + config.max_view) {
                start = select - config.max_view + 1;
            }
        }
        const end = @min(start + config.max_view, ctx.games.items.len);

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(config.bg_color);

        const visible = ctx.games.items[start..end];
        for (visible, start..) |game, i| {
            const size = rl.measureTextEx(font, game.name, font_size, spacing);
            const pos: rl.Vector2 = .{
                .x = (screenWidth - size.x) / 2,
                .y = @as(f32, @floatFromInt(i - start)) * (size.y + 5),
            };
            const color = if (i == select) config.hg_color else config.txt_color;
            rl.drawTextEx(font, game.name, pos, font_size, spacing, color);
        }
        rl.drawFPS(0, 0);
    }
}
