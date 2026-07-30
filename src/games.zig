const std = @import("std");
const Context = @import("context.zig").Context;

pub fn list(ctx: *Context) !void {
    const dir = try std.Io.Dir.openDirAbsolute(ctx.io, ctx.config.games_dir, .{ .iterate = true });
    defer dir.close(ctx.io);

    var walker = try dir.walk(ctx.gpa);
    defer walker.deinit();

    while (try walker.next(ctx.io)) |entry| {
        if (entry.kind == .directory)
            std.debug.print("{s}\n", .{entry.basename});
    }
}
