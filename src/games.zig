const std = @import("std");
const Context = @import("context.zig").Context;

pub const Game = struct {
    name: [:0]const u8,
    path: [:0]const u8,
};

pub fn list(ctx: *Context) !void {
    const dir = try std.Io.Dir.openDirAbsolute(ctx.io, ctx.config.games_dir, .{ .iterate = true });
    defer dir.close(ctx.io);

    var it = dir.iterate();
    while (try it.next(ctx.io)) |entry| {
        if (entry.kind != .directory) continue;
        const path = try std.fs.path.joinZ(ctx.arena, &.{ ctx.config.games_dir, entry.name });
        const name = path[path.len - entry.name.len ..];
        try ctx.games.append(ctx.arena, .{ .name = name, .path = path });
    }
}
