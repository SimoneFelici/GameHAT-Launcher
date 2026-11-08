const std = @import("std");
const rl = @import("raylib");
const known_folders = @import("known-folders");
const Context = @import("context.zig").Context;

pub const Config = struct {
    background_color: rl.Color = .{ .r = 0, .g = 30, .b = 39, .a = 255 },
    text_color: rl.Color = .{ .r = 156, .g = 194, .b = 195, .a = 255 },
    highlight_color: rl.Color = .{ .r = 245, .g = 75, .b = 0, .a = 255 },
    games_folder: []const u8 = "/usr/local/games",
    max_viewable_items: usize = 5,
    text_scale: f32 = 10,
    text_spacing: f32 = 5,
};

pub fn load(ctx: *Context) void {
    var buf: [2048]u8 = undefined;
    const source = readFile(ctx, &buf) catch |err| {
        std.log.err("Config error {s}", .{@errorName(err)});
        return;
    };

    var diag: std.zon.parse.Diagnostics = undefined;
    ctx.config = std.zon.parse.fromSlice(Config, .{
        .gpa = ctx.gpa,
        .arena = ctx.arena,
        .source = source,
        .diagnostics = &diag,
    }) catch |err| switch (err) {
        error.ParseZon => return diag.log("config.zon"),
        error.OutOfMemory => return std.log.err("Config error: out of memory", .{}),
    };
}

fn readFile(ctx: *Context, buf: []u8) ![:0]const u8 {
    const config_dir = try known_folders.getPath(ctx.io, ctx.gpa, ctx.environ, .local_configuration) orelse return error.NoConfigDir;
    defer ctx.gpa.free(config_dir);

    const path = try std.fs.path.join(ctx.gpa, &.{ config_dir, "GameHAT-Launcher", "config.zon" });
    defer ctx.gpa.free(path);

    const data = try std.Io.Dir.cwd().readFile(ctx.io, path, buf[0 .. buf.len - 1]);
    buf[data.len] = 0;
    return buf[0..data.len :0];
}
