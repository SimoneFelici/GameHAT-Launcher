const std = @import("std");
const config = @import("config.zig");
const games = @import("games.zig");

pub const Context = struct {
    io: std.Io,
    gpa: std.mem.Allocator,
    environ: *const std.process.Environ.Map,
    contents_buf: [2048]u8 = undefined,
    config: config.Config = .{},

    pub fn loadConfig(self: *Context) void {
        config.load(self);
    }

    pub fn listGames(self: *Context) !void {
        try games.list(self);
    }
};
