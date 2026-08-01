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

fn normalEx(ctx: *Context, sel: usize) !void {
    const dir = try std.Io.Dir.openDirAbsolute(ctx.io, ctx.games.items[sel].path, .{ .iterate = true });
    defer dir.close(ctx.io);

    var walker = try dir.walk(ctx.gpa);
    defer walker.deinit();

    while (try walker.next(ctx.io)) |entry| {
        if (entry.kind != .file) continue;
        const stat = try dir.statFile(ctx.io, entry.basename, .{});

        const mode = stat.permissions.toMode();
        const is_executable = (mode & 0o111) != 0;

        // TODO: ONCE GETS MERGED USE spawnPath
        if (is_executable) {
            const exe_path = try std.fs.path.join(ctx.gpa, &.{ ctx.games.items[sel].path, entry.path });
            defer ctx.gpa.free(exe_path);

            std.log.info("Launching: {s}", .{exe_path});

            var proc = try std.process.spawn(ctx.io, .{
                .argv = &.{ "cage", "--", exe_path },
            });
            const term = try proc.wait(ctx.io);

            switch (term) {
                .exited => |code| std.log.info("Exited with code {d}", .{code}),
                else => std.log.warn("Terminated abnormally: {}", .{term}),
            }
            return;
        }
    }
}

pub fn launch(ctx: *Context, sel: usize) !void {
    const game_folder = ctx.games.items[sel].path;
    std.log.info("Launching game in directory: {s}", .{game_folder});

    const lopts_path = try std.fs.path.join(ctx.gpa, &.{ game_folder, ".launchopts" });
    defer ctx.gpa.free(lopts_path);

    var buf: [2048]u8 = undefined;
    const contents = std.Io.Dir.cwd().readFile(ctx.io, lopts_path, &buf) catch |err| switch (err) {
        error.FileNotFound => {
            std.log.info(".launchopts not found, defaulting to normal execution", .{});
            try normalEx(ctx, sel);
            return;
        },
        else => return err,
    };

    var argv: std.ArrayList([]const u8) = .empty;
    defer argv.deinit(ctx.gpa);
    try argv.append(ctx.gpa, "cage");
    try argv.append(ctx.gpa, "--");

    var env = try ctx.environ.clone(ctx.gpa);
    defer env.deinit();

    var lines = std.mem.splitScalar(u8, contents, '\n');
    while (lines.next()) |line| {
        if (line.len == 0 or line[0] == '#') continue;
        const eq = std.mem.indexOfScalar(u8, line, '=') orelse continue;
        const key = std.mem.trim(u8, line[0..eq], &std.ascii.whitespace);
        const value = std.mem.trim(u8, line[eq + 1 ..], &std.ascii.whitespace);

        if (std.mem.eql(u8, key, "cmd")) {
            var parts = std.mem.tokenizeScalar(u8, value, ' ');
            while (parts.next()) |part| try argv.append(ctx.gpa, part);
        } else if (std.mem.eql(u8, key, "env")) {
            const sep = std.mem.indexOfScalar(u8, value, '=') orelse continue;
            try env.put(
                std.mem.trim(u8, value[0..sep], &std.ascii.whitespace),
                std.mem.trim(u8, value[sep + 1 ..], &std.ascii.whitespace),
            );
        }
    }

    if (argv.items.len <= 2) {
        std.log.warn("no cmd in .launchopts", .{});
        return error.NoCmdFound;
    }

    var proc = try std.process.spawn(ctx.io, .{
        .argv = argv.items,
        .environ_map = &env,
    });
    const term = try proc.wait(ctx.io);
    std.log.info("Game closed: {}", .{term});
}
