const std = @import("std");
const rl = @import("raylib");
const known_folders = @import("known-folders");

const DEFAULT_BG = rl.Color{ .r = 0x00, .g = 0x2b, .b = 0x36, .a = 255 };
const DEFAULT_TXT = rl.Color{ .r = 0x83, .g = 0x94, .b = 0x96, .a = 255 };
const DEFAULT_HG = rl.Color{ .r = 0xcb, .g = 0x4b, .b = 0x16, .a = 255 };

pub const Config = struct {
    bg_color: rl.Color,
    txt_color: rl.Color,
    hg_color: rl.Color,
    // games_dir: []u8,

    pub fn default() Config {
        return .{
            .bg_color = DEFAULT_BG,
            .txt_color = DEFAULT_TXT,
            .hg_color = DEFAULT_HG,
        };
    }

    pub fn init(io: std.Io, gpa: std.mem.Allocator, environ: *const std.process.Environ.Map) Config {
        return loadFromFile(io, gpa, environ) catch |err| {
            std.debug.print("Config error {s}\n", .{@errorName(err)});
            return Config.default();
        };
    }

    fn loadFromFile(io: std.Io, gpa: std.mem.Allocator, environ: *const std.process.Environ.Map) !Config {
        const config_dir = try known_folders.getPath(io, gpa, environ, .roaming_configuration) orelse
            return error.NoConfigDir;
        defer gpa.free(config_dir);

        const path = try std.fs.path.join(gpa, &.{ config_dir, "GameHat-Launcher", "config.txt" });
        defer gpa.free(path);

        var buf: [10240]u8 = undefined;
        const contents = try std.Io.Dir.cwd().readFile(io, path, &buf);

        return parseConfig(contents);
    }
};

fn parseConfig(contents: []const u8) Config {
    const Key = enum { bg_color, txt_color, hg_color };
    const key_map = std.StaticStringMap(Key).initComptime(.{
        .{ "background", .bg_color },
        .{ "text", .txt_color },
        .{ "highlight", .hg_color },
    });

    var config = Config.default();

    var lines = std.mem.splitScalar(u8, contents, '\n');
    while (lines.next()) |line| {
        if (line.len == 0 or line[0] == '#') continue;
        const eq = std.mem.indexOfScalar(u8, line, '=') orelse continue;
        const key = std.mem.trim(u8, line[0..eq], &std.ascii.whitespace);
        const value = std.mem.trim(u8, line[eq + 1 ..], &std.ascii.whitespace);

        const k = key_map.get(key) orelse continue;
        switch (k) {
            .bg_color => config.bg_color = parseHexColor(value, DEFAULT_BG),
            .txt_color => config.txt_color = parseHexColor(value, DEFAULT_TXT),
            .hg_color => config.hg_color = parseHexColor(value, DEFAULT_HG),
        }
    }

    return config;
}

fn parseHexColor(hex: []const u8, default: rl.Color) rl.Color {
    if (hex.len != 7 or hex[0] != '#') {
        std.debug.print("Invalid hex code: '{s}'\n", .{hex});
        return default;
    }
    const red = std.fmt.parseInt(u8, hex[1..3], 16) catch return default;
    const green = std.fmt.parseInt(u8, hex[3..5], 16) catch return default;
    const blue = std.fmt.parseInt(u8, hex[5..7], 16) catch return default;
    return .{ .r = red, .g = green, .b = blue, .a = 255 };
}
