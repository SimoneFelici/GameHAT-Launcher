const std = @import("std");
const Context = @import("context.zig").Context;

pub const Game = struct {
    name: [:0]const u8,
    path: [:0]const u8,
};

const LaunchOpts = struct {
    exec: []const u8,
    args: []const []const u8 = &.{},
    env: []const [2][]const u8 = &.{},
};

pub fn list(ctx: *Context) !void {
    ctx.games.clearRetainingCapacity();
    const dir = try std.Io.Dir.openDirAbsolute(ctx.io, ctx.config.games_folder, .{ .iterate = true });
    defer dir.close(ctx.io);

    var it = dir.iterate();
    while (try it.next(ctx.io)) |entry| {
        if (entry.kind != .directory) continue;
        const path = try std.fs.path.joinZ(ctx.arena, &.{ ctx.config.games_folder, entry.name });
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
        const stat = try dir.statFile(ctx.io, entry.path, .{});

        const mode = stat.permissions.toMode();
        const is_executable = (mode & 0o111) != 0;

        // TODO: ONCE GETS MERGED USE spawnPath
        if (is_executable) {
            const exe_path = try std.fs.path.join(ctx.gpa, &.{ ctx.games.items[sel].path, entry.path });
            defer ctx.gpa.free(exe_path);

            std.log.info("Launching: {s}", .{exe_path});

            var proc = try std.process.spawn(ctx.io, .{
                .argv = &.{ "cage", "--", exe_path },
                .cwd = .{ .path = ctx.games.items[sel].path },
            });
            const term = try proc.wait(ctx.io);

            switch (term) {
                .exited => |code| std.log.info("Exited with code {d}", .{code}),
                else => std.log.err("Terminated abnormally: {}", .{term}),
            }
            return;
        }
    }
}

pub fn launch(ctx: *Context, sel: usize) !void {
    const game_folder = ctx.games.items[sel].path;
    std.log.info("Launching game in directory: {s}", .{game_folder});

    const lopts_path = try std.fs.path.join(ctx.gpa, &.{ game_folder, ".launchopts.zon" });
    defer ctx.gpa.free(lopts_path);

    var buf: [2048]u8 = undefined;
    const data = std.Io.Dir.cwd().readFile(ctx.io, lopts_path, buf[0 .. buf.len - 1]) catch |err| switch (err) {
        error.FileNotFound => {
            std.log.info(".launchopts.zon not found, defaulting to normal execution", .{});
            return normalEx(ctx, sel);
        },
        else => return err,
    };
    buf[data.len] = 0;

    var arena_state: std.heap.ArenaAllocator = .init(ctx.gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var diag: std.zon.parse.Diagnostics = undefined;
    const opts = std.zon.parse.fromSlice(LaunchOpts, .{
        .gpa = ctx.gpa,
        .arena = arena,
        .source = buf[0..data.len :0],
        .diagnostics = &diag,
    }) catch |err| {
        if (err == error.ParseZon) diag.log(lopts_path);
        return err;
    };

    var argv: std.ArrayList([]const u8) = .empty;
    try argv.appendSlice(arena, &.{ "cage", "--", opts.exec });
    try argv.appendSlice(arena, opts.args);

    var env = try ctx.environ.clone(ctx.gpa);
    defer env.deinit();
    for (opts.env) |envs| try env.put(envs[0], envs[1]);

    var proc = try std.process.spawn(ctx.io, .{
        .argv = argv.items,
        .environ_map = &env,
        .cwd = .{ .path = game_folder },
    });
    const term = try proc.wait(ctx.io);
    std.log.info("Game closed: {}", .{term});
}
