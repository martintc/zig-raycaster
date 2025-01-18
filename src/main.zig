const std = @import("std");
const heap = std.heap;
const mem = std.mem;
const g = @import("game.zig");

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const game = try allocator.create(g.Game);
    defer allocator.destroy(game);

    game.* = g.Game.init();
    try game.*.setup();
    defer game.*.deinit();
    game.*.run();
}
