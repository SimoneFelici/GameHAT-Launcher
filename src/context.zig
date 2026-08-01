const std = @import("std");
const config = @import("config.zig");
const games = @import("games.zig");

pub const Context = struct {
    io: std.Io,
    gpa: std.mem.Allocator,
    arena: std.mem.Allocator,
    environ: *const std.process.Environ.Map,
    config: config.Config = .{},
    games: std.ArrayList(games.Game) = .empty,

    pub fn loadConfig(self: *Context) void {
        config.load(self);
    }

    pub fn listGames(self: *Context) !void {
        try games.list(self);
    }

    pub fn launchGame(self: *Context, sel: usize) !void {
        try games.launch(self, sel);
    }
};
