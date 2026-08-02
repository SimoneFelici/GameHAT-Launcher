const std = @import("std");
const rl = @import("raylib");
const Context = @import("context.zig").Context;

const gamehat_mapping =
    "15000000010000000500000000010000,GPIO Controller 1," ++
    "a:b0,b:b1,x:b3,y:b4," ++
    "leftshoulder:b6,rightshoulder:b7," ++
    "back:b10,start:b11," ++
    "leftx:a0,lefty:a1," ++
    "platform:Linux,";

pub fn main(init: std.process.Init) anyerror!void {
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
    rl.initWindow(0, 0, "Game-Hat Launcher");
    defer rl.closeWindow();

    rl.hideCursor();
    rl.setTargetFPS(15);
    _ = rl.setGamepadMappings(gamehat_mapping);

    const screenWidth: f32 = @floatFromInt(rl.getScreenWidth());
    const screenHeight: f32 = @floatFromInt(rl.getScreenHeight());
    const font = try rl.getFontDefault();
    const font_size: f32 = @divTrunc(@min(screenWidth, screenHeight), config.text_scale);

    var prev_y: f32 = 0;
    var start: usize = 0;
    var selected: usize = 0;
    var scroll_count: f32 = 0.0;

    while (!rl.windowShouldClose()) {
        var axis_y = rl.getGamepadAxisMovement(0, .left_y);
        if (rl.isKeyDown(.down)) axis_y = 1;
        if (rl.isKeyDown(.up)) axis_y = -1;

        const pad_down = axis_y == 1 and prev_y != 1;
        const pad_up = axis_y == -1 and prev_y != -1;
        prev_y = axis_y;

        scroll_count += rl.getFrameTime();
        if (axis_y == 0) {
            scroll_count = 0;
        } else if (scroll_count > 0.2) {
            prev_y = 0;
            scroll_count = 0;
        }

        if (ctx.games.items.len > 0) {
            if (rl.isKeyPressed(.enter) or rl.isGamepadButtonPressed(0, .right_face_down)) {
                ctx.launchGame(selected) catch |err| {
                    std.log.err("launch failed: {s}", .{@errorName(err)});
                };
            }
            if (pad_down) {
                selected = (selected + 1) % ctx.games.items.len;
            }
            if (pad_up) {
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
            const size = rl.measureTextEx(font, game.name, font_size, config.text_spacing);
            const pos: rl.Vector2 = .{
                .x = (screenWidth - size.x) / 2,
                .y = @as(f32, @floatFromInt(i - start)) * (size.y + 5),
            };
            const color = if (i == selected) config.hg_color else config.txt_color;
            rl.drawTextEx(font, game.name, pos, font_size, config.text_spacing, color);
        }
    }
}
