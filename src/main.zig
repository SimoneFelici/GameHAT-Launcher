const std = @import("std");
const rl = @import("raylib");
const Context = @import("context.zig").Context;

const gamehat_mapping =
    "15000000010000000500000000010000,GPIO Controller 1," ++
    "a:b0,b:b1,x:b3,y:b4," ++
    "leftshoulder:b6,rightshoulder:b7," ++
    "back:b10,start:b11," ++
    "dpup:-a1,dpdown:+a1,dpleft:-a0,dpright:+a0," ++
    "platform:Linux,";

pub fn main(init: std.process.Init) anyerror!void {
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

    rl.setConfigFlags(.{ .fullscreen_mode = true, .window_resizable = true });
    rl.initWindow(0, 0, "Game-Hat Launcher");
    defer rl.closeWindow();

    rl.setTargetFPS(15);
    _ = rl.setGamepadMappings(gamehat_mapping);
    rl.hideCursor();
    // rl.enableEventWaiting();

    const screenWidth: f32 = @floatFromInt(rl.getScreenWidth());
    const screenHeight: f32 = @floatFromInt(rl.getScreenHeight());
    const font = try rl.getFontDefault();
    const font_size = @divTrunc(@min(screenWidth, screenHeight), config.text_scale);
    // var prev_y: f32 = 0;

    var start: usize = 0;
    var selected: usize = 0;

    while (!rl.windowShouldClose()) {
        // const axis_y = rl.getGamepadAxisMovement(0, .left_y);
        // const pad_down = axis_y == 1 and prev_y != 1;
        // const pad_up = axis_y == -1 and prev_y != -1;
        // prev_y = axis_y;

        if (ctx.games.items.len > 0) {
            if (rl.isKeyPressed(.enter) or rl.isGamepadButtonPressed(0, .right_face_down)) {
                ctx.launchGame(selected) catch |err| {
                    std.log.err("launch failed: {s}", .{@errorName(err)});
                };
            }
            if (rl.isKeyPressedRepeat(.down) or rl.isGamepadButtonDown(0, .left_face_down)) {
                selected = (selected + 1) % ctx.games.items.len;
            }
            if (rl.isKeyPressedRepeat(.up) or rl.isGamepadButtonDown(0, .left_face_up)) {
                selected = if (selected == 0) ctx.games.items.len - 1 else selected - 1;
            }

            if (selected < start) {
                start = selected;
            } else if (selected >= start + config.max_view) {
                start = selected - config.max_view + 1;
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
            const color = if (i == selected) config.hg_color else config.txt_color;
            rl.drawTextEx(font, game.name, pos, font_size, spacing, color);
        }
        rl.drawFPS(0, 0);
    }
}
