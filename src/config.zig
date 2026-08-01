const std = @import("std");
const rl = @import("raylib");
const known_folders = @import("known-folders");
const Context = @import("context.zig").Context;

const DEFAULT_BG = rl.Color{ .r = 0x00, .g = 0x2b, .b = 0x36, .a = 255 };
const DEFAULT_TXT = rl.Color{ .r = 0x83, .g = 0x94, .b = 0x96, .a = 255 };
const DEFAULT_HG = rl.Color{ .r = 0xcb, .g = 0x4b, .b = 0x16, .a = 255 };
const DEFAULT_GD = "/usr/local/games";
const DEFAULT_MX = 5;
const DEFAULT_SCALE = 10;
const DEFAULT_SPACE = 5;

pub const Config = struct {
    bg_color: rl.Color = DEFAULT_BG,
    txt_color: rl.Color = DEFAULT_TXT,
    hg_color: rl.Color = DEFAULT_HG,
    games_dir: []const u8 = DEFAULT_GD,
    max_view: usize = DEFAULT_MX,
    text_scale: f32 = DEFAULT_SCALE,
    text_spacing: f32 = DEFAULT_SPACE,
};

pub fn load(ctx: *Context) void {
    var contents_buf: [2048]u8 = undefined;
    const contents = readFile(ctx, &contents_buf) catch |err| {
        std.log.err("Config error {s}\n", .{@errorName(err)});
        return;
    };
    parse(ctx, contents);
}

fn readFile(ctx: *Context, buf: []u8) ![]u8 {
    const config_dir = try known_folders.getPath(ctx.io, ctx.gpa, ctx.environ, .roaming_configuration) orelse
        return error.NoConfigDir;
    defer ctx.gpa.free(config_dir);

    const path = try std.fs.path.join(ctx.gpa, &.{ config_dir, "GameHAT-Launcher", "config.txt" });
    defer ctx.gpa.free(path);

    return std.Io.Dir.cwd().readFile(ctx.io, path, buf);
}

fn parse(ctx: *Context, contents: []const u8) void {
    const Key = enum { bg_color, txt_color, hg_color, games_dir, max_view, text_scale, text_spacing };

    // Config fields
    const key_map = std.StaticStringMap(Key).initComptime(.{
        .{ "background_color", .bg_color },
        .{ "text_color", .txt_color },
        .{ "highlight_color", .hg_color },
        .{ "games_directory", .games_dir },
        .{ "max_viewable_items", .max_view },
        .{ "text_scale", .text_scale },
        .{ "text_spacing", .text_spacing },
    });

    var lines = std.mem.splitScalar(u8, contents, '\n');
    while (lines.next()) |line| {
        if (line.len == 0 or line[0] == '#') continue;
        const eq = std.mem.indexOfScalar(u8, line, '=') orelse continue;
        const key = std.mem.trim(u8, line[0..eq], &std.ascii.whitespace);
        const value = std.mem.trim(u8, line[eq + 1 ..], &std.ascii.whitespace);

        const k = key_map.get(key) orelse continue;
        switch (k) {
            .bg_color => ctx.config.bg_color = parseHexColor(value, DEFAULT_BG),
            .txt_color => ctx.config.txt_color = parseHexColor(value, DEFAULT_TXT),
            .hg_color => ctx.config.hg_color = parseHexColor(value, DEFAULT_HG),
            .games_dir => setGamesDir(&ctx.config.games_dir, ctx.io, value),
            .max_view => ctx.config.max_view = parseMaxView(value),
            .text_scale => ctx.config.text_scale = parseTextScale(value),
            .text_spacing => ctx.config.text_spacing = parseTextSpace(value),
        }
    }
}

fn setGamesDir(games_dir: *[]const u8, io: std.Io, dir: []const u8) void {
    std.Io.Dir.accessAbsolute(io, dir, .{ .read = true, .execute = true }) catch {
        std.log.err("Games directory not accessible: '{s}'\n", .{dir});
        return;
    };
    games_dir.* = dir;
}

// TODO: Maybe add RGB support
fn parseHexColor(hex: []const u8, default: rl.Color) rl.Color {
    if (hex.len != 7 or hex[0] != '#') {
        std.log.err("Invalid hex code: '{s}'\n", .{hex});
        return default;
    }
    const red = std.fmt.parseInt(u8, hex[1..3], 16) catch return default;
    const green = std.fmt.parseInt(u8, hex[3..5], 16) catch return default;
    const blue = std.fmt.parseInt(u8, hex[5..7], 16) catch return default;
    return .{ .r = red, .g = green, .b = blue, .a = 255 };
}

fn parseMaxView(num: []const u8) usize {
    const int = std.fmt.parseInt(usize, num, 10) catch return DEFAULT_MX;
    return if (int > 0) int else DEFAULT_MX;
}

fn parseTextScale(num: []const u8) f32 {
    const val = std.fmt.parseFloat(f32, num) catch return DEFAULT_SCALE;
    return if (val > 0) val else DEFAULT_SCALE;
}

fn parseTextSpace(num: []const u8) f32 {
    const val = std.fmt.parseFloat(f32, num) catch return DEFAULT_SPACE;
    return if (val > 0) val else DEFAULT_SPACE;
}
